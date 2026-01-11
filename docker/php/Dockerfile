FROM php:8.4-fpm-alpine3.21


# Installer dépendances système
RUN apk update && apk add --no-cache \
    git \
    unzip \
    bash \
    curl \
    wget \
    tar \
    mysql-client \
    libzip-dev \
    icu-dev \
    oniguruma-dev

# Extensions PHP
RUN docker-php-ext-install \
        pdo \
        pdo_mysql \
        mysqli \
        zip \
        intl \
        opcache \
        bcmath

# Configuration PHP
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "upload_max_filesize=50M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size=50M" >> /usr/local/etc/php/conf.d/uploads.ini

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer

# Installer Symfony CLI
RUN wget https://github.com/symfony-cli/symfony-cli/releases/download/v5.12.0/symfony-cli_linux_amd64.tar.gz \
    && tar -xvzf symfony-cli_linux_amd64.tar.gz \
    && chmod +x symfony \
    && mv symfony /usr/local/bin/ \
    && rm symfony-cli_linux_amd64.tar.gz

WORKDIR /var/www/html

# Définir les permissions
RUN addgroup -g 1000 appuser && adduser -D -u 1000 -G appuser appuser
RUN chown -R appuser:appuser /var/www/html

USER appuser
