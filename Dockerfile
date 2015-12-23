FROM ubuntu:14.04.3

RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8 && \
    apt-get clean

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install tools & libs to compile everything
RUN apt-get update && apt-get install -y build-essential libssl-dev libreadline-dev wget && apt-get clean

RUN apt-get install -y git-core && apt-get clean
RUN git clone https://github.com/sstephenson/ruby-build.git && cd ruby-build && ./install.sh

ENV CONFIGURE_OPTS --disable-install-rdoc
RUN ruby-build 2.2.4 /usr/local
RUN gem install bundler

# ruby-dev build-essential for compiling gems
# libxml2-dev libxslt-dev zlib1g-dev for nokogiri
RUN apt-get update && apt-get install -y ruby-dev build-essential libxml2-dev libxslt-dev zlib1g-dev libmysqlclient-dev libfcgi-dev apache2 libapache2-mod-fcgid mysql-client curl less vim --no-install-recommends && rm -rf /var/lib/apt/lists/*

ADD fcgid.conf /etc/apache2/mods-available/fcgid.conf
RUN a2enmod alias auth_basic authn_file authnz_ldap authz_groupfile authz_host authz_user autoindex cgi deflate dir env fcgid filter ldap mime negotiation rewrite setenvif ssl status headers include

ADD apache_site.conf /etc/apache2/sites-available/app.conf
RUN a2ensite app && a2dissite 000-default

COPY httpd-foreground /usr/local/bin/

RUN mkdir -p /app
WORKDIR /app

# this list came from: https://github.com/jacksoncage/apache-docker/blob/master/Dockerfile
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www

EXPOSE 80

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
RUN mkdir -p /app/tmp

RUN chgrp www-data -R /app/log /app/tmp /app/Gemfile.lock && chmod g+w /app/log /app/tmp && \
  mkdir -p /app/public/stylesheets/cache /app/public/javascripts/cache && \
  chgrp www-data -R /app/public/stylesheets/cache /app/public/javascripts/cache && \
  chmod g+w /app/public/stylesheets/cache /app/public/javascripts/cache && \
  chmod g+w /app/Gemfile.lock

RUN touch /app/log/production.log && chmod 0666 /app/log/production.log

CMD ["httpd-foreground"]
