#!/bin/bash

mkdir $HOME/install
exec &> $HOME/install/install.log

# Set hostname
echo "$HOSTNAME" > /etc/hostname
hostname -F /etc/hostname
echo -e "\n127.0.0.1 $HOSTNAME $HOSTNAME.local\n" >> /etc/hosts

# Update system
apt-get update
apt-get -y install aptitude
aptitude -y full-upgrade

# Update en-US locale
dpkg-reconfigure locales
update-locale LANG=en_US.UTF-8

# Install common packages
yes | aptitude install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libexpat1 ssl-cert libcurl4-openssl-dev libaprutil1-dev libapr1-dev apache2 apache2.2-common apache2-mpm-prefork apache2-utils apache2-prefork-dev

# Install vim, wget, less, enable color root prompt and the "ll" list long alias
aptitude -y install wget vim less
sed -i -e 's/^#PS1=/PS1=/' /root/.bashrc
sed -i -e "s/^#alias ll='ls -l'/alias ll='ls -al'/" /root/.bashrc

# Install find utils
aptitude install findutils locate
updatedb
crontab -l > file; echo "0 0 * * * /usr/bin/updatedb" >> file; crontab file

# Install Nginx
aptitude install nginx

# Install RVM
\curl -L https://get.rvm.io | sudo bash -s stable
source /etc/profile.d/rvm.sh

# Add global gems
echo "rake" >> /usr/local/rvm/gemsets/global.gems
echo "bundler" >> /usr/local/rvm/gemsets/global.gems

# Install Ruby
rvmsudo rvm install $RUBY
rvmsudo rvm use $RUBY --default

# Update Rubygems
rvmsudo gem update --system

# Install Unicorn
rvmsudo gem install unicorn --no-rdoc --no-ri

# Install /etc/init.d/unicorn
wget https://raw.github.com/archan937/stackscripts/master/templates/unicorn.init.d -P /etc/init.d/unicorn
chmod 755 /etc/init.d/unicorn
/usr/sbin/update-rc.d -f unicorn defaults
mkdir /etc/unicorn

# Install mash
wget https://raw.github.com/archan937/stackscripts/master/utils/mash -P /usr/local/bin/
chmod +x /usr/local/bin/mash

# Install MySQL
if [ "$MYSQLPASSWORD" != "" ]; then
    echo "mysql-server-5.1 mysql-server/root_password password $MYSQLPASSWORD" | debconf-set-selections
    echo "mysql-server-5.1 mysql-server/root_password_again password $MYSQLPASSWORD" | debconf-set-selections
    apt-get -y install mysql-server mysql-client
    sleep 5
fi

# Add user
if [ "$USERNAME" != "" ] && [ "$PASSWORD" != "" ]; then
    useradd --home /home/$USERNAME --create-home --shell /bin/bash $USERNAME
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers
fi

# Setup a simple Rack application
if [ "$APPLICATION" != "" ]; then
    mkdir -p /var/www/$APPLICATION
    mkdir /var/www/$APPLICATION/public
    mkdir /var/www/$APPLICATION/log
    mkdir /var/www/$APPLICATION/tmp
    mkdir /var/www/$APPLICATION/tmp/sockets
    mkdir /var/www/$APPLICATION/tmp/pids

    wget https://raw.github.com/archan937/stackscripts/master/templates/nginx.conf     -P $HOME/install/
    wget https://raw.github.com/archan937/stackscripts/master/templates/unicorn.conf   -P $HOME/install/
    wget https://raw.github.com/archan937/stackscripts/master/templates/unicorn.rb     -P $HOME/install/
    wget https://raw.github.com/archan937/stackscripts/master/templates/rack.config.ru -P $HOME/install/

    mash $HOME/install/nginx.conf     application:$APPLICATION > /etc/nginx/sites-available/$APPLICATION
    mash $HOME/install/unicorn.conf   application:$APPLICATION > /etc/unicorn/$APPLICATION.conf
    mash $HOME/install/unicorn.rb     application:$APPLICATION > /var/www/$APPLICATION/unicorn.rb
    mash $HOME/install/rack.config.ru application:$APPLICATION > /var/www/$APPLICATION/config.ru

    ln -nfs /etc/nginx/sites-available/$APPLICATION /etc/nginx/sites-enabled/$APPLICATION
    rm /etc/nginx/sites-enabled/default

    /etc/init.d/nginx reload && /etc/init.d/unicorn start
fi

echo "Installation completed. Please reboot the server."