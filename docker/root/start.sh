#!/bin/bash

chmod ugo+w -R /tmp

. /tmp/.env

if test -n "$ALLOW_ONLY_IOS_KEY"; then
  patch -d / -p 0 < /root/add_nginx_auth_ios.patch
  sed -i s/__%ALLOW_ONLY_IOS_KEY%__/$ALLOW_ONLY_IOS_KEY/ /etc/nginx/sites-available/redash
fi

cat > /opt/redash/.env <<EOF
export REDASH_STATIC_ASSETS_PATH="../client/dist/"
export REDASH_LOG_LEVEL="INFO"
export REDASH_REDIS_URL=redis://localhost:6379/0
export REDASH_DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
export REDASH_COOKIE_SECRET=veryverysecret
export REDASH_MAIL_SERVER="${SMTP_HOST}"
export REDASH_MAIL_PORT="${SMTP_PORT}"
export REDASH_MAIL_USE_TLS="${SMTP_TLS}"
export REDASH_MAIL_USE_SSL="${SMTP_SSL}"
export REDASH_MAIL_USERNAME="${SMTP_USER}"
export REDASH_MAIL_PASSWORD="${SMTP_PASSWD}"
export REDASH_MAIL_DEFAULT_SENDER="${SMTP_SENDER}"
export REDASH_HOST="${FRONT_URL}"
export REDASH_ALLOW_SCRIPTS_IN_USER_INPUT="true"
export REDASH_ALLOW_PARAMETERS_IN_EMBEDS="true"
EOF

if test -e /tmp/report.sql; then
  export PGPASSWORD="${DB_PASSWD}"
  cat /tmp/report.sql | psql -h ${DB_HOST} -U ${DB_USER} -p ${DB_PORT} ${DB_NAME}
fi

service redis-server start
service supervisor start
nginx
sudo cron -f
