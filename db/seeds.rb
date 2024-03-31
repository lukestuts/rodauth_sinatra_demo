require 'rodauth'

RodauthLib = Rodauth.lib do
  enable :disallow_password_reuse
  enable :create_account

  password_hash_table Sequel[:"#{DB.opts[:database]}_password"][:account_password_hashes]
  previous_password_hash_table Sequel[:"#{DB.opts[:database]}_password"][:account_previous_password_hashes]
  function_name do |name|
    puts "XXXXXX"
    puts name.inspect
    "#{DB.opts[:database]}_password.#{name}"
  end
end

RodauthLib.create_account(login: "demo@demo.com", password: "demodemo") unless RodauthLib.account_exists?(login: "demo@demo.com")
