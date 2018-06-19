# frozen_string_literal: true

require_relative './evented_file_update_checker.rb'

module Piktur

  # @deprecated Superceded by {Loader} implementation
  #
  # Configure {Piktur.component_dir} reloading
  module Reloader

    module_function

    # @param [Rails::Application] app
    #
    # @see https://rmosolgo.github.io/blog/2017/04/12/watching-files-during-rails-development/
    # @see https://bitbucket.org/piktur/piktur_core/issues/39 Ensure absolute control of reloading
    #
    # @return [void]
    def call(app)
      reloader = self.reloader
      app.reloaders << reloader

      app.reloader.to_run do
        ::Piktur::Reloader.before
        reloader.execute_if_updated # { require_unload_lock! }
      end

      true
    end

    # Returns a new reloader instance with a pid matching that of the forked process.
    #
    # @return [Piktur::EventedFileUpdateChecker]
    def reloader
      ::Piktur::EventedFileUpdateChecker
        .new([], paths) { |changes| ::Piktur::Reloader.on_change(changes) }
        .instance_exec { @pid = Process.pid if @pid != Process.pid; self }
    end

    # :nodoc
    def before(*)
      ::Piktur.load!
    rescue LoadError => error
      ::Piktur.debug(binding, warn: <<~WARN)
        Did you set the correct name for the namespace in Piktur::Config#namespaces?
      WARN
    end

    # @param [Array] changes An Array containing `changed`, `added` and `deleted` file lists.
    #
    # @return [void]
    def on_change(changes)
      if changes
        ::Piktur.loader.reload!(changes)
        ::Piktur.to_complete
      end

      true
    end

    def after(*); end

    # Returns a Hash mapping autoload paths to extensions for each {Piktur.railties} where
    # {Piktur.component_dir} exists.
    #
    # @return [Hash{Pathname=>[String]}]
    def paths
      ::Piktur.railties.each_with_object({}) do |railtie, a|
        # @note Piktur::Store::Engine hasn't been loaded yet
        path = ::Piktur.components_dir(root: railtie.root)
        next unless path.exist?
        # BuildFileList[path, files]
        a[path] = %w(rb)
      end
    end
    private_class_method :paths

  end

end
