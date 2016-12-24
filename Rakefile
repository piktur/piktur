# frozen_string_literal: true

require 'piktur/docs'

namespace :yard do
  libs = Dir[Piktur.root.join('piktur_*')]
    .select! { |e| File.directory? e }
    .collect! { |e| File.basename(e) }

  # @see YARD::CLI::YardoptsCommand#parse_arguments
  defaults = %w(
    --verbose
    --backtrace
    --debug
    --protected
    --private
    --embed-mixins
    --hide-void-return
    --use-cache
    --markup
    markdown
    --markup-provider
    redcarpet
    --load
    lib/piktur.rb
    --exclude
    db/migrate/**
    --exclude
    spec/**
  )
  # Frozen string literal seems to break this
  # --single-db
  # --use-cache

  desc 'Generate YARD Documentation for all libraries'
  # @example
  #   rake yard
  #   rake yard OPTS='--override --default --opts'
  # @see file:.yardopts
  YARD::Rake::YardocTask.new do |t|
    options = defaults.dup
    options.unshift('--db', '.yardoc')

    t.name    = :all
    t.options = defaults
    t.files   = %w(
      piktur_core
      piktur_api
      lib
      -
      docs/**/README.markdown
    )
    # t.files = libs << ./lib

    t.stats_options = %w(--list-undoc)
  end

  libs.each do |lib|
    desc "Generate YARD Documentation for #{lib}"
    YARD::Rake::YardocTask.new do |t|
      path    = Piktur::Docs.root.relative_path_from(Piktur.root).join(lib) # Pathname.new(lib)
      options = defaults.dup
      options.push('--output-dir', "docs/#{lib}")

      yardoc = path.join('.yardoc')
      options.unshift('--db', yardoc.to_s)

      if (yardopts = path.join('.yardopts')).exist? # File.exist?("#{path}/.yardopts")
        yardopts.each_line.with_object(options) do |e, a|
          a.push(*e.split(/\s/))
        end
      end

      t.name          = lib.split('piktur_')[-1]
      t.files         = [lib, '-', "#{lib}/README.markdown"]
      t.options       = options
      t.stats_options = %w(--list-undoc)
      # t.before        = lambda do
      #   (libs - [lib]).select do |e|
      #     yardoc = "docs/#{e}/.yardoc"
      #     # YARD::Registry.load_yardoc(yardoc) if File.exist?(yardoc)
      #     YARD::Registry.load!(yardoc) if File.exist?(yardoc)
      #   end
      # end
    end
  end
end
