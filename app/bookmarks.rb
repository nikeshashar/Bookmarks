require "sinatra"
require "data_mapper"
require "bcrypt"
require 'rack-flash'
require 'sinatra/partial'
require 'rest_client'
require './app/models/link' 
require './app/models/tag' 
require './app/models/user'
require './app/models/mailer' 

require_relative 'controllers/users'
require_relative 'controllers/sessions'
require_relative 'controllers/links'
require_relative 'controllers/tags'
require_relative 'controllers/application'
require_relative 'controllers/forgot'

require_relative 'data_mapper_setup'
require_relative 'helpers/application'

enable :sessions
set :session_secret, 'super secret'
set :partial_template_engine, :erb
set :static, true
set :public_folder, Proc.new { File.join(__FILE__, '..', "public") }
use Rack::Flash
use Rack::MethodOverride
