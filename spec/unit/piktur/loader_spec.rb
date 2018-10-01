# frozen_string_literal: true

require 'spec_helper'

RSpec.require_support 'files_configuration'

RSpec.describe Piktur::Loader::ActiveSupport do
  include_context 'loader'

  def mimic_load(&block)
    allow(subject).to receive(:load).with(any_args, &block)
  end

  subject do
    described_class.new.tap do |loader|
      loader.types  = component_types
      loader.target = target
    end
  end

  before do
    subject.instance_exec do
      @booted = false
      @loaded = Set.new
    end

    mimic_load.and_call_original
    allow(Object).to receive(:require_dependency).and_return(true)
  end

  let(:component_types) { Piktur.config.component_types }
  let(:namespace)  { 'users' }
  let(:type)       { :models }
  let(:namespaces) { %w(users catalogues/items test/in_progress) }
  let(:unloadable) { ActiveSupport::Dependencies.explicitly_unloadable_constants }

  # * In NON-PRODUCTION ENVIRONMENTS load aspects of the code base in isolation
  # * In PRODUCTION eager load, yet have the ability to retrieve a list of files matching some
  #   condition
  # Given the above, the loader:
  # * IS NOT required to scan to maximum depth and/or preload
  # * IS NOT required to cache the *result* of a search, only the function that would allow the
  #   operation to be repeated the operation
  context 'when a namespace is a registered' do
    it 'should utilise the loader to list or load its components'

    context 'and component type given' do
      it 'should return a list of files matching component type'
    end

    context 'and path given' do
      it 'should return files within path'

      describe 'the list of files' do
        it 'should match current directory state'
        it 'can be sorted'
      end

      context 'if pattern given' do
        it 'should filter files by pattern'
      end
    end
  end

  context 'when a watched file is modified, added or deleted' do
    before(:all) do
      Test.safe_const_set(:InProgress, Module.new)

      require_relative Pathname.pwd.join('../piktur_spec/config/application.rb')
      require 'piktur/setup/boot'

      @app = Piktur::Spec::Application.new
    end

    after(:all) { Test.safe_remove_const(:InProgress) }

    let(:reloader) { @app.reloader }

    before do
      allow(Piktur).to receive(:namespaces).and_return(namespaces)
      allow(Piktur.loader).to receive(:loaded).and_return(namespaces)
      allow(Piktur).to receive(:before_class_unload).and_call_original

      allow(reloader).to receive(:before_class_unload) do
        Piktur.before_class_unload
      end

      allow(reloader).to receive(:reload!) do
        reloader.before_class_unload
        ActiveSupport::Dependencies.clear
      end
    end

    context 'and the application is reloaded' do
      describe 'loaded constant(s)' do
        it(<<~TODO) do
          should be unloaded

          {Piktur::Reloader} SHOULD be redundant given
            * `Rails.application.reloader` clears auto loaded constants on `.reload!`
            * #target is an autoloadable directory
          So the file should be re-evaluated after `reload!`.

          If the above hypothesis valid, then remove Loader::Load#reload!
        TODO
          expect { reloader.reload! }.to \
            change { unloadable }.and \
              change { Test.constants }

          expect(Test.const_defined?(:InProgress)).to be(false)
        end
      end
    end
  end

  describe '#call' do
    context 'when no :path or type specified' do
      before do
        allow(Piktur).to receive(:namespaces).and_return([namespace, 'profiles'])
        subject.call
      end

      it 'should load all namespaces listed in Piktur.namespaces' do
        expect(subject.loaded).to contain_exactly('users', 'profiles')
      end
    end

    context 'when :path given' do
      it 'should load the given :path and depedencies' do
        mimic_load do |id, paths, **options|
          expect(paths).to all(start_with(namespace))
        end

        subject.call(path: 'users')
      end
    end

    context 'when type given' do
      it 'should load only the files matching the given type' do
        mimic_load do |id, paths, **options|
          expect(paths).to all(include('model'))
        end

        subject.call(type: :models)
      end
    end

    context 'when pattern given' do
      it 'should load files matching the pattern' do
        mimic_load do |id, paths, **options|
          expect(paths).to include('users/transactions/subscribe.rb')
        end

        subject.call(path: 'users', pattern: 'users/transactions/{subscribe}.rb')
      end
    end

    context 'when scope given' do
      it 'should load files in directory scope matching type' do
        mimic_load do |id, paths, **options|
          expect(paths).to all(match(/users\/transactions.?/))
        end

        subject.call(type: :transactions, scope: 'users')
      end
    end

    context 'when :force false' do
      before do
        subject.instance_exec do
          @booted = true
          @loaded << 'users'
        end
      end

      context 'and path already loaded' do
        it 'should not load the path(s)' do
          expect(subject).not_to receive(:load)
          subject.call(path: 'users', force: false)
        end
      end
    end

    context 'when :force true' do
      context 'and booted?' do
        it 'should load the path(s)' do
          expect(subject).to receive(:load).and_return(an_instance_of(Array))
          subject.call(path: 'users', force: true)
        end
      end
    end
  end

  describe '#index!' do
    it 'is inneficient and unnecessary'
  end

  describe '#reload!(files)' do
    context 'in development' do
      context 'when the application is reloaded' do
        let(:root)             { Pathname.pwd }
        let(:target)           { Pathname('app/concepts') }
        let(:components_dir)   { root / target }

        let(:modified) { [components_dir.join('users')] }
        let(:added)    { [components_dir.join('added')] }
        let(:changed)  { [modified, added, []] }

        it 'loads new paths' do
          allow(subject).to receive(:by_path).and_return(added)

          expect { subject.send(:reload!, changed) }.to \
            change { subject.loaded }.to(include('added'))
        end
      end
    end
  end

  describe '#to_constant_path(path, namespace:, suffix:)' do
    it 'should return the segment of a file path corresponding to the constant it defines' do
      %w(app/concepts/users/relation.rb users/relation.rb).each do |path|
        actual = subject.to_constant_path(String.new(path))
        expect(actual).to eq 'users/relation'
      end
    end

    context 'when namespace given' do
      it 'should return namespace' do
        actual = subject.to_constant_path(String.new('users/model.rb'), namespace: true)

        expect(actual).to eq 'users'
      end
    end

    context 'when suffix given' do
      it 'should remove the suffix' do
        actual = subject.to_constant_path(String.new('users/model.rb'), suffix: /\.rb$/)

        expect(actual).to eq 'users/model'
      end
    end
  end

  describe '#booted!' do
    before do
      Piktur.configure do |config|
        config.namespaces = ['users']
      end
    end

    it 'should be booted after the first call' do
      expect { subject.call }.to change { subject.booted? }
    end
  end

  describe '#config' do
    it { expect(subject.config).to respond_to(:debug) }
  end

  describe '#debug' do
    context 'when Piktur::loader.debug true' do
      before do
        allow(subject.config).to receive(:debug).and_return(true)
      end

      it 'should log the loaded files' do
        expect(Piktur.logger).to receive(:info).with(anything)
        subject.call(path: 'genders')
      end
    end
  end

  describe '#root_directories' do
    it { expect(subject.send(:root_directories)).to all(exist) }
  end

  describe '#models' do
    let(:type) { 'models' }

    it 'should return a list of model files' do
      expect(subject.models).to be_blank.or(all(include('model.rb')))
    end
  end

  describe '#matchers' do
    it { expect(subject.send(:matchers)).to be_a(Hash) }
  end

  describe '#patterns' do
    it { expect(subject.send(:patterns)).to be_a(Hash) }
  end

  describe '#pattern_combination(*types)' do
    it 'should return patterns for given types' do
      expect(subject.send(:pattern_combination, :models)).to \
        all(be_a(String))
    end
  end

  if ENV['DEBUG']
    describe '#by_type(type)' do
      it 'should return all files matching type' do
        models   = subject.send(:by_type, :models)
        policies = subject.send(:by_type, :policies)
        expect(models).to all(include('model').and(end_with('.rb')))
        expect(policies).to all(include('polic').and(end_with('.rb')))
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
        expect(actual).to be_blank.or(all(end_with('.rb')))
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
