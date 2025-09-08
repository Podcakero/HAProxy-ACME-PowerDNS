# HAProxy-ACME-PowerDNS
This is a customized HAProxy Docker Image that integrates ACME.sh Certificate Creation with PowerDNS Record Creation for easy and automatic reverse proxy Domain creation.

## Required Environment Variables
ACME_MAIL - Email for the ACME Account

ACME_DNS_API - Which ACME DNS API to Use. See ACME.sh Documentation

POWERDNS_URL - URL of PowerDNS HTTP Rest API

POWERDNS_API_KEY - API Key for PowerDNS HTTP Rest API

POWERDNS_ZONE - PowerDNS Zone to create records in

POWERDNS_TTL - TTL for PowerDNS Records

HAPROXY_URL - Hostname of HAProxy Host

BASE_DOMAIN - Base Domain for all Records (ex. example.com)

## Docker Run
```bash
docker run \
-e ACME_MAIL=<Your Email Address> \
-e ACME_DNS_API=<Your DNS Provider> \
-e POWERDNS_URL=http://dns.example.com:8083 \
-e POWERDNS_API_KEY=changeme \
-e POWERDNS_ZONE=example.com \
-e POWERDNS_TTL=86400 \
-e HAPROXY_URL=haproxy.example.com \
-e BASE_DOMAIN=example.com \
-v ./acme:/var/lib/acme \
-v ./certs:/certs \
-v ./config:/usr/local/etc/haproxy \
-v ./haproxy:/var/lib/haproxy \
-p 80:80 \
-p 443:443 \
ghcr.io/podcakero/haproxy-acme-pdns:latest
```

## Docker Compose
```docker-compose
services:
  haproxy:
    image: haproxy-acme-pdns:latest
    container_name: haproxy
    environment:
      ACME_MAIL: admin@example.com
      ACME_DNS_API: dns_cf
      POWERDNS_URL: http://dns.example.com:8083/
      POWERDNS_API_KEY: changeme
      POWERDNS_ZONE: example.com
      POWERDNS_TTL: 86400
      HAPROXY_URL: haproxy.example.com
      BASE_DOMAIN: example.com
    volumes:
      - type: volume
        source: acme
        target: /var/lib/acme
      - type: volume
        source: certs
        target: /certs
      - type: volume
        source: config
        target: /usr/local/etc/haproxy
      - type: volume
        source: haproxy
        target: /var/lib/haproxy
    ports:
      - name: HTTP
        target: 80
        published: "80"
        protocol: tcp
        app_protocol: http
      - name: HTTPS
        target: 443
        published: "443"
        protocol: tcp
        app_protocol: https
    restart: unless-stopped

volumes:
  acme:
  certs:
  config:
  haproxy:
