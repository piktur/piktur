# frozen_string_literal: true

module Piktur

  module Services

    # The FileIndex is an aggregate of all files exposed through each service's `.gemsepec`.
    #
    # @note Use `Dir.glob(<pattern>, base: __dir__)` when declaring `Gem::Specification#files`.
    #   This ensures the file list is scoped to the gem's root. Failure to do so will apply the
    #   given patterns to the current working directory.
    #
    # @note FileIndex **MAY NOT** reflect the current state of the directory structure.
    class FileIndex

      # @!attribute [r] root_directories
      #   @return [Array<Pathname>]
      attr_reader :root_directories

      # @!attribute [r] files
      #   A Hash mapping the service to a Files object
      #   @return [Hash{String=>Files}]
      attr_reader :files

      # @param [Array<Services::Service>] services
      def initialize(services)
        @root_directories = services.map(&:root)
        @files = _build_file_index(services)

        freeze
      end

      alias all files

      # @return [String]
      def inspect
        # services = root_directories
        #   .map { |e| "\"#{e.instance_variable_get(:@path)[/\/piktur_\w+(?:|-)/]}\"" }
        "#<FileIndex count=#{files.size}>"
      end

      # @return [void]
      def pretty_print(pp); pp.text inspect; end

      private

        # Returns a list of all (absolute) paths listed in the loaded gem specs.
        #
        # @return [Array<String>]
        def _build_file_index(services)
          services.flat_map do |service|
            service.gemspec.files.map { |f| ::File.expand_path(f, service.path) }
          end
        end

    end

  end

end
