FROM debian:8
RUN apt-get -y update
RUN apt-get install -y curl supervisor git openssl build-essential libssl-dev wget vim curl tree nano less
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
WORKDIR /apps/
RUN wget -O - http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.27.tar.gz | tar zxfv - \
    && CPU=$(( `nproc --all`-1 )) \
    && cd /apps/squid-3.5.27/ \
    && ./configure --prefix=/apps/squid --enable-icap-client --enable-ssl --with-openssl --enable-ssl-crtd --enable-auth --enable-basic-auth-helpers="NCSA" \
    && make -j$CPU \
    && make install \
    && cd /apps \
    && rm -rf /apps/squid-3.5.27
ADD . /apps/

RUN chown -R nobody:nogroup /apps/
RUN mkdir -p  /apps/squid/var/lib/
RUN /apps/squid/libexec/ssl_crtd -c -s /apps/squid/var/lib/ssl_db -M 4MB
RUN /apps/squid/sbin/squid -z -f /apps/squid.conf.cache
RUN chown -R nobody:nogroup /apps/

EXPOSE 3128
#CMD ["/usr/bin/supervisord"]
