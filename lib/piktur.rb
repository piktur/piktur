# frozen_string_literal: true

require 'pathname'
%w(
  dependencies/autoload
  core_ext/string/inquiry
  core_ext/object/blank
  core_ext/hash/keys
  core_ext/module/delegation
).each { |f| require "active_support/#{f}" }

# Reusable configuration and utility modules for Piktur applications.
# Use {.install} to expose this interface within your application.
#
# @see https://trello.com/c/gcytwRuV/79-decouple-core-dependencies
# @see https://bitbucket.org/piktur/piktur_core/issues/21
module Piktur

  extend ::ActiveSupport::Autoload

  autoload :Cache, 'piktur/support/cache'
  autoload :Config
  autoload :Constants
  autoload :Container
  autoload :Configurable
  autoload :DEBUGGER, 'piktur/debugger'
  autoload :Deprecation
  autoload :Environment
  autoload :Errors
  autoload :EventedFileUpdateChecker
  autoload :Interface
  autoload :Loader
  autoload :Logger
  autoload :Plugin
  autoload :Plugins
  autoload :Reloader
  autoload :Registry
  autoload :Support
  autoload :Secrets
  autoload :Services
  autoload :Types

  # @note You should really restart Spring before switching environments.
  defined?(::Spring) && ::Spring.after_fork do
    # Reset singleton Environment instance.
    safe_remove_const(:Environment)
    ::Kernel.load(::File.expand_path('./piktur/environment.rb', __dir__))

    ::NAMESPACE.remove_instance_variable(:@logger)
  end

  require_relative ::File.expand_path('./piktur/environment.rb', __dir__)
  require_relative ::File.expand_path('./piktur/debugger.rb', __dir__)

  Constants.install

  Support.install(:inflector)

  private_constant :Interface
  extend Interface if ::File.basename(::Dir.pwd).start_with?('piktur')

  # @todo Implement production ready Secrets management.
  #   Use /bin/env in non-prouction enviroments to load ENV variables from **untracked**
  #   local files.
  # Secrets.overload

  # @param [Module] base
  # @param [Array<Symbol, String>] args A list of constants to be aliased
  #
  # @return [void]
  def self.install(base, *args, containerize: false) # rubocop:disable MethodLength
    base.extend Interface

    eager_load!

    ::Set[
      :Support,
      :Environment,
      :Deprecation,
      :DEBUGGER,
      :Errors,
      :Logger,
      :Config,
      *args.map(&:capitalize)
    ].each do |const|
      if const == :Config
        base.safe_const_set(:Config, ::Class.new(Config))
      else
        base.safe_const_set(const, const_get(const))
      end
    end

    base.include Constants
    base.extend Container::Mixin if containerize
  end

end
