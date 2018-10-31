# frozen_string_literal: true

require 'spec_helper'

RSpec.require_support 'loader', app: 'piktur'

RSpec.describe Piktur::Loader::ActiveSupport do
  include_context 'loader'

  xcontext 'when a watched file is modified, added or deleted' do
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

  xdescribe '#reload!(files)' do
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
end
