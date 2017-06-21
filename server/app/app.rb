require 'sinatra'
require 'sinatra/json'
require 'date'

get '/' do
  "pod => #{`hostname`.strip}"
end

get '/now' do
  json DateTime.now.to_s
end
