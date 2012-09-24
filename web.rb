require 'sinatra'

enable :sessions, :raise_errors
# this is erroring out for some reason??
use Rack::Flash

set :public_folder, File.expand_path(File.dirname(__FILE__) + '/assets')

require 'config_loader'

ironmq = IronMQ::Client.new(SingletonConfig.config[:iron])
#ironmq.logger.level = Logger::DEBUG
ironcache = IronCache::Client.new(SingletonConfig.config[:iron])
ironworker = IronWorkerNG::Client.new(SingletonConfig.config[:iron])
set :ironmq, ironmq
set :ironcache, ironcache
set :ironworker, ironworker
set :cache, ironcache.cache("koders")

get '/' do

  begin
    user_list_item = settings.cache.get("user_list")
    @user_id_list = JSON.parse(user_list_item.value)
    @user_list = []
    limit = 10
    @user_id_list.each_with_index do |user_id, i|
      item = settings.cache.get(user_id.to_s)
      user = JSON.parse(item.value)
      p user
      # get total language size
      total_bytes = 0
      user['languages'].each_pair do |k,v|
        total_bytes += v
      end
      user['total_bytes'] = total_bytes
      @user_list << OpenStruct.new(user)
      if i >= 10
        break
      end
    end

  rescue => ex
    puts "FUCKING EXCEPTION!!"
    p ex
    p ex.backtrace
  end

  erb :index
end
