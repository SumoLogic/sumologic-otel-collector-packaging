FROM alpine:3.17
MAINTAINER Sumo Logic <collection@sumologic.com>

RUN apk add --no-cache \
    cmake \
    dpkg \
    dpkg-dev \
    file \
    git \
    make \
    rpm \
    rpm-dev

WORKDIR /src/build
