ARG BASE_IMAGE=debian:12-slim@sha256:df52e55e3361a81ac1bead266f3373ee55d29aa50cf0975d440c2be3483d8ed3
FROM ${BASE_IMAGE}

# Create the build image.

ARG SENZING_ACCEPT_EULA="I_ACCEPT_THE_SENZING_EULA"
ARG SENZING_APT_INSTALL_PACKAGE="senzingsdk-runtime"
ARG SENZING_APT_REPOSITORY_NAME="senzingrepo_2.0.1-1_all.deb"
ARG SENZING_APT_REPOSITORY_URL="https://senzing-production-apt.s3.amazonaws.com"

ENV REFRESHED_AT=2025-08-27

ENV SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
    SENZING_APT_INSTALL_PACKAGE=${SENZING_APT_INSTALL_PACKAGE} \
    SENZING_APT_REPOSITORY_NAME=${SENZING_APT_REPOSITORY_NAME} \
    SENZING_APT_REPOSITORY_URL=${SENZING_APT_REPOSITORY_URL}

LABEL Name="senzing/senzingsdk-runtime" \
      Maintainer="support@senzing.com" \
      Version="4.0.0" \
      SenzingSDK="4.0.0"

# Run as "root" for system installation.

USER root

# Eliminate warning messages.

ENV TERM=xterm

# Install packages via apt.

RUN apt-get -qqq update \
 && apt-get -yqqq install \
      wget

# Install Senzing repository index.

RUN wget -qqqO \
      /${SENZING_APT_REPOSITORY_NAME} \
      ${SENZING_APT_REPOSITORY_URL}/${SENZING_APT_REPOSITORY_NAME} > /dev/null \
 && apt-get -y -qqq install \
      /${SENZING_APT_REPOSITORY_NAME} \
 && apt-get update -qqq \
 && rm /${SENZING_APT_REPOSITORY_NAME}

# Install Senzing package.

RUN apt-get -yqqq install \
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
