# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require 'fileutils'

RSpec.require_support 'loader', app: 'piktur'

RSpec.describe Piktur::Loader::ActiveSupport do
  include_context 'loader'

  let(:config) do
    OpenStruct.new(
      namespaces: namespaces,
      component_types: [component].map { |component| Inflector.pluralize(component).to_sym },
      loader: nil,
      nouns: :pluralize
    )
  end
  let(:root) { Pathname(SPEC_ROOT).join('fixtures') }
  let(:target) { Pathname('app/concepts') }
  let(:component_types) { NAMESPACE.config.component_types }
  let(:namespace) { 'users' }
  let(:type) { Inflector.pluralize(component).to_sym }
  let(:namespaces) { [namespace, 'others'] }
  let(:unloadable) { ActiveSupport::Dependencies.explicitly_unloadable_constants }
  let(:extension) { '.rb' }
  let(:file_name) { component + extension }
  let(:component) { 'component' }
  let(:file_list) do
    {
      '.' => namespaces.map { |namespace| "#{namespace}#{extension}" },
      namespace => [file_name],
      "#{namespace}/#{component_types.sample}" => [file_name],
      'others/namespace' => [file_name]
    }
  end

  subject do
    described_class.new.tap do |loader|
      loader.types = component_types
      loader.target = Pathname(target)
    end
  end

  before do
    services = OpenStruct.new(railties: [OpenStruct.new(root: root)])

    namespace = Piktur.dup
    namespace.extend Piktur::Loader::Ext
    def namespace.component_types; config.component_types; end
    def namespace.namespaces; config.namespaces; end

    stub_const('NAMESPACE', namespace)

    allow(NAMESPACE).to receive(:config).and_return(config)
    allow(NAMESPACE).to receive(:services).and_return(services)
    allow(NAMESPACE).to receive(:debug).with(any_args).and_return(true)
    allow(Object).to receive(:require_dependency).and_return(true)
    allow(subject.class).to receive(:cache).and_return(Concurrent::Map.new)

    config.loader = OpenStruct.new(
      instance: subject,
      debug: false
    )

    file_list.each do |dir, files|
      FileUtils.mkdir_p(dir = root.join(target, dir))

      files.each do |file|
        path = dir.join(file)
        File.exist?(path) || FileUtils.touch(path)
      end
    end

    Dir.chdir(root)

    subject.instance_exec do
      @booted = false
      @loaded = Set.new
    end
  end

  after(:all) { Dir.chdir(File.expand_path('..', SPEC_ROOT)) }

  describe '#call' do
    context 'when no :path or type specified' do
      before do
        subject.call
      end

      it 'should load all namespaces listed in NAMESPACE.namespaces' do
        expect(subject.loaded).to contain_exactly(*namespaces)
      end
    end

    context 'when :path given' do
      let(:result) { subject.call(path: namespace) }

      it 'should load the given :path and depedencies' do
        expect(result).to all(start_with(namespace))
      end
    end

    context 'when :type given' do
      let(:result) { subject.call(type: component.to_sym) }

      it 'should load only the files matching the given type' do
        expect(result).to all(include(component))
      end
    end

    context 'when :pattern given' do
      let(:base) { File.join(namespace, component_types.sample.to_s) }
      let(:pattern) { File.join(base, "{#{component}}.rb") }
      let(:result) { subject.call(path: namespace, pattern: pattern) }

      it 'should load files matching the pattern' do
        expect(result).to include(File.join(base, file_name))
      end
    end

    context 'when :scope given' do
      let(:result) { subject.call(type: component, scope: namespace) }

      it 'should load files in directory scope matching type' do
        expect(result).to all(match(/#{namespace}\/#{component}.?/))
      end
    end

    context 'when :force false' do
      before do
        subject.instance_exec(namespace) do |namespace|
          @booted = true
          @loaded << namespace
        end
      end

      context 'and path already loaded' do
        it 'should not load the path(s)' do
          expect(subject).not_to receive(:load)
          subject.call(path: namespace, force: false)
        end
      end
    end

    context 'when :force true' do
      context 'and booted?' do
        it 'should load the path(s)' do
          expect(subject).to receive(:load).and_return(an_instance_of(Array))

          subject.call(path: namespace, force: true)
        end
      end
    end
  end

  describe '#to_constant_path(path, namespace:, suffix:)' do
    it 'should return the segment of a file path corresponding to the constant it defines' do
      ["#{target}/#{namespace}/#{file_name}", "#{namespace}/#{file_name}"].each do |path|
        actual = subject.to_constant_path(String.new(path))

        expect(actual).to eq File.join(namespace, component)
      end
    end

    context 'when namespace given' do
      it 'should return namespace' do
        actual = subject.to_constant_path(String.new(File.join(namespace, file_name)), namespace: true)

        expect(actual).to eq namespace
      end
    end

    context 'when suffix given' do
      it 'should remove the suffix' do
        actual = subject.to_constant_path(String.new(File.join(namespace, file_name)), suffix: /\.rb$/)

        expect(actual).to eq File.join(namespace, component)
      end
    end
  end

  describe '#booted!' do
    it 'should be booted after the first call' do
      expect { subject.call }.to change { subject.booted? }
    end
  end

  describe '#config' do
    it { expect(subject.config).to respond_to(:debug) }
  end

  describe '#root_directories' do
    it { expect(subject.send(:root_directories)).to all(exist) }
  end

  describe '#matchers' do
    it { expect(subject.send(:matchers)).to be_a(Hash) }
  end

  describe '#patterns' do
    it { expect(subject.send(:patterns)).to be_a(Hash) }
  end

  describe '#pattern_combination(*types)' do
    it 'should return patterns for given types' do
      expect(subject.send(:pattern_combination, component_types.sample)).to \
        all(be_a(String))
    end
  end

  if ENV['DEBUG']
    describe '#by_type(type)' do
      it 'should return all files matching type' do
        type = subject.send(:by_type, component.to_sym)

        expect(type).to all(include(component).and(end_with(extension)))
      end

      context 'when given type invalid' do
        it 'should return an empty Array' do
          result = subject.send(:by_type, :non)

          expect(result).to be_empty
        end
      end
    end

    describe '#by_path(path)' do
      it 'should return a list of files within the given directory' do
        actual = subject.send(:by_path, path)

        expect(actual).to be_blank.or(all(end_with(extension)))
      end
    end

    describe '#fetch_or_store(key)' do
      context 'when the given key exists' do
        before { subject.fetch_or_store('test') { value } }

        it 'should return the cached value' do
          actual = subject.fetch_or_store('test')

          expect(actual).to be(value)
        end
      end
    end
  end
end
