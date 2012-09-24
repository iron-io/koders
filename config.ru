require 'sinatra'
require 'iron_worker_ng'
require 'iron_mq'
require 'iron_cache'
require 'yaml'
require 'rack-flash'

$: << '.'

require 'web'

run Sinatra::Application
