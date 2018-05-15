# frozen_string_literal: true

module Piktur

  VERSION = '0.0.1'

  def self.rails_version; ENV.fetch('RAILS_VERSION'); end

  def self.ruby_version; ENV.fetch('RUBY_VERSION').sub('ruby-', ''); end

end
