#!/bin/bash

self=$(cd $(dirname $BASH_SOURCE); pwd)/$(basename $BASH_SOURCE)
group=rvm

addgroup $group

if [ $(id -gn) != $group ]; then

echo "Installing RVM ..."; {

  # Install RVM package(s)
  aptitude -y install build-essential bison autoconf openssl ssl-cert
  aptitude -y install libreadline6 libreadline6-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev
  aptitude -y install libexpat1 libcurl4-openssl-dev libaprutil1-dev libapr1-dev zlib1g zlib1g-dev

  # Install RVM (multi-user mode)
  curl -sSL https://get.rvm.io | sudo bash -s stable
  sudo usermod -aG $group `whoami`
  sudo usermod -aG $group root

  # Run with `rvm` group
  exec sg $group "$self"

} 2>&1 | sed "s/^/   /"
else {

  # Load RVM
  source /etc/profile.d/rvm.sh

  # Test RVM
  type rvm | head -n1

  # Add global gems
  echo "rake" | sudo tee -a /usr/local/rvm/gemsets/global.gems > /dev/null
  echo "bundler" | sudo tee -a /usr/local/rvm/gemsets/global.gems > /dev/null

  # Install Ruby 2.1.5
  ruby="ruby-2.1.5"
  rvmsudo rvm install $ruby
  rvm use $ruby --default

  # Update Rubygems
  gem update --system

} 2>&1 | sed "s/^/   /"

fi