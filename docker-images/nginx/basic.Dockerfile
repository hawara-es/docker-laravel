FROM nginx:1.22-alpine

ENV USER=laravel
ENV GROUP=laravel
RUN adduser -g ${GROUP} -s /bin/sh -D ${USER}

# Create the webroot folder
RUN mkdir -p /var/www/html
RUN chown -R ${USER}:${GROUP} /var/www/html

# Copy the nginx configuration file
RUN mkdir /etc/nginx/conf.templates
ADD basic.conf /etc/nginx/conf.templates/basic.conf
ADD mime.types /etc/nginx/mime.types

# Use the basic nginx configuration
RUN rm /etc/nginx/conf.d/default.conf
RUN ln -s /etc/nginx/conf.templates/basic.conf \
  /etc/nginx/conf.d/basic.conf

# Tell nginx to use our laravel user rather than www-data
RUN sed -i "s/user www-data/user ${USER}/g" /etc/nginx/nginx.conf