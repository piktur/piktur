# frozen_string_literal: true

module Piktur::Config::Delegates # rubocop:disable ClassAndModuleChildren, Documentation

  # @return [void]
  def configure(&block); self::Config.configure(&block); end

  # @return [Config]
  def config; self::Config.config; end

  # @example
  #   components_dir(::Rails.root) # => <Pathname:/root/app/concepts>
  #   components_dir               # => <Pathname:app/concepts>
  #
  # @see Config.components_dir
  #
  # @param [Pathname] root
  #
  # @return [Pathname] the relative path of the components directory
  # @return [Pathname] if `root` the absolute path of the components directory from root
  def components_dir(root = nil)
    root ? config.components_dir.expand_path(root) : config.components_dir
  end

  # @see Config.component_types
  #
  # @return [Array<Symbol>] A list of the component types implemented
  def component_types; config.component_types; end

end
