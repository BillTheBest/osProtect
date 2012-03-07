# osProtect

This is a Ruby on Rails application that offers a modern interface for network security IDS/IPS management and reporting.

## Installation Overview

1. Prerequisites:
  * **Snort** and **Barnyard2** (or another IDS that supports the default Snort database schema)
  * **Ruby** 1.9.3 +
  * **Rails** 3.2.2 + (actually this is not a prerequisite, as the rails gems are installed when you do bundle install later)
  * **MySQL** Ver 14.14 Distrib 5.1.41 +
2. Configure the server so **emails** may be sent from the rails app, and installing **Postfix** is suggested
3. Install **Redis** which is used by **Resque** and **Resque Scheduler** for background processing
4. Install this Rails application


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

To allow this rails app to send emails install the **Postfix** Mail Server (or you may use another mailing solution such as SMTP):

```
sudo aptitude install telnet postfix
```

Choose "Internet Site" and leave the **system mail name** at default.

To ensure Postfix and Sendmail are working do:

```
/usr/sbin/sendmail your_email_account@something.com
FROM: me
SUBJECT: hi
this is only a test
. <press Enter twice>
```

Check your inbox for the email.

## Redis

Redis is used by the gems **Resque** and **Resque Scheduler** for background processing, and is only
needed if you desire to do **background emailing**, **Notifications**, **Reports/PDFs** which are 
all optional features in **osProtect**.

```
cd ~/src (you may need to > mkdir ~/src)
wget http://redis.googlecode.com/files/redis-2.4.6.tar.gz
tar xzf redis-2.4.6.tar.gz
cd redis-2.4.6
sudo make
sudo make install
mkdir /etc/redis
mkdir /var/redis
cp redis.conf /etc/redis/
nano /etc/redis/redis.conf
```

Be sure to check the [Redis site](http://redis.io/download "redis install") for the latest installation instructions.

To set up Redis as an Upstart service (the System-V init replacement, but highly recommended) do this:

```
mkdir /var/log/redis
nano /etc/init/redis-server.conf
```
Then enter the following:

```
description "redis server"
start on runlevel [2345]
stop on shutdown
exec /usr/local/bin/redis-server /etc/redis/redis.conf
respawn
```

and save.

The above will automatically start Redis when the server is rebooted, and restarts redis if it should be killed or dies.

To test Redis you can manually start it by doing (for Upstart):

```
sudo service redis-server start (or stop or restart)
```

To ensure it works do:

```
redis-cli info
or
redis-cli ping
```

## Install this Rails application

1. **git clone git://github.com/clonesec/osProtect.git**
2. cd **osProtect**
3. edit **config/app_config.yml** and change as appropriate for your installation (the defaults are sensible)
4. the Snort (or other IDS with the same schema) database must be installed, and you may also want to create another user in 
MySQL for this rails app to use to access the snort database ... [details here](osProtect/wiki/create-rails-app-user-for-snort-database "create rails app user in mysql")
5. edit **config/database.yml** and change to match your installation of Snort/MySQL
6. **bundle install**
7. **bundle exec rake db:migrate** ... which add tables in addition to the Snort schema, and note that the Snort tables are not altered by this app
8. **bundle exec rake db:seed** ... which creates the initial admin user
9. edit **config/resque.yml** ... change if you are not using the default IP/Port
10. as a quick test do: **bundle exec rails server** ... then visit http://localhost:3000/ in a web browser
