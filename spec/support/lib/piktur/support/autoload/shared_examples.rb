require 'rails_helper'

RSpec.shared_examples 'Piktur::Support::Autoload' do
  context 'when included' do
    described_class.parent.extend(Piktur::Support::Autoload)

    let(:models_path) { Piktur::Engine.paths['app/models'].first }
    let(:namespace)   { described_class.parent.name }
    let(:subclasses) do
      Rake::FileList[File.join(models_path, namespace.underscore, '*.rb')]
        .collect { |path| "#{namespace}::#{File.basename(path, '.rb').classify}" }
        .reject { |klass| klass.include?('Base') }
    end

    context "when Rails.env == 'development'" do
      context 'and Rails.configuration.eager_load == false' do
        it { expect(described_class.parent).to respond_to(:eager_autoload) }
      end

      # describe ActiveSupport::Dependencies do
      #   describe '.loaded' do
      #     let(:loaded) { described_class.loaded }
      #   end

      #   describe '.remove_constant' do
      #     before { Asset::Base }

      #     let(:constant) { 'Asset::Base' }
      #     let(:path)     { constant.underscore }

      #     it 'should remove corresponding path from .loaded' do
      #       described_class.remove_constant(constant)
      #       expect(described_class.loaded.select { |f| f.include?(path) }).not_to be_present
      #     end
      #   end

      #   context 'when removed constant encountered' do
      #     it 'should be reloaded' do
      #       Asset::Base.new
      #       expect(described_class.loaded.select { |f| f.include?(path) }).to be_present
      #     end
      #   end
      # end

      describe '$LOADED_FEATURES' do
        it do
          skip
          # Verify load order with
          $LOADED_FEATURES.select { |a| a =~ /piktur_core/ }
        end
      end
    end
  end
end
