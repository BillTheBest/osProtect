source 'https://rubygems.org'

gem 'rails', '3.2.1'

gem 'mysql2'

# Postgresql:
# gem 'pg'

# gem "composite_primary_keys", "~> 5.0.0.rc1"
# gem 'composite_primary_keys', path: '~/Sites/composite_primary_keys'
gem 'composite_primary_keys', git: 'git://github.com/cleesmith/composite_primary_keys.git'

gem 'cancan'

gem 'sass-rails',   '~> 3.2.3'
gem 'coffee-rails', '~> 3.2.1'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer'
gem 'uglifier', '>= 1.0.3'

gem 'jquery-rails'

gem 'will_paginate', '~> 3.0.2'

gem 'bcrypt-ruby', '~> 3.0.0'

gem 'prawn'

# background jobs:
gem 'resque', :require => 'resque/server'
gem 'resque-scheduler'
gem 'resque_mailer'

gem 'sys-proctable'
gem 'sys-cpu'

gem 'googlecharts'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

group :development do
  gem 'letter_opener'
  gem 'thin'
  gem 'foreman'
  # web: bundle exec thin start -p $PORT -e production
end

gem "rspec-rails", :group => [:development, :test]
group :test do
  gem 'turn', :require => false
  gem "factory_girl_rails"
  gem "capybara"
  gem "launchy"
  gem "guard-rspec"
end

group :production do
  gem 'thin'
  gem 'foreman'
end
