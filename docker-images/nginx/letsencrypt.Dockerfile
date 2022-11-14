FROM nginx:1.22-alpine

RUN apk add certbot certbot-nginx

ARG LETSENCRYPT_DOMAIN
ENV LETSENCRYPT_DOMAIN=${LETSENCRYPT_DOMAIN}

ARG LETSENCRYPT_EMAIL
ENV LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}

ENV NGINXUSER=laravel
ENV NGINXGROUP=laravel

# Set LETSENCRYPT_DOMAIN and LETSENCRYPT_EMAIL as a mandatory build arguments
RUN test -n "$LETSENCRYPT_DOMAIN" || \
  (echo "You must set the LETSENCRYPT_DOMAIN build argument" && false)
RUN test -n "$LETSENCRYPT_EMAIL" || \
  (echo "You must set the LETSENCRYPT_EMAIL build argument" && false)

# Create the webroot folder
RUN mkdir -p /var/www/html/public

# Copy the nginx configuration files
RUN mkdir /etc/nginx/conf.templates
ADD basic.conf /etc/nginx/conf.templates/basic.conf
ADD letsencrypt.conf /etc/nginx/conf.templates/letsencrypt.template.conf
ADD mime.types /etc/nginx/mime.types

# Use the basic nginx configuration until the certificates are present
RUN rm /etc/nginx/conf.d/default.conf
RUN ln -s /etc/nginx/conf.templates/basic.conf \
  /etc/nginx/conf.d/basic.conf

# Copy the script to create the certificates
ADD scripts/create-certificates /usr/sbin/create-certificates
ADD scripts/use-certificates /usr/sbin/use-certificates
RUN chmod +x /usr/sbin/create-certificates
RUN chmod +x /usr/sbin/use-certificates

# Prepare the Nginx config file for Let's Encrypt
RUN envsubst \$LETSENCRYPT_DOMAIN \
  < /etc/nginx/conf.templates/letsencrypt.template.conf \
  > /etc/nginx/conf.templates/letsencrypt.conf

# Tell nginx to use our $NGINXUSER rather than www-data
RUN sed -i "s/user www-data/user ${NGINXUSER}/g" /etc/nginx/nginx.conf
RUN adduser -g ${NGINXGROUP} -s /bin/sh -D ${NGINXUSER}
RUN chown ${NGINXUSER}:${NGINXGROUP} /var/www/html/public