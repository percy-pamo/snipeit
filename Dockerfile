FROM php:8.3-apache

# 1. Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev libicu-dev libonig-dev libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql zip gd intl bcmath

# 2. Configura Apache
RUN a2enmod rewrite && \
    sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# 3. Instala Composer y permite ejecución como root
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# 4. Directorio de trabajo
WORKDIR /var/www/html

# 5. Copia SOLO los archivos esenciales para composer (incluyendo artisan)
COPY composer.json composer.lock artisan ./

# 6. Instala dependencias (deshabilita scripts post-install para evitar el error)
RUN php -d memory_limit=-1 /usr/bin/composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# 7. Copia el resto del proyecto
COPY . .

# 8. Ejecuta los scripts de artisan MANUALMENTE después de copiar todo
RUN php artisan package:discover --ansi

# 9. Ajusta permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache vendor

EXPOSE 80
CMD ["apache2-foreground"]