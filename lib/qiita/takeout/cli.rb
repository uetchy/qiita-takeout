require 'thor'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'fileutils'

class Qiita::Takeout::CLI < Thor
  desc "dump NAME PASSWORD", "Dump your articles on Qiita."
  def dump(name, password)
    auth = Qiita::Takeout::Connector.auth name, password
    unless auth
      puts "Error: invalid credentials. Please confirm your inputs are correct."
      exit
    end
    data = Qiita::Takeout::Connector.get(:items, :token => auth['token'])

    dest_path = File.join(Qiita::Takeout::OUTPUT_PATH % {:timestamp => Time.now.strftime("%Y%m%d")})
    articles_dest_path = File.join(dest_path, "articles")

    FileUtils.mkdir_p(dest_path) unless File.exist?(dest_path)
    FileUtils.mkdir_p(articles_dest_path) unless File.exist?(articles_dest_path)

    open(File.join(dest_path, "articles.json"), "w") do |f|
      f.write data.to_json
    end

    data.each do |article|
      id = article['id'].to_s
      title = article['title']
      created_at = Time.parse(article['created_at'])

      output_path = File.join(articles_dest_path, id)
      FileUtils.mkdir_p(output_path) unless File.exist?(output_path)

      # Fetch images
      img_arr = Nokogiri::HTML.parse(article['body']).css("img[src^='https://qiita-image-store.s3.amazonaws.com']")
      img_arr.each do |img|
        url = img.attr('src')
        output = img.attr('alt')
        open(File.join(output_path, output), 'wb') do |f|
          f.write open(url, 'rb').read
        end
      end

      # Markdown
      markdown = article['raw_body']
      markdown_filename = "%{timestamp}-%{title}.md" % {:timestamp => created_at.strftime("%Y-%m-%d"), :title => title.gsub(/[\\\/\:\*\?"<>\|]/, "")}
      open(File.join(output_path, markdown_filename), 'w') do |f|
        f.write markdown
      end
    end

    puts "Dumped => #{dest_path}"
  end

  desc "version", "Show version"
  def version
    puts "qiita-takeout version #{Qiita::Takeout::VERSION}"
  end
end
