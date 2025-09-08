ARG BASE_IMAGE=ghcr.io/flobernd/haproxy-acme:latest

FROM $BASE_IMAGE

# Environment

ENV HAPROXY_HTTP_PORT=80
ENV HAPROXY_HTTPS_PORT=443

ENV ACME_SERVER=letsencrypt
ENV ACME_MAIL=
ENV ACME_KEYLENGTH=ec-256
ENV ACME_DNS_API=
ENV ACME_DNS_SLEEP=

ENV SERVER_ADDRESS=
ENV SERVER_PORT=80
ENV SERVER_DIRECTIVES=

# Set up 'haproxy' certificate directory

RUN mkdir -p /certs && chown haproxy:haproxy /certs && chmod 0700 /certs

# Copy 'haproxy' configuration template

COPY --chown=haproxy:haproxy ./haproxy.cfg /etc/haproxy/haproxy.cfg.template
COPY --chown=haproxy:haproxy ./hostnames.map /usr/local/etc/haproxy/hostnames.map

# Copy scripts

COPY acmeinit.early.sh /usr/local/bin/
COPY acmeinit.late.sh  /usr/local/bin/
COPY initialize.sh     /usr/local/bin/
