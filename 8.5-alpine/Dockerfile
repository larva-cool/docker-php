FROM alpine:3.23

LABEL maintainer="Tongle Xu <xutongle@msn.com>" version="1.0" license="MIT"

WORKDIR /app

RUN set -ex \
    && apk update \
    && apk add --no-cache \
    # Install base packages ('ca-certificates' will install 'nghttp2-libs')
    ca-certificates \
    curl \
    wget \
    tar \
    xz \
    tzdata \
    pcre \
    php85 \
    php85-bcmath \
    php85-curl \
    php85-ctype \
    php85-dom \
    php85-fileinfo \
    php85-gd \
    php85-iconv \
    php85-intl \
    php85-mbstring \
    php85-mysqlnd \
    php85-openssl \
    php85-pdo \
    php85-pdo_mysql \
    php85-phar \
    php85-posix \
    php85-redis \
    php85-sockets \
    php85-sodium \
    php85-sysvshm \
    php85-sysvmsg \
    php85-sysvsem \
    php85-simplexml \
    php85-tokenizer \
    php85-zip \
    php85-zlib \
    php85-xml \
    php85-xmlreader \
    php85-xmlwriter \
    php85-pcntl \
    php85-pecl-mongodb \
    php85-pecl-rdkafka \
    php85-pecl-memcached \
    php85-pecl-msgpack \
    php85-pecl-igbinary \
    php85-pecl-event \
    php85-pecl-protobuf \
    php85-pecl-amqp \
    php85-pecl-imagick \
    # php85-pecl-swoole \
    && ln -sf /usr/bin/php85 /usr/bin/php \
    && curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && apk del --purge *-dev \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man /usr/share/php85 \
    && php -v \
    && php -m \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

COPY php.ini /etc/php85/conf.d/99-php.ini

CMD ["php", "-a"]
