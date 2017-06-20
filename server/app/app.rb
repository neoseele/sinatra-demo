require 'sinatra'
require 'sinatra/json'

get '/' do
  `hostname`.strip
end
