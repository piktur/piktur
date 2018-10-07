#!/usr/bin/env ruby
# frozen_string_literal: true

require 'thor'
require 'piktur/support/inflector'

class Git::Move < Thor::Group

  NOOP = { force: false, noop: true, verbose: true }.freeze

  desc 'Move a group of files FROM TO [options]'

  argument :from, desc: 'The source path'
  argument :to, desc: 'The destination path'

  class_option :glob, default: '**/*'
  class_option :force, default: false
  class_option :noop, default: true
  class_option :versbose, default: true

  def call
    return unless ::File.exist?(::File.expand_path(from, ::Dir.pwd))

    glob   = ::Dir["#{from}/#{glob}"]
    dirs   = directories(glob)
    files  = files(glob)

    dirs.zip(destination(from, to, dirs)).each do |(from, to)|
      run "mkdir -pv #{to}"
      git mv: "-k #{from}/* #{to} #{prepare_options}"
    end

    files.zip(destination(from, to, files)).each do |(from, to)|
      git mv: "-k #{from} #{to} #{prepare_options}"
    end
  end

  private

    def prepare_options
      options = ENV['DEBUG'] ? NOOP : self.options
      str = ::String.new('-')
      str << 'f' if options[:force]
      str << 'n' if options[:noop]
      str << 'v' if options[:verbose]
      str
    end

    def directories(glob)
      glob.select { |path| ::File.directory?(path) }
    end

    def files(glob)
      glob.reject { |path| ::File.directory?(path) }
    end

    def destination(from_root, to_root, paths) # rubocop:disable MethodLength
      paths.map do |path|
        *, rel = path.partition(from_root + ::File::SEPARATOR)
        if ::File.directory?(path)
          segments = rel.split('/').map { |e| Support::Inflector.pluralize(e) }
        elsif ::File.file?(path)
          if path.end_with?('_spec.rb')
            segments = Support::Inflector.pluralize(rel.sub('_spec.rb', ''))
            segments << '_spec.rb'
          end
        end

        [to_root, *(segments || rel)].join(::File::SEPARATOR)
      end
    end

end
