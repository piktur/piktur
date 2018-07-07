# frozen_string_literal: true

require 'spec_helper'
require 'piktur/setup/loader/ext'

RSpec.require_support 'files_configuration'

RSpec.describe Piktur::Loader::Ext do
  include_context 'files configuration'

  subject { double('Module').extend(described_class) }

  before do
    allow(Object).to receive(:require_dependency).and_return(nil)
    allow(subject).to receive(:config).and_return(Test::Config)
  end

  let(:components_dir)  { Pathname('app/concepts') }
  let(:component_types) { %i(models policies transactions locales) }
  let(:namespace) { 'users' }
  let(:filter)    { namespace }
  let(:paths)     { %w(users.rb users/model.rb) }

  describe '.loader=' do
    it('should allow the loader instance to be set') { should respond_to(:loader=) }
  end

  describe '.loader' do
    let(:loader) { subject.config.loader.instance }

    it 'should return the default loader instance' do
      expect(subject.loader).to eq(loader)
    end

    context 'when specified' do
      let(:loader) { instance_double('Loader') }

      before do
        subject.loader = loader
      end

      it 'should return the specified loader instance' do
        expect(subject.loader).to eq(loader)
      end
    end

    describe '#target(root)' do
      it 'should return the relative path' do
        expect(subject.loader.target).to eq(components_dir)
      end

      context 'when root given' do
        it 'should return the absolute path' do
          expect(subject.loader.target(Pathname.pwd)).to \
            eq(Pathname.pwd.join(components_dir))
        end
      end
    end

    describe '#types' do
      it 'should return a list of Symbols' do
        expect(subject.loader.types).to all(be_a(Symbol))
      end
    end
  end

  describe '.load(paths:, type:, scope:, pattern:, force:, index:)' do
    before :context, components: true do
      expect(subject.loader).to receive(:load).at_least(1) do |id, paths, options|
        expect(id).to be_in(subject.config.namespaces).or(be_in(subject.loader.types))
        expect(paths).to include(*paths)
        expect(options).to eq options
      end
    end

    context 'when no args given', components: true do
      it 'should load all namespaces listed under Piktur.namespaces' do
        subject.load
      end
    end

    context 'when :namespaces given', components: true do
      it 'should load the given namespace'  do
        subject.load(paths: filter)
      end
    end

    context 'when component :type given', components: true do
       let(:filter) { :models }
       let(:paths)  { %W(#{namespace}/model.rb) }

      it 'should load the files matching given type' do
        subject.load(type: filter)
      end
    end

    context 'when :index true' do
      let(:paths) { %w(users.rb) }

      before { subject.loader.instance_exec { @loaded = Set.new } }

      it 'should only load the index' do
        result = subject.load(paths: filter, index: true)

        expect(result).to eq(paths)
      end
    end
  end

  describe '.load!(*args)' do
    context 'when booted' do
      it 'should reload the files' do
        expect(subject.loader).to \
          receive(:call)
          .at_least(1)
          .with(force: true)
          .and_call_original

        subject.load!
      end
    end
  end

  describe '.files(paths:, type:, **options)' do
    after(:each) { subject.loader.instance_exec { @loaded = Set.new; @booted = false } }

    context 'when :type given' do
      it 'should return a list of files matching type' do
        expect(subject.files(type: :models)).to be_blank.or(all(match(/model/)))
      end
    end

    context 'when :paths or :namespaces given' do
      it 'should return a list of files matching the given path' do
        expect(subject.files(paths: filter)).to include(*paths)
      end
    end
  end

  describe '.locales', slow: true do
     before do
      require 'piktur/spec/helpers/application'
      I18n::Railtie.initialize_i18n(Piktur::Spec.app)
    end

    it 'should return a list of files matching type' do
      expect(subject.locales).to all(match(/locale/))
    end if ENV['DEBUG']
  end
end
