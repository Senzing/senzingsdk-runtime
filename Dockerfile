ARG BASE_IMAGE=debian:13-slim@sha256:e711a7b30ec1261130d0a121050b4ed81d7fb28aeabcf4ea0c7876d4e9f5aca2
FROM ${BASE_IMAGE}

# Create the build image.

ARG SENZING_ACCEPT_EULA="I_ACCEPT_THE_SENZING_EULA"
ARG SENZING_APT_INSTALL_PACKAGE="senzingsdk-runtime"
ARG SENZING_APT_REPOSITORY_NAME="senzingrepo_2.0.1-1_all.deb"
ARG SENZING_APT_REPOSITORY_URL="https://senzing-production-apt.s3.amazonaws.com"

ENV REFRESHED_AT=2025-11-11

ENV SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
    SENZING_APT_INSTALL_PACKAGE=${SENZING_APT_INSTALL_PACKAGE} \
    SENZING_APT_REPOSITORY_NAME=${SENZING_APT_REPOSITORY_NAME} \
    SENZING_APT_REPOSITORY_URL=${SENZING_APT_REPOSITORY_URL}

LABEL Name="senzing/senzingsdk-runtime" \
      Maintainer="support@senzing.com" \
      Version="4.1.0" \
      SenzingSDK="4.1.0"

# Run as "root" for system installation.

USER root

# Eliminate warning messages.

ENV TERM=xterm

# Install packages via apt.

RUN apt-get update \
 && apt-get -y --no-install-recommends install \
      ca-certificates \
      wget \
 && wget -O \
      /${SENZING_APT_REPOSITORY_NAME} \
      ${SENZING_APT_REPOSITORY_URL}/${SENZING_APT_REPOSITORY_NAME} > /dev/null \
 && apt-get -y --no-install-recommends install \
      /${SENZING_APT_REPOSITORY_NAME} \
 && apt-get update -qqq \
 && rm /${SENZING_APT_REPOSITORY_NAME} \
 && apt-get -y --no-install-recommends install \
      libpq5 \
      ${SENZING_APT_INSTALL_PACKAGE} \
      jq \
 && apt-get clean

HEALTHCHECK CMD apt list --installed | grep senzingsdk-runtime

# Set environment variables for root.

ENV LD_LIBRARY_PATH=/opt/senzing/er/lib

# Runtime execution.

WORKDIR /
CMD ["/bin/bash"]
