# osProtect

osProtect is a ruby on rails application for detecting and analyzing security threats. 

## Getting Started

1. git clone git://github.com/clonesec/osProtect.git
2. cd osProtect
3. edit config/app_config.yml and change ...
4. bundle install ... to install all the necessary ruby gems
5. rake db:migrate ... to create a users table to be used by Devise for sign in/out/timeout of user sessions
6. rails server ... then visit http://localhost:3000/ in a web browser

### Emails

To send emails install Postfix Mail Server:

```ruby
sudo aptitude install telnet postfix
```

Choose "Internet Site" and leave system mail name at default.

To ensure Postfix and Sendmail are working do:

    /usr/sbin/sendmail your_email_account@something.com
    FROM: me
    SUBJECT: hi
    this is only a test
    . <press Enter twice>


Install Redis
Redis is used by the gems Resque and Resque Scheduler for background jobs, and is only
needed if you desire to do background emailing, Notifications, Reports/PDFs which are 
all optional features in osProtect.
    cd ~/src (you may need to > mkdir ~/src)
    wget http://redis.googlecode.com/files/redis-2.4.6.tar.gz
    tar xzf redis-2.4.6.tar.gz
    cd redis-2.4.6

You may wish to do the following as root or preferably as sudo.
    make
    make install
    mkdir /etc/redis
    mkdir /var/redis
    cp redis.conf /etc/redis/
    nano /etc/redis/redis.conf

If you use Upstart then do this:
    mkdir /var/log/redis
    nano /etc/init/redis-server.conf ... and enter the following (not indented) and save:
    description "redis server"
    start on runlevel [2345]
    stop on shutdown
    exec /usr/local/bin/redis-server /etc/redis/redis.conf
    respawn
The above will start Redis when the server is rebooted, and restarts it if it is killed or dies.

To test Redis you can manually start it by doing (for Upstart):
    sudo service redis-server start (also, stop or restart)
To test that it works:
    redis-cli info
- or -
    redis-cli ping
