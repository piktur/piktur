#!/usr/bin/env ruby
# frozen_string_literal: true

# @example Move commit history forward 10 days
#   ADJUST=10 tasks/git/change_date.rb
#
# @see https://swoogan.blogspot.com/2015/06/changing-date-on-series-of-git-commits.html

require 'open3'
require 'time'

CMD = 'git log --pretty=format:"%H %ct"'
ADJUST = 60 * 60 * 24 * ENV.fetch('ADJUST').to_i

Open3.popen3(CMD) do |stdin, stdout, _stderr, wait_thread|
  stdin.close

  while (e = stdout.gets)
    hash, timestamp = e.split
    old_time = timestamp.to_i    # Time.at(old_time) convert UNIX timestamp to Date
    new_time = old_time - ADJUST # Time.at(new_time).iso8601

    `git filter-branch -f --env-filter '
if test "$GIT_COMMIT" = "#{hash}"
then
  GIT_AUTHOR_DATE="#{new_time}"
  GIT_COMMITTER_DATE="#{new_time}"
fi
'`
  end

  wait_thread.exit
end
