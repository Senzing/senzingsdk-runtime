ARG BASE_IMAGE=debian:13-slim@sha256:66b37a5078a77098bfc80175fb5eb881a3196809242fd295b25502854e12cbec
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

RUN apt-get update \
  && apt-get -y --no-install-recommends install \
      ca-certificates \
      wget

# Install Senzing repository index and package.

RUN wget -O \
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
