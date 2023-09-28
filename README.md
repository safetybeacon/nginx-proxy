# NGINX Reverse Proxy

The NGINX Reverse Proxy that intercepts all traffic to the server and routes it to the appropriate service.

## Running the NGINX Reverse Proxy

Run a docker container of the `nginx` image.

- Use the `--name` flag to give the container a name so that it can be easily referenced later.
- Use the `--network="host"` flag to allow the container to access the host machine's network.
- Map the `/etc/nginx/conf.d` directory in the container to the directory on the host machine that holds the `nginx.conf` file.
- Map the `/etc/nginx/auth` directory in the container to the directory on the host machine that holds the `.htpasswd` file.
- Map the `/etc/nginx/ssl` directory in the container to the directory on the host machine that holds the SSL certificates from [Let's Encrypt](https://letsencrypt.org/).

```bash
docker run --name nginx-proxy -d \
    -v /home/ubuntu/nginx/config:/etc/nginx/conf.d:ro \
    -v /home/ubuntu/nginx/auth/.htpasswd:/etc/nginx/auth/.htpasswd \
    -v /etc/letsencrypt:/etc/nginx/ssl:ro \
    -v /home/ubuntu/nginx/entry.sh:/entry.sh \
    --entrypoint /entry.sh \
    --network="host" \
    nginx:1.25.2
```

## Obtaining SSL Certificates

On the server that the NGINX container runs on, run the following command to obtain a certificate for a domain.

Note: You'll need to have a DNS record pointing to the server's IP address for the domain.

```bash
# Stop the NGINX container so that it doesn't interfere with the certbot process that uses port 80.
docker container stop nginx-proxy

# Obtain a certificate for the domain.
sudo certbot certonly --standalone -d <domain>

# Restart the NGINX container.
docker container start nginx-proxy
```

## Auto-renewing SSL Certificates

Let's Encrypt certificates are valid for 90 days. You'll want to set up a cron job or systemd timer to automatically renew the certificates. After renewal, you'll also need to restart the NGINX container to pick up the new certificate.

```bash
sudo crontab -e
```

Add the following line to routinely attempt to renew the certificate (daily at 2 AM). If the certificate is close to expiration, it will be renewed, and the NGINX container will be restarted.

```bash
0 2 * * * /usr/bin/certbot renew --quiet && docker restart nginx-proxy
```
