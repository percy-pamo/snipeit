# Usa PHP 8.3 con Apache
FROM php:8.3-apache

# Instala dependencias del sistema (¡formato correcto!)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libsodium-dev \
    libonig-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd intl bcmath sodium

# Habilita mod_rewrite y headers
RUN a2enmod rewrite headers

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Directorio de trabajo
WORKDIR /var/www/html

# 1. Copia solo los archivos necesarios primero
COPY composer.json composer.lock ./

# 2. Instala dependencias (sin archivos de desarrollo)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 3. Copia el resto del código
COPY . .

# Permisos (incluyendo vendor/)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 storage bootstrap/cache vendor

# Puerto expuesto
EXPOSE 80

# Comando de inicio
CMD ["apache2-foreground"]