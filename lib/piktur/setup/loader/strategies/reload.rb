# frozen_string_literal: true

module Piktur

  module Loader

    # Shouldn't be necessary to {Filter#_rescan} on change since only the {Store#globber} is
    # cached. When the globber is called, the return value will always reflect the current state
    # of the directory. A globber will be generated and cached for any new path during the call
    # to {#load_path!}
    #
    #   _, added, = changed
    #   added.each { |path| _rescan(path) } if added.present?
    #   modified.each { |path| _rescan(path) } if modified.present?
    #   removed.each { |path| _rescan(path) } if removed.present?
    module Reload

      protected

        # @param [Array<(Array, Array, Array)>] changed The changed paths
        #   1. `modified`
        #   2. `added`
        #   3. `removed`
        #
        # @return [void]
        def reload!(changed)
          return if changed.all?(&:blank?)

          changed.each do |group|
            group.each do |path|
              load_path!(
                Path.relative_path_from_target(path, target),
                pattern: Filter::NAMESPACE_PATTERN,
                force:   true
              )
            end
          end
        end

    end

  end

end
