require 'uber_config'
require 'iron_worker_ng'
require 'iron_cache'

@config = UberConfig.load
p @config

namespace :config do
  task :push do
    require_relative 'config_pusher'
    cp = ConfigPusher.new
    cp.push
  end
end

namespace :workers do
  task :upload_master do
    client = IronWorkerNG::Client.new(@config['iron'])
    # Upload the code
    code = IronWorkerNG::Code::Base.new('koder_master')
    client.codes.create(code)
  end
  task :upload_slave do
    client = IronWorkerNG::Client.new(@config['iron'])
    # Upload the code
    code = IronWorkerNG::Code::Base.new('koder_slave')
    client.codes.create(code, :max_concurrency=>50)
  end
  task :upload do
    Rake::Task["workers:upload_master"].invoke
    Rake::Task["workers:upload_slave"].invoke
  end
end

# queues up the master task
task :run do
  client = IronWorkerNG::Client.new(@config['iron'])
  client.tasks.create("koder_master", @config)
end

task :cleanup do
  ic = IronCache::Client.new(@config['iron'])
  cache = ic.cache("koders")
  cache.delete("user_list") rescue puts "user_list not found, continuing"
  # todo: we don't dynamically create this list anywhere, but we should so this isn't hardcoded
  # Or scrape list from here: https://github.com/languages
  langs = %w(Ruby
      Clojure
      JavaScript
      Shell
      Objective-C
      Python
      C
      C++
      Perl
      Io
      PHP
      C#
      Shell
      Perl
      Assembly)
  langs << "OpenEdge ABL"
  langs << "Emacs Lisp"
  p langs
  langs.each { |l| cache.delete(l) rescue puts "#{l} not found, continuing" }

end
