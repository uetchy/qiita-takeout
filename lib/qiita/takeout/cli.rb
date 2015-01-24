require 'thor'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'fileutils'

require 'pp'

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
    images_dest_path = File.join(dest_path, "images")

    FileUtils.mkdir_p(dest_path) unless File.exist?(dest_path)

    open(File.join(dest_path, "articles.json"), "w") do |f|
      f.write data.to_json
    end

    data.each do |article|
      id = article['id'].to_s
      body = Nokogiri::HTML.parse(article['body'])
      img_arr = body.css("img[src^='https://qiita-image-store.s3.amazonaws.com']")
      img_arr.each do |img|
        url = img.attr('src')
        output = img.attr('alt')
        output_path = File.join(images_dest_path, id, output)
        FileUtils.mkdir_p(File.dirname(output_path)) unless File.exist?(File.dirname(output_path))
        open(output_path, 'wb') do |f|
          f.write open(url, 'rb').read
        end
      end
    end

    puts "Dumped => #{dest_path}"
  end

  desc "version", "Show version"
  def version
    puts "qiita-takeout version #{Qiita::Takeout::VERSION}"
  end
end
