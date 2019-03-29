FROM nginx:alpine

RUN apk add --update \
    openssl \
    bind-tools \
    && rm -rf /var/cache/apk/*

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]