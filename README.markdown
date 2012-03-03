# osProtect

This is a Ruby on Rails application that offers a modern interface for network security IDS/IPS management and reporting.

## Installation Overview

1. Prerequisites include:
  * Ruby 1.9.3
  * Rails 3.2.1
  * MySQL
  * Snort and Barnyard2 (or another IDS that supports the default Snort database schema)
2. Install Postfix to handle emails
3. Install Redis to assist Resque with background processing
4. Install the Ruby on Rails application

## Emails

To send emails install Postfix Mail Server:

```
sudo aptitude install telnet postfix
```

Choose "Internet Site" and leave system mail name at default.

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

Redis is used by the gems **Resque** and **Resque Scheduler** for background jobs, and is only
needed if you desire to do **background emailing**, **Notifications**, **Reports/PDFs** which are 
all optional features in osProtect.

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

If you use Upstart (highly recommended) then do this:

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

## Install the Rails app

1. git clone git://github.com/clonesec/osProtect.git
2. cd osProtect
3. edit config/app_config.yml and change ...
4. the Snort (or other IDS with the same schema) database must be installed
5. edit config/database.yml and change ...
6. bundle install ... to install all the necessary ruby gems
7. bundle exec rake db:migrate ... to add tables in addition to the Snort schema
8. bundle exec rake db:seed ... creates the initial admin user
9. edit config/resque.yml and change if you are not using the defaults
10. rails server ... then visit http://localhost:3000/ in a web browser
