FROM alpine as prod

#
# Valid options for **install_method** are:
#
# - composer
# - composer-repo
# - git
#
# When using the:
#
# **composer** method, the application
#   will be installed from **install_from_composer** using
#   a `composer --create-project` command.
#
# **composer-repo** method, the application
#   will be installed from **install_from_composer_repo** using
#   a `composer --create-project` command with a custom
#   `--repository-url`.
#
# **git** method, the application
#   will be downloaded from **install_from_git** using
#   a `git clone` command.
#

ARG install_method=composer
ARG install_from_composer=laravel/laravel
ARG install_from_composer_repo
ARG install_from_git

ARG timezone=Atlantic/Canary

ENV USER=laravel
ENV GROUP=laravel
RUN adduser -g ${USER} -s /bin/sh -D ${GROUP}

RUN echo "rm -rf /var/cache/apk/* /tmp/* /usr/share/man /usr/local/lib/php/doc/*" > /opt/remove-unnecessary-files && \
    chmod +x /opt/remove-unnecessary-files

## PHP 8.1, FPM and extensions
COPY php-fpm/global.conf /etc/php81/php-fpm.conf
COPY php-fpm/www.conf /etc/php81/php-fpm.d/www.conf
RUN apk add --no-cache \
        tzdata fcgi openrc tini curl icu-data-full lynx \
        php81 php81-fpm \
        php81-posix php81-zlib php81-curl php81-opcache php81-tokenizer \
        php81-phar php81-gd php81-iconv php81-mbstring \
        php81-mysqli php81-mysqlnd php81-pdo_mysql \
        php81-dba php81-pdo_dblib php81-pdo_odbc php81-sqlite3 \
        php81-pdo php81-intl php81-pcntl php81-redis \
        php81-dev php81-pear php81-openssl unixodbc-dev \
        php81-zip php81-dom php81-xml php81-xmlwriter php81-fileinfo && \
    ln -s /usr/sbin/php-fpm81 /usr/sbin/php-fpm && \
    ln -s /usr/bin/php81 /usr/bin/php && \
    /opt/remove-unnecessary-files

## Set the cron for Laravel schedule
RUN echo '* * * * * /usr/bin/php /var/www/html/artisan schedule:run >> /dev/null 2>&1' > /etc/crontabs/root

## Set the system and PHP time zones
ENV TZ=$timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo "[PHP]" > /etc/php81/conf.d/tzone.ini && \
    echo "date.timezone = \"$TZ\"" >> /etc/php81/conf.d/tzone.ini

## FPM Health Check
RUN wget -O /usr/local/bin/php-fpm-healthcheck \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck && \
    chmod +x /usr/local/bin/php-fpm-healthcheck

## Composer
RUN curl -sS https://getcomposer.org/installer | \
    /usr/bin/php81 -- --install-dir=/usr/local/bin --filename=composer

## Node.js && NPM
RUN apk add --no-cache nodejs npm && \
    /opt/remove-unnecessary-files

## Git
RUN apk add --no-cache git && \
    /opt/remove-unnecessary-files

## Application
WORKDIR /var/www/html

RUN chown $USER:$GROUP /var/www/html

USER $USER

RUN if [ "$install_method" = "composer" ]; then \
    composer create-project $install_from_composer /var/www/html; fi

RUN if [ "$install_method" = "composer_repo" ]; then \
    composer create-project --repository-url $install_from_composer_repo /var/www/html; fi

RUN if [ "$install_method" = "git" ]; then \
    git clone $install_from_git /var/www/html; fi

RUN mkdir -p /var/www/html/storage/logs/ && \
    touch /var/www/html/storage/logs/xdebug.log

USER root

FROM prod as sqlserver

## See: https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15#alpine18
RUN curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/msodbcsql18_18.0.1.1-1_amd64.apk \
    && curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/mssql-tools18_18.0.1.1-1_amd64.apk \
    && apk add --no-cache --allow-untrusted \
        msodbcsql18_18.0.1.1-1_amd64.apk \
        mssql-tools18_18.0.1.1-1_amd64.apk \
    && rm \
        msodbcsql18_18.0.1.1-1_amd64.apk \
        mssql-tools18_18.0.1.1-1_amd64.apk && \
    /opt/remove-unnecessary-files

FROM prod as supervisor

## Supervisor
WORKDIR /etc/supervisor/conf.d
COPY supervisor/supervisor.conf /etc/supervisor/supervisord.conf
COPY supervisor/watchdog.py /opt/supervisor/watchdog.py
RUN apk add --no-cache supervisor && \
    /opt/remove-unnecessary-files

FROM prod as dev

## Mailhog
RUN echo 'sendmail_path = /usr/sbin/sendmail -S mailhog:1025' > \
    /etc/php81/conf.d/mailhog.ini

## XDebug config
COPY php-fpm/xdebug.ini /etc/php81/conf.d/50_xdebug.ini
RUN mkdir -p /var/www/html/storage/logs/ && \
    touch /var/www/html/storage/logs/xdebug.log && \
    chown -R laravel: /var/www/html/storage/logs/ && \
    apk add --no-cache php81-xdebug && \
    /opt/remove-unnecessary-files
