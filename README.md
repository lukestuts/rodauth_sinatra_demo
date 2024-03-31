# rodauth_sinatra_demo

A quick demo of Sinatra and Rodauth with Postgres. It demonstrates:

* Working ("On My Mac") login and logout and user creation
* Separate Rodauth app and db users
* Use of non-default schema

`setup_mac.sh` will install required postgres (requires HomeBrew) and gems (Bundler-free zone) and seed the database

Start the Sinatra server using `ruby demo.rb` (config.ru-free zone)

`db/seeds.rb` creates a user login with credentials `demo@demo.com / demodemo`.

I believe there isn't an equivalent demo online so hopefully this will be useful to someone.
