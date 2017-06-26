require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'date'
require 'yaml'

DB_CONFIG = YAML::load(File.open('config/database.yml'))

set :database, "mysql2://#{DB_CONFIG['username']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"

class Resource < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
end

get '/' do
  json Resource.select('id', 'name').all
end

get '/pod' do
  "pod => #{`hostname`.strip}"
end

get '/:id' do
  resource =  Resource.find_by_id(params[:id])

  if resource
    json resource
  else
    halt 404
  end
end

post '/' do
  resource = Resource.create(params)

  if resource
    halt 206, json(resource)
  else
    halt 500
  end
end

patch '/:id' do
  resource = Resource.find_by_id(params[:id])

  if resource
    resource.update(name: params[:name])
  else
    halt 404
  end
end

delete '/:id' do
  resource = Resource.find_by_id(params[:id])

  if resource
    resource.destroy
  else
    halt 404
  end
end
