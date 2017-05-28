require 'rspec/core'

spec_helper = Dir[File.join(Gem.loaded_specs['rspec-core'].gem_dir, '**/spec_helper.rb')][0]
require_relative spec_helper

RSpec.configure do |config|
  config.default_formatter = 'doc' if config.files_to_run.one?
end

require 'pry'
