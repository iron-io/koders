require 'rest'
require 'uber_config'
require 'base64'

print "Enter your github username: "
username = gets.chomp
print "Enter your github password: "
password = gets.chomp

p username
p password

base_url = "https://api.github.com/"
@header_value = "Basic #{Base64.encode64([username, password].join(':')).gsub("\n", '')}"
headers = {'Authorization'=>@header_value}
@rest = Rest::Client.new
r = @rest.post("#{base_url}authorizations", headers: headers, body: {})
p r
p r.body
body = JSON.parse(r.body)
puts "Your token is #{body["token"]}"
