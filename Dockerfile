# Build stage: caddy
FROM abiosoft/caddy:builder AS builder_caddy

ARG version="1.0.2"
ARG plugins="git,cors,realip,expires,cache,cloudflare"
RUN go get -v github.com/abiosoft/parent
RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh


# Build stage: v2ray
FROM ubuntu:latest AS builder_v2ray

RUN apt-get update
RUN apt-get install curl -y
RUN curl -L -o /tmp/go.sh https://install.direct/go.sh
RUN chmod +x /tmp/go.sh
RUN /tmp/go.sh


# Build stage: final
FROM alpine:latest

LABEL maintainer "jingxi.zheng<zjx7014@gmail.com>"

# Install caddy
COPY --from=builder_caddy /go/bin/parent /bin/parent
COPY --from=builder_caddy /install/caddy /usr/bin/caddy
RUN apk add --no-cache \
    ca-certificates \
    git \
    mailcap \
    openssh-client \
    tzdata

# Install v2ray
COPY --from=builder_v2ray /usr/bin/v2ray/v2ray /usr/bin/v2ray/
COPY --from=builder_v2ray /usr/bin/v2ray/v2ctl /usr/bin/v2ray/
COPY --from=builder_v2ray /usr/bin/v2ray/geoip.dat /usr/bin/v2ray/
COPY --from=builder_v2ray /usr/bin/v2ray/geosite.dat /usr/bin/v2ray/
RUN set -ex && \
    apk --no-cache add ca-certificates && \
    mkdir /var/log/v2ray/ &&\
    chmod +x /usr/bin/v2ray/v2ctl && \
    chmod +x /usr/bin/v2ray/v2ray



###

ENV CADDY_DOMAIN=""
ENV V2RAY_UUID=""

EXPOSE 80 443

ADD entrypoint.sh /entrypoint.sh
CMD ["/bin/sh", "/entrypoint.sh"]