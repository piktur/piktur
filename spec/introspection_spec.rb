# frozen_string_literal: true

require 'spec_helper'

require 'active_support/core_ext/module/introspection'
require 'piktur/support/inflector'

# active_support/core_ext/module/introspection.rb
#   Module.nesting[1..-1] << Object
#
# @see file:spec/benchmark/constant.rb
# @see https://bitbucket.org/piktur/piktur/src/master/spec/introspection_spec.rb

class Module

  %i(parents parent parent_name).each do |m|
    undef_method(m) if method_defined?(:parents)
  end

end

# Returns all the parents of a Module; from innermost to outermost.
# The receiver is not included.
#
# @return [Array<Module>]
def Module.parents
  binding.pry
  @_parents ||= ::Module.nesting
end

# @return [Module]
def Module.parent
  @_parent ||= parents[0] # ::Inflector.constantize(parent_name)
end

# @return [String]
def Module.parent_name
  @_parent_name ||= parent&.name
end

RSpec.describe 'namespace introspection' do
  def names(char)
    (1..5).map { |n| "#{char}#{n}".to_sym }
  end

  def parents(names)
    mod     = mod(names)
    n       = names.length - 1
    parents = []
    parents << names[0..(n -= 1)].join('::') until n.zero?
    parents.map! { |name| Piktur::Support::Inflector.constantize(name) }
    parents << Object
  end

  def mod(names)
    Object.safe_get_const(names.join('::')) || names.inject(Object) do |mod, const|
      mod.const_set(const, Module.new)
    end
  end

  before { load 'piktur/support/introspection.rb' }

  subject { mod(names(char)) }

  let(:char)     { 'L' }
  let(:expected) { parents(names(char)) }

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
      module A1::A2::A3::A4::A5
        def self.parents
          super
          remove_instance_variable(:@_parents)
          super
        end
      end

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

  after(:all) { %i(L1 A1 B1).each { |const| Object.send(:remove_const, const) } }
end