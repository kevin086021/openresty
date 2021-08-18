FROM openresty/openresty

VOLUME /nginx_logs

ADD app /work/app
ADD conf /work/conf

RUN mkdir -p /work/logs

RUN mv -f /work/app/configs/env.online.lua /work/app/configs/env.lua

RUN mv -f /work/conf/nginx.online.conf /work/conf/nginx.conf

RUN apt-get -y update

RUN apt-get -y install zlib1g-dev

EXPOSE 80

CMD ["/work/app/tools/start.sh"]

#CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;", "-p", "/work", "-c", "/work/conf/nginx.conf"]

