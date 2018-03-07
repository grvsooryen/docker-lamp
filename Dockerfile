FROM php:7.1.2-apache 
RUN docker-php-ext-install mysqli gd
RUN a2enmod rewrite expires
