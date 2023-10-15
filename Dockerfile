# Use Ruby 3.2.2 as the base image
FROM ruby:3.2.2-alpine

MAINTAINER cronv <mister.swim@yandex.ru>

# Apache Version
ENV APACHE_VERSION="2.4.57"

# Phusion Passenger Version (mod httpd)
ENV FP_VERSION="6.0.18"

# Install necessary packages and dependencies
RUN apk upgrade && apk update && \
    gem update && \
    apk add --no-cache \
    bash \
    nano \
    git \
    build-base \
    ruby-dev \
    apache2-dev apache2-utils \
    apr-dev apr-util-dev \
    pcre-dev openssl-dev \
    curl curl-dev \
    nodejs \
    tzdata

# Install apxs2 and an equivalent version of Apache
RUN cd /usr/src && \
    wget "https://archive.apache.org/dist/httpd/httpd-${APACHE_VERSION}.tar.gz" && \
    tar -xzvf "httpd-${APACHE_VERSION}.tar.gz" && \
    cd "httpd-${APACHE_VERSION}" && \
    ./configure --prefix=/usr/local/apache2 --with-apxs=/usr/bin/apxs && \
    make && \
    make install && \
    rm -rv /usr/src/* && \
    apk add apache2="${APACHE_VERSION}-r3"

# Install a gem to create a simple starting page
RUN gem install \
        mysql2 \
        bundler && \
        gem install passenger -v "${FP_VERSION}" && \
        gem install rails

# Install the Passenger module for Apache2
RUN passenger-install-apache2-module --auto --apxs2-path=/usr/local/apache2/bin/apxs

# Copy files into the container
WORKDIR /var/www/html/

# Add Apache2 "passenger" settings
RUN echo -e "LoadModule passenger_module /usr/local/bundle/gems/passenger-${FP_VERSION}/buildout/apache2/mod_passenger.so\n\
    <IfModule mod_passenger.c>\n\
      PassengerRoot /usr/local/bundle/gems/passenger-${FP_VERSION}\n\
      PassengerDefaultRuby /usr/local/bin/ruby\n\
    </IfModule>" > /etc/apache2/conf.d/fp.conf

# Add ServerName to the main Apache2 configuration file
RUN echo "ServerName localhost" >> /etc/apache2/httpd.conf

# Open port 80
EXPOSE 80

# Start Apache (httpd)
CMD ["httpd", "-D", "FOREGROUND"]
