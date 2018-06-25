# frozen_string_literal: true

require 'spec_helper'

require 'active_support/core_ext/module/introspection'
require 'piktur/support/introspection'
require 'piktur/support/inflector'

# active_support/core_ext/module/introspection.rb
#   Module.nesting[1..-1] << Object
#
# @see file:spec/benchmark/constant.rb
# @see https://bitbucket.org/piktur/piktur/src/master/spec/introspection_spec.rb

RSpec.describe Piktur::Support::Introspection do
  before(:all) do
    # %i(parents parent parent_name).each do |m|
    #   Module.send(:undef_method, m) if Module.method_defined?(:parents)
    # end

    Piktur::Support.install(:module)
  end

  def names(char)
    (1..5).map { |n| "#{char}#{n}".to_sym }
  end

  def mod(names)
    Object.safe_const_get(names.join('::')) || names.inject(Object) do |mod, const|
      mod.const_set(const, described_class.new)
    end
  end

  subject { mod(names(char)) }

  let(:char)  { 'L' }
  let(:expected) do
    names   = names(char)
    mod     = mod(names)
    n       = names.length - 1
    parents = []
    parents << names[0..(n -= 1)].join('::') until n.zero?
    parents.map! { |name| Piktur::Support::Inflector.constantize(name) }
    parents << Object
  end

  describe Module do
    describe '.parents' do
      it 'should return all parents of a Module from innermost to outermost' do
        actual = subject.parents

        RSpec.debug(binding, actual - expected)

        expect(actual).to eq(expected)
      end
    end

    describe '.parent' do
      it 'should return the parent Module' do
        expect(subject.parent).to eq(expected[0])
      end
    end

    describe '.parent_name' do
      it 'should return the name of the parent Module' do
        expect(subject.parent_name).to eq(expected[0].name)
      end
    end

    context 'when defined with compact module definition style' do
      let(:char) { 'A' }

      before(:all) do
        A1 = Module.new
        A1::A2 = Module.new
        A1::A2::A3 = Module.new
        A1::A2::A3::A4 = Module.new
        module A1::A2::A3::A4::A5; end
      end

      it do
        expect(subject.parents).to eq(expected)
      end
    end

    context 'when defined with nested module definition style' do
      let(:char) { 'B' }

      before(:all) do
        module B1
          module B2
            module B3
              module B4
                module B5
                end
              end
            end
          end
        end
      end

      it { expect(subject.parents).to eq(expected) }
    end
  end

  describe Class do
    describe 'inheritance' do
      let(:char) { 'C' }

      subject { mod(names(char)) }

      it 'should return all parents of a Class from innermost to outermost' do
        actual = subject.parents

        RSpec.debug(binding, actual - expected)

        expect(actual).to eq(expected)
      end

      it do
        class C1
          self::Sub1 = Class.new(self::C2::C3::C4::C5)
          class Sub2 < C2::C3::C4::C5; end
        end
        class C1::C2::C3::Sub3 < C1::C2::C3::C4; end

        expect(C1::Sub1.parents).to eq([C1, Object])
        expect(C1::Sub2.parents).to eq([C1, Object])
        expect(C1::C2::C3::Sub3.parents).to eq([C1::C2::C3, C1::C2, C1, Object])
      end
    end

    context 'when defined with compact module definition style' do
      let(:char) { 'D' }

      before(:all) do
        class D1
          class D2
            class D3
              class D4
                class D5
                end
              end
            end
          end
        end
      end

      it { expect(subject.parents).to eq(expected) }
    end
  end

  after(:all) { %i(L1 A1 B1).each { |const| Object.send(:remove_const, const) } }
end