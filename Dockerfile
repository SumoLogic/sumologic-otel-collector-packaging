FROM ubuntu:24.04

ARG TARGETPLATFORM
ARG TARGETARCH

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
    ca-certificates \
    unzip && \
    curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install &&

COPY docker/install-deps.sh /install-deps.sh

RUN /install-deps.sh "${TARGETARCH}"

COPY docker/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]