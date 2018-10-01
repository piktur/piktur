# frozen_string_literal: true

require 'spec_helper'
require 'piktur/loader/pathname'

RSpec.describe Piktur::Loader::Pathname do
  let(:root) { Pathname('app/concepts') }
  let(:relative_path) { Pathname('users') }
  let(:absolute_path) { root / relative_path }

  describe '.right_of(path, other)' do
    it 'should return everything right of other' do
      actual   = described_class.right_of(absolute_path, root)
      expected = relative_path.to_s

      expect(actual).to eq(expected)
    end
  end

  describe '.left_of(path, other)' do
    it 'should return everything left of other' do
      actual   = described_class.left_of(absolute_path, relative_path)
      expected = root.to_s

      expect(actual).to eq(expected)
    end
  end
end
