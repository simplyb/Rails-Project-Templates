rvmrc = <<-RVMRC
if [[ -n "$rvm_path/environments" && -s "$rvm_path/environments/ruby-1.8.7-p302@#{app_name}" ]] ; then
  \. "$rvm_path/environments/ruby-1.8.7-p302@#{app_name}"
else
  rvm --create use  "ruby-1.8.7-p302@#{app_name}"
fi
RVMRC

create_file ".rvmrc", rvmrc
username = ask("What is the db user name?")
password = ask("What is the db password?")

gem "factory_girl_rails", ">= 1.0.0", :group => :test
gem "factory_girl_generator", ">= 0.0.1", :group => [:development, :test]
gem "rspec-rails", ">= 2.2.1", :group => [:development, :test]

generators = <<-GENERATORS

    config.generators do |g|
      g.test_framework :rspec, :fixture => true, :views => false
      g.integration_tool :rspec, :fixture => true, :views => true
    end
GENERATORS

application generators

get "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js",  "public/javascripts/jquery.js"
get "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.5/jquery-ui.min.js", "public/javascripts/jquery-ui.js"
`curl http://github.com/rails/jquery-ujs/raw/master/src/rails.js -o public/javascripts/rails.js`

gsub_file 'config/application.rb', 'config.action_view.javascript_expansions[:defaults] = %w()', 'config.action_view.javascript_expansions[:defaults] = %w(jquery.js jquery-ui.js rails.js)'

gsub_file 'config/database.yml', 'username: root', "username: #{username}"
gsub_file 'config/database.yml', 'password:', "password: #{password}"

remove_file "public/index.html"

create_file "log/.gitkeep"
create_file "tmp/.gitkeep"

git :init
git :add => "."

docs = <<-DOCS

Run the following commands to complete the setup of #{app_name.humanize}:

% cd #{app_name}
% mysql_new #{app_name}_dev
% mysql_new #{app_name}_test
% bundle install
% rails generate rspec:install

DOCS

log docs