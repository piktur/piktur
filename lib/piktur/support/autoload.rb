# frozen_string_literal: true

module Piktur

  module Support

    # @example enable autoloading of all files under a namespace. Select or reject files with  `.only` or `.except`
    #   base.filter_file_list.each do |path|
    #     const = File.basename(path, '.rb').classify
    #     base.autoload const.to_sym, "#{base.name}::#{const}".underscore
    #   end
    #
    # @note Do not use `ActiveSupport::Autoload` to load required constants. Previous iterations
    #   overloaded `ActiveSupport::Autoload.eager_load!` so that files were loaded with
    #   `ActiveSupport::Dependencies.require_dependency` rather than the default `Module.require`.
    #   This approach is not Rails compliant.
    module Autoload

      # @param [Class, Module] base
      # @return [void]
      def self.extended(base)
        base.extend ActiveSupport::Autoload
        # Autoload all files under namespace
        # base.filter_file_list.each do |path|
        #   const = File.basename(path, '.rb').classify
        #   base.autoload const.to_sym, "#{base.name}::#{const}".underscore
        # end
      end

      # List files under namespace
      # @see file:spec/benchmark/file_system.rb Benchmark: Rake::FileList vs Dir.glob
      # @return [Rake::FileList]
      def file_list(root = Piktur.root) # Piktur::Engine.paths['app/models'].first
        @_file_list ||= Rake::FileList[File.join(root, name.underscore, '*.rb')]
      end

      # @return [Rake::FileList]
      def filter_file_list
        if respond_to?(:only) && only.present?
          return file_list.select { |f| f =~ Regexp.union(only) }
        elsif respond_to?(:except) && except.present?
          return file_list.reject { |f| f =~ Regexp.union(except) }
        end

        file_list
      end

    end

  end

end
