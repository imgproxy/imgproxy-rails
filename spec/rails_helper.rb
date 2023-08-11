# frozen_string_literal: true

require "spec_helper"

require "bundler/setup"
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

require "imgproxy-rails"
require "database_cleaner/active_record"

class User < ActiveRecord::Base
  has_one_attached :avatar
end

Rails.application.routes.default_url_options[:host] = "http://example.com"
Imgproxy.configure { |config| config.endpoint = "http://imgproxy.io" }

# Run activestorage migrations
active_storage_path = Gem::Specification.find_by_name("activestorage").gem_dir
ActiveRecord::MigrationContext.new(
  File.join(active_storage_path, "db/migrate"),
  ActiveRecord::SchemaMigration
).migrate

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
