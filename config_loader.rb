require 'sinatra'
require 'yaml'
require 'uber_config'
require 'iron_worker_ng'
require 'iron_cache'
require 'open-uri'

@config = UberConfig.load
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
