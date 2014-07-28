require 'sinatra/base'
require "data_mapper"

env = ENV["RACK_ENV"] || "development"
# we're telling the datamapper to use a postgres database on localhost. The name will be 
# either bookmarks_test or bookmarks_development, depending on the environment
DataMapper.setup(:default, "postgres://localhost/bookmarks_#{env}")

require './lib/link' #this needs to be done after DataMapper has been initialised
require './lib/tag' #this needs to be done after DataMapper has been initialised


#After declaring your models you need to finalise them
DataMapper.finalize

#However the database tables don't exist yet. Let's tell Datamapper to create them
DataMapper.auto_upgrade!

class Bookmarks < Sinatra::Base
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

  # start the server if ruby file executed directly
  run! if app_file == $0
end
