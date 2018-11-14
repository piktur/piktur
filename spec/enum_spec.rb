# frozen_string_literal: true

require 'spec_helper'

require_relative File.expand_path('../lib/piktur/support/enum.rb', __dir__)

RSpec.require_support 'container', app: 'piktur'

RSpec.describe Piktur::Support::Enum do
  include_context 'container'

  around do |example|
    types(replace: true) do |container|
      example.run
    end
  end

  before do
    stub_const('Types', Piktur::Types.dup)

    allow(Piktur::Support::Enum).to receive(:config) do
      OpenStruct.new(
        inflector: Inflector,
        i18n_namespace: :enum,
        types: Types,
        container: test_container.new,
      )
    end
  end

  let(:options) { Hash[i18n_scope: nil] }
  let(:name) { :colours }
  let(:namespace) { stub_const('Test::Palette', Module.new) }
  let(:sample) { enum.values.sample }
  let(:default) { enum.default }
  let(:block) do
    lambda do
      default :black
      value   :blue
      value   :purple
      value   :red

      finalize do |enum|
        def enum.extended?; true; end
      end
    end
  end

  subject(:enum) { Piktur::Support::Enum.new(name, namespace: namespace, **options, &block) }

  describe 'constructor' do
    it 'should map enumerable values' do
      expect(enum[:black]).to eq(0)
      expect(enum[:black]).to eq(enum.default)
      expect(enum[:blue]).to eq(1)
      expect(enum[:purple]).to eq(2)
      expect(enum[:red]).to eq(3)

      expect(enum).to be_extended
    end

    context 'with duplicate key' do
      let(:block) do
        lambda do
          value :black
          value :black
        end
      end

      it 'should remove the duplicate' do
        expect(subject.size).to eq(1)
      end
    end

    context 'when block given to finalize' do
      it 'should add the methods to the enum instance' do
        expect(enum).to be_extended
      end
    end

    context 'when predicates called with an attribute name' do
      let(:result) { enum.predicates(:colour) }

      it 'should build predicate methods for the attribute' do
        expect(result).to be_a(Module)
      end
    end
  end

  describe '#[]' do
    context 'when value given' do
      let(:input) { sample.key }

      it { expect(enum[input]).to be(sample) }
    end

    context 'when key given' do
      let(:input) { sample.value }

      it { expect(enum[input]).to be(sample) }
    end

    context 'when Value given' do
      it { expect(enum[sample]).to be(sample) }
    end

    it 'is case insensitive' do
      expect(enum[sample.to_sym.swapcase]).to be(sample)
    end

    it 'is type insensitive' do
      expect(enum[sample.to_s]).to be(sample)
    end

    context 'when input is not in enumerable' do
      let(:invalid) { :non }

      it { expect(enum[invalid]).to be_nil }
    end
  end

  describe '#call(input)' do
    let(:input) { sample.key }

    it 'should return Value matching key or value' do
      expect(enum.call(input)).to be(sample)
    end

    context 'when input is not in enumerable' do
      let(:input) { :non }

      context 'and default' do
        it 'should return default' do
          expect(enum.call(input)).to be(enum.default)
        end
      end

      context 'and no default' do
        let(:block) do
          lambda do
            value   :blue
            value   :red
          end
        end

        it { expect(enum.call(input)).to be_nil }
      end
    end
  end

  describe '#find!(input)' do
    it 'should raise error if input not in enumerable' do
      expect { enum.find!(:non) }.to raise_error(NameError)
    end

    it 'is case sensitive' do
      expect { enum.find!(sample.to_sym.swapcase) }.to raise_error(NameError)
    end

    it 'is not type sensitive' do
      expect { enum.find!(sample.to_s) }.not_to raise_error(NameError)
    end

    it 'should raise error if input not in enumerable' do
      expect { enum.find!(enum.size) }.to raise_error(IndexError)
    end
  end

  describe '#find_by_key' do
    it 'should return Value matching key' do
      expect(enum.find_by_key(sample.key)).to be(sample)
    end

    context 'when key is not in enumerable' do
      it { expect(enum.find_by_key(:non)).to be_nil }
    end
  end

  describe '#find_by_value' do
    it 'should return Value matching value' do
      expect(enum.find_by_value(sample.value)).to be(sample)
    end

    context 'when value is not in enumerable' do
      it { expect(enum.find_by_value(8)).to be_nil }
    end
  end

  describe '#find_by_key!(key)' do
    it 'should return Value matching key' do
      expect(enum.find_by_key!(sample.key)).to be(sample)
    end

    context 'when key is not in enumerable' do
      it 'should raise error' do
        expect { enum.find_by_key!(:non) }.to raise_error
      end
    end
  end

  describe '#find_by_value!(value)' do
    it 'should return Value matching value' do
      expect(enum.find_by_value!(sample.value)).to be(sample)
    end

    context 'when value is not in enumerable' do
      it 'should raise error' do
        expect { enum.find_by_value!(8) }.to raise_error
      end
    end
  end

  describe '#each(&block)' do
    it 'should yield values to block' do
      expect(enum.each).to be_a(Enumerator)
    end
  end

  describe '#select(&block)' do
    it 'should yield values to block' do
      expect(enum.select).to be_a(Enumerator)
    end
  end

  describe '#values_at(values)' do
    it 'should return Value for each key' do
      expect(enum.values_at(sample.value)).to include(sample)
    end

    context 'when input is not in enumerable' do
      it 'should return an empty Array' do
        expect(enum.values_at(enum.size + 1)).to eq(EMPTY_ARRAY)
      end
    end
  end

  describe '#to_s' do
    it 'should return collection name' do
      expect(enum.to_s).to eq('colours')
    end
  end

  describe '#human' do
    it 'should return collection name' do
      expect(enum.human).to eq('Colours')
    end
  end

  describe '#to_enum' do
    it { expect(enum.to_enum).to be_a(Enumerator) }
  end

  describe '#include?(value)' do
    context 'when other in enumerable' do
      it 'should be true' do
        expect(enum.include?(sample)).to be(true)
      end
    end

    context 'when other not in enumerable' do
      it 'should be false' do
        expect(enum.include?(:non)).to be(false)
      end
    end
  end

  describe '#default_value' do
    context 'when default' do
      it 'should return the default value' do
        expect(enum.default_value).to eq(default)
      end
    end

    context 'when no default' do
      let(:block) do
        -> { value :one }
      end

      it 'should return nil' do
        expect(enum.default_value).to be_nil
      end
    end
  end

  describe '#size' do
    it 'should return the number of enumerable values' do
      expect(enum.size).to be > 0
    end
  end

  describe '#to_hash' do
    it 'should return mapping' do
      expect(enum.to_hash).to be_a(::Hash)
    end
  end

  describe '#to_a' do
    it 'should return enumerable values' do
      expect(enum.to_a).to be_a(Array)
    end
  end

  describe Piktur::Support::Enum::Value do
    let(:value) { enum.values.sample }

    describe '#meta' do
      let(:block) do
        -> { value :black, meta: { spell: :blackened } }
      end

      it 'should return a Hash' do
        expect(value.meta).to be_a(::Hash).or be_nil
      end

      it 'should be frozen' do
        expect(value.meta).to be_frozen
      end
    end

    describe '#matcher' do
      it 'should return a Regexp' do
        expect(value.matcher).to be_a(Regexp)
      end
    end

    describe '#key' do
      it 'should return a Symbol' do
        expect(value.key).to be_a(Symbol)
      end
    end

    describe '#value' do
      it 'should return an Integer' do
        expect(value.value).to be_a(Integer)
      end
    end

    describe '#i18n_scope' do
      it 'should i18n scope segments' do
        expect(value.i18n_scope).to be_a(Array)
      end
    end

    describe '#as_json(**)' do
      it 'should return an Integer' do
        expect(value.as_json).to be_a(Integer)
      end
    end

    describe '#human' do
      before do
        allow(I18n).to receive(:t).with(value.key, scope: value.i18n_scope) do |result|
          value.key.to_s
        end
      end

      it 'should return translated String' do
        expect(value.human).to be_a(String)
      end
    end

    describe '#to_s' do
      it 'should return a String' do
        expect(value.to_s).to be_a(String)
      end
    end

    describe '#to_i' do
      it 'should return an Integer' do
        expect(value.to_i).to be_a(Integer)
      end
    end

    describe '#to_sym' do
      it 'should return a Symbol' do
        expect(value.to_sym).to be_a(Symbol)
      end
    end

    describe '#default?' do
      it 'should return Boolean' do
        expect(value.default?).to be(true).or be(false)
      end
    end

    describe '#eql?(other)' do
      context 'when other is nil' do
        it { expect(value.eql?(nil)).to be(false) }
      end

      context 'when other == value' do
        it { expect(value.eql?(value.to_i)).to be(true) }
      end

      context 'when other == key' do
        it { expect(value.eql?(value.key.to_s)).to be(true) }
      end
    end

    describe '#===(other)' do
      context 'when other is Value' do
        it { expect(value === value).to be(true) }
      end

      context 'when other is a Symbol and == value.key' do
        it { expect(value === value.key).to be(true) }
      end

      context 'when other is a Integer and == value.value' do
        it { expect(value === value.value).to be(true) }
      end
    end

    describe '#match?(other)' do
      it { expect(value.match?(value.to_s)).to be(true) }

      it 'should ignore case' do
        expect(value.match?(value.to_s.swapcase)).to be(true)
      end
    end
  end

  shared_context 'mixin' do
    before do
      stub_const('Shape', Struct.new(attribute))
    end

    let(:attribute) { :colour }
    let(:shape) { Shape.new(sample) }
  end

  describe '#predicates(attribute)' do
    include_context 'mixin'

    before do
      Shape.include enum.predicates(attribute)
    end

    it { expect(enum.predicates(attribute)).to be_a Module }

    context 'when included' do
      it do
        expect(shape).to respond_to(*enum.keys.map { |key| "#{key}?".to_sym })
      end

      describe '#<value>?' do
        it 'should be true if attribute value matches' do
          expect(shape.send("#{sample.key}?")).to be(true)
        end
      end
    end
  end

  describe '#attributes(attribute)' do
    include_context 'mixin'

    before do
      Shape.include enum.attributes(attribute)
    end

    it { expect(enum.attributes(attribute)).to be_a Module }

    context 'when included' do
      it do
        expect(shape).to respond_to(
          "default_#{attribute}!".to_sym,
          *enum.keys.map { |key| "#{key}!".to_sym }
        )
      end

      describe '#default_<attribute>!' do
        it 'should set default value' do
          expect(shape.send("default_#{attribute}!")).to eq(enum.default)
        end
      end

      describe '#<value>!' do
        it 'should set attribute to value' do
          expect(shape.send("#{sample.key}!")).to eq(sample)
        end
      end
    end
  end

  context 'with types plugin' do
    describe '.Enum(name, namespace, options, &block)' do
      before do
        Piktur::Support::Enum.use :types

        Types.Enum(name, namespace: namespace, **options) do
          default :black
          value   :blue
          value   :purple
          value   :red
        end
      end

      let(:options) { Hash[predicates: nil, i18n_scope: nil] }
      let(:name) { :colours }
      let(:namespace) { Test.safe_const_reset(:Palette, ::Module.new) }
      let(:key) { "enum.test.palette.#{name}" }
      let(:result) { Types.container[key] }

      describe 'the constructor' do
        it 'is assigned to the Types container' do
          expect(result).to be_a(Dry::Types::Type)
        end

        it 'casts input to enum value' do
          expect(result[:black]).to be_a(Piktur::Support::Enum::Value).or(raise_error)
        end
      end
    end
  end
end

RSpec.describe Piktur::Support::Enum::Validator do
  let(:key) { :key }
  let(:value) { 1 }
  let(:mapping) { { :key => Value.new(:key, 1) } }

  let(:input) { [key, value, mapping] }
  let(:result) { subject.call(*input) }

  before do
    stub_const('Value', Struct.new(:key, :value) {
      def ==(other); key == other || value == other; end
    })
  end

  describe 'valid' do
    let(:key) { :other }
    let(:value) { 2 }

    it { expect { result }.not_to throw_symbol(:invalid) }
  end

  describe 'duplicate key' do
    let(:value) { 2 }

    it { expect { result }.to throw_symbol(:invalid) }
  end

  describe 'duplicate value' do
    let(:key) { :other }

    it { expect { result }.to throw_symbol(:invalid) }
  end

  describe 'non numeric value' do
    let(:key) { :other }
    let(:value) { '2' }

    it { expect { result }.to throw_symbol(:invalid) }
  end
end
