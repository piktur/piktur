# frozen_string_literal: true

module Piktur

  module Loader

    # @deprecated
    #   Shouldn't be necessary to {Index#_rescan} on change since only the {Filter#call} is
    #   cached. When the query is called, the list of files will always be current.
    #   The query will be cached for any new path when {Load#load} called.
    #
    # @see Reloader
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

          # _, added, = changed
          # added.each { |path| _rescan(path) } if added.present?
          # modified.each { |path| _rescan(path) } if modified.present?
          # removed.each { |path| _rescan(path) } if removed.present?

          changed.each do |group|
            group.each do |path|
              load_path!(Path.rpartition(path, target)[-1], force: true)
            end
          end
        end

    end

  end

end
