FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive
ENV COMPOSER_ALLOW_SUPERUSER 1

# install base packages
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get -y install locales locales-all unzip vim cron && \
    locale-gen en_US.UTF-8 && \
    update-locale

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# for php7.2
RUN apt-get install -y --no-install-recommends apt-transport-https lsb-release ca-certificates wget && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    apt-get update

RUN apt-get -y upgrade
# install php packages
RUN apt-get -y install php7.2-fpm php7.2-curl php7.2-mbstring php7.2-intl php7.2-bcmath php7.2-xmlrpc php7.2-xml php7.2-zip php7.2-mysql
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 10M/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 12M/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/variables_order = .*/variables_order = 'EGPCS'/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/variables_order = .*/variables_order = 'EGPCS'/" /etc/php/7.2/cli/php.ini && \
    sed -i -e "s/pid =.*/pid = \/var\/run\/php7.2-fpm.pid/" /etc/php/7.2/fpm/php-fpm.conf && \
    sed -i -e "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php/7.2/fpm/php-fpm.conf && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf && \
    sed -i "s/listen = .*/listen = 9000/" /etc/php/7.2/fpm/pool.d/www.conf && \
    sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/7.2/fpm/pool.d/www.conf && \
    sed -i "s/^;clear_env = no$/clear_env = no/" /etc/php/7.2/fpm/pool.d/www.conf

WORKDIR /var/www/html

COPY . /var/www/html
RUN cp .env.example .env

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');"

# for more speed
RUN php composer.phar config -g repos.packagist composer https://packagist.jp && \
    php composer.phar global require hirak/prestissimo

# composer install for lumen
RUN php composer.phar install --no-dev --no-scripts && \
    php composer.phar dumpautoload --optimize

# Add crontab file in the cron directory
ADD docker/crontab /etc/cron.d/laravel-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/laravel-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
# CMD printenv > /etc/environment && echo "cron starting..." && (cron) && : > /var/log/cron.log && tail -f /var/log/cron.log
CMD printenv > /etc/environment && echo "cron starting..." && (cron -f)
