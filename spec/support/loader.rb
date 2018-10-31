# frozen_string_literal: true

begin
  require 'piktur/core'
rescue LoadError
  nil
end

require 'piktur/spec/helpers/loader'

RSpec.shared_context 'loader' do
  begin
    require_relative File.expand_path('./config/piktur.rb', ENGINE_ROOT)
  rescue LoadError
    nil
  end

  include Piktur::Spec::Helpers::Loader

  before(:all) { Test.safe_const_set(:Config, NAMESPACE::Config.dup) }
  after(:all) { Test.safe_remove_const(:Config) }

  let(:root)            { Pathname.pwd }
  let(:target)          { Pathname('app/concepts') }
  let(:components_dir)  { Pathname(target) }
  let(:qualified_components_dir) { root / components_dir }
  let(:component_types) { NAMESPACE.config.component_types }
  let(:namespace)       { 'users' }
  let(:path)            { qualified_components_dir.join(namespace, component_types.sample.to_s, '.rb') }
  let(:type)            { component_types.sample }
  let(:value)           { EMPTY_ARRAY }
  let(:models)          { EMPTY_ARRAY }
  let(:policies)        { EMPTY_ARRAY }
  let(:repositories)    { EMPTY_ARRAY }
  let(:transactions)    { EMPTY_ARRAY }
  let(:relative_path)   { Pathname(namespace) }
  let(:absolute_path)   { components_dir / relative_path }
end
