# frozen_string_literal: true

require_relative './evented_file_update_checker.rb'

module Piktur

  # @todo Reloader should be made redundant by incomoing {Loader} implementation
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

    # @note Extracted model namespace loading so that it occurs before SetupReloader on every
    #   fork, not just when watched files changed. This is to ensure any top level configuration is
    #   applied before nested constants loaded. Seems heavy handed, alternatively we could load
    #   parent concept before any nested concept. But time... none!
    #
    #
    #
    # REWRITE COMMENTS
    #
    #
    #
    def before(*)
      ::Piktur.load!
    rescue LoadError => error
      ::Piktur.debug(binding, warn: "Did you set the correct name for the namespace in Piktur::Config#namespaces?")
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
        a[path] = ['rb']
      end
    end
    private_class_method :paths

  end

end
