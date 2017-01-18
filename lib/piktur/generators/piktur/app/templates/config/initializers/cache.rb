# frozen_string_literal: true

Rails.cache.logger = Logger.new(STDOUT) if Rails.env.development?
