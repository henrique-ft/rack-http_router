require 'byebug' if ENV['RACK_ENV'] == 'development'

#require_relative '../../lib/rackr'
require 'rackr'
require 'sequel'
require_relative 'load'
require_relative 'app/app'

use Rack::Static, :urls => ["/public"]

#if ENV['RACK_ENV'] != 'development'
  #use Rack::Auth::Basic, "Restricted Area" do |username, password|
    #[username, password] == ['some_username', 'some_password']
  #end
#end

run App
