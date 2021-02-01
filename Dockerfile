# Install dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng \
    libjpeg \
    icu \
    icu-dev \
    libxml2 \
    libxml2-dev \
    openssl \
    openssl-dev \
    libwebp-dev \
    libjpeg-turbo-dev \
    build-essential \
    libpng-dev \
    libxpm-dev \
    freetype-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    supervisor

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl mysqli intl xml opcache bcmath soap
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-zlib-dir=/usr/include/ --with-xpm-dir=/usr/include/
RUN docker-php-ext-install gd

RUN apt-get install -y
    $PHPIZE_DEPS \
    && pecl install xdebug-2.7.0 \
    && docker-php-ext-enable xdebug

RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  docker-php-ext-enable redis

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

#Create Composer Direcoty
RUN mkdir /home/www/.composer

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer global require laravel/installer
ENV PATH="/home/www/.composer/vendor/bin:${PATH}"
RUN composer global require hirak/prestissimo
RUN composer global require phpunit/phpunit ^7

# Copy existing application directory contents
#COPY ./lumen-app/etod-backend /var/www

# Copy existing application directory permissions
#COPY --chown=www:www ./lumen-app/etod-backend /var/www

#Add SSH Server and Requirements
RUN apt update && apt install openssh-server -y

#Create SSH Directory
RUN mkdir /home/www/.ssh
RUN chown -R www-data:www /home/www/

# Change current user to www
USER www

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
