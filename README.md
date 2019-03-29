# self-signed-https-proxy

[![Build Status](https://travis-ci.com/qoomon/self-signed-https-proxy.svg?branch=master)](https://travis-ci.com/qoomon/self-signed-https-proxy)

[![GitHub release](https://img.shields.io/github/release/qoomon/self-signed-https-proxy.svg)](https://hub.docker.com/r/qoomon/self-signed-https-proxy/)

[![Docker Stars](https://img.shields.io/docker/pulls/qoomon/self-signed-https-proxy.svg)](https://hub.docker.com/r/qoomon/self-signed-https-proxy/)


Generate self-signed certificate for given `SERVER_DOMAIN` on the fly and starts a proxy https server.

### build
`docker build -t localhost-ssl-proxy .`

### Usage
`docker run -p 443:443 self-signed-https-proxy`

#### Mount local directory to store and reuse certificate and key
`docker run -v "$PWD":'/etc/nginx/certificates' -p 443:443 self-signed-https-proxy`

### Environment Variables
* `SERVER_DOMAIN` default: 'localtest.me'
  * 'localtest.me' and subdomains will always resolve to `127.0.0.1`
* `SERVER_PORT` default: '443'
* `TARGET_DOMAIN` default: "$SERVER_DOMAIN"
* `TARGET_PORT` default: '80'
