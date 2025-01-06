# syntax=docker/dockerfile:1-labs
FROM php:8.4.2-cli-alpine3.21

RUN set -e -u -x \
    # Install packages \
    && apk update \
    && apk upgrade --available && sync \
    && apk add --no-cache --no-progress --virtual BUILD_DEPS ${PHPIZE_DEPS} linux-headers oniguruma-dev \
    && apk add --no-cache --no-progress \
            bash \
    # Install php-ext-opcache
    && docker-php-ext-install -j$(nproc) opcache \
    # Clean up
    && apk del --no-progress BUILD_DEPS \
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
