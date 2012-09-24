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
  @all_langs = {}
  @total_bytes = 0
  @total_users = 0

  user_list_item = settings.cache.get("user_list")

  if user_list_item
    @user_id_list = JSON.parse(user_list_item.value)
    @total_users = @user_id_list.length
    @user_list = []
    limit = 10
    @user_id_list.each_with_index do |user_id, i|
      item = settings.cache.get(user_id.to_s)
      user = JSON.parse(item.value)
      p user
      # get total language size
      total_bytes = 0
      user['languages'].each_pair do |k, v|
        @all_langs[k] = 0
        total_bytes += v
      end
      user['total_bytes'] = total_bytes
      @user_list << OpenStruct.new(user)
      if i >= 10
        break
      end
    end

    @all_langs.each_pair do |lang, v|
      lang_bytes = settings.cache.get(lang).value
      puts "lang_bytes: #{lang_bytes}"
      @all_langs[lang] = lang_bytes
      @total_bytes += lang_bytes
    end
  end

  erb :index
end
