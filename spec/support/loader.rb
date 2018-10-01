# frozen_string_literal: true

require 'piktur/core'
require 'piktur/spec/helpers/loader'

RSpec.shared_context 'loader' do
  require_relative File.expand_path('./config/piktur.rb', ENGINE_ROOT)

  include Piktur::Spec::Helpers::Loader

  before(:all) { Test.safe_const_set(:Config, Piktur::Config.dup) }
  after(:all) { Test.safe_remove_const(:Config) }

  let(:root)            { Pathname.pwd }
  let(:target)          { Pathname('app/concepts') }
  let(:components_dir)  { Pathname(target) }
  let(:qualified_components_dir) { root / components_dir }
  let(:component_types) { Piktur.config.component_types }
  let(:namespace)       { 'users' }
  let(:path)            { qualified_components_dir.join('users/model.rb') }
  let(:type)            { :models }
  let(:value)           { EMPTY_ARRAY }
  let(:models)          { EMPTY_ARRAY }
  let(:policies)        { EMPTY_ARRAY }
  let(:repositories)    { EMPTY_ARRAY }
  let(:transactions)    { EMPTY_ARRAY }
  let(:relative_path)   { Pathname('users') }
  let(:absolute_path)   { components_dir / relative_path }
end
