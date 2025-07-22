FROM php:8.1-apache

# 1. Instalar extensiones de PHP y paquetes necesarios
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git curl supervisor \
    && docker-php-ext-install pdo pdo_mysql zip

# 2. Habilitar mod_rewrite de Apache
RUN a2enmod rewrite

# 3. Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Copiar archivos del proyecto Laravel
COPY . /var/www/html/

# 5. Establecer permisos para Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# 6. Instalar dependencias de Laravel con Composer
WORKDIR /var/www/html
RUN composer install --no-dev --optimize-autoloader

# 7. Copiar archivo de configuración de supervisord
COPY docker/supervisord.conf /etc/supervisord.conf

# 8. Exponer el puerto
EXPOSE 80

# 9. Iniciar supervisord (que inicia Apache y el schedule)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
