# frozen_string_literal: true

require 'spec_helper'

RSpec.require_support 'container', app: 'piktur'

RSpec.describe Piktur::Support::Types do
  include_context 'container'
  it_should_behave_like 'a container'

  subject { described_class.container }

  around do |example|
    types(replace: true) do |container|
      example.run
    end
  end
end
