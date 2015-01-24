require "qiita/takeout/version"
require "qiita/takeout/connector"

module Qiita
  module Takeout
    OUTPUT_PATH = 'qiita-takeout-%{timestamp}'
  end
end

require "qiita/takeout/cli"
