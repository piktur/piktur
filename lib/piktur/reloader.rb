# frozen_string_literal: true

require_relative './evented_file_update_checker.rb'

module Piktur

  # @deprecated ActiveSupport::Dependencies will clears all previously loaded constants on
  #   `Rails.application.reloader.reload!`. Reloader is redundant as long as:
  #   * `Rails.configuration.reload_classes_only_on_change` is true
  #   * {Interface#loader} {Loader#target} is autoloadable
  #   * components within {Loader#target} are defined within their own file
  #     and the file is named accoding to the constant defined within it
  #   * any constant(s) not inferrable from an autoloadable path **IS** added to
  #     `ActiveSupport::Dependencies.explicitly_unloadable_constants`
  #   * if necessary, load order **SHOULD** be declared by an **index** `<namespace>.rb`
  #     located under {Interface#components_dir}; the index **MUST** be loaded before
  #     references to constants within its scope.
  #
  # A conservative {Reloader} watches a directory for changes reloading changed files if
  # `Pathname('<NAMESPACE.components_dir>/<namespace>').children` modified.
  # If using {Reloader}, eager loading **SHOULD** be disabled for the
  # {Interface#components_dir}.
  #
  # @see EventedFileUpdateChecker
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
        reloader.execute_if_updated # { require_unload_lock! }
      end

      true
    end

    # Returns a new reloader instance with a pid matching that of the forked process.
    #
    # @return [EventedFileUpdateChecker]
    def reloader
      ::Piktur::EventedFileUpdateChecker
        .new([], paths) { |changes| ::Piktur::Reloader.on_change(changes) }
        .instance_exec { @pid = ::Process.pid if @pid != ::Process.pid; self }
    end

    # @param [Array] changes An Array containing `changed`, `added` and `deleted` file lists.
    #
    # @return [void]
    def on_change(changes)
      if changes
        ::NAMESPACE.loader.reload!(changes)
        ::NAMESPACE.to_complete
      end

      true
    end

    def after(*); end

    # Returns a Hash mapping autoload paths to extensions for each {Interface#railties}
    # where {Interface#components_dir} exists.
    #
    # @return [Hash{Pathname=>[String]}]
    def paths
      ::NAMESPACE.loader.root_directories.each_with_object({}) { |path, a| a[path] = %w(rb) }
    end
    private_class_method :paths

  end

end
