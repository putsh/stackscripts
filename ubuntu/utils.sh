#!/bin/bash

utils="$HOME/stackscripts/utils"

echo "Installing utilities ..."; {

  # Symlink addapp
  echo "Symlinking addapp"
  ln -nfs $utils/addapp /usr/local/bin/

  # Install Mash
  echo "Copying Mash"
  cp $utils/mash /usr/local/bin/
  chmod +x /usr/local/bin/mash

} 2>&1 | sed "s/^/   /"