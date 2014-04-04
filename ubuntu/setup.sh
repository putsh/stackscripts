#!/bin/bash

echo "Cloning stackscripts repository ..."; {

  # Install Git
  yes | aptitude install git-core

  # Clone Git repository
  cd $HOME
  git clone git@github.com:archan937/stackscripts.git

} 2>&1 | sed "s/^/   /"

mkdir -p $HOME/install

# Run install scripts
$HOME/stackscripts/ubuntu/system.sh
$HOME/stackscripts/ubuntu/utils.sh
$HOME/stackscripts/ubuntu/packages.sh

# Re-login to ensure correct environment
exec sudo su -l `whoami`