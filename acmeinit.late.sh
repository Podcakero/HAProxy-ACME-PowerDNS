#!/bin/bash
set -e
set -f

while IFS="" read -r entry || [ -n "$entry" ]
do
    domain=`echo $entry | cut -f 1 -d " "`
    if [[ $domain == "#" ]]; then
        continue
    fi
    if [[ $domain != *"${BASE_DOMAIN}" ]]; then
        continue
    fi
    echo "Issuing certificate for '$domain' ..."

    args=(
        "--issue"
        "-d" "${domain}"
        "--dns" "$ACME_DNS_API"
        "--keylength" "$ACME_KEYLENGTH"
        "--server" "$ACME_SERVER"
    )

    if [ -n "$ACME_DNS_SLEEP" ]; then
        args+=("--dnssleep" "$ACME_DNS_SLEEP")
    fi

    if [ $ACME_DEBUG -eq 1 ]; then
        args+=("--debug")
    fi

    result=0
    acme.sh "${args[@]}" || result=$?

    if [ $result -ne 0 ] && [ $result -ne 2 ]; then
        # 0 = Certificate issued
        # 2 = Certificate is still valid and does not require renewal
        exit $result
    fi

    echo "Deploying certificate ..."

    export DEPLOY_HAPROXY_HOT_UPDATE=yes
    export DEPLOY_HAPROXY_STATS_SOCKET=/var/lib/haproxy/admin.sock
    export DEPLOY_HAPROXY_PEM_PATH=/certs

    args=(
        "--deploy"
        "--deploy-hook" "haproxy"
        "-d" "${domain}"
    )

    acme.sh "${args[@]}"

    echo "Adding CNAME DNS Record to PowerDNS"

    target=`echo $domain | cut -d "." -f 1`

    curl -sS -X "PATCH" -H "X-API-Key: ${POWERDNS_API_KEY}" -H "Content-Type: application/json" --json '{"rrsets": [{"name": "'${domain}'.", "type": "CNAME", "ttl": '${POWERDNS_TTL}', "changetype": "REPLACE", "records": [{"content": "'${HAPROXY_URL}'.", "disabled": false}]}]}' ${POWERDNS_URL}/api/v1/servers/localhost/zones/${POWERDNS_ZONE}.

done < /usr/local/etc/haproxy/hostnames.map
