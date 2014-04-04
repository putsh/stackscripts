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
# A sample configuration file (e.g. /etc/unicorn/my_rack_or_rails_based_app.conf)
#
#     APP_ROOT=/home/bangmedia/my_app/current
#     APP_CONFIG=config/unicorn.rb
#     APP_ENV=production
#
# This configures a unicorn master for your app at /home/bangmedia/my_app/current running in
# production mode. It will read config/unicorn.rb for further set up.
#
# You should ensure different ports or sockets are set in each config/unicorn.rb if
# you are running more than one master concurrently.
#
# Example: (restart Unicorn application only for /etc/unicorn/my_rack_or_rails_based_app.conf)
#
#     $ sudo /etc/init.d/unicorn restart my_rack_or_rails_based_app
#
# $1 - Command to run <start|stop|restart|upgrade|rotate|force-stop>
# $2 - Name of Unicorn conf (optional)

set -e

sig () {
  test -s "$PID" && kill -$1 `cat "$PID"`
}

oldsig () {
  test -s "$OLD_PID" && kill -$1 `cat "$OLD_PID"`
}

run () {
  cd $APP_ROOT || return

  export PID=$APP_PID
  export OLD_PID="$PID.oldbin"
  CMD="/usr/local/rvm/bin/boot_unicorn -c $APP_CONFIG -E $APP_ENV -D"

  case ${1:-start} in
    start)
      sig 0 && echo >&2 "Already running" && return
      echo "Starting $APP_ROOT"
      $CMD
      ;;
    stop)
      sig QUIT && echo "Stopping $APP_ROOT" && return
      echo >&2 "Not running"
      ;;
    force-stop)
      sig TERM && echo "Forcing stop $APP_ROOT" && return
      echo >&2 "Not running"
      ;;
    restart|reload)
      sig USR2 && sleep 5 && oldsig QUIT && echo "Reloading $APP_ROOT" && return
      echo >&2 "Couldn't reload, starting '$CMD' instead"
      $CMD
      ;;
    upgrade)
      sig USR2 && echo "Upgraded $APP_ROOT" && return
      echo >&2 "Couldn't upgrade, starting '$CMD' instead"
      $CMD
      ;;
    rotate)
      sig USR1 && echo "Rotated logs $APP_ROOT" && return
      echo >&2 "Couldn't rotate logs" && return
      ;;
    *)
      echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop> <name of conf (optional)>"
      return
      ;;
  esac
}

dir="/etc/unicorn"

if [ $2 ]; then
  source $dir/$2.conf
  run $1
else
  if [ "$(ls -A $dir)" ]; then
    for CONF in $dir/*.conf; do
      source $CONF
      run $1
    done
  fi
fi