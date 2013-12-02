#!/bin/bash

# <UDF name="hostname" label="Hostname">
# <UDF name="username" label="Username">
# <UDF name="password" label="Password">
# <UDF name="ruby" label="Ruby version" default="2.0.0">
# <UDF name="mysqlpassword" label="MySQL root password"/>
# <UDF name="application" label="Rack application (optional)">

source <ssinclude StackScriptID="1">
mkdir /root/install
exec &> /root/install/stackscript.log

# Set hostname
echo "$HOSTNAME" > /etc/hostname
hostname -F /etc/hostname
echo -e "\n127.0.0.1 $HOSTNAME $HOSTNAME.local\n" >> /etc/hosts

# Update system
system_update

# Update en-US locale
dpkg-reconfigure locales
update-locale LANG=en_US.UTF-8

# Install common packages
yes | aptitude install build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libexpat1 ssl-cert libcurl4-openssl-dev libaprutil1-dev libapr1-dev apache2 apache2.2-common apache2-mpm-prefork apache2-utils apache2-prefork-dev
goodstuff

# Install find utils
aptitude install findutils locate
updatedb
crontab -l > file; echo "0 0 * * * /usr/bin/updatedb" >> file; crontab file

# Install Nginx
aptitude install nginx

# Install RVM
\curl -L https://get.rvm.io | sudo bash -s stable
echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc

# Add global gems
echo "rake" >> /usr/local/rvm/gemsets/global.gems
echo "bundler" >> /usr/local/rvm/gemsets/global.gems

# Install Ruby
source "/usr/local/rvm/scripts/rvm"
rvm install $RUBY
rvm use $RUBY --default
rvm list

# Update Rubygems
gem update --system

# Install Unicorn
gem install unicorn --no-rdoc --no-ri

# Install /etc/init.d/unicorn
wget https://raw.github.com/archan937/stackscripts/master/linode/nginx-rvm-unicorn-mysql/unicorn -P /etc/init.d/
chmod 755 /etc/init.d/unicorn
/usr/sbin/update-rc.d -f unicorn defaults
mkdir /etc/unicorn

# Install MySQL
if [ "$MYSQLPASSWORD" != "" ]; then
    mysql_install "$MYSQLPASSWORD"
fi

# Add user
if [ "$USERNAME" != "" ] && [ "$PASSWORD" != "" ]; then
    useradd --home /home/$USERNAME --create-home --shell /bin/bash $USERNAME
    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> /home/$USERNAME/.bashrc
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

    wget https://raw.github.com/archan937/stackscripts/master/utils/mash                                  -P /usr/local/bin/
    wget https://raw.github.com/archan937/stackscripts/master/linode/nginx-rvm-unicorn-mysql/config.ru    -P /root/install/
    wget https://raw.github.com/archan937/stackscripts/master/linode/nginx-rvm-unicorn-mysql/nginx.conf   -P /root/install/
    wget https://raw.github.com/archan937/stackscripts/master/linode/nginx-rvm-unicorn-mysql/unicorn.conf -P /root/install/
    wget https://raw.github.com/archan937/stackscripts/master/linode/nginx-rvm-unicorn-mysql/unicorn.rb   -P /root/install/

    chmod +x /usr/local/bin/mash

    mash /root/install/config.ru    application:$APPLICATION > /var/www/$APPLICATION/config.ru
    mash /root/install/unicorn.rb   application:$APPLICATION > /var/www/$APPLICATION/unicorn.rb
    mash /root/install/unicorn.conf application:$APPLICATION > /etc/unicorn/$APPLICATION.conf
    mash /root/install/nginx.conf   application:$APPLICATION > /etc/nginx/sites-available/$APPLICATION

    ln -nfs /etc/nginx/sites-available/$APPLICATION /etc/nginx/sites-enabled/$APPLICATION
    rm /etc/nginx/sites-enabled/default

    /etc/init.d/nginx reload && /etc/init.d/unicorn start
fi

echo 'Installation completed. Please `reboot` the server.'
