#!/usr/bin/env ruby
# frozen_string_literal: true

# Transfer a list of files from one repository to another preserving history.
#
# @see https://stackoverflow.com/posts/11426261/revisions

require 'optparse'

from, to, regex = nil

OptionParser.new do |opts|
  opts.on('--from=MANDATORY') { |val| from = File.expand_path(val, Dir.pwd) }
  opts.on('--to=MANDATORY') { |val| to = File.expand_path(val, Dir.pwd) }
  opts.on('--regex=MANDATORY') { |val| regex = Regexp.new(val) }
end.parse!

Dir.chdir(from) do
  list = Dir['**/*.{rb,js}']
    .reject { |e| e.start_with?('node_modules', 'coverage') }
    .select { |e| e.match?(regex) }

  File.open('list', 'w+') do |f|
    list.each { |e| f.write e << "\n" }
  end

  `git log
  --pretty=email \
  --patch-with-stat \
  --reverse \
  --full-index \
  --binary -- $(cat list) > patch`
end

Dir.chdir(to) do
  `git am --committer-date-is-author-date < #{from}/patch`
end
