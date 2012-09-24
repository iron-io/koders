require 'rest'
require 'uber_config'
require 'base64'

@config = UberConfig.load
UberConfig.symbolize_keys!(@config)
p @config

base_url = "https://api.github.com/"
@header_value = "Basic #{Base64.encode64([@config[:github][:username], @config[:github][:password]].join(':')).gsub("\n", '')}"
headers = {'Authorization'=>@header_value}
@rest = Rest::Client.new
r = @rest.post("#{base_url}authorizations", headers: headers, body: {})
p r
p r.body
body = JSON.parse(r.body)
puts "Your token is #{body["token"]}"
