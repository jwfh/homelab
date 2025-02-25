#!/bin/sh

if [ $# -ne 2 ]; then
    echo "Expected 2 arguments: ${0} ASN FILE"
    exit 1
fi

asn="${1}"
output="${2}"

echo "-i origin AS${asn}" | nc whois.radb.net 43 | awk '/^route6?:/ { print $2 }' >"${output}"
chmod 644 "${output}"
