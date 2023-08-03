# frozen_string_literal: true

require_relative "lib/imgproxy/rails/version"

Gem::Specification.new do |s|
  s.name = "imgproxy-rails"
  s.version = Imgproxy::Rails::VERSION
  s.authors = ["Vladimir Dementyev"]
  s.email = ["dementiev.vm@gmail.com"]
  s.homepage = "http://github.com/palkan/imgproxy-rails"
  s.summary = "TODO"
  s.description = "TODO"

  s.metadata = {
    "bug_tracker_uri" => "http://github.com/palkan/imgproxy-rails/issues",
    "changelog_uri" => "https://github.com/palkan/imgproxy-rails/blob/master/CHANGELOG.md",
    "documentation_uri" => "http://github.com/palkan/imgproxy-rails",
    "homepage_uri" => "http://github.com/palkan/imgproxy-rails",
    "source_code_uri" => "http://github.com/palkan/imgproxy-rails"
  }

  s.license = "MIT"

  s.files = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.7"

  s.add_development_dependency "bundler", ">= 1.15"
  s.add_development_dependency "combustion", ">= 1.1"
  s.add_development_dependency "rake", ">= 13.0"
  s.add_development_dependency "rspec", ">= 3.9"

end
