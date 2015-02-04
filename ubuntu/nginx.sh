#!/bin/bash

self=$(cd $(dirname $BASH_SOURCE); pwd)/$(basename $BASH_SOURCE)
group=nginx

if [ $(id -gn) != $group ]; then

echo "Installing Nginx ..."; {

  # Install Nginx
  aptitude -y install nginx
  addgroup $group
  usermod -aG $group `whoami`

  # Loosen permissions
  sudo chmod +rx /var/log/nginx
  sudo chmod 711 $HOME

  # Install Nginx as a service
  sudo chkconfig nginx on

  # Run with `nginx` group
  exec sg $group "$self"

} 2>&1 | sed "s/^/   /"
else {

  # Start Nginx
  sudo /etc/init.d/nginx start

} 2>&1 | sed "s/^/   /"

fi
