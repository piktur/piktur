require 'rails_helper'
RSpec.require_shared_examples 'piktur/security'

RSpec.describe Piktur::Security::Authorization do
  subject { Piktur::Security::Authorization }

  describe '::ROLES' do
    it { expect(subject::ROLES).to be_a(Array) }
  end

  include_examples 'Authorization' do
    let(:described_class) do
      Class.new { extend Piktur::Security::Authorization }
    end
  end
end
