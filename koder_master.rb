require 'iron_worker_ng'
require 'iron_cache'
require 'rest'
require 'uber_config'

begin
  @config = UberConfig.load
  UberConfig.symbolize_keys!(@config)
rescue => ex
  puts "Using params for config"
  @config = params
end

#puts "config:"
#p @config

rest = Rest::Client.new
cache = IronCache::Client.new(@config[:iron])
worker = IronWorkerNG::Client.new(@config[:iron])

koders = cache.cache("koders")
user_ids = []

pages = 1
pagesize = 1

pages.downto(1) do |p|
  url = "https://api.stackexchange.com/2.1/users?pagesize=#{pagesize}&order=desc&sort=reputation&site=stackoverflow&page=#{p}"
  res = rest.get(url)
  results = JSON.parse(res.body)

  results["items"].each do |i|
    #puts "Found user #{i["display_name"]}"
    koders.put(i["user_id"].to_s, i.to_json)
    user_ids << i["user_id"]

    worker.tasks.create("koder_slave", {:user_id => i["user_id"],
                                        :name => i["display_name"]}.merge(@config))
  end

  puts "Results --> #{results}"
end

koders.put("user_list", user_ids.to_json)

puts "Processed #{user_ids.size} users"
