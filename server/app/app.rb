require 'sinatra'
require 'sinatra/json'

get '/' do
  json `hostname`.strip
end
