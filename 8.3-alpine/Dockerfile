FROM alpine:3.22

LABEL maintainer="Tongle Xu <xutongle@msn.com>" version="1.0" license="MIT"

WORKDIR /app

RUN set -ex \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
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
    php83 \
    php83-bcmath \
    php83-curl \
    php83-ctype \
    php83-dom \
    php83-fileinfo \
    php83-gd \
    php83-iconv \
    php83-intl \
    php83-mbstring \
    php83-mysqlnd \
    php83-openssl \
    php83-pdo \
    php83-pdo_mysql \
    php83-phar \
    php83-posix \
    php83-redis \
    php83-sockets \
    php83-sodium \
    php83-sysvshm \
    php83-sysvmsg \
    php83-sysvsem \
    php83-simplexml \
    php83-tokenizer \
    php83-zip \
    php83-zlib \
    php83-xml \
    php83-xmlreader \
    php83-xmlwriter \
    php83-pcntl \
    php83-opcache \
    php83-pecl-mongodb \
    php83-pecl-rdkafka \
    php83-pecl-msgpack \
    php83-pecl-igbinary \
    php83-pecl-event \
    php83-pecl-protobuf \
    php83-pecl-imagick \
    php83-pecl-amqp \
    php83-pecl-swoole \
    && ln -sf /usr/bin/php83 /usr/bin/php \
    && curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && apk del --purge *-dev \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man /usr/share/php83 \
    && php -v \
    && php -m \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

COPY php.ini /etc/php83/conf.d/99-php.ini

CMD ["php", "-a"]