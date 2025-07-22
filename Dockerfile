FROM php:8.3-apache

# 1. Instalación de extensiones necesarias (PHP 8.2+)
RUN apt-get update && apt-get install -y \
    git unzip curl libpng-dev libonig-dev libxml2-dev zip libzip-dev supervisor \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl xml bcmath \
    && docker-php-ext-enable sodium fileinfo intl gd

# 2. Habilitar mod_rewrite para Laravel
RUN a2enmod rewrite

# 3. Copiar el código del proyecto
COPY . /var/www/html

# 4. Copiar configuración de supervisord
COPY docker/supervisord.conf /etc/supervisord.conf

# 5. Ajustar permisos (storage, cache)
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 6. Definir directorio de trabajo
WORKDIR /var/www/html

# 7. Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 8. Instalar dependencias PHP
RUN composer install --no-dev --optimize-autoloader

# 9. Exponer el puerto HTTP
EXPOSE 80

# 10. Iniciar supervisord para Apache y scheduler
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

