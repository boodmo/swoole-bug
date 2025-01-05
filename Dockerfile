# syntax=docker/dockerfile:1-labs
FROM php:8.4.2-alpine3.21

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
    && apk add --no-cache --no-progress postgresql-client postgresql-libs \
    && apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_PGSQL postgresql-dev \
    && docker-php-ext-install -j$(nproc) pdo_pgsql pgsql \
    # Install Swoole
    && apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_SWOOLE curl-dev c-ares-dev \
    && curl -fsSL https://github.com/swoole/swoole-src/archive/v6.0.0.tar.gz -o swoole.tar.gz \
    && mkdir -p /tmp/swoole \
    && tar -xf swoole.tar.gz -C /tmp/swoole --strip-components=1 \
    && rm swoole.tar.gz \
    # --enable-iouring --enable-debug --enable-trace-log
    && docker-php-ext-configure /tmp/swoole --enable-debug --enable-trace-log --enable-openssl --enable-swoole-curl --enable-cares --enable-swoole-pgsql \
    && docker-php-ext-install -j$(nproc) /tmp/swoole \
    && docker-php-ext-enable swoole \
    # Install php-ext-pcntl
    && docker-php-ext-install -j$(nproc) pcntl \
    # Install php-ext-gd
    && apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_GD freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev \
    && apk add --no-cache --no-progress freetype libjpeg-turbo libpng libwebp \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd \
    # Install php-ext-gnupg
    #&& apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_GNUPG gpgme-dev \
    #&& apk add --no-cache --no-progress gpgme \
    #&& pecl install gnupg \
    #&& docker-php-ext-enable gnupg \
    # Install php-ext-intl
    && apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_INTL icu-dev \
    && apk add --no-cache --no-progress icu \
    && docker-php-ext-install -j$(nproc) intl \
    # Install php-ext-opcache
    && docker-php-ext-install -j$(nproc) opcache \
    # Install pecl-ext-igbinary
    && pecl install igbinary \
    && docker-php-ext-enable igbinary \
    # Install pecl-ext-redis
    && pecl install -D 'enable-redis-igbinary="yes" enable-redis-lzf="yes"' redis-${PHPREDIS_VERSION} \
    && docker-php-ext-enable redis \
    # Install ext-amqp (temporary, waiting libs with PHP8 supporting in PECL repo)
    # See: https://www.exploit.cz/how-to-compile-amqp-extension-for-php-8-0-via-multistage-dockerfile/
    && docker-php-source extract \
    && apk add --no-cache --no-progress rabbitmq-c \
    && apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_AMQP rabbitmq-c-dev \
    && pecl install amqp \
    && docker-php-ext-enable amqp \
    # Install php-ext-zip
    && apk add --no-cache --no-progress --virtual BUILD_DEPS_PHP_ZIP libzip-dev \
    && apk add --no-cache --no-progress libzip \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-enable zip \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-enable bcmath \
    # Add support of multipart/form-data for PUT
    && pecl install apfd \
    && docker-php-ext-enable apfd \
    # Add support of native GRPC
    #&& pecl install grpc \
    #&& docker-php-ext-enable grpc \
    # Add support for code coverage
    && pecl install pcov \
    # Install ext-xlswriter
    #&& apk add  --no-progress --virtual BUILD_DEPS_PHP_XLSWRITER zlib-dev \
    #&& git clone --recursive https://github.com/viest/php-ext-xlswriter /tmp/xlswriter-src \
    #&& cd /tmp/xlswriter-src \
    #&& phpize && ./configure --with-php-config=/usr/local/bin/php-config --enable-reader \
    #&& make && make install \
    #&& echo "extension=xlswriter.so" > /usr/local/etc/php/conf.d/docker-php-ext-xlswriter.ini \
    && pecl install xlswriter \
    && docker-php-ext-enable xlswriter \
    # Clean up
    && apk del --no-progress BUILD_DEPS \
        BUILD_DEPS_PHP_AMQP \
        BUILD_DEPS_PHP_GD \
        BUILD_DEPS_PHP_INTL \
        BUILD_DEPS_PHP_PGSQL \
        BUILD_DEPS_PHP_SWOOLE \
        BUILD_DEPS_PHP_ZIP \
    #    BUILD_DEPS_PHP_XLSWRITER \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR /app

COPY test.php /app/test.php

CMD ["/app/test.php"]
ENTRYPOINT ["tini", "-v", "--", "/entrypoint.sh"]
