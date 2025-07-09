FROM php:8.1-apache

# Instala dependencias del sistema y extensiones PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    libmcrypt-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia el contenido del proyecto al contenedor
COPY . /var/www/html/

# Establece permisos
RUN chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Expone el puerto 80
EXPOSE 80
