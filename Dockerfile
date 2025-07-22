# Usa PHP 8.3 con Apache
FROM php:8.3-apache

# Instala dependencias del sistema
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
    zlib1g-dev \
    libxslt1-dev \
    libjpeg62-turbo-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd bcmath intl

# Habilita mod_rewrite
RUN a2enmod rewrite

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece directorio de trabajo
WORKDIR /var/www/html

# Copia primero los archivos necesarios para Composer
COPY composer.json composer.lock ./

# Copia el archivo .env (si ya lo tienes creado, mejor)
COPY .env .env

# Ejecuta composer install (antes de copiar todo el proyecto)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Ahora copia todo el resto del proyecto
COPY . .

# Asegura permisos correctos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Expone el puerto
EXPOSE 80

# Comando por defecto
CMD ["apache2-foreground"]
