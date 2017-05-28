# frozen_string_literal: true

module Piktur

  module Support

    # Dependencies extends Object adding helpers to retrieve full constant path(s) from truncated
    # query input.
    #
    # @example Find path
    #   find_model('item') # => "catalogue/item/base"
    #
    #   find_model('item', &:classify) # => "Catalogue::Item::Base"
    #
    # @example Find paths
    #   find_models('item', 'artwork')
    #
    #   find_models('item', 'artwork') do |results|
    #     results.map { |e| e[:match].classify }
    #   end
    #
    # ## Note on Rails Constant reloading
    #
    # Rails adds all under `/app/**` to `Application.config.eager_load_paths`. Constants defined
    # under `._all_autoload_paths` are loaded during `Rails.application.initialize!`, or lazy
    # loaded to reduce boot time in development.
    #
    # To ensure constant reloading in development use
    # `ActiveSupport::Dependencies.require_dependency` rather than `require` or
    # `ActiveSupport::Autoload.eager_load!`.
    #
    # To ensure constants under `/lib` reloaded in  development add path to `config.watchable_dirs`
    # and use `require_dependency`.
    #
    # Modules defined in `lib/piktur/api.rb` must be loaded up front to ensure correct constant
    # lookup in development.
    #
    # ```ruby
    #   # const_get will return root level constant if parent not defined
    #   Rails.env.development?                                   # => true
    #   Object.const_defined?('Piktur::Api::V1::Admin::Asset')   # => false
    #   Object.const_get('Piktur::Api::V1::Admin::Asset::Audio') # => Asset::Audio
    #
    #   # after parent loaded
    #   require_dependency 'app/serializers/piktur/api/v1/admin/asset/base_serializer.rb'
    #   Object.const_defined?('Piktur::Api::V1::Admin::Asset')   # => true
    #
    #   # the correct constant is returned
    #   Object.const_get('Piktur::Api::V1::Admin::Asset::AudioSerializer')
    #   # => Piktur::Api::V1::Admin::Asset::AudioSerializer
    # ```
    #
    # @note Add deeply nested paths to `Rails.application.config.autoload_paths` to
    #   limit redundancy in require statements. `require_dependency` must receive the relative path
    #   from `Rails.root` if called before `Rails.application.initialize!` after which
    #   `._all_autoload_paths` is defined.
    #
    # @see //guides.rubyonrails.org/autoloading_and_reloading_constants.html
    # @see //blog.plataformatec.com.br/2012/08/eager-loading-for-greater-good/
    # @see //bitbucket.org/piktur/piktur_core/issues/24 Rake::FileList vs Dir
    # @see //bitbucket.org/piktur/piktur/src/master/piktur/config.rb Piktur::Config.services
    module Dependencies

      class << self

        # @!method types
        #   Return constant types
        #   @return [Array<String>]
        delegate :types, to: 'Piktur.services.files'

      end

      # Return list of namespaced object types ie. controllers nested under `Admin` namespace
      # @return [Array<String>]
      NAMESPACED = %w(controllers).freeze

      # @return [Piktur::Cache::TSafeMap]
      def self.cache
        @_cache ||= Piktur::Cache::TSafeMap.new { {} }
      end

      # InstanceMethods
      module InstanceMethods

        attr_reader :path, :type

        delegate :cache, to: 'Piktur::Support::Dependencies'
        private :cache

        private

          # @return [String]
          def namespace
            @namespace ||= 'client' if Dependencies::NAMESPACED.include?(type)
          end

          # @param [Object] key
          # @return [Array<String>]
          def cache_key(key)
            [@type, *namespace, key]
          end

          # @raise [Errno::ENOENT]
          def directory!
            raise Errno::ENOENT, path unless directory?
          end

          # @return [Boolean]
          def directory?
            Dependencies.types.include?(type)
          end

          # @return [Array<String>]
          def _files
            @_files ||= Piktur.send(type)
          end

          # @return [String]
          def _type_from_path(path)
            path.split('/')[-1]
          end

          # @return [Regexp]
          def _namespace_matcher
            /.*(?:#{namespace}.*?)/ if namespace
          end

          # @return [Regexp]
          def _path_matcher
            Regexp.escape(path)
          end

          # @param [String] args Truncated constant paths
          # @return [Regexp]
          def _base_class_matcher(*args)
            names = args.join('|')
            /\A(.*#{_path_matcher}\/)((.*#{_namespace_matcher}(#{names}))\/base(?:_\w+)?)\.rb\Z/
          end

          # @param [String] args Truncated constant paths
          # @return [Regexp]
          def _other_matcher(*args)
            names = args.map! { |e| [e, e.to_s.pluralize] }.join('|')
            a = /#{_namespace_matcher}(#{names})/
            b = /(?:\w+\/)*#{_namespace_matcher}(#{names})/
            /\A.*#{_path_matcher}\/((#{a}|#{b})(?:_\w+)?)\.rb\Z/
          end

      end

      # Lookup file(s) by path segment
      class Selector

        include InstanceMethods

        # @!method names
        #   @return [Array<String>]
        attr_reader :names

        # @param [String] path Relative path from engine root
        # @param [Array<String>] names Truncated constant paths
        # @param [String] namespace
        def initialize(path, names, namespace: nil)
          @path      = path
          @names     = names.map!(&:to_s)
          @namespace = namespace.to_s if namespace
          @type      = _type_from_path(path)
        end

        # Return {#cache}d match or store {#_search} result
        # @example
        #   path      = 'app/controllers'
        #   namespace = 'admin'
        #   names     = %w(artwork catalogue)
        #   Selector.new(path, names, namespace: namespace).result
        #   Selector.new(path, names, namespace: namespace).result do |results|
        #     results.map { |e| e['match'].classify }
        #   end
        # @param [Proc] block Transform match data
        # @yieldparam [Array<Hash>]
        # @return [Array<Hash>]
        def result(&block)
          return unless directory?
          _search
          _result && block ? yield(_result) : _result
        end

        private

          # @return [Array]
          # @return [nil] if cache entry exists
          def _search
            return unless _cacheable
            _files.select { |f| _match_base_class(f) }.presence ||
              _files.select { |f| _match_other(f) }.presence
          end

          # @return [String]
          # @return [nil]
          def _result
            @_result ||= cache.values_at(*names.map { |e| cache_key(e) }).presence
          end

          # @return [Array]
          # @return [nil]
          def _cacheable
            @_cacheable ||= names.reject { |e| cache.key?(cache_key(e)) }.presence
          end

          # @param [String] matcher
          # @return [Regexp]
          def _matcher(matcher)
            case matcher
            when :base
              @_base_class_matcher ||= _base_class_matcher(*_cacheable)
            when :other
              @_other_matcher ||= _other_matcher(*_cacheable)
            end
          end

          # @param [String] str
          # @return [Hash]
          def _match_base_class(str)
            return unless str =~ _matcher(:base) && File.directory?($1 + $3)
            cache[cache_key($4)] = { match: $2.freeze, path: str.freeze }
          end

          # @param [String] str
          # @return [Hash]
          def _match_other(str)
            return unless str =~ _matcher(:other)
            cache[cache_key(($3 || $4).singularize)] = { match: $1.freeze, path: str.freeze }
          end

      end

      # Lookup file(s) by path segment
      class Finder

        include InstanceMethods

        # @!method name
        #   @return [String]
        attr_accessor :name

        # @param [String] path Relative path from engine root
        # @param [String] namespace
        # @param [String] name Truncated constant path
        def initialize(path, name, namespace: nil)
          @path      = path
          @namespace = namespace.to_s if namespace
          @name      = name.to_s
          @type      = _type_from_path(path)
        end

        # Return {#cache}d match or store {#_search} result
        # @example
        #   path      = 'app/controllers'
        #   namespace = 'admin'
        #   name      = 'artwork'
        #   Finder.new(path, name, namespace: namespace).result
        #   Finder.new(path, name, namespace: namespace).result(&:classify)
        # @param [Proc] block Transform match data
        # @yieldparam [String] yields matched segment to block
        # @return [String]
        def result(&block)
          return unless directory?
          _search
          _result && block ? yield(_result) : _result
        end

        private

          # @return [Array<String>]
          def cache_key(*)
            @cache_key ||= super(@name)
          end

          # @return [String]
          # @return [nil] if cache entry exists
          def _search
            return if cache.key?(name)
            _files.find { |f| _match_base_class(f) } ||
              _files.find { |f| _match_other(f) }
          end

          # @return [String]
          # @return [nil]
          def _result
            @_result ||= cache[cache_key][:match]
          end

          # @param [String] matcher
          # @return [Regexp]
          def _matcher(matcher)
            case matcher
            when :base
              @_base_class_matcher ||= _base_class_matcher(name)
            when :other
              @_other_matcher ||= _other_matcher(name)
            end
          end

          # @param [String] str
          # @return [Hash]
          def _match_base_class(str)
            return unless str =~ _matcher(:base) && File.directory?($1 + $3)
            cache[cache_key] = { match: $2.freeze, path: str.freeze }
          end

          # @param [String] str
          # @return [Hash]
          def _match_other(str)
            return unless str =~ _matcher(:other)
            cache[cache_key] = { match: $1.freeze, path: str.freeze }
          end

      end

      class << self

        # @param [String] path Relative path from engine root
        # @param [String] except
        # @param [String] only
        # @yieldparam [Array<String>] files
        # @return [Array<String>]
        def search(path = 'app', except: nil, only: nil, &block)
          type  = _type_from_path(path)
          files = Piktur.respond_to?(type) && Piktur.send(type)
          files ||= Piktur.services.search(path).freeze
          files = if except
                    files.reject { |e| e =~ Regexp.union(except) }
                  elsif only
                    files.select { |e| e =~ Regexp.union(only) }
                  end
          block ? yield(files) : files
        end

        # @example
        #   select('app/models', 'artwork', 'catalogue')
        #   select('app/controllers', 'artwork', 'catalogue', namespace: 'admin')
        # @param [String] path
        # @param [String, Symbol] names
        # @param [String, Symbol] namespace
        # @param [Proc] block
        def select(path, *names, namespace: nil, &block)
          Selector.new(path, names, namespace: namespace).result(&block)
        end

        # @example
        #   find('app/models', 'artwork')
        #   find('app/controllers', 'artwork', namespace: 'admin')
        #   find('app/controllers', 'artwork', namespace: 'admin', &:classify)
        # @param [String] path
        # @param [String, Symbol] name
        # @param [String, Symbol] namespace
        # @param [Proc] block
        def find(path, name, namespace: nil, &block)
          Finder.new(path, name, namespace: namespace).result(&block)
        end

        # @return [void]
        def hook!
          Object.class_eval { include ::Piktur::Support::Dependencies }
        end

      end

      delegate :search, to: :class

      # @!scope instance
      # @!method find_concern
      # @!method find_controller
      # @!method find_model
      # @!method find_policy
      # @!method find_presenter
      # @!method find_serializer
      # @!method find_service
      # @!method find_validator
      # @!method find_worker
      # @param [String, Symbol] name Truncated constant path
      # @param [String, Symbol] namespace
      # @param [Proc] block Transform match data
      # @return [String]

      # @!method find_concerns
      # @!method find_controllers
      # @!method find_models
      # @!method find_policies
      # @!method find_presenters
      # @!method find_serializers
      # @!method find_services
      # @!method find_validators
      # @!method find_workers
      # @param [Array<String, Symbol>] names Truncated constant paths
      # @param [String, Symbol] namespace
      # @param [Proc] block
      # @yieldparam [Array<Hash>] results
      # @return [Array<Hash>]
      Dependencies.types.each do |type|
        define_method("find_#{type.singularize}") do |name, namespace: nil, &block|
          Dependencies.find("app/#{type}", name, namespace: namespace, &block)
        end

        define_method("find_#{type}") do |*names, namespace: nil, &block|
          Dependencies.select("app/#{type}", *names, namespace: namespace, &block)
        end
      end

      # @param [String] name Demodulized constant
      # @param [String] path Relative path from engine root
      # @return [Class, Module]
      def constantize_matched(path, name, namespace: nil)
        Dependencies.find(path, name, namespace: namespace) { |str| Object.const_get(str.classify) }
      end

      # @param [String] name Demodulized constant
      # @param [String] path Relative path from engine root
      # @return [String]
      def classify_matched(path, name, namespace: nil)
        Dependencies.find(path, name, namespace: namespace, &:classify)
      end

      # @param [String] name Demodulized constant
      # @param [String] path Relative path from engine root
      # @return [void]
      def require_matched(path, name, namespace: nil)
        Dependencies.find(path, name, namespace: namespace) { |str| require_dependency str }
      end

      # DRY `ActiveSupport::Dependencies.require_dependency`
      # @example
      #   require_dependencies('app/serializers/piktur/api/v1/catalogue/attribution_serializer')
      #   require_dependencies('v1/catalogue/attribution_serializer')
      #   require_dependencies 'v1/client/catalogue', type: :serializer
      #
      # @param [String, Object] type [:controller, :serializer, :policy, :presenter]
      # @param [String] args
      # @return [Boolean]
      def require_dependencies(*args, type: nil)
        suffix = "_#{type}" if type
        args.each { |f| require_dependency "#{f}#{suffix}.rb" }
      end

    end

  end

end
