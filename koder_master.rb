require 'iron_worker_ng'
require 'iron_cache'
require 'rest'
require 'json'

options = {}
url = "https://api.stackexchange.com/2.1/users?order=desc&sort=reputation&site=stackoverflow"
rest = Rest::Client.new(:gem => :typhoeus)
cache = IronCache::Client.new(:token => params[:token], :project_id => params[:project_id])
worker = IronWorkerNG::Client.new(:token => params[:token], :project_id => params[:project_id])

koders = cache.cache("koders")
user_ids = []

res = rest.get(url, options)
results = JSON.parse(res.body)

results["items"].each do |i|
  puts "Found user #{i["display_name"]}"
  koders.put(i["user_id"].to_s, i.to_s)
  user_ids << i["user_id"]

  worker.tasks.create("koder_slave", :user_id => i["user_id"])
end

puts "Processed #{user_ids.size} users"
