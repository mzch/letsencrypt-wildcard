#! /usr/bin/env bash

DOMAIN=$1
if [[ -z "$DOMAIN" ]] ; then
  DOMAIN="$CERTBOT_DOMAIN"
fi
if [[ -z "$DOMAIN" ]] ; then
  echo "Missing argument."
  exit 1
fi

if [[ -z "$VD_TOKEN_FILE" ]] ; then
  VD_TOKEN_FILE="$HOME/.vd-token"
fi
if [[ ! -f "$VD_TOKEN_FILE" ]] ; then
  echo "Missing API Token file."
  exit 1
fi

if [[ -z "$VD_NAMESERVER" ]] ; then
  VD_NAMESERVER="valuedomain1"
elif [[ "$VD_NAMESERVER" != "valuedomain1" && "$VD_NAMESERVER" != "valuedomain11" ]] ; then
  echo "Invalid name servers."
  exit 1
fi

if [[ -z "$TMPDIR" ]] ; then
  TMPDIR="/tmp"
fi
TMPFILE=$(mktemp -p "$TMPDIR" 'vd-dns.XXXXXXXX')
DNSFILE=$(mktemp -p "$TMPDIR" 'vd-dns.XXXXXXXX')

APIENDPOINT="https://api.value-domain.com/v1/domains"
API_TOKEN=$(cat "${VD_TOKEN_FILE}")
AUTHHDR="Authorization: Bearer ${API_TOKEN}"
CTYPHDR="Content-Type: application/json"

CURL="curl -sSL -4 -X \"GET\" -H \"${AUTHHDR}\" ${APIENDPOINT}/${DOMAIN}/dns"

eval ${CURL} | jq -r '.results.records' | awk '{if (NF > 2) {if ($2 != "_acme-challenge") { print $0; }}}' > "$TMPFILE"

set -f

DNSREQ=""
DNSREQ=${DNSREQ}"{\"ns_type\":\"${VD_NAMESERVER}\",\"records\":\""
DNSREQ=${DNSREQ}$(cat "$TMPFILE" | sed -e 's/\"/\\"/g' | sed -e ':loop' -e 'N; $!b loop' -e 's/\n/\\n/g')
DNSREQ=${DNSREQ}"\",\"ttl\":\"3600\"}"

echo $DNSREQ > "$DNSFILE"

set +f

CURL="curl -sSL -4 -X \"PUT\" -H \"${AUTHHDR}\" -H \"${CTYPHDR}\" -d @${DNSFILE} -o /dev/null -w '%{http_code}\n' ${APIENDPOINT}/${DOMAIN}/dns"
STATUS=$(eval "$CURL") || exit 2
if [[ "$STATUS" != "200" ]] ; then
   printf "ERROR! Response Cdoe = %s\n" "$STATUS"
   exit 2
fi

rm "$TMPFILE" "$DNSFILE"
