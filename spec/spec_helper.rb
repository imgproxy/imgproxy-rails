# frozen_string_literal: true

begin
  require "debug" unless ENV["CI"]
rescue LoadError
end

ENV["RAILS_ENV"] = "test"

RSpec.configure do |config|
  config.mock_with :rspec

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed
end
