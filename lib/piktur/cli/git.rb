# frozen_string_literal: true

require 'thor'

class Git < Thor

end

%w(
  move
  current_branch
).each { |f| require_relative "./git/#{f}.rb" }

Git.register Git::Move, 'mv', 'mv', 'Move a group of files FROM TO [options]'
