# syntax=docker/dockerfile:1-labs
FROM php:8.4.2-zts-alpine3.21

ENV SWOOLE_VERSION=6.0.0
ENV PHPREDIS_VERSION=6.1.0
ARG PRAEFECTUS_VERSION=20220825.13
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV ENABLE_JIT=1
ENV TERM="xterm"

RUN set -e -u -x \
    # Install packages \
    && apk update \
    && apk upgrade --available && sync \
    && apk add --no-cache --no-progress --virtual BUILD_DEPS ${PHPIZE_DEPS} linux-headers oniguruma-dev \
    && apk add --no-cache --no-progress \
        bash \
        binutils \
        coreutils \
        git \
        libltdl \
        libpq \
        libressl \
        libstdc++ \
        openssl \
        jq \
        openssh-client \
        patch \
        tini \
        c-ares \
        liburing \
        liburing-dev \
    # Install php-ext-sockets
    && docker-php-ext-install -j$(nproc) sockets \
    # Install php-ext-pgsql
    #&& apk add --no-cache --no-progress postgresql-client postgresql-libs \
    #&& apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_PGSQL postgresql-dev \
    #&& docker-php-ext-install -j$(nproc) pdo_pgsql pgsql \
    # Install Swoole
    #&& apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_SWOOLE curl-dev c-ares-dev \
    #&& curl -fsSL https://github.com/swoole/swoole-src/archive/v6.0.0.tar.gz -o swoole.tar.gz \
    #&& mkdir -p /tmp/swoole \
    #&& tar -xf swoole.tar.gz -C /tmp/swoole --strip-components=1 \
    #&& rm swoole.tar.gz \
    # --enable-iouring --enable-debug --enable-trace-log
    #&& docker-php-ext-configure /tmp/swoole --enable-debug --enable-trace-log --enable-swoole-thread --enable-openssl --enable-swoole-curl --enable-cares --enable-swoole-pgsql \
    #&& docker-php-ext-install -j$(nproc) /tmp/swoole \
    #&& docker-php-ext-enable swoole \
    # Install php-ext-pcntl
    && docker-php-ext-install -j$(nproc) pcntl \
    # Install php-ext-opcache
    && docker-php-ext-install -j$(nproc) opcache \
    # Clean up
    && apk del --no-progress BUILD_DEPS \
    #    BUILD_DEPS_PHP_PGSQL \
    #    BUILD_DEPS_PHP_SWOOLE \
    #    BUILD_DEPS_PHP_XLSWRITER \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY docker-entrypoint.sh /entrypoint.sh
COPY opcache.ini /usr/local/etc/php/conf.d/101-opcache.ini
WORKDIR /app

COPY test.php /app/test.php

CMD ["/app/test.php"]
ENTRYPOINT ["tini", "-v", "--", "/entrypoint.sh"]
