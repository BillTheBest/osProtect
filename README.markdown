# osProtect

This is a Ruby on Rails application that offers a modern interface for network security IDS/IPS management and reporting.

## Installation Overview

* Prerequisites:
  * **Snort** and **Barnyard2** (or another IDS that supports the default Snort database schema)
  * **Ruby** 1.9.3 +
  * **Rails** 3.2.2 + (actually this is not a prerequisite, as the rails gems are installed when you do bundle install later)
  * **MySQL** Ver 14.14 Distrib 5.1.41 +
  * A web and/or application server, such as **Apache/Passenger**, **Nginx/Thin**, or **Nginx/Unicorn**, and so on
* Configure the server so **emails** may be sent from the rails app, and installing **Postfix** is suggested
* Install **Redis** which is used by **Resque** and **Resque Scheduler** for background processing
* Install this Rails application


## Snort and Barnyard2

Please consult the [Snort docs](http://www.snort.org/docs "snort install") and [Barnyard2 site](http://www.securixlive.com/barnyard2/download.php "barnyard2 install") for the latest installation instructions.


## Ruby 1.9.3 +

Please consult the [Ruby site](http://www.ruby-lang.org/en/downloads/ "ruby install") for the latest installation instructions.

As mentioned on the Ruby site, installing **RVM** is an excellent way to manage different versions of Ruby as well as creating **gemsets** for each application ... highly recommended.


## Rails 3.2.2 +

See step **6.** under **Install this Rails application** later on this page.


## MySQL Ver 14.14 Distrib 5.1.41 +

Please consult the [MySQL site](http://dev.mysql.com/downloads/ "mysql install") for the latest installation instructions.


## Emails

See these instructions [to allow this rails app to send emails](osProtect/wiki/allowing-a-rails-app-to-send-emails "allowing a rails app to send emails")


## Redis

Redis is used by the gems **Resque**, **Resque Scheduler**, and **Resque Mailer** for background processing, and is only
needed if you desire to do **background emailing**, **Notifications**, **Reports/PDFs** which are 
all optional features in **osProtect**.

Be sure to check the [Redis site](http://redis.io/download "redis install") for the latest installation instructions, but [these instructions](osProtect/wiki/installing-Redis "installing redis") are typical for installing Redis.

Also, see the instructions [to set up Redis as an Upstart service](osProtect/wiki/setting-up-Redis-as-an-Upstart-service "setting up redis as an upstart service").

## Install this Rails application

1. **git clone git://github.com/clonesec/osProtect.git**
2. cd **osProtect**
3. edit **config/app_config.yml** and change as appropriate for your installation (the defaults are sensible)
4. the Snort (or other IDS with the same schema) database must be installed, and you may also want to create another user in 
MySQL for this rails app to use to access the snort database ... [details here](osProtect/wiki/create-rails-app-user-for-snort-database "create rails app user in mysql")
5. edit **config/database.yml** and change to match your installation of Snort/MySQL
6. **bundle install** ... this is where the **rails gems** and other gems are installed
7. **bundle exec rake db:migrate** ... which add tables in addition to the Snort schema, and note that the Snort tables are not altered by this app
8. **bundle exec rake db:seed** ... which creates the initial admin user
9. edit **config/resque.yml** ... change if you are not using the default IP/Port
10. as a quick test do: **bundle exec rails server** ... then visit http://localhost:3000/ in a web browser
