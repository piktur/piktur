require 'benchmark/ips'
Benchmark.ips do |x|
  x.report 'set' do
    enum = Types.Enum("set#{rand}".to_sym, constructor: :set) do
      i18n_scope nil

      value :one
      value :two
      value :three
    end

    one = enum[:one]
    enum[1]
    enum[one]
  end

  x.report 'map' do
    enum = Types.Enum("map#{rand}".to_sym, constructor: :map) do
      i18n_scope nil

      value :one
      value :two
      value :three
    end

    one = enum[:one]
    enum[1]
    enum[one]
  end

  x.report 'code' do
    enum = Types.Enum("code#{rand}".to_sym, constructor: :map) do
      i18n_scope nil

      code :one, 1
      code :two, 2
      code :three, 3
    end

    one = enum[:one]
    enum[1]
    enum[one]
  end

  x.compare!
end
