# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

desc 'Copy executables to namespaced directory'
task :copy_executables do
  Dir['bin/*'].each do |src|
    next if src == (dest = src.sub(/(bin\/)(\w+)$/, '\1piktur-\2'))

    File.open(dest, 'w+') { |f|
      f.write(File.read(src))
      f.chmod(0o700)
    }
  end
end

# Rake::Task['build'].prerequisites << :copy_executables

Dir['lib/piktur/tasks/**/*.rake'].each { |task| load(task) }
