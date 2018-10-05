# frozen_string_literal: true

module Piktur

  module Loader

    # Implements loading mechanism utilising `ActiveSupport::Dependencies.require_dependency`.
    #
    # @example
    #   Namespace = Module.new do
    #     extend Loader::Ext
    #     load()
    #   end
    #
    # @note It is expected that:
    #   * files located under `app/models` or files named `model.rb` define a "model" and the
    #     definition is assigned to a constant matching the file or directory name.
    #   * {Filters#target} must also be added to `ActiveSupport::Dependencies.autoload_paths`.
    #
    #   Constants with a name other from that of the file **MUST** be added to the list of
    #   `explicitly_unloadable_constants`, if not, the file name cannot be inferred from the
    #   constant and will not be cleared for reload.
    #
    #   Model constants, and other known deviances, are flagged in {Piktur.before_class_unload}.
    #
    # @see https://bitbucket.org/piktur/piktur/wiki/Structure.markdown#Components
    #
    # ## On `Rails` constant reloading
    #
    # By default `Rails` adds all `/app/**` direcotries to `Application.config.eager_load_paths`.
    # Constants defined under `._all_autoload_paths` are loaded during
    # `Rails.application.initialize!`, or lazy loaded to reduce boot time in development.
    #
    # In non-production environments, if `Rails.configuration.reload_classes_only_on_change`
    # is true constants will be cleared on `Rails.application.reloader.reload!`.
    #
    # If a specific load sequence specific required, use
    # `ActiveSupport::Dependencies.require_dependency` instead of `require`.
    #
    # ### Regarding `/lib`
    #
    # Possible, though a *transgression* -- code under `lib` is expected to be run once on boot.
    # If you must reload constants under `/lib` add the relevant path(s) to `config.watchable_dirs`.
    #
    # ```ruby
    #   # lib/namespace/to_reload.rb
    #   module Namespace
    #     extend ActiveSupport::Autoload
    #     autoload :ToReload
    #
    #     module ToReload
    #       LOADED_AT = Time.zone.now
    #     end
    #   end
    #
    #   # app/models/with_requirements.rb
    #   require_dependency 'namespace/to_reload.rb'
    #   class WithRequirements; end
    #
    #   > time_at_initial_load = Namespace::ToReload::LOADED_AT
    #   # Edit app/models/with_requirements.rb
    #   > reload!
    #   > time_at_initial_load < Namespace::ToReload::LOADED_AT # => true
    # ```
    #
    # This technique will only work when used in conjuction with `require_dependency` and the
    # constants are added to `ActiveSupport::Dependencies.explicitly_unloadable_constants`.
    #
    # @see https://bitbucket.org/piktur/piktur_core/src/master/lib/piktur/engine/paths.rb
    # @see http://ileitch.github.io/2012/03/24/rails-32-code-reloading-from-lib.html
    # @see http://guides.rubyonrails.org/autoloading_and_reloading_constants.html
    # @see http://blog.plataformatec.com.br/2012/08/eager-loading-for-greater-good/
    class ActiveSupport

      include Loader::Base

      self.use_relative = true

      self.default_proc = lambda do |file|
        require_dependency(file)
      rescue ::NameError, ::LoadError => err
        ::NAMESPACE.debug(binding, error: err)
      end

      # @overload target=(path)
      #   Must be one of `ActiveSupport.autoload_paths`

      # @param [Hash] options
      #
      # @option options [String] :path (nil)
      # @option options [Symbol] :type (nil)
      #
      # @raise [LoadError]
      #
      # @return [Array<String>] A list of loaded paths
      def call(path: nil, type: nil, **options)
        # @example Prefetch (disabled -- likely unnecessary)
        #
        #   index! unless booted?
        return load_type!(type, options) if type

        loaded = path ? load_path!(path, options) : load_all!(options)
        debug(loaded)
      rescue ::LoadError => err
        ::NAMESPACE.debug(binding, error: err)
      end
      alias [] call

    end

  end

end
