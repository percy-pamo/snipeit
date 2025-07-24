# Usa PHP 8.3 con Apache
FROM php:8.3-apache

# 1. Instala dependencias del sistema
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

# 2. Habilita mod_rewrite y configura Apache
RUN a2enmod rewrite && \
    sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# 3. Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Directorio de trabajo
WORKDIR /var/www/html

# 5. Copia SOLO archivos necesarios para composer (¡antes de instalar dependencias!)
COPY composer.json composer.lock ./

# 6. Instala dependencias (sin caché para evitar problemas)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 7. Copia el resto del proyecto (¡después de composer install!)
COPY . .

# 8. Ajusta permisos (optimizado)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache vendor

EXPOSE 80
CMD ["apache2-foreground"]