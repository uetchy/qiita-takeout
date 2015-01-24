# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qiita/takeout/version'

Gem::Specification.new do |spec|
  spec.name          = "qiita-takeout"
  spec.version       = Qiita::Takeout::VERSION
  spec.authors       = ["Yasuaki Uechi"]
  spec.email         = ["uetchy@randompaper.co"]
  spec.summary       = %q{Dump your articles on Qiita.}
  spec.description   = %q{Dump your articles on Qiita.}
  spec.homepage      = "https://github.com/uetchy/qiita-takeout"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry-byebug"
  spec.add_runtime_dependency "thor"
  spec.add_dependency "nokogiri"
end
