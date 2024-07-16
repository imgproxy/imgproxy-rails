# frozen_string_literal: true

require "spec_helper"

require "combustion"
begin
  Combustion.initialize!(:active_storage, :active_record) do
    config.logger = Logger.new(nil)
    config.log_level = :fatal
  end
rescue => e
  $stdout.puts "Failed to load the app: #{e.message}\n#{e.backtrace.take(5).join("\n")}"
  exit(1)
end

require "rspec/rails"
require "imgproxy-rails"

class User < ActiveRecord::Base
  has_one_attached :avatar
end

Rails.application.routes.default_url_options[:host] = "http://example.com"
Imgproxy.configure { |config| config.endpoint = "http://imgproxy.io" }

# Run activestorage migrations
active_storage_migrate_dir = File.join(
  Gem.loaded_specs["activestorage"].full_gem_path,
  "db", "migrate"
)

Dir.children(active_storage_migrate_dir).each do
  require File.join(active_storage_migrate_dir, _1)
end

CreateActiveStorageTables.new.migrate(:up)

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
