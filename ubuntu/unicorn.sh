#!/bin/bash

self=$(cd $(dirname $BASH_SOURCE); pwd)/$(basename $BASH_SOURCE)
group=rvm
templates="$HOME/stackscripts/templates/unicorn"

if [ $(id -gn) != $group ]; then

echo "Installing Unicorn ..."; {

  # Run with `rvm` group
  exec sg $group "$self"

} 2>&1 | sed "s/^/   /"
else {

  # Load RVM
  source /etc/profile.d/rvm.sh

  # Install Unicorn
  gem install unicorn --no-rdoc --no-ri
  rvm wrapper `rvm current` boot unicorn

  # Install init.d script
  cp $templates/init.d /etc/init.d/unicorn
  chmod 755 /etc/init.d/unicorn
  chkconfig --add unicorn
  chkconfig unicorn on
  mkdir -p /etc/unicorn

  # Start Unicorn
  /etc/init.d/unicorn start

} 2>&1 | sed "s/^/   /"

fi