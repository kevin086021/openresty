#!/bin/sh

service cron start
echo resolver $(awk 'BEGIN{ORS=" "} $1=="nameserver" {print $2}' /etc/resolv.conf) ";" > /work/conf/resolvers.conf
/usr/local/openresty/bin/openresty -g "daemon off;" -p /work -c /work/conf/nginx.conf