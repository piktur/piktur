require 'benchmark/ips'

module Types; include Dry::Types.module; end

Roles   = ['0', '1', '2', '3', '4', '5', '6', '7']

Roles.instance_exec do
  singleton_class.send(:define_method, :find_role) do |val|
    case val
    when String  then find_index(val)
    when Integer then self[val]
    end
  end

  singleton_class.send(:define_method, :find_role_) do |val|
    return find_index(val) if val.is_a?(String)
    self[val] if val.is_a?(Integer)
  end
end

Roles_ = { 0 => 'default'.inquiry, 1 => 'shipping'.inquiry, 2 => 'billing'.inquiry }.tap do |obj|
  obj.instance_variable_set(:@keys, obj.keys)
  obj.instance_variable_set(:@values, obj.values)
  obj.singleton_class.send(:redefine_method, :keys)   { obj.instance_variable_get(:@keys) }
  obj.singleton_class.send(:redefine_method, :values) { obj.instance_variable_get(:@values) }
  obj.singleton_class.send(:define_method, :[]) do |val|
    case val
    when String  then values.find_index(val)
    when Integer then super(val)
    end
  end
  obj.freeze
end

::Dry::Types::Enum.include Module.new {
  def index(input); values.find_index(input); end
  def index_(input); mapping.key(input); end
  def call(input)
    value =
      if values.include?(input)
        input
      else
        mapping[input]
      end
    value
    # type[value || input]
  end
}

DryEnum = Dry::Types['string'].default(Roles[0]).enum(*Roles)

mapping = { 0 => 'test' }
values  = ['test']
value   = values[0]

Benchmark.ips do |x|
  x.report('Hash#key') { mapping.key(value) }
  x.report('Array#find_index') { values.find_index(value) }
  x.compare!
end

Benchmark.ips do |x|
  x.report('Hash#keys') { mapping.keys.include?(0) }
  x.report('Hash#key?') { mapping.key?(0) }
  x.compare!
end

val = Roles[-1]
i   = Roles.size - 1
Benchmark.ips do |x|
  x.report('Dry::Types::String.enum') {
    DryEnum.values.find_index(val)
    DryEnum[val]
  }

  x.report('Dry::Types::String.enum#values.find_index') {
    DryEnum.index(val)
    DryEnum[val]
  }

  x.report('Dry::Types::String.enum#mapping.key') {
    DryEnum.index_(val)
    DryEnum[val]
  }

  x.report('Array with case') {
    Roles.find_role(val)
    Roles.find_role(i)
  }

  x.report('Array with Object.is_a?') {
    Roles.find_role_(val)
    Roles.find_role_(i)
  }

  x.compare!
end

# @example
#   Enum = Dry::Types['string'].default('default').enum('default', 'value')
#   Enum.index('value') # => 1

# @example Hash#key
#   ::Dry::Types::Enum.send(:define_method, :index) { |input| mapping.key call(input) }
# @see file:spec/enum_spec.rb `Hash#key` ~1.6x slower than `Array#find_index`
# ::Dry::Types::Enum.send(:define_method, :index) { |input| values.find_index call(input) }

# Address#type
# Catalogue::Event#traits.type
# Catalogue::Participant#role
# Profile#gender
# User::Base#role
# Asset::Base#role

# require 'ruby-enum'
# require 'enumerize'
# require 'safe-enum'


class Test < Enum
  enum  name:                :roles,
        subscriber_basic:    { value: 0, default: true },
        subscriber_standard: { value: 1 },
        subscriber_complete: { value: 2 },
        admin:               { value: 3 },
        customer:            { value: 4 }
end

class A
  attr_accessor :role
  include Piktur::Security::Authorization::Test.predicates(:role)
end
