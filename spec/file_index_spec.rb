# frozen_string_literal: true

require 'spec_helper'
require 'piktur/spec/helpers/files'
require 'piktur/services/file_index'

RSpec.describe Piktur::Services::FileIndex do
  include Piktur::Spec::Helpers::Files

  # before do
  #   # build_file_index(services)
  #   @file_index ||= double(Piktur::Services::FileIndex)
  #   allow(@file_index).to receive(:all).and_return([])
  #   allow(@file_index).to receive(:to_a).and_return([])
  #
  #   # build_service('piktur_core', namespace: 'Piktur')
  #   @services ||= double(Piktur::Services::Index)
  #   allow(@services).to receive(:files).and_return(@file_index)
  # end

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
