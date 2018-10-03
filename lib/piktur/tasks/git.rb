# frozen_string_literal: true

require 'fileutils'
require_relative 'support/inflector'

module Piktur

  module Git

    NOOP = { force: false, noop: true, verbose: true }.freeze

    module_function

    # call('spec/models', 'spec/concepts' '**/*', force: false, noop: true, verbose: true)
    def call # rubocop:disable MethodLength
      command = ::ARGV.shift.to_sym
      args    = nil
      options = ::ARGV[-1].start_with?('-') ? ::ARGV.pop : ::String.new('-')

      case command
      when :mv
        from = ::ARGV.shift
        to   = ::ARGV.shift
        glob = ::ARGV.shift || '**/*'
        args = [from, to, options, glob: glob]

        return unless ::File.exist?(::File.expand_path(from, ::Dir.pwd))
      end

      public_send(command, *args) if respond_to?(command)
    end

    def mv(from_root, to_root, options, glob: '**/*')
      glob   = ::Dir["#{from_root}/#{glob}"]
      dirs   = directories(glob)
      files  = files(glob)

      dirs.zip(destination(from_root, to_root, dirs)).each do |(from, to)|
        `mkdir -pv #{to}`
        `git mv -k #{from}/* #{to} #{options}`
      end

      files.zip(destination(from_root, to_root, files)).each do |(from, to)|
        `git mv -k #{from} #{to} #{options}`
      end
    end

    def options(_input, git: true)
      options = NOOP if ENV['DEBUG']
      str = ::String.new('-')
      str << 'f' if options[:force]
      str << 'n' if options[:noop]
      str << 'v' if options[:verbose]
      # git, ruby
    end
    private_class_method :options

    def directories(glob)
      glob.select { |path| ::File.directory?(path) }
    end
    private_class_method :directories

    def files(glob)
      glob.reject { |path| ::File.directory?(path) }
    end
    private_class_method :files

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
    private_class_method :destination

  end

end
