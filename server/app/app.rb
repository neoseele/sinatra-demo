require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require "sinatra/config_file"
# require 'date'
# require 'yaml'
require './models/resource.rb'

class SimpleApp < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'config/database.yml'
  config_file 'config/settings.yml'

  set :database, "mysql2://#{settings.username}@#{settings.host}:#{settings.port}/#{settings.database}"
  set :port, 4567

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
          settings.admin_user,
          settings.admin_password
        ]
    end
  end

  ### public endpoints

  get '/' do
    json Resource.select('id', 'name').all
  end

  get '/pod' do
    "pod => #{`hostname`.strip}"
  end

  get '/test' do
    File.read(File.join('public', 'test.html'))
  end

  get '/pw' do
    json settings.admin_password
  end

  ### protected endpoints

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

  # start the server if ruby file executed directly
  run! if app_file == $0
end
