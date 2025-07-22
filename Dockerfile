FROM php:8.3-apache

# Instala dependencias del sistema
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

# Habilita mod_rewrite
RUN a2enmod rewrite headers

# Crea usuario no-root
RUN useradd -G www-data,root -d /home/snipe snipe \
    && mkdir -p /home/snipe \
    && chown -R snipe:snipe /home/snipe

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Directorio de trabajo y usuario
WORKDIR /var/www/html
USER snipe

# 1. Copia solo los archivos necesarios para composer
COPY --chown=snipe:snipe composer.json composer.lock ./

# 2. Instala dependencias
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 3. Copia el resto del código
COPY --chown=snipe:snipe . .

# Permisos
RUN chmod -R 775 storage bootstrap/cache vendor

# Puerto expuesto
EXPOSE 80

# Comando de inicio (como root)
USER root
CMD ["apache2-foreground"]