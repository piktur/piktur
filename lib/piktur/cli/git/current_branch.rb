# frozen_string_literal: true

class Git

  # Print the current branch for given repository
  #   cd $PIKTUR_HOME/$1
  #   git rev-parse --abbrev-ref HEAD
  #
  # @return [String]
  def self.current_branch_name_for(gem)
    path = ::File.expand_path(gem, ::ENV['PIKTUR_HOME'])
    ::Dir.chdir(path) { return current_branch_name }
  rescue ::Errno::ENOENT => err
    ::Piktur.logger.warn("#{err.class}: Gem not found at #{path}")
  end

  # @return [String]
  def self.current_branch_name
    `git rev-parse --abbrev-ref HEAD`.chomp
  end

end
