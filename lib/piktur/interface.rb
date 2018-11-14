# frozen_string_literal: true

module Piktur

  # :nodoc
  module Interface

    # Avoid explicit calls to `Piktur`, instead assign `base` to root scope and Use
    # this alias `NAMESPACE` to reference the dependent's namespace.
    #
    # @param [Module]
    #
    # @return [void]
    def self.extended(base) # rubocop:disable MethodLength
      ::Object.const_set(:NAMESPACE, base)

      base.extend Logger
      base.extend Debugger
      base.extend Environment::Predicates

      require_relative ::File.expand_path('./container.rb', __dir__)
      base.extend Container::Mixin
      base.extend Container::Delegates

      require_relative ::File.expand_path('./types.rb', __dir__)
      require_relative ::File.expand_path('./config.rb', __dir__)

      base.extend Config::Delegates
      base.extend Services::Delegates
    end

    # @return [void]
    def setup!
      return unless ENV['DISABLE_SPRING']

      ::Bundler.require(:default, :test, :benchmark)
    end

    # @return [void]
    def boot!(*)
      true
    end

    # Returns absolute path to root directory
    #
    # @return [Pathname]
    def root; Pathname(__dir__).parent; end

    # @return [Plugins::Registry]
    def plugins; @plugins ||= self::Plugins::Registry.new; end

    # @return [Container::Aggregate]
    def __container__
      @__container__ ||= Container::Aggregate.new # rubocop:disable MemoizedInstanceVariableName
    end

  end

end
