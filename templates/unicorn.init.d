#!/bin/sh
#
### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $all
# Required-Stop:     $network $local_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts unicorn applications
# Description:       init.d script for single or multiple unicorn installations
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
  CMD="/usr/local/rvm/bin/boot_unicorn -c $CONFIG -E $ENVIRONMENT -D"

  case ${1:-start} in
    start)
      echo "Starting $ROOT"
      sig 0 && echo >&2 "Already running" && exit 0
      $CMD
      ;;
    stop)
      echo "Stopping $ROOT"
      sig QUIT && exit 0
      echo >&2 "Not running"
      ;;
    restart|reload)
      echo "Reloading $ROOT"
      sig HUP && exit 0
      echo >&2 "Couldn't reload, starting '$CMD' instead"
      $CMD
      ;;
    upgrade)
      echo "Upgrading $ROOT"
      sig USR2 && exit 0
      echo >&2 "Couldn't upgrade, starting '$CMD' instead"
      $CMD
      ;;
    rotate)
      echo "Rotating logs $ROOT"
      sig USR1 && exit 0
      echo >&2 "Couldn't rotate logs" && exit 1
      ;;
    force-stop)
      echo "Forcing stop $ROOT"
      sig TERM && exit 0
      echo >&2 "Not running"
      ;;
    *)
      echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop> <name of conf (optional)>"
      exit 1
      ;;
  esac
}

ARGS="$1 $2"

if [ $2 ]; then
  . /etc/unicorn/$2.conf
  run $ARGS
else
  for CONFIG in /etc/unicorn/*.conf; do
    . $CONFIG
    run $ARGS
  done
fi