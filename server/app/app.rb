require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
# require "sinatra/config_file"
require 'yaml'
require './models/resource.rb'
require './helpers/hostinfo.rb'

class SimpleApp < Sinatra::Base
  helpers Sinatra::HostinfoHelper
  # register Sinatra::ConfigFile

  DB = YAML::load(File.open('config/database.yml'))
  SETTINGS = YAML::load(File.open('config/settings.yml'))

  set :database, "mysql2://#{DB['username']}@#{DB['host']}:#{DB['port']}/#{DB['database']}"
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
          SETTINGS['admin_user'],
          SETTINGS['admin_password']
        ]
    end
  end

  ### public endpoints

  get '/' do
    "pod => #{`hostname`.strip}"
  end

  get '/test' do
    File.read(File.join('public', 'test.html'))
  end

  get '/resources' do
    json Resource.select('id', 'name').all
  end

  # get '/stress' do
  #   `dd if=/dev/zero of=/dev/null bs=10240 count=1000 2>&1`
  # end

  ### protected endpoints

  get '/hostinfo' do
    # protected!
    json hostinfo
  end

  get '/resources/:id' do
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
