# frozen_string_literal: true

require 'spec_helper'
require 'piktur/spec/helpers/files'
require 'piktur/services/file_index'

RSpec.describe Piktur::Services::FileIndex do
  include Piktur::Spec::Helpers::Files

  subject { build_file_index(build_service('piktur_core', namespace: 'Piktur')) }

  describe '#root_directories' do
    it 'should return a list of paths' do
      expect(subject.root_directories).to all(be_a(Pathname))
    end
  end

  describe '#files' do
    it 'should return a list of files' do
      expect(subject.files).to respond_to(:to_a)
    end
  end
end
