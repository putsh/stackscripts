#!/bin/bash

echo "Updating system ..."; {

  # Update apt-get
  apt-get update

  # Install aptitude
  apt-get -y install aptitude
  aptitude -y full-upgrade

  # Update en-US locale
  dpkg-reconfigure locales
  update-locale LANG=en_US.UTF-8

  # Enable color root prompt
  sed -i -e 's/^#PS1=/PS1=/' /root/.bashrc

  # Install wget, nano and vim
  aptitude -y install wget nano vim

  # Install find utils
  aptitude -y install findutils locate
  updatedb
  crontab -l > file; echo "0 0 * * * /usr/bin/updatedb" >> file; crontab file

} 2>&1 | sed "s/^/   /"