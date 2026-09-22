#!/bin/sh
set -e

: "${BASIC_AUTH_USER:?La variable d'environnement BASIC_AUTH_USER est requise}"
: "${BASIC_AUTH_PASSWORD:?La variable d'environnement BASIC_AUTH_PASSWORD est requise}"

htpasswd -cb /usr/local/apache2/conf/.htpasswd "$BASIC_AUTH_USER" "$BASIC_AUTH_PASSWORD"

exec "$@"
