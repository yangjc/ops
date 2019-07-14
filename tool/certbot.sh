#!/bin/bash

# ( export _webroot=  _domain=  _email=  \
# && if [ -z "$_webroot" ] || [ -z "$_domain" ] || [ -z "$_email" ]; \
# then echo "Variables undefined."; exit 1; fi \
# && set -x \
# && docker run -it --rm \
# -v "/etc/letsencrypt:/etc/letsencrypt" \
# -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
# -v "$_webroot:/tmp" \
# certbot/certbot \
#     certonly --webroot \
#     --webroot-path "/tmp" \
#     -d "$_domain" \
#     --email "$_email" \
#     --preferred-challenges "http" \
# )

( _run() {
    _webroot="$1"
    _domain="$2"
    _email="$3"
    if [ -z "$_webroot" ] || [ -z "$_domain" ] || [ -z "$_email" ]; then
        echo "Unexpected arguments." >&2
        exit 1
    fi
    set -x

    docker run -it --rm \
        -v "/etc/letsencrypt:/etc/letsencrypt" \
        -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
        -v "$_webroot:/tmp" \
        certbot/certbot \
            certonly --webroot \
            --webroot-path "/tmp" \
            -d "$_domain" \
            --email "$_email" \
            --preferred-challenges "http"
}
# _run  webroot  domain  email
_run "" "" "" )