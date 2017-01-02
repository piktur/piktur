# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'
require 'rails/generators/app_base'

module Piktur

  include Rails::ActionMethods

  # @see http://edgeguides.rubyonrails.org/rails_application_templates.html
  module Generators

    # @return [String]
    RAILS_DEV_PATH = Rails::Generators::RAILS_DEV_PATH

    # @return [Array]
    RESERVED_NAMES = Rails::Generators::RESERVED_NAMES

    # @see Rails::AppBuilder
    class AppBuilder < Rails::AppBuilder

      require_relative '../../../piktur/deployment'
      include Deployment

      # @see Thor::Actions::ClassMethods#run
      # def run(command, config = {})
      #   config[:verbose] = false
      #   config[:pretend] ||= false
      #   config[:capture] ||= false
      #   super
      # end

      # @example
      #   export ROOT=/Users/daniel/Documents/webdev/current_projects/piktur
      #   export CACHE=$ROOT/vendor/cache
      #
      #   bundle config --local local.piktur_core $ROOT
      #   bundle config --local local.amoeba $CACHE/amoeba
      #   bundle config --local local.annotate $CACHE/annotate_models
      #   bundle config --local local.awesome_print $CACHE/awesome_print
      #   bundle config --local local.yard $CACHE/yard
      #
      #   unset ROOT
      #   unset CACHE
      #   @return [void]
      #
      def setup
        # Fetch core gem dependencies from remote repository
        run <<~EOS
          curl https://#{ENV['BUNDLE_BITBUCKET__ORG']}@bitbucket.org/piktur/piktur_core/raw/master/piktur_core/Gemfile -o #{destination_root}/Gemfile.core
        EOS

        run "bundle config --local local.piktur_core #{Piktur.root}"

        # Setup local source for git repositories
        cache = Piktur.root.join('vendor/cache')
        %w(amoeba annotate awesome_print yard).each do |e|
          run "bundle config --local local.#{e} #{cache.join(e)}"
        end

        after_bundle do
          create_local_repo
          create_remote_repo
          push_to_remote_repo

          link_ci_server

          create_staging_server
          set_server_env 'staging', '.env.common', '.env.staging'

          deploy_to_staging_server

          create_production_server
          set_server_env 'production', '.env.common', '.env'

          domain_alias

          checkout_development_branch
        end
      end

      # @!group Directory Structure

      # @return [void]
      def readme
        template 'README.markdown'
      end

      # @return [void]
      def ruby
        create_file '.ruby-gemset', 'piktur'
        create_file '.ruby-version', '2.3.0'
      end

      # @return [void]
      def rakefile
        super
      end

      # @return [void]
      def gemfile
        super
      end

      # @return [void]
      def configru
        super
      end

      # @return [void]
      def gitignore
        template 'gitignore'
      end

      # @return [void]
      def app
        super
      end

      # @return [void]
      def bin
        super
      end

      # @return [void]
      def config
        empty_directory 'config'

        inside 'config' do
          template 'application.rb'
          template 'environment.rb'
          template 'newrelic.yml'
          template 'puma.rb'
          template 'routes.rb'
          template 'secrets.yml'
          template 'sidekiq.yml'

          directory 'environments'
          directory 'initializers'
          directory 'locales'
        end
      end

      # @return [void]
      def config_when_updating
        super
      end

      # @return [void]
      def database_yml
        template 'config/database.yml'
      end

      # @return [void]
      def db
        directory 'db'
      end

      # @return [void]
      def lib
        empty_directory 'lib'
        empty_directory_with_keep_file 'lib/tasks'
        empty_directory_with_keep_file 'lib/assets'

        inside 'lib' do
          bootstrap
          railtie
          version
        end
      end

      # @return [void]
      def bootstrap
        create_file "piktur_#{app_name}.rb", <<~RUBY
          # frozen_string_literal: true

          module Piktur

            module #{app_const_base}

            end

          end

          require_relative "./piktur/#{app_name}/railtie" if defined?(Rails)
        RUBY

        create_file "piktur/#{app_name}.rb", <<~RUBY
          # frozen_string_literal: true

          module Piktur

            module #{app_const_base}

            end

          end
        RUBY
      end

      # @return [void]
      def railtie
        create_file "piktur/#{app_name}/railtie.rb", <<~RUBY
          # frozen_string_literal: true

          module Piktur

            module #{app_const_base}

              class Railtie < ::Rails::Railtie

                initializer :set_app_glob, before: :set_load_path do |app|
                  app.paths['app'].glob = '{*,*/concerns,*/piktur/api/v*}'
                end

              end

            end

          end
        RUBY
      end

      # @return [void]
      def version
        create_file "piktur/#{app_name}/version.rb", <<~RUBY
          # frozen_string_literal: true

          module Piktur

            module #{app_const_base}

              VERSION = '0.0.1'

            end

          end
        RUBY
      end

      # @return [void]
      def gemspec
        create_file "piktur_#{app_name}.gemspec", <<~RUBY
          # frozen_string_literal: true
          # rubocop:disable Metrics/BlockLength

          $LOAD_PATH.push File.expand_path('./lib', __dir__)

          # Maintain your gem's version:
          require 'piktur/#{app_name}/version'

          # Describe your gem and declare its dependencies:
          Gem::Specification.new do |s|
            s.name        = "piktur_#{app_name}"
            s.version     = Piktur::#{app_const_base}::VERSION
            s.authors     = ['Daniel Small']
            s.email       = ["#{ENV['EMAIL']}"]
            s.homepage    = 'https://bitbucket.org/piktur/piktur_#{app_name}'
            s.summary     = "Piktur a complete Portfolio Management System for Artists"
            s.description = "Piktur::#{app_name.classify} provides"
            s.license     = ''
            s.bindir      = 'bin'
            s.files = Dir[
              '{app,db,config,lib}/**/*',
              'Rakefile',
              'README.markdown'
            ]
            s.test_files = Dir['spec/**/*.rb']
          end
        RUBY
      end

      # @return [void]
      def log
        super
      end

      # @return [void]
      def public_directory
        directory 'public'
      end

      # @return [void]
      def test
        directory 'spec'

        inside 'spec' do
          %w(
            controllers
            factories
            features
            fixtures
            lib
            models
            requests
            routing
            serializers
            support
          ).each(&:directory)

          %w(controllers models requests routing serializers).each do |dir|
            create_file "support/#{dir}/shared_examples.rb", <<~RUBY
              require 'rails_helper'

              # RSpec.shared_context <INSERT NAME> do
              # end

              # RSpec.shared_examples <INSERT NAME> do
              # end
            RUBY
          end

          create_file 'support/test_helpers.rb', <<~RUBY
            module Piktur

              module Support

                # @example
                #   https://bitbucket.org/piktur/src/master/piktur_core/lib/piktur/spec/support/test_helpers.rb
                module TestHelpers

                end

              end

            end
          RUBY
        end
      end

      # @return [void]
      def tmp
        super
      end

      # @return [void]
      def vendor
        super
      end

      # @return [void]
      def vendor_javascripts
        super
      end

      # @return [void]
      def vendor_stylesheets
        super
      end

      # Copies environment variables from `Piktur.root`
      # @note Or otherwise provision blank template
      # @return [void]
      def env
        puts <<~EOS
          DEPRECATED: Do not duplicate environment variables across apps.
          Refer to variables defined at `~/webdev/current_projects/piktur/.env*` instead.
        EOS

        # %w(
        #   .env
        #   .env.common
        #   .env.development
        #   .env.staging
        #   .env.test
        # ).each do |f|
        #   vars = `cat #{Piktur.root.parent.join(f)}`
        #   create_file f, vars
        #   # Set environment variables
        #   # `export #{vars}`
        # end
      end

      # @return [void]
      def leftovers
        ruby
        %w(circle.yml Procfile).each { |f| template f }
        %w(rspec rubocop.yml).each { |f| template ".#{f}" }
        create_file '.yardopts', ''
      end

      # @!endgroup

    end

    # @example
    #   cd ~/Documents/webdev/current_projects/piktur
    #   bin/piktur new <name>
    #
    # @example Using custom template with Rails app generator
    #   # lib/generators/piktur/app/template.rb
    #
    #   # frozen_string_literal: true
    #   # Add `./template` files to source_paths
    #   Rails::Generators::AppGenerator.class_eval do
    #     # source_root File.expand_path('template', __dir__)
    #     def source_paths
    #       super.unshift File.expand_path('template', __dir__)
    #     end
    #   end
    #
    #   template 'README.markdown'
    #
    #   # $ rails new <app_name> --template https://${BUNDLE_BITBUCKET__ORG}@bitbucket.org/piktur/piktur_core/raw/master/lib/generators/piktur/app/template.rb
    #
    # @note It may be worth incorporating `Rails::Generators::NamedBase` to manage constants
    #   namespaces
    class AppGenerator < Rails::Generators::AppGenerator

      require 'dotenv'

      Dotenv.overload(*%w(common development).map! { |f| Piktur.root.parent.join(".env.#{f}") })

      class_option :deploy, type: :boolean, aliases: '-v', group: :rails,
                            desc: 'Show Rails version number and quit'

      class << self

        # Execute actions in the defined order
        # @see Thor::Base::ClassMethods
        # @return [Boolean]
        def strict_args_position
          true
        end

        protected

          # @return [String]
          def banner
            "piktur new #{arguments.map(&:usage).join(' ')} [options]"
          end

      end

      def initialize(*args)
        super

        unless app_path
          raise Error, "Application name should be provided in arguments. For details run: rails --help"
        end

        options[:database] ||= 'postgresql'

        if !options[:skip_active_record] && !DATABASES.include?(options[:database])
          raise Error, "Invalid value for --database option. Supported for preconfiguration are: #{DATABASES.join(", ")}."
        end
      end

      source_root File.expand_path('template', __dir__)

      # @return [String, nil]
      def set_default_accessors!
        self.destination_root = File.expand_path("piktur_#{app_name}", destination_root)
        self.rails_template =
          case options[:template]
          when /^https?:\/\//
            options[:template]
          when String
            File.expand_path(options[:template], Dir.pwd)
          else
            options[:template]
          end
      end

      # @!group Actions

      public_task :create_root

      # @return [void]
      def create_root_files
        build(:setup)
        build(:gemspec)
        super
      end

      # @return [void]
      def create_app_files
        build(:app)
      end

      # @return [void]
      def create_bin_files
        build(:bin)
      end

      # @return [void]
      def create_config_files
        build(:config)
      end

      # @return [void]
      def update_config_files
        build(:config_when_updating)
      end
      remove_task :update_config_files

      # @return [void]
      def create_boot_file
        template 'config/boot.rb'
      end

      # @return [void]
      def create_active_record_files
        return if options[:skip_active_record]
        build(:database_yml)
      end

      # @return [void]
      def create_db_files
        build(:db)
      end

      # @return [void]
      def create_lib_files
        build(:lib)
      end

      # @return [void]
      def create_log_files
        build(:log)
      end

      # @return [void]
      def create_public_files
        build(:public_directory)
      end

      # @return [void]
      def create_test_files
        build(:test) unless options[:skip_test_unit]
      end

      # @return [void]
      def create_tmp_files
        build(:tmp)
      end

      # @return [void]
      def create_vendor_files
        build(:vendor)
      end

      # @return [void]
      def delete_js_folder_skipping_javascript
        remove_dir 'app/assets/javascripts' if options[:skip_javascript]
      end

      # @return [void]
      def delete_assets_initializer_skipping_sprockets
        remove_file 'config/initializers/assets.rb' if options[:skip_sprockets]
      end

      # @return [void]
      def finish_template
        build(:env)
        build(:leftovers)
      end

      public_task :apply_rails_template, :run_bundle
      public_task :generate_spring_binstubs

      # @return [void]
      def run_after_bundle_callbacks
        @after_bundle_callbacks.each(&:call)
      end

      # @!endgroup

      protected

        # @return [void]
        def gemfile_entries
          [
            # rails_gemfile_entry,
            # database_gemfile_entry,
            assets_gemfile_entry,
            javascript_gemfile_entry,
            # jbuilder_gemfile_entry,
            # sdoc_gemfile_entry,
            # psych_gemfile_entry,
            @extra_entries
          ].flatten.find_all(&@gem_filter)
        end

        # @return [String]
        def app_name
          @app_name ||=
            if defined_app_const_base?
              defined_app_name
            else
              File.basename(app_path)
            end.tr('\\', '').tr('. ', '_')
        end

        # @return [String]
        def heroku_name
          "piktur-#{app_name.dasherize}"
        end

        # @return [Class]
        def get_builder_class
          Generators::AppBuilder
        end

    end

  end

end
