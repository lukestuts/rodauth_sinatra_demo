#!/usr/bin/env ruby

# Simple rodauth and sinatra test

require 'sinatra'

# Rodauth libs
require 'roda'
require 'sequel/core'
require 'bcrypt'

set :sessions, true
SESSION_SECRET_FILE = 'session_secret.txt'
if File.exist?('session_secret.txt')
  SESSION_SECRET = File.read(SESSION_SECRET_FILE)
else
  SESSION_SECRET = SecureRandom.hex(64)
  File.write(SESSION_SECRET_FILE, SESSION_SECRET)
end
set :session_secret, SESSION_SECRET
use Rack::Session::Cookie, secret: SESSION_SECRET

db_url = File.read('db_connection_string.txt').gsub("\n",'')
DB = Sequel.connect(db_url)

# Used to hold the latest r.rodauth from the roda middleware
class MyRodauth
  @@rodauth = nil
  def self.set(rodauth)
    @@rodauth = rodauth
  end
  def self.get
    return @@rodauth
  end

  def self.method_missing(method, *args)
    if @@rodauth.respond_to?(method)
      @@rodauth.send(method, *args)
    else
      super
    end
  end
end

def rodauth_logout
  RODAUTH[0].logout
end

class RodauthApp < Roda
  plugin :middleware
  plugin :rodauth do
    
    enable :login
    enable :logout
    enable :remember
    enable :create_account

    enable :disallow_password_reuse
    password_hash_table Sequel[:"#{DB.opts[:database]}_password"][:account_password_hashes]
    previous_password_hash_table Sequel[:"#{DB.opts[:database]}_password"][:account_previous_password_hashes]
    function_name do |name|
      "#{DB.opts[:database]}_password.#{name}"
    end

    hmac_secret SESSION_SECRET
  end

  #alias erb render
  route do |r|
    r.rodauth

    rodauth.require_authentication
    MyRodauth.set(rodauth)
  end
end
use RodauthApp

get '/' do
  erb :index
end
