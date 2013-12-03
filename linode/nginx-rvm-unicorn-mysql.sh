#!/bin/bash

# <UDF name="hostname" label="Hostname">
# <UDF name="username" label="Username">
# <UDF name="password" label="Password">
# <UDF name="ruby" label="Ruby version" default="2.0.0">
# <UDF name="mysqlpassword" label="MySQL root password"/>
# <UDF name="application" label="Rack application (optional)">

\curl -L https://raw.github.com/archan937/stackscripts/master/ubuntu/nginx-rvm-unicorn-mysql.sh | bash