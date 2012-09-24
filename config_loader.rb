require 'sinatra'
require 'yaml'
require 'uber_config'
require 'iron_worker_ng'
require 'iron_cache'
require 'open-uri'

begin
  @config = UberConfig.load
rescue => ex
  puts "Couldn't load UberConfig: #{ex.message}"
end

@config = {} unless @config

# Load it from cache
if ENV['CONFIG_CACHE_KEY']
  puts "Getting config from #{ENV['CONFIG_CACHE_KEY']}"
  config_from_cache = open(ENV['CONFIG_CACHE_KEY']).read
  config_from_cache = JSON.parse(config_from_cache)
  config_from_cache = YAML.load(config_from_cache['value'])
  puts "config from cache"
  p config_from_cache

  @config.merge!(config_from_cache)
end

UberConfig.symbolize_keys!(@config)
p @config

module SingletonConfig
  def self.config=(c)
    @config = c
  end

  def self.config
    @config
  end
end

SingletonConfig.config = @config
