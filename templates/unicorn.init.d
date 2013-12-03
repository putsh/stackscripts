#!/bin/sh
#
### BEGIN INIT INFO
# Short-Description: Unicorn init.d
# Description:       init.d script for single or multiple Unicorn installations
# Provides:          Unicorn
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
### END INIT INFO
#
# Modified by archan937@gmail.com http://github.com/archan937
# based on https://gist.github.com/jaygooby/504875 by http://github.com/jaygooby
#
# Expects at least one configuration file in /etc/unicorn
#
# A sample configuration file (e.g. /etc/unicorn/my_rack_based_app.conf)
#
#     ROOT=/var/www/my_rack_based_app
#     CONFIG=/var/www/my_rack_based_app/unicorn.rb
#     ENVIRONMENT=production
#
# This configures a unicorn master for your app at /var/www/my_rack_based_app running in
# production mode. It will read config/unicorn.rb for further set up.
#
# You should ensure different ports or sockets are set in each config/unicorn.rb if
# you are running more than one master concurrently.
#
# Example: (restart Unicorn application only for /etc/unicorn/my_rack_based_app.conf)
#
#   $ /etc/init.d/unicorn restart my_rack_based_app
#
# $1 - Command to run <start|stop|restart|upgrade|rotate|force-stop>
# $2 - Name of Unicorn conf (optional)

set -e

sig () {
  test -s "$PID" && kill -$1 `cat "$PID"`
}

run () {
  cd $ROOT || exit 1

  export PID=$ROOT/tmp/pids/unicorn.pid
  CMD="/usr/local/rvm/gems/`rvm current`/bin/unicorn -c $CONFIG -E $ENVIRONMENT -D"

  case $1 in
    start)
      echo "Starting $ROOT"
      sig 0 && echo >&2 "Already running" && exit 0
      $CMD
      ;;
    stop)
      echo "Stopping $ROOT"
      sig QUIT && echo >&2 "Not running" && exit 0
      ;;
    restart|reload)
      echo "Reloading $ROOT"
      sig HUP && echo reloaded OK && exit 0
      echo >&2 "Couldn't reload, starting '$CMD' instead"
      $CMD
      ;;
    upgrade)
      echo "Upgrading $ROOT"
      sig USR2 && echo Upgraded && exit 0
      echo >&2 "Couldn't upgrade, starting '$CMD' instead"
      $CMD
      ;;
    rotate)
      echo "Rotating logs $ROOT"
      sig USR1 && echo rotated logs OK && exit 0
      echo >&2 "Couldn't rotate logs" && exit 1
      ;;
    force-stop)
      echo "Forcing stop $ROOT"
      sig TERM && echo >&2 "Not running" && exit 0
      ;;
    *)
      echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop> <name of conf (optional)>"
      exit 1
      ;;
  esac
}

if [ $2 ]; then
  . /etc/unicorn/$2.conf
  run
else
  for CONFIG in /etc/unicorn/*.conf; do
    . $CONFIG
    run
  done
fi