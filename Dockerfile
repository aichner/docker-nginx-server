FROM alpine:latest

LABEL description "Lightweight content server container with Nginx based on Alpine Linux."

# developed for Pharmaziegasse(R) by Florian Kleber for terms of use have a look at the LICENSE file
MAINTAINER Florian Kleber <kleberbaum@erebos.xyz>

# WordPress change here to desired version
ARG CONTENT_URL=https://github.com/IndividualDifference/docker-wordpress/releases/download/1.0/config.tar.gz
ARG CONTENT_SHA1=ac54253b369f0e7e67b8fe5bf47e33a8f00c710f

# Config change here to desired config backup
ARG CONFIG_URL=https://github.com/IndividualDifference/docker-wordpress/releases/download/1.0/config.tar.gz
ARG CONFIG_SHA1=ac54253b369f0e7e67b8fe5bf47e33a8f00c710f

WORKDIR /var/www/content

# update, install and cleaning
RUN echo "## Installing base ##" && \
    echo "@main http://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/main && \
    echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    apk upgrade --update-cache --available && \
    \
    apk add --force \
        bash@main \
        nginx@main \
        php7@community \
        php7-fpm@community \
        php7-mysqli@community \
        php7-json@community \
        php7-openssl@community \
        php7-curl@community \
        php7-zlib@community \
        php7-xml@community \
        php7-phar@community \
        php7-intl@community \
        php7-dom@community \
        php7-xmlreader@community \
        php7-ctype@community \
        php7-mbstring@community \
        php7-gd@community \
        supervisor@main \
        tini@community \
    \
    && chown -R nobody.nobody /var/www \
    && mkdir -p /usr/src \
    && echo "## Downloading content ##" \
    && wget "${CONTENT_URL}" -O content.tar.gz \
    && echo "$CONTENT_SHA1 *content.tar.gz" | sha1sum -c - \
    && tar -xzf content.tar.gz -C /usr/src/ \
    && chown -R nobody.nobody /usr/src/content \
    && echo "## Downloading config ##" \
    && wget "${CONFIG_URL}" -O config.tar.gz \
    && echo "$CONFIG_SHA1 *config.tar.gz" | sha1sum -c - \
    && echo "## Configuring nginx ##" \
    && tar -xzf config.tar.gz -C /etc/nginx/ nginx.conf \
    && echo "## Configuring php-fpm ##" \
    && tar -xzf config.tar.gz -C /etc/php7/php-fpm.d/ zzz_custom.conf \
    && tar -xzf config.tar.gz -C /etc/php7/conf.d/ zzz_custom.ini \
    && echo "## Configuring supervisord ##" \
    && tar -xzf config.tar.gz -C /etc/ supervisord.conf \
    && echo "## Configuring nginx ##" \
    && tar -xzf config.tar.gz -C /usr/src/wordpress/ wp-config.php \
    && chown nobody.nobody /usr/src/wordpress/wp-config.php  \
    && chmod 640 /usr/src/wordpress/wp-config.php \
    \
    && rm wordpress.tar.gz \
    && rm config.tar.gz \
    && rm -rf /tmp/* /var/cache/apk/* /var/cache/distfiles/*

EXPOSE 80

# add volume
VOLUME /var/www/content

# add license
ADD LICENSE /

# deploy init script
ADD docker-entrypoint.sh /

# starting via tini as init
ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]

CMD ["/usr/bin/supervisord"]
