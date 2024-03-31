#!/bin/bash

# Install db and gems

# "It works on my Mac..."

DBUSER="rodauthtest"
DBNAME="rodauthtest"
DBPASS="rodauthtest"

brew install postgresql
brew install libpq
brew services start postgresql

createuser -s postgres

# Bundler booooo
gem install roda rodauth sequel sequel_pg sequel_tools sinatra bcrypt

rake db:create; rake db:migrate; rake db:seed
