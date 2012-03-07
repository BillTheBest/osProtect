rails -v
ruby -v
apt-get update
apt-get upgrade
apt-get dist-upgrade

apt-get install gcc g++ build-essential libssl-dev libreadline5-dev zlib1g-dev linux-headers-generic 
libsqlite3-dev sqlite3 git-core python-software-properties

aptitude install build-essential bison openssl libreadline6 libreadline6-dev curl git-core 
zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libexpat1 ssl-cert 
libcurl4-openssl-dev libaprutil1-dev libapr1-dev 
mysql mysql-server 
apache2 apache2.2-common apache2-mpm-prefork apache2-utils apache2-prefork-dev

sudo apt-get install nmap nbtscan apache2 php5 php5-mysql php5-gd libpcap0.8-dev libpcre3-dev g++ bison flex 
libpcap-ruby mysql-server libmysqlclient16-dev

mkdir /TEMP
cd /TEMP/
wget ftp://ftp.ruby-lang.org//pub/ruby/1.9/ruby-1.9.2-p290.tar.gz
tar -xvzf ruby-1.9.2-p290.tar.gz
cd ruby-1.9.2-p0/
ls
cd ruby-1.9.2-p290/
./configure --prefix=/usr/local/ruby
make && sudo make install
nano /etc/environment
source /etc/environment
ruby -v
sudo ln -s /usr/local/ruby/bin/ruby /usr/local/bin/ruby
sudo ln -s /usr/local/ruby/bin/gem /usr/bin/gem
gem install tzinfo builder memcache-client rack rack-test erubis mail text-format bundler thor i18n sqlite3-ruby thin
gem install rack-mount --version=0.4.0
gem install rails --version 3.0.0
sqlite -version
sqlite3 -version
rails -v
thin -v
sudo gem update rails
reboot
git -help
git --version
exit
nano /etc/hosts
nano /etc/hostname 
nano /etc/network/interfaces 
rm /etc/udev/rules.d/70-persistent-net.rules 
reboot
exit
find -name index.php
find -name index.*
cd /
find -name index.*
ls
mkdir /var/www
cd /var/www
rails new osProtect
ls
cd osProtect/
ls
cd app/views/
cd /var/www/osProtect/Gemfile
nano /var/www/osProtect/Gemfile
cd /var/www/osProtect/
bundle install
rails server
gem install execjs
bundle install
rails server
nano /var/www/osProtect/Gemfile
bundle install
rails server
nano /var/www/osProtect/Gemfile
bundle install
rails server
nano /var/www/osProtect/Gemfile
ls
rails server
rails server -help
rails server -d
ls
ls -la
nano .gitignore 
git init
git add .
git status
exit
nano /etc/network/interfaces 
nano /etc/hosts
apt-get update
apt-get dist-upgrade
nano /etc/network/interfaces 
shutdown -P now
apt-get update
apt-get dist-upgrade
ping 192.168.11.112
ifconfig
ping 192.168.11.1
ping 192.168.11.112
ping 192.168.11.113
ping 192.168.11.111
ping 192.168.11.110
ping 192.168.11.112
ping 192.168.11.110
ping 192.168.11.112
ping 192.168.11.1
reboot
ping 192.168.11.112
arp -a
apt-get update
apt-get dist-upgrade
mount /dev/cdrom /mnt
cd /mnt/
ls
cd Linux/
ls
cp xe-guest-utilities_6.0.0-743_amd64.de /
cp xe-guest-utilities_6.0.0-743_amd64.deb /
cd /
mkdir TEMP
cp xe-guest-utilities_6.0.0-743_amd64.deb /TEMP/
cd TEMP/
ls
dpkg -i xe-guest-utilities_6.0.0-743_amd64.deb 
shutdown -P now
nano /etc/hostname 
nano /etc/network/interfaces 
reboot
ps -ef | grep ss
ruby -v
rails -v
apt-get update
apt-get dist-upgrade
nano /etc/hosts
nano /etc/hostname 
nano /etc/network/interfaces 
shutdown -P now
exit
pwd
ls
ps aux
free -lm
cat /etc/issue
cat /etc/lsb-release 
nano .bash_history 
ps aux
ping clsmith.org
ping google.com
curl
wget http://clsmith.org
wget http://google.com
wget "http://chart.apis.google.com/chart?chco=FFF804,336699,339933,ff0000,cc99cc,cf5910&chf=bg,s,FFFFFF&chd=s:9JBBAA&chl=19.168.1.3|19.168.1.4|19.168.1.8|10.81.4.130|0.0.0.1|0.0.4.87&chtt=&cht=p3&chs=900x300&chxr=0,1561,1561"
free -lm
ps aux
nano .bash_history 
nano /etc/environment 
nano .bash_history 
ifconfig
exit
apt-get update
apt-get dist-upgrade
exit
sudo apt-get update
sudo apt-get upgrade

sudo apt-get install nmap nbtscan apache2 php5 php5-mysql php5-gd libpcap0.8-dev libpcre3-dev g++ bison flex 
libpcap-ruby mysql-server libmysqlclient16-dev

sudo apt-get install phpmyadmin
cd /TEMP/
ls
wget http://www.snort.org/downloads/1408
tar zxvf 1408 
cd daq-0.6.2/
./configure 
make
make install
ldconfig
cd ..
sudo wget http://libdnet.googlecode.com/files/libdnet-1.12.tgz
tar zxvf libdnet-1.12.tgz 
cd libdnet-1.12
./configure 
make
make install
ln -s /usr/local/lib/libdnet.1.0.1 /usr/lib/libdnet.1
cd ..
wget http://zlib.net/zlib-1.2.6.tar.gz
tar zxvf zlib-1.2.6.tar.gz 
cd zlib-1.2.6
./configure 
make
make install
cd ..
wget http://www.snort.org/downloads/1416
tar 1416 
tar zxvf 1416 
cd snort-2.9.2.1/
sudo ./configure --prefix=/usr/local/snort
ls
make
make install
sudo mkdir /var/log/snort
sudo mkdir /var/snort
sudo groupadd snort
sudo useradd -g snort snort
sudo chown snort:snort /var/log/snort
echo "create database snort;" | mysql -u root -p
mysql -u root -p -D snort < ./schemas/create_mysql
echo "grant create, insert, select, delete, update on snort.* to snort@localhost identified by 'cl0nesys01'" | mysql -u root -p
cd ..
wget http://www.snort.org/sub-rules/snortrules-snapshot-2920.tar.gz/23fe804749726f14ae4fc135e4540ad81f27510d -O snortrules-snapshot-2920.tar.gz
sudo mkdir /usr/local/snort/lib/snort_dynamicrules
sudo cp /usr/local/snort/so_rules/precompiled/Ubuntu-10-4/x86-64/2.9.2.0/* /usr/local/snort/lib/snort_dynamicrules
sudo touch /usr/local/snort/rules/white_list.rules
sudo nano /usr/local/snort/etc/snort.conf
sudo cp /usr/local/snort/etc/snort.conf  /usr/local/snort/etc/snort-eth0.conf
sudo cp /usr/local/snort/etc/snort.conf  /usr/local/snort/etc/snort-eth1.conf
wget http://www.securixlive.com/download/barnyard2/barnyard2-1.9.tar.gz
tar zxvf barnyard2-1.9.tar.gz 
cd barnyard2-1.9
sudo ./configure --with-mysql
make
make install
sudo cp etc/barnyard2.conf /usr/local/snort/etc
sudo mkdir /var/log/barnyard2
sudo chmod 667 /var/log/barnyard2
sudo touch /var/log/snort/barnyard2.waldo
sudo chown snort:snort /var/log/snort/barnyard2.waldo
sudo nano /usr/local/snort/etc/barnyard2.conf
sudo cp /usr/local/snort/etc/barnyard2.conf  /usr/local/snort/etc/barnyard2-eth0.conf
sudo nano /usr/local/snort/etc/barnyard2-eth0.conf
sudo cp /usr/local/snort/etc/barnyard2.conf  /usr/local/snort/etc/barnyard2-eth1.conf
sudo nano /usr/local/snort/etc/barnyard2-eth1.conf
mkdir /var/log/snort/eth0
chmod 667 /var/log/snort/eth0
mkdir /var/log/snort/eth1
chmod 667 /var/log/snort/eth1
touch /var/log/snort/eth0/barnyard2.waldo
chown snort:snort /var/log/snort/eth0/barnyard2.waldo
chown snort:snort /var/log/snort/eth1/barnyard2.waldo
sudo nano /etc/rc.local
exit
nano /etc/network
sudo passwd root
apt-get update
apt-get dist-upgrade
nano /etc/network/interfaces 
exit
nano .bash_history 
free -lm
ps aux
exit
ps -ef | grep snort
htop
free -m\
free -m
ps -ef | grep snort
free -m
shutdown -P now
cd /home/cleesmith/apps/osprotect/releases/20120227-032005/
cd app/views/layouts/
ftp 192.168.4.3
exit
cd /home/cleesmith/apps/osprotect/releases/20120227-032005/
cd app/views/shared/
ftp 192.168.4.3
exit
cd /home/cleesmith/apps/osprotect/releases/20120302-020641/
nano app/views/layouts/application.html.erb 
reboot
cd /home/cleesmith/apps/osprotect/releases/20120302-020641/
nano app/views/layouts/application.html.erb 
scp --help
scp * root@192.168.11.132:/home/cleesmith/apps/osprotect/releases/20120227-032005/
scp -r * root@192.168.11.132:/home/cleesmith/apps/osprotect/releases/20120227-032005/
exit
shutdown -P now
nano /etc/passwd
nano /etc/passwd- 
exit
cd /home/cleesmith/apps/osprotect/
git clone git@github.com:tevo/osProtect.git
git status
git -config --global user.name "TeVo"
git config --global user.name "TeVo"
git config --global user.email tvong@clone-systems.com
git clone git@github.com:tevo/osProtect.git
ssh git@github.com
ssh -T git@github.com
ssh -vT git@github.com
nano ~/.ssh/config
nano ~/.ssh/known_hosts 
git clone git@github.com:tevo/osProtect.git
ls
nano hook.log 
git init
git status
git clone git@github.com:tevo/osProtect.git
ssh -vT git@github.com
git clone git@github.com:clonesec/osProtect.git
git status
exit
