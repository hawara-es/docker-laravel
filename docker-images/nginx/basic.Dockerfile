FROM nginx:stable-alpine

ENV NGINXUSER=laravel
ENV NGINXGROUP=laravel

# Create the webroot folder
RUN mkdir -p /var/www/html/public

# Copy the nginx configuration file
RUN mkdir /etc/nginx/conf.templates
ADD basic.conf /etc/nginx/conf.templates/basic.conf
ADD mime.types /etc/nginx/mime.types

# Use the basic nginx configuration
RUN rm /etc/nginx/conf.d/default.conf
RUN ln -s /etc/nginx/conf.templates/basic.conf \
  /etc/nginx/conf.d/basic.conf

# Tell nginx to use our $NGINXUSER rather than www-data
RUN sed -i "s/user www-data/user ${NGINXUSER}/g" /etc/nginx/nginx.conf
RUN adduser -g ${NGINXGROUP} -s /bin/sh -D ${NGINXUSER}
RUN chown ${NGINXUSER}:${NGINXGROUP} /var/www/html/public