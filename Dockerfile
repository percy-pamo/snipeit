# Usa la imagen oficial de PHP 8.3 con Apache
FROM php:8.3-apache

# Variables de entorno para Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/composer

# Instala Composer (copiado desde la imagen oficial de Composer)
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Instala extensiones necesarias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    curl \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    gd \
    zip

# Activa el módulo de reescritura de Apache
RUN a2enmod rewrite

# Copia los archivos del proyecto al contenedor
COPY . /var/www/html

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Instala dependencias de PHP vía Composer
RUN composer install --no-dev --optimize-autoloader

# Da permisos correctos a Apache
RUN chown -R www-data:www-data /var/www/html

# Expone el puerto del servidor
EXPOSE 80
