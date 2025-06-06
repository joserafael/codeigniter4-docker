# Usa uma imagem oficial do PHP como imagem base
FROM php:8.2-fpm-alpine

# Define o diretório de trabalho
WORKDIR /var/www/html

# Instala dependências do sistema
# build-base é para compilar extensões, mysql-client para pdo_mysql e CLI do mysql
# icu-dev para intl, libzip-dev para zip, libpng-dev/libjpeg-turbo-dev/freetype-dev para gd
# oniguruma-dev para mbstring, hiredis-dev para a extensão PECL do redis
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

# Instala extensões do PHP
# Configura GD com suporte para FreeType e JPEG
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

# Instala a extensão PECL do Redis
# build-base e hiredis-dev já estão instalados.
# phpize (usado pelo pecl) precisa do autoconf. Instalamos temporariamente.
RUN apk add --no-cache --virtual .build-deps-redis autoconf \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps-redis

# Instala o Composer globalmente
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Limpa o cache do Composer antes de tentar criar o projeto
# (Pode ser útil se voltarmos a usar o composer create-project mais tarde)
RUN composer clear-cache


# Expõe a porta 9000 e inicia o servidor php-fpm
EXPOSE 9000
CMD ["php-fpm"]