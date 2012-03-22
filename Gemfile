source 'https://rubygems.org'

gem 'rails', '3.2.2'

gem 'mysql2'

# Postgresql:
# gem 'pg'

# gem "composite_primary_keys", "~> 5.0.0.rc1"
# gem 'composite_primary_keys', path: '~/Sites/composite_primary_keys'
# gem 'composite_primary_keys', git: 'https://github.com/cleesmith/composite_primary_keys.git'
gem 'composite_primary_keys'

gem 'cancan'

gem 'sass-rails',   '~> 3.2.3'
gem 'coffee-rails', '~> 3.2.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# note: sudo aptitude/apt-get nodejs is a better solution than:
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

gem 'googlecharts'

# gem 'snortor'
# gem 'snortor', path: '~/Sites/snortor'
gem 'snortor', git: 'https://github.com/cleesmith/snortor.git'

# to easily create cron jobs:
gem 'whenever', :require => false

# To use Jbuilder templates for JSON
# gem 'jbuilder'

gem 'thin'
gem 'foreman'
gem 'unicorn'

group :development do
  gem 'letter_opener'
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
end
