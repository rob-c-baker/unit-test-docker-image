FROM php:8.3

# Updates & requirements
RUN apt-get update \
    && apt-get install -y \
        git \
        unzip \
        libicu-dev \
        libzip-dev \
        libpng-dev \
        libmagickwand-dev \
    --no-install-recommends

# php extensions
RUN docker-php-ext-install -j$(nproc) bcmath intl zip exif gd pcntl \
    && docker-php-ext-enable bcmath intl zip exif gd pcntl

# Install for Imagick on PHP 8.3 due to https://github.com/Imagick/imagick/issues/643 \
RUN curl -L -o /tmp/imagick.tar.gz https://github.com/Imagick/imagick/archive/7088edc353f53c4bc644573a79cdcd67a726ae16.tar.gz \
    && tar --strip-components=1 -xf /tmp/imagick.tar.gz \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && rm /tmp/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
