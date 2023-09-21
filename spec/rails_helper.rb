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

# Custom previewer for PDFs to avoid requiring os libs
# Based on: https://github.com/PacktPublishing/Layered-Design-for-Ruby-on-Rails-Applications/blob/main/Chapter03/06-active-storage-dummy-previewer.rb
class DummyPDFPreviewer < ActiveStorage::Previewer
  def self.accept?(blob)
    blob.content_type == "application/pdf"
  end

  def preview(**options)
    output = File.open(File.join(__dir__, "avatar.png"))
    yield io: output, filename: "#{blob.filename.base}.png", content_type: "image/png", metadata: {"dummy" => true}, **options
  end
end

ActiveStorage.previewers << DummyPDFPreviewer

# Run activestorage migrations
active_storage_path = Gem::Specification.find_by_name("activestorage").gem_dir
ActiveRecord::MigrationContext.new(
  File.join(active_storage_path, "db/migrate"),
  ActiveRecord::SchemaMigration
).migrate

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
