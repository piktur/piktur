# frozen_string_literal: true

module Piktur

  # @todo add CLI actions
  # @todo deploy to AWS Elastic Beanstalk with `eb` CLI
  # @see Thor::Actions::ClassMethods
  module Deployment

    # `aws-sdk` or heroku CLI
    module Service

      require 'aws-sdk'

      # @see http://docs.aws.amazon.com/AWSRubySDK/latest/AWS.html#config-class_method
      # ::Aws.config(
      #   access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
      #   secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      #   region:            ENV['AWS_REGION']
      # )

      # @see http://docs.aws.amazon.com/sdkforruby/api/Aws/Route53/Client.html AWS ElasticBeanstalk
      module Server

        def self.client
          @client ||= Aws::ElasticBeanstalk::Client.new(
            access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
            secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
            region:            ENV['AWS_REGION']
          )
        end

        # "piktur-#{app_name}-env.<id>.#{ENV['AWS_REGION']}.elasticbeanstalk.com."
        attr_accessor :app_url

        # Configure directory for interaction with **AWS ElasticBeanstalk**
        # @return [void]
        def self.init
          `eb init`
        end

        def self.env
          Piktur.env('.env').gsub(/\n/, ', ')
        end

        # @example AWS EB CLI usage
        #   `eb create`
        # @example
        #   client = Aws::ElasticBeanstalk::Client.new(
        #     access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
        #     secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        #     region:            ENV['AWS_REGION']
        #   )
        #
        #   client.describe_configuration_settings(
        #     application_name: "gem-server-env",
        #     environment_name: "gem-server-env",
        #   )
        #
        # @example Set environment variables
        #   option_settings:     [
        #     {
        #       resource_name: "",
        #       namespace:     "aws:cloudformation:template:parameter",
        #       option_name:   "EnvironmentVariables",
        #       value:         <<~EOS
        #         GEMINABOX_ALLOW_REPLACE=true,
        #         RACK_ENV=production,
        #         # ...
        #       EOS
        #     }
        #   ]
        #
        # @see [Deploying Elastic Beanstalk Applications from Docker Containers](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.html)
        # @see http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html Stacks
        def self.create
          resp = client.create_environment(
            application_name:    "piktur-#{app_name}",
            cname_prefix:        "piktur-#{app_name}",
            environment_name:    "piktur-#{app_name}-env",
            solution_stack_name: "64bit Amazon Linux 2016.09 v2.3.0 running Ruby 2.3 (Puma)",
            version_label:       '0.0.1',
            option_settings:     [
              {
                resource_name: "",
                namespace:     "aws:cloudformation:template:parameter",
                option_name:   "EnvironmentVariables",
                value:         env
              }
            ]
          )

          self.app_url = resp.cname
          resp
        end

        # def self.setenv
        #   `eb setenv #{Piktur.env('.env.production')}`
        # end

        def self.deploy
          `eb deploy`
        end

      end

      # @see http://docs.aws.amazon.com/sdkforruby/api/Aws/Route53/Client.html AWS Route53
      module Domain

        PIKTUR__IO_HOSTED_ZONE_ID = 'Z30J5Z9Y83HO2I'

        def self.client
          @client ||= Aws::Route53::Client.new(
            access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
            secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
            region:            ENV['AWS_REGION']
          )
        end

        def self.hosted_zone
          @hosted_zone ||= client.get_hosted_zone(id: PIKTUR__IO_HOSTED_ZONE_ID)
        end

        def self.create_resource_record_set
          client.change_resource_record_sets(
            hosted_zone_id: hosted_zone.id,
            change_batch:   {
              comment: '',
              changes: [
                {
                  action:              'CREATE',
                  resource_record_set: {
                    name:             "#{app_name}.piktur.io.",
                    type:             'CNAME',
                    region:           ENV['AWS_REGION'],
                    ttl:              1.day,
                    resource_records: [
                      {
                        value: app_url
                      }
                    ]
                  }
                }
              ]
            }
          )
        end

      end

    end

    # @return [void]
    def repo_name
      "piktur_#{app_name}"
    end

    # @return [void]
    def create_local_repo
      git :init
      git add:    '.'
      git commit: "-am 'Initial commit'"
    end

    # @return [void]
    def remote_settings
      <<~JS.gsub(/\s|\n/, '')
        {
          "scm":         "git",
          "has_issues":  true,
          "is_private":  true,
          "fork_policy": "no_public_forks"
        }
      JS
    end

    # @return [void]
    def create_remote_repo
      run <<~EOS
        curl -X POST -u #{ENV['BITBUCKET_USER']}:#{ENV['BITBUCKET_DEVELOPER_PASSWORD']} -H "Content-Type: application/json" https://api.bitbucket.org/2.0/repositories/#{ENV['BITBUCKET_USER']}/#{repo_name} -d '#{remote_settings}'
      EOS
      git remote: "add origin ssh://git@bitbucket.org/#{ENV['BITBUCKET_USER']}/#{repo_name}.git"
    end

    # @return [void]
    def push_to_remote_repo
      git push: '-u origin master'
    end

    # @return [void]
    def link_ci_server
      run <<~EOS
        curl -X POST -u #{ENV['CIRCLECI_API_KEY']}: https://circleci.com/api/v1.1/project/bitbucket/#{ENV['BITBUCKET_USER']}/#{repo_name}/follow
      EOS
    end

    # @return [void]
    def create_staging_server
      name = "#{remote_app_name}-staging"
      run "heroku apps:create #{name} --remote staging"
      # run "heroku git:remote -a #{name}"
      run "heroku addons:create newrelic:wayne --app #{name}"
      run "heroku maintenance:on --app #{name}"
    end

    # @example
    #   set_server_env 'production', '.env.common', '.env.staging'
    # @params [String] remote
    # @params [String] args File list
    # @return [void]
    def set_server_env(remote = 'staging', *args)
      run "heroku config:set #{Piktur.env(*args)}) --remote #{remote}"
    end

    # @return [void]
    def deploy_to_staging_server
      git push: 'staging master'
    end

    # @return [void]
    def create_production_server
      run "heroku fork --from #{remote_app_name}-staging --to #{remote_app_name} --skip-pg"
      git remote: "add production https://git.heroku.com/#{remote_app_name}.git"
      run "heroku maintenance:on --app #{remote_app_name}"
    end

    # @return [void]
    def domain_alias
      run "heroku domains:add #{app_name}.piktur.io --app #{remote_app_name}"
      run "heroku domains:add staging.#{app_name}.piktur.io --app #{remote_app_name}-staging"
    end

    # @return [void]
    def checkout_development_branch
      git checkout: '-b develop'
    end

    # @return [String]
    def remote_app_name
      "piktur-#{app_name.dasherize}"
    end

  end

end
