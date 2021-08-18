#!/bin/sh
cd /home/your_name/web/openresty_base
git status
git stash
git pull 

cd /home/your_name/web/openresty_base/conf/
sudo cp nginx.online.conf nginx.conf

cd /home/your_name/web/openresty_base/app/configs
sudo cp env.online.lua env.lua

cd /home/your_name/web/openresty_base/
sudo killall -9 nginx 
sudo /usr/local/openresty/nginx/sbin/nginx 
sudo /usr/local/openresty/nginx/sbin/nginx -p `pwd`/ -c conf/nginx.conf
