require 'sinatra/base'
require "data_mapper"
require "bcrypt"



env = ENV["RACK_ENV"] || "development"
# we're telling the datamapper to use a postgres database on localhost. The name will be 
# either bookmarks_test or bookmarks_development, depending on the environment
DataMapper.setup(:default, "postgres://localhost/bookmarks_#{env}")

require './lib/link' #this needs to be done after DataMapper has been initialised
require './lib/tag' #this needs to be done after DataMapper has been initialised
require './lib/user' #this needs to be done after DataMapper has been initialised

#After declaring your models you need to finalise them
DataMapper.finalize

#However the database tables don't exist yet. Let's tell Datamapper to create them
DataMapper.auto_upgrade!

class Bookmarks < Sinatra::Base

enable :sessions
set :session_secret, 'super secret'

  get '/' do
  	@links = Link.all
 	erb :index
  end

post '/links' do
  url = params["url"]
  title = params["title"]
  tags = params["tags"].split(" ").map do |tag|
  	Tag.first_or_create(:text => tag)
  end
  Link.create(:url => url, :title => title, :tags => tags)
  redirect to('/')
end

get '/tags/:text' do
	tag = Tag.first(:text => params[:text])
	@links = tag ? tag.links : []
	erb :index
end

get '/users/new' do 
  erb :"users/new"
end

post '/users' do 
  user = User.create(:email => params[:email], :password => params[:password],
          :password_confirmation => params[:password_confirmation])
  session[:user_id] = user.id
  redirect to('/')
end

helpers do 

  def current_user
    @current_user ||=User.get(session[:user_id]) if session[:user_id]
  end
end
  # start the server if ruby file executed directly
  run! if app_file == $0
end
