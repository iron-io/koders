# Expected parameters:
#   name: name of person to search for
#   user_id: the stackoverflow_id
#   github:token: oauth token for github
#   iron:token: Iron.io token
#   iron:project: Iron.io project
#
#

require 'rest'
require 'uber_config'
require 'iron_cache'

begin
  @config = UberConfig.load
  UberConfig.symbolize_keys!(@config)
rescue => ex
  @config = params
end

name = @config[:name] || @config[:name]
puts "name: #{name}"

@stackoverflow_id = @config[:user_id]

@ic = IronCache::Client.new(@config[:iron])
@cache = @ic.cache("koders")

headers = {'Authorization' => "token #{@config[:github][:token]}"}
@rest = Rest::Client.new
base_url = "https://api.github.com"

q = CGI.escape("\"" + name + "\"")
r = @rest.get("#{base_url}/legacy/user/search/#{q}")
p r
p r.body
body = JSON.parse(r.body)
p body

best_user_match = nil

body["users"].each do |user|
  puts "#{user["username"]} - #{user["name"]} has #{user["followers"]} followers and #{user["repos"]} public repos."
  best_user_match = user if best_user_match.nil?
  if user["name"] == name
    best_user_match = user
    break
  end
end

puts "BEST MATCH: " + best_user_match.inspect

language_counts = {}

if best_user_match
  r = @rest.get("#{base_url}/users/#{CGI.escape(best_user_match["username"])}/repos")
  p r
  p r.body
  repos = JSON.parse(r.body)
  p repos

  # todo: should page through full set of repos, "Link" header: http://developer.github.com/v3/repos/
  repos.each do |repo|

    # some stats we could use from each repo: forks, watchers
    p repo

    r = @rest.get("#{repo["url"]}/languages")
    p r
    p r.body
    languages = JSON.parse(r.body)
    p languages
    languages.each_pair do |lang, bytes|
      language_counts[lang] ? language_counts[lang] += bytes : language_counts[lang] = bytes
    end
  end

end

puts "FINAL COUNTS:"
p language_counts

# increment global stats
language_counts.each_pair do |lang, bytes|
  begin
    @cache.increment(lang, bytes)
  rescue => ex
    if ex.code == 404
      @cache.put(lang, bytes)
    else
      raise ex
    end
  end
end

user_in_cache = @cache.get(@stackoverflow_id.to_s)
p user_in_cache
new_value = JSON.parse(user_in_cache.value)
new_value["languages"] = language_counts
@cache.put(@stackoverflow_id.to_s, new_value.to_json)

