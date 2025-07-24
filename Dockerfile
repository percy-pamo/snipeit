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

# 3. Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Directorio de trabajo y permisos iniciales
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

# 5. Copia solo composer.json y composer.lock
COPY composer.json composer.lock ./

# 6. Instala dependencias (con reintento y memoria ilimitada)
RUN php -d memory_limit=-1 /usr/bin/composer install --no-dev --optimize-autoloader --no-interaction || \
    (echo "Reintentando composer install..." && php -d memory_limit=-1 /usr/bin/composer install --no-dev --optimize-autoloader --no-interaction)

# 7. Copia el resto del proyecto
COPY . .

# 8. Ajusta permisos finales
RUN chmod -R 775 storage bootstrap/cache vendor

EXPOSE 80
CMD ["apache2-foreground"]