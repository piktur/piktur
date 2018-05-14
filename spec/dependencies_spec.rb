# frozen_string_literal: true

# rubocop:disable BlockLength

require 'rails_helper'

types = %w(
  concerns
  controllers
  models
  policies
  presenters
  serializers
  services
  validators
  workers
)

RSpec.describe Piktur do
  types.each do |type|
    describe ".#{type}" do
      it { expect(Piktur.send(type)).to be_a(Array) }
    end
  end

  describe '.services' do
    describe '.search' do
      let(:paths) do
        [
          Piktur::Engine.root.join('app/models/**/*.rb'),
          Piktur::Store::Engine.root.join('app/models/**/*.rb'),
          Rails.root.join('app', 'models', '**', '*.rb')
        ]
      end

      it { expect(Piktur.services.search('app/models')).to include(*paths) }
    end
  end
end

RSpec.describe Piktur::Support::Dependencies do
  let(:base_path) { Pathname.new('/Users/daniel/Documents/webdev/current_projects/piktur/') }
  let(:controllers) do
    %w(
      piktur_api/app/controllers/piktur/api/v1/admin/users_controller.rb
      piktur_api/app/controllers/piktur/api/v1/admin/catalogue/base_controller.rb
      piktur_api/app/controllers/piktur/api/v1/admin/catalogue/item/base_controller.rb
      piktur_api/app/controllers/piktur/api/v1/admin/catalogue/item/artworks_controller.rb
      piktur_api/app/controllers/piktur/api/v1/admin/asset/base_controller.rb
      piktur_api/app/controllers/piktur/api/v1/admin/asset/audios_controller.rb
      piktur_api/app/controllers/piktur/api/v1/admin/site_controller.rb
    ).map! { |f| base_path.join(f) }
  end
  let(:models) do
    %w(
      piktur_core/app/models/user.rb
      piktur_core/app/models/catalogue/base.rb
      piktur_core/app/models/catalogue/item/base.rb
      piktur_core/app/models/catalogue/item/artwork.rb
      piktur_core/app/models/asset/base.rb
      piktur_core/app/models/asset/audio.rb
      piktur_core/app/models/site.rb
    ).map! { |f| base_path.join(f) }
  end
  let(:policies) do
    %w(
      piktur_core/app/policies/user_policy.rb
      piktur_core/app/policies/catalogue/base_policy.rb
      piktur_core/app/policies/catalogue/item/base_policy.rb
      piktur_core/app/policies/catalogue/item/artwork_policy.rb
      piktur_core/app/policies/asset/base_policy.rb
      piktur_core/app/policies/asset/audio_policy.rb
      piktur_core/app/policies/site_policy.rb
    ).map! { |f| base_path.join(f) }
  end
  let(:serializers) do
    %w(
      piktur_api/app/serializers/piktur/api/v1/user_serializer.rb
      piktur_api/app/serializers/piktur/api/v1/catalogue/base_serializer.rb
      piktur_api/app/serializers/piktur/api/v1/catalogue/item/base_serializer.rb
      piktur_api/app/serializers/piktur/api/v1/catalogue/item/artwork_serializer.rb
      piktur_api/app/serializers/piktur/api/v1/asset/base_serializer.rb
      piktur_api/app/serializers/piktur/api/v1/asset/audio_serializer.rb
      piktur_api/app/serializers/piktur/api/v1/site_serializer.rb
    ).map! { |f| base_path.join(f) }
  end

  it { expect(described_class.types).to contain_exactly(*types) }

  describe Object do
    types.each do |type|
      singular = type.singularize
      it "should respond to .find_#{singular}" do
        expect(described_class).to respond_to "find_#{singular}"
      end

      it "should respond to .find_#{type}" do
        expect(described_class).to respond_to "find_#{type}"
      end
    end

    %w(classify_matched constantize_matched require_matched).each do |m|
      it("should respond to .#{m}") { expect(described_class).to respond_to m }
    end
  end

  describe '.classify_matched' do
    it { expect(classify_matched('app/models', 'item')).to eq 'Catalogue::Item::Base' }
  end

  describe '.constantize_matched' do
    it 'should resolve constant' do
      expect(constantize_matched('app/models', 'item')).to be_a(Class)
    end
  end

  describe '.require_matched' do
    before { require_matched('app/models', 'item') }
    it('should load constant') { expect(defined? Catalogue::Item::Base).to be_truthy }
  end

  describe '.find_models' do
    context "when args 'item', 'artwork' supplied" do
      result = find_models('item', 'artwork')
      it("should contain exactly #{result.to_sentence}") { expect(result.size).to eq 2 }
    end
  end

  describe '.find_model' do
    result = find_model('item')

    it('should return path to constant definition') { expect(result).to be_a(String) }

    context 'when block given' do
      it 'should recieve match data' do
        # Piktur::Support::Dependencies.send(:_find, 'app/models', 'artwork', &:classify)
        expect(find_model('item', &:classify)).to eq 'Catalogue::Item::Base'
      end
    end
  end

  types.select { |type| type.match?(/mod|contr|pol|serial/) }.each do |type|
    singular_type = type.singularize

    describe ".find_#{singular_type}" do
      let(:path)    { "app/#{type}" }
      let(:files)   { Piktur::Support::Dependencies.send(type) }
      let!(:__name) { "#{_name}|#{_name.pluralize}" }
      let!(:result) { Piktur::Support::Dependencies.send(:find, path, _name) }

      context "when called with `name` 'user'" do
        let(:_name) { 'user' }
        it { expect(result).to match(/user(?:_#{singular_type})?/) }
      end

      context "when called with `name` 'catalogue'" do
        let(:_name) { 'catalogue' }
        it { expect(result).to match(/catalogue\/base(?:_#{singular_type})?/) }
      end

      context "when called with `name` 'item'" do
        let(:_name) { 'item' }
        it { expect(result).to match(/catalogue\/item\/base(?:_#{singular_type})?/) }
      end

      context "when called with `name` 'artwork'" do
        let(:_name) { 'artwork' }
        it { expect(result).to match(/catalogue\/item\/#{__name}(?:_#{singular_type})?/) }
      end

      context "when called with `name` 'asset'" do
        let(:_name) { 'asset' }
        it { expect(result).to match(/asset\/base(?:_#{singular_type})?/) }
      end

      context "when called with `name` 'audio'" do
        let(:_name) { 'audio' }
        it { expect(result).to match(/asset\/#{__name}(?:_#{singular_type})?/) }
      end

      context "when called with `name` 'site'" do
        let(:_name) { 'site' }
        it { expect(result).to match(/site\/base(?:_#{singular_type})?/) }
      end

      context "when called with `name` 'template'" do
        let(:_name) { 'template' }
        it { expect(result).to match(/site\/#{__name}(?:_#{singular_type})?/) }
      end
    end
  end
end
