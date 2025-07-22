FROM php:8.3-apache

# 1. Instala dependencias del sistema (incluyendo GD, Sodium, ZIP)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libsodium-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_mysql \
        zip \
        intl \
        gd \
        sodium

# 2. Habilita mod_rewrite
RUN a2enmod rewrite

# 3. Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Directorio de trabajo
WORKDIR /var/www/html

# 5. Copia SOLO archivos necesarios para composer
COPY composer.json composer.lock ./

# 6. Instala dependencias (sin desarrollo)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 7. Copia el resto del proyecto
COPY . .

# 8. Ajusta permisos
RUN chmod -R 775 storage bootstrap/cache

# 9. Puerto y comando
EXPOSE 80
CMD ["apache2-foreground"]