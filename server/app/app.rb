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

  set :database, "mysql2://#{settings.user}@#{settings.host}:#{settings.port}/#{settings.name}"
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

  get '/settings' do
    a = {}
    a['db_user'] = settings.user
    a['db_host'] = settings.host
    a['db_port'] = settings.port
    a['db_name'] = settings.name
    a['app_user'] = settings.admin_user
    a['app_pwd'] = settings.admin_password
    a['app_user_env'] = ENV['APP_ADMIN_USER']
    a['app_pwd_env'] = ENV['APP_ADMIN_PASSWORD']
    a['env'] = ENV
    json a
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
