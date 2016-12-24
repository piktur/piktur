require 'rails_helper'
Piktur::Support.require_shared_examples 'support/autoload'

RSpec.describe Piktur::Support::Autoload do
  include_examples 'Piktur::Support::Autoload'
end

