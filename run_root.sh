#!/bin/bash
service mongodb stop &&
killall mongod 2> /dev/null
build/opt/mongo/mongod -f /etc/mongod.conf

