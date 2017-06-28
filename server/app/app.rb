require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'date'
require 'yaml'
require './models/resource.rb'

DB_CONFIG = YAML::load(File.open('config/database.yml'))
SETTINGS = YAML::load(File.open('config/settings.yml'))

set :database, "mysql2://#{DB_CONFIG['username']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? \
      and @auth.basic? \
      and @auth.credentials \
      and @auth.credentials == [
        SETTINGS['admin_username'],
        SETTINGS['admin_password']
      ]
  end
end

get '/' do
  json Resource.select('id', 'name').all
end

get '/pod' do
  "pod => #{`hostname`.strip}"
end

get '/:id' do
  protected!
  resource =  Resource.find_by_id(params[:id])

  if resource
    json resource
  else
    halt 404
  end
end

post '/' do
  protected!
  resource = Resource.create(params)

  if resource
    halt 206, json(resource)
  else
    halt 500
  end
end

patch '/:id' do
  protected!
  resource = Resource.find_by_id(params[:id])

  if resource
    resource.update(name: params[:name])
  else
    halt 404
  end
end

delete '/:id' do
  protected!
  resource = Resource.find_by_id(params[:id])

  if resource
    resource.destroy
  else
    halt 404
  end
end
