# frozen_string_literal: true

module Piktur

  module Services

    # Group files by object type. Object types are inferred from {#target} subdirectory names.
    # Per Rails autoloading conventions, we expect files located within `app/models` to define a
    # constant and that it behaves as a Model ie. it inherits from ActiveRecord::Base etc.
    #
    # {Piktur::Support::Dependencies} utilises these lists to abbreviate constant lookup
    class FileIndex

      # @!attribute [r] services
      #   @return [Array<Services::Service>]
      attr_reader :services

      # @!attribute [r] files
      #   Returns all files found under {#target} path for all services
      #   @return [Array<String>]
      attr_reader :files

      # @!attribute [r] target
      #   Targeted path from service root, default 'app'
      #   @return [String]
      attr_reader :target

      # @!attribute [r] types
      #   Derived object types accoring to existent sub directories under {#target}
      #   @return [Array<String>]
      attr_reader :types

      # @param [Array<Services::Service>] services
      # @param [String] target
      def initialize(services, target = 'app')
        @services = services
        @target   = target
        @files    = {}
        services.each { |service| @files[service.path] = service.gemspec.files }
        @types = extract_types
        Piktur.extend Types()
      end

      # @overload search('app/models')
      #   Returns all files for loaded services under `[service]/app/models`
      # @overload search('config/locales', '**/*.{rb,yml}')

      # @param [String] args
      # @return [Array<String>]
      def search(*args)
        Dir[*paths_glob(*args)]
      end

      private

        # Extract object types from existent sub directories under {#target}
        # @return [Array<String>]
        def extract_types
          files.map do |_, paths|
            paths
              .select { |f| f.start_with?(target) }
              .map { |f| f =~ type_matcher && $1 }
          end
            .flatten
            .uniq
            .compact
        end

        # @return [Regexp]
        def type_matcher
          /#{target}\/([\w\-_]+)\//
        end

        # Return an array of paths where `dir` exists -- relative to railtie root, and
        # appends `glob` pattern to each.
        # @param [String] dir
        # @param [String] glob
        # @return [Array<Pathname>] absolute path per railtie where `dir` exists
        # @return [Array<Pathname>] if `glob` given, appends `glob` pattern to absolute path
        def paths_glob(dir, glob = '**/*.rb')
          @services.map do |service|
            next unless (path = service.path.join(dir)).directory?
            path.join(glob.to_s)
          end.compact
        end

        # @param [String] type
        # @return [Array]
        def group_by_type(type)
          arr = []
          files.each do |root, paths|
            paths.each do |f|
              next unless f =~ /\A#{target}\/#{type}(?!\/concerns)/
              path = File.join(root, f)
              arr << path if File.file?(path)
            end
          end
          arr.sort!
        end

        # Adds context aware helpers returning combined file list per object type
        # @return [Module]
        def Types(context = self) # rubocop:disable MethodName
          Module.new do
            context.types.each do |type|
              files = context.send(:group_by_type, type).freeze
              define_method(type) { files }
            end

            files = context.search('config/locales', '**/*.{rb,yml}').sort!.freeze
            define_method(:locales) { files }
          end
        end

    end

  end

end
