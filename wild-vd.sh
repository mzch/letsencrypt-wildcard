#! /usr/bin/env bash

if [[ $# -lt 1 ]]; then
  echo $0' example.com [email-address]'
  exit 1
fi

OPTS=
if [[ -n $2 ]] ; then
  LE_EMAIL=$2
fi
if [[ -n "$LE_EMAIL" ]] ; then
  OPTS="-m "$LE_EMAIL
fi

which dns-hook-vd.sh > /dev/null
if [[ $? -ne 0 ]] ; then
  DNS_HOOK="/etc/letsencrypt/dns-hook-vd.sh"
  if [[ ! -x $DNS_HOOK ]] ; then
    echo "Not found dns-hook-vd.sh"
    exit 2
  fi
else
  DNS_HOOK="dns-hook-vd.sh"
fi

which clean-hook-vd.sh > /dev/null
if [[ $? -ne 0 ]] ; then
  CLN_HOOK="/etc/letsencrypt/clean-hook-vd.sh"
  if [[ ! -x $CLN_HOOK ]] ; then
    echo "Not found clean-hook-vd.sh"
    exit 2
  fi
else
  CLN_HOOK="clean-hook-vd.sh"
fi

SUDO=""
if [[ $UID -ne 0 ]] ; then
  SUDO="sudo"
fi

$SUDO certbot certonly --manual \
	--agree-tos --preferred-challenges dns "$OPTS" \
	--manual-auth-hook "$DNS_HOOK"
	--manual-cleanup-hook "$CLN_HOOK"
	-d $1 -d *.$1
