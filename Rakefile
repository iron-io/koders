require 'uber_config'
require 'iron_worker_ng'

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
    client.codes.create(code)
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
