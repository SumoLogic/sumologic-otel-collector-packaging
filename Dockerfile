FROM debian:bookworm-slim

ARG TARGETPLATFORM

LABEL org.opencontainers.image.authors="Sumo Logic <opensource-collection-team@sumologic.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    dpkg \
    dpkg-dev \
    file \
    git \
    make \
    rpm \
    curl \
    bash \
    tar \
    gzip \
    awscli \
    ca-certificates

COPY docker/install-deps.sh /install-deps.sh

RUN /install-deps.sh "$TARGETARCH"

COPY docker/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
