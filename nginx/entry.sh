#!/bin/sh

# Set ownership and permissions for .htpasswd
chown 101:101 /etc/nginx/auth/.htpasswd
chmod 644 /etc/nginx/auth/.htpasswd

# Start NGINX
exec nginx -g 'daemon off;'
