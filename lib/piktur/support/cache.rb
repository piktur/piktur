# frozen_string_literal: true

module Piktur

  module Support

    # Provides a thread safe memory store with `Hash` like interface.
    #
    # @see file:spec/cache_spec.rb
    module Cache

      # Provides multi value read capability equivalent to
      #   * [Hash#fetch_values](http://ruby-doc.org/core-2.4.1/Hash.html#method-i-fetch_values)
      #   * [Hash#values_at](http://ruby-doc.org/core-2.4.1/Hash.html#method-i-values_at)
      #
      module ReadMulti

        # @raise [KeyError]
        # @return [Object]
        def fetch_values(*args)
          args.map! { |key| fetch(key) }
        end

        # @return [Object]
        def values_at(*args)
          args.map! { |key| self[key] }
        end

      end

    end

  end

  # A **thread safe** data store caching the return value of a given block by the given arguments.
  class Cache

    extend  ::Dry::Core::Cache
    include Support::ReadMulti

  end

end
