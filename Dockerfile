FROM php:8.3-apache

# 1. Configuración inicial
ENV COMPOSER_PROCESS_TIMEOUT=900 \
    COMPOSER_PREFER_DIST=1 \
    COMPOSER_ALLOW_SUPERUSER=1

# 2. Instala dependencias del sistema
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
    && docker-php-ext-install pdo pdo_mysql zip gd bcmath \
	&& docker-php-ext-enable sodium
	
# 3. Configura Apache
RUN a2enmod rewrite && \
    sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# 4. Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Directorio de trabajo
WORKDIR /var/www/html

# 6. Copia archivos esenciales primero
COPY composer.json composer.lock ./

# 7. Instala dependencias
RUN composer install #--no-dev --optimize-autoloader --no-interaction

# 8. Copia el resto del proyecto
COPY . .

# 9. Configuración de Laravel
RUN php artisan key:generate && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 775 storage bootstrap/cache vendor

EXPOSE 80
CMD ["apache2-foreground"]