# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'yard'
# @example Load yard doc extensions. Transfered equivalent behaviour to `/.yardopts`
#   require_relative './piktur_core/lib/yard/ext.rb'
require 'redcarpet'
require 'piktur'

module Piktur

  # @see https://github.com/lsegal/yard/blob/master/lib/yard/registry.rb YARD::Registry
  #
  # @see https://github.com/lsegal/yard/blob/master/lib/yard/server/library_version.rb
  #   YARD::Server::LibraryVersion
  #
  # @see https://github.com/lsegal/yard/blob/master/lib/yard/server/rack_middleware.rb
  #   YARD::Server::RackMiddleware
  #
  # @see https://bitbucket.org/snippets/piktur/84Bkj Piktur::Docs::App example
  #
  # @see file:docs/config.ru
  #
  # @example Piktur API
  #   api/v1/token?auth[email]=*&auth[password]=*
  #
  # @example Generate token from console
  #   Knock::AuthToken.new(payload: Admin.first.to_token_payload)
  #
  # @example Caching strategy
  #   def self.cache
  #     @cache ||= ActiveSupport::Cache.lookup_store(:memory_store)
  #   end
  #
  #   def render(object = nil)
  #     cache do
  #       case object
  #       when CodeObjects::Base
  #         object.format(options)
  #       when nil
  #         Templates::Engine.render(options)
  #       else
  #         object
  #       end
  #     end
  #   end
  #
  #   # Override this method to implement custom caching mechanisms for
  #   #
  #   # @example Caching to memory
  #   #   $memory_cache = {}
  #   #   def cache(data)
  #   #     $memory_cache[path] = data
  #   #   end
  #   # @param [String] data the data to cache
  #   # @return [String] the same cached data (for chaining)
  #   # @see StaticCaching
  #   def cache(data = nil, &block)
  #     self.body = if caching && block
  #       self.class.cache.fetch(request.path_info) { yield block }
  #     else
  #       data
  #       # key = Digest::MD5.hexdigest(data.to_s)
  #       # self.class.cache.fetch(key) { data }
  #     end
  #   end
  module Docs

    class << self

      # Return absolute path to docs directory
      # @return [Pathname]
      def root
        Piktur.root.join('docs')
      end

      # @todo blog, client, admin, store
      # @return [Hash{String=>[YARD::Server::LibraryVersion]}]
      def libraries # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        %w(
          core
          api
        ).each_with_object({}) do |lib, a|
          dir_name    = "piktur_#{lib}"
          docs_path   = root.join(dir_name)
          source_path = Piktur.root.join(dir_name)

          # if lib == 'core'
          #   # namespace = 'Piktur'
          #   version   = Piktur::VERSION
          # else
          #   namespace = "Piktur::#{lib.classify}"
          #   require_relative source_path.join("lib/piktur/#{lib}/version.rb")
          #   const     = "#{namespace}::VERSION"
          #   version   = Object.const_defined?(const) && Object.const_get(const)
          # end

          yardoc = docs_path.join('.yardoc').to_s

          # @example Is it possible to load library data serializing its Objects from another library?
          #   @return [Array<String>]
          #   def self.registries
          #     @docs = []
          #   end
          #
          #   def self.load
          #     YARD::Registry.load(docs, true)
          #   end
          #
          #   registries << yardoc

          # libver = YARD::Server::LibraryVersion.new(dir_name, version, yardoc, :disk)
          libver = YARD::Server::LibraryVersion.new(dir_name, nil, yardoc, :disk)
          libver.source      = source_path.to_s
          libver.source_path = source_path.to_s
          a[dir_name] = [libver] # "Piktur::#{lib.classify} [#{dir_name}]"
        end
      end

    end

  end

end
