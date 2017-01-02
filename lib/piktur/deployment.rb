# frozen_string_literal: true

module Piktur

  # @todo add CLI actions
  # @see Thor::Actions::ClassMethods
  module Deployment

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
      name = "#{heroku_name}-staging"
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
      return if args.blank?

      files = args.collect! do |e|
        file = Piktur.root.parent.join(e)
        file if file.exist?
      end.compact

      return if files.blank?

      run "heroku config:set $(cat #{files.join(' ')}) --remote #{remote}"
    end

    # @return [void]
    def deploy_to_staging_server
      git push: 'staging master'
    end

    # @return [void]
    def create_production_server
      run "heroku fork --from #{heroku_name}-staging --to #{heroku_name} --skip-pg"
      git remote: "add production https://git.heroku.com/#{heroku_name}.git"
      run "heroku maintenance:on --app #{heroku_name}"
    end

    # @return [void]
    def domain_alias
      run "heroku domains:add #{app_name}.piktur.io --app #{heroku_name}"
      run "heroku domains:add staging.#{app_name}.piktur.io --app #{heroku_name}-staging"
    end

    # @return [void]
    def checkout_development_branch
      git checkout: '-b develop'
    end

    # @return [String]
    def heroku_name
      "piktur-#{app_name.dasherize}"
    end

  end

end
