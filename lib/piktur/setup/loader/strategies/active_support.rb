
# frozen_string_literal: true

module Piktur

  module Loader

    class ActiveSupport

      include Base

      self.default_proc = lambda do |file|
        begin
          require_dependency(file)
        rescue NameError, LoadError => error
          ::Piktur.debug(binding, error: error)
        end
      end

    end

  end

end

