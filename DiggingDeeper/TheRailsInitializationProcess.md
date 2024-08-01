# The Rails Initialization Process

## 1 Lançar!
  - bin/rails
  - config/boot.rb
  - rails/commands.rb
  - rails/command.rb
  - actionpack/lib/action_dispatch.rb
  - rails/commands/server/server_command.rb
  - Prateleira:lib/rack/server.rb
  - config/application
  - Rails::Server#start
  - config/environment.rb
  - config/application.rb
## 2 Carregando Trilhos
  - railties/lib/rails/all.rb
  - De volta aconfig/environment.rb
  - railties/lib/rails/application.rb
  - Rack: lib/rack/server.rb
