# frozen_string_literal: true

require_relative "lib/imgproxy-rails/version"

Gem::Specification.new do |s|
  s.name = "imgproxy-rails"
  s.version = ImgproxyRails::VERSION
  s.authors = ["Vladimir Dementyev", "Albert Pazderin"]
  s.email = ["dementiev.vm@gmail.com", "afaceisnomore@gmail.com"]
  s.homepage = "http://github.com/imgproxy/imgproxy-rails"
  s.summary = "integration of imgproxy.rb with ActiveStorage::Variant API"
  s.description = "A gem that integrates imgproxy.rb with ActiveStorage::Variant API"

  s.metadata = {
    "bug_tracker_uri" => "http://github.com/imgproxy/imgproxy-rails/issues",
    "changelog_uri" => "https://github.com/imgproxy/imgproxy-rails/blob/master/CHANGELOG.md",
    "documentation_uri" => "http://github.com/imgproxy/imgproxy-rails",
    "homepage_uri" => "http://github.com/imgproxy/imgproxy-rails",
    "source_code_uri" => "http://github.com/imgproxy/imgproxy-rails"
  }

  s.license = "MIT"

  s.files = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + Dir.glob("config/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.7"

  s.add_dependency "imgproxy"
  s.add_dependency "activestorage", ">= 6.0"

  s.add_development_dependency "bundler", ">= 1.15"
  s.add_development_dependency "combustion", ">= 1.1"
  s.add_development_dependency "rake", ">= 13.0"
  s.add_development_dependency "rspec", ">= 3.9"
  s.add_development_dependency "rspec-rails", ">= 4.0"
  s.add_development_dependency "rails", "~> 8.0.0"
  s.add_development_dependency "image_processing", "~> 1.2"
end
