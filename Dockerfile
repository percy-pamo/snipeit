# Usa PHP 8.3 con Apache
FROM php:8.3-apache

# Instala paquetes del sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        gd \
        zip \
        opcache \
    && apt-get clean

# Instala Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Habilita mod_rewrite de Apache
RUN a2enmod rewrite

# Copia el código fuente
COPY . /var/www/html

# Ajusta permisos
RUN chown -R www-data:www-data /var/www/html \
 && chmod +x /var/www/html/artisan

# Directorio de trabajo
WORKDIR /var/www/html

# Instala dependencias PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Expone el puerto 80
EXPOSE 80

# Comando por defecto (solo Apache, no supervisord)
CMD ["apache2-foreground"]
