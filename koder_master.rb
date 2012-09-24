require 'iron_worker_ng'
require 'iron_cache'
require 'rest'
require 'json'

rest = Rest::Client.new(:gem => :typhoeus)
cache = IronCache::Client.new(:token => params[:token], :project_id => params[:project_id])
worker = IronWorkerNG::Client.new(:token => params[:token], :project_id => params[:project_id])

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
                                        :name => i["display_name"],
                                        :iron => {:token => params[:token], :project_id => params[:project_id]},
                                        :github => {token: "c9277d644f4127cdce954ec136d820675a1934a0"}})
  end

  puts "Results --> #{results}"
end

koders.put("user_list_array", user_ids.to_json)

puts "Processed #{user_ids.size} users"
