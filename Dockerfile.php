# Using an official PHP image as base image
FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
# build-base is for compiling extensions, mysql-client for pdo_mysql and mysql CLI
# icu-dev for intl, libzip-dev for zip, libpng-dev/libjpeg-turbo-dev/freetype-dev for gd
# oniguruma-dev for mbstring, hiredis-dev for redis PECL extension
RUN apk update && apk add --no-cache \
    build-base \
    mysql-client \
    icu-dev \
    libzip-dev \
    zlib-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    git \
    unzip \
    hiredis-dev

# Install PHP extensions
# Configure GD with FreeType and JPEG support
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    zip \
    intl \
    gd \
    mbstring \
    exif \
    pcntl \
    bcmath \
    opcache

# Install Redis PECL extension
# build-base and hiredis-dev are already installed.
# phpize (used by pecl) needs autoconf. We install it temporarily.
RUN apk add --no-cache --virtual .build-deps-redis autoconf \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps-redis

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Clear Composer cache before trying to create the project
# (Might be useful if we use composer create-project later)
RUN composer clear-cache


# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]