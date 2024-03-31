require 'sequel_tools'
require 'sequel/core'
require 'securerandom'

db_url = File.read('db_connection_string.txt').gsub("\n",'')
db = Sequel.connect(db_url, test: false, keep_reference: false)
DB = db
base_config = SequelTools.base_config(
  project_root: "#{__dir__}",
  dbadapter: db.opts[:adapter],
  dbhost: db.opts[:host],
  dbname: db.opts[:database],
  username: db.opts[:user].to_s,
  password: db.opts[:password]
)
PW_USER_PW = SecureRandom.hex(12)

namespace :db do
  SequelTools.inject_rake_tasks base_config.merge(log_level: :info, sql_log_level: :info), self

  task :create_db_users do
    puts "Creating db users"
    `createuser -h #{db.opts[:host]} -U postgres #{db.opts[:user]}`
    `psql -h #{db.opts[:host]} -U postgres -c "alter user #{db.opts[:user]} createdb"`
    `createuser -h #{db.opts[:host]} -U postgres #{db.opts[:user]}_password`
    `psql -h #{db.opts[:host]} -U postgres -c "alter user #{db.opts[:user]}_password createdb"`
  end

  Rake::Task["db:create"].enhance([Rake::Task["db:create_db_users"]]) do
    puts "Creating separate schemas"
    `psql -h #{db.opts[:host]} -U postgres -c "DROP SCHEMA public;" #{db.opts[:database]}`
    `psql -h #{db.opts[:host]} -U postgres -c "CREATE SCHEMA #{db.opts[:database]} AUTHORIZATION #{db.opts[:database]};" #{db.opts[:database]}`
    `psql -h #{db.opts[:host]} -U postgres -c "CREATE SCHEMA #{db.opts[:database]}_password AUTHORIZATION #{db.opts[:database]}_password;" #{db.opts[:database]}`
    `psql -h #{db.opts[:host]} -U postgres -c "GRANT USAGE ON SCHEMA #{db.opts[:database]} TO #{db.opts[:database]}_password;" #{db.opts[:database]}`
    `psql -h #{db.opts[:host]} -U postgres -c "GRANT USAGE ON SCHEMA #{db.opts[:database]}_password TO #{db.opts[:database]};" #{db.opts[:database]}`
    puts "Adding citext extension"
    `psql -h #{db.opts[:host]} -U postgres -c "CREATE EXTENSION citext SCHEMA #{db.opts[:database]}" #{db.opts[:database]}`
  end

  task :rodauth_migrate do
    # Add rodauth password user hash migrations
    Sequel.extension :migration
    Sequel.postgres(db.opts[:database], host: db.opts[:host], user: "#{db.opts[:user]}_password") do |dba|
      Sequel::Migrator.run(dba, 'db/migrations/rodauth', table: 'schema_info_password')
    end
  end

  Rake::Task["db:migrate"].enhance do
    Rake::Task["db:rodauth_migrate"].invoke
    # Increase security slightly by restricting db access to the app's db account
    `psql -h #{db.opts[:host]} -U postgres -c "GRANT ALL ON DATABASE  #{db.opts[:database]} TO #{db.opts[:database]};"`
    `psql -h #{db.opts[:host]} -U postgres -c "REVOKE ALL ON DATABASE #{db.opts[:database]} FROM public;"`
  end
end