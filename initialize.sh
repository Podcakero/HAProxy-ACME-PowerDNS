#!/bin/bash
set -e

# Adjust permissions for 'haproxy' certificate directory

mkdir -p /certs
chown -R haproxy:haproxy /certs
chmod 0700 /certs
chmod 0600 /certs/* 2> /dev/null || true

# Copy 'haproxy' configuration template

haproxy_cfg_template=/etc/haproxy/haproxy.cfg.template
haproxy_cfg=/usr/local/etc/haproxy/haproxy.cfg
if [ ! -f "$haproxy_cfg" ]; then
    cp "$haproxy_cfg_template" "$haproxy_cfg"
    chown haproxy:haproxy "$haproxy_cfg"
    chmod 0600 "$haproxy_cfg"
fi

# Check mandatory environment variables

mandatory=(
    "ACME_SERVER"
    "ACME_MAIL"
    "ACME_KEYLENGTH"
    "ACME_DNS_API"
    "POWERDNS_URL"
    "POWERDNS_API_KEY"
    "POWERDNS_ZONE"
    "POWERDNS_TTL"
    "HAPROXY_URL"
    "BASE_DOMAIN"
)

missing=false
for value in "${mandatory[@]}"
do
    if [ -z "${!value}" ]; then
        missing=true
        echo "Missing mandatory environment variable: '$value'"
    fi
done

if [ "$missing" = true ]; then
    exit 1
fi
