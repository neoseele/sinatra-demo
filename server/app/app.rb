require 'sinatra'
require 'sinatra/json'

get '/' do
  "Pod: #{`hostname`.strip}"
end
