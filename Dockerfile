# Usa PHP 8.3 con Apache
FROM php:8.3-apache

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    libpq-dev \
    libicu-dev \
    libmcrypt-dev \
    libssl-dev \
    zlib1g-dev \
    libxslt1-dev \
    libjpeg62-turbo-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd bcmath

# Habilita mod_rewrite
RUN a2enmod rewrite

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece directorio de trabajo
WORKDIR /var/www/html

# Copia los archivos del proyecto al contenedor
COPY . /var/www/html

# Instala dependencias PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Corrige permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expone el puerto 80
EXPOSE 80

# Define el comando por defecto
CMD ["apache2-foreground"]
