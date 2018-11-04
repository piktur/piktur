# frozen_string_literal: true

require 'benchmark/ips'
require_relative File.expand_path('../lib/piktur.rb', __dir__)
require_relative File.expand_path('../lib/piktur/support/enum.rb', __dir__)

# Warming up --------------------------------------
#                  set     1.772k i/100ms
#                  map     2.249k i/100ms
#                 code     2.084k i/100ms
# Calculating -------------------------------------
#                  set     18.073k (± 2.4%) i/s -     90.372k in   5.003104s
#                  map     23.128k (± 2.2%) i/s -    116.948k in   5.058805s
#                 code     21.201k (± 1.8%) i/s -    106.284k in   5.014814s
#
# Comparison:
#                  map:    23127.8 i/s
#                 code:    21200.8 i/s - 1.09x  slower
#                  set:    18073.0 i/s - 1.28x  slower
#
#
# Warming up --------------------------------------
#                  set     1.616k i/100ms
#                  map     2.055k i/100ms
#                 code     1.951k i/100ms
# Calculating -------------------------------------
#                  set     16.730k (± 2.1%) i/s -     84.032k in   5.024857s
#                  map     20.924k (± 2.1%) i/s -    104.805k in   5.010974s
#                 code     19.773k (± 1.7%) i/s -     99.501k in   5.033550s
#
# Comparison:
#                  map:    20924.2 i/s
#                 code:    19773.0 i/s - 1.06x  slower
#                  set:    16729.8 i/s - 1.25x  slower
module Enum

  module_function

  def set
    Piktur::Support::Enum.new(:set, constructor: :set) do
      i18n_scope nil

      value :one
      value :two
      value :three
    end
  end

  def map
    Piktur::Support::Enum.new(:map, constructor: :map) do
      i18n_scope nil

      value :one
      value :two
      value :three
    end
  end

  def code(*args)
    Piktur::Support::Enum.new(:code, constructor: :map) do
      i18n_scope nil

      code :one, 1
      code :two, 2
      code :three, 3
    end
  end

  def constructor
    Benchmark.ips do |x|
      x.report('set') { set }
      x.report('map') { map }
      x.report('code') { code }
      x.compare!
    end
  end

  def find
    Benchmark.ips do |x|
      x.report 'set' do
        enum = set
        one = enum[:one]
        enum[1]
        enum[one]
        enum.find!(:one)
      end

      x.report 'map' do
        enum = map
        one = enum[:one]
        enum[1]
        enum[one]
        enum.find!(:one)
      end

      x.report 'code' do
        enum = code
        one = enum[:one]
        enum[1]
        enum[one]
        enum.find!(:one)
      end

      x.compare!
    end
  end

  def run
    constructor
    find
  end

end

ENV['BENCHMARK'] && Enum.run
Object.send(:remove_const, :Enum)
