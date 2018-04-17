FROM ubuntu:xenial

# Update APT-GET cache
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential gperf \
    software-properties-common apt-utils language-pack-en-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils vim curl zip \
    php7.1 php7.1-soap php7.1-curl \
    php7.1-mcrypt php7.1-gd php-imagick php7.1-json php7.1-xml php7.1-mbstring \
    php7.1-mysqli php7.1-mysqlnd php7.1-pdo php7.1-pdo-mysql php7.1-xdebug \
    php7.1-zip php7.1-apc php7.1-dba php7.1-enchant php7.1-igbinary php7.1-imap \
    php7.1-xmlrpc php7.1-redis php7.1-oauth php7.1-intl php7.1-ldap php7.1-recode \
    php7.1-tidy php7.1-sqlite3 \
    apache2 libapache2-mod-php7.1 \
    && rm -rf /var/lib/apt/lists/*

# Enable apache mods.
RUN a2enmod php7.1
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.1/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.1/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# Expose apache.
EXPOSE 80

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND