
require 'iron_cache'
require 'uber_config'
require 'yaml'
require 'open-uri'

class ConfigPusher
  def push

    @config = UberConfig.load
    raise "Config needs an app_name field." unless @config['app_name']

    c = IronCache::Client.new(@config['iron'])
    cache = c.cache("configs")
    item = cache.put(@config['app_name'], @config.to_yaml)
    p item

    url = cache.url(@config['app_name'])
    url_with_token = url + "?oauth=#{c.token}"
    #puts url_with_token
    puts `heroku config:add CONFIG_CACHE_KEY=#{url_with_token}`

  end
end
