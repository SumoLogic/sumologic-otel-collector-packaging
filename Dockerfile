FROM alpine:3.17
LABEL org.opencontainers.image.authors="Sumo Logic <collection@sumologic.com>"

RUN apk add --no-cache \
    cmake \
    dpkg \
    dpkg-dev \
    file \
    git \
    make \
    rpm \
    rpm-dev

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
