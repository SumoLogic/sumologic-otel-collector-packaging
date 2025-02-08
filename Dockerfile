FROM alpine:3.19.6

ARG TARGETPLATFORM

LABEL org.opencontainers.image.authors="Sumo Logic <opensource-collection-team@sumologic.com>"

RUN apk add --no-cache \
    cmake \
    dpkg \
    dpkg-dev \
    file \
    git \
    make \
    rpm \
    rpm-dev \
    curl \
    bash \
    tar \
    gzip \
    aws-cli

COPY docker/install-deps.sh /install-deps.sh

RUN /install-deps.sh "$TARGETARCH"

COPY docker/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
