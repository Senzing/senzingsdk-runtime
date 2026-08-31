#!/usr/bin/env bash

# Check ENV for LD_LIBRARY_PATH
if [[ -z "${LD_LIBRARY_PATH}" ]]; then
  echo "[ERROR] Environment variable LD_LIBRARY_PATH is not set"
  exit 1
fi

# Verify that some Senzing files have been installed
# /opt/senzing/er/szBuildVersion.json  (log contents)
FILE=/opt/senzing/er/szBuildVersion.json
if test -f "$FILE"; then
    echo "[INFO] $FILE exists."
else
    echo "[ERROR] $FILE does not exist."
    exit 1
fi

# /opt/senzing/data/address_datamodel/model.onnx
FILE=/opt/senzing/data/address_datamodel/model.onnx
if test -f "$FILE"; then
    echo "[INFO] $FILE exists."
else
    echo "[ERROR] $FILE does not exist."
    exit 1
fi

# parse /opt/senzing/data/g2BuildVersion.json, get BUILD_VERSION and compare it with SENZING_APT_INSTALL_PACKAGE="senzingsdk-runtime=3.3.1-22283" 
# {
#     "PLATFORM": "Linux",
#     "VERSION": "4.0.0",
#     "BUILD_VERSION": "4.0.0.24318",
#     "BUILD_NUMBER": "2024_11_13__14_22",
#     "DATA_VERSION": "6.0.0"
# }

# check that g2build version is the same as the senzing apt installed 
FILE=/opt/senzing/data/szBuildVersion.json
if test -f "$FILE"; then
    echo "[INFO] $FILE exists."

    # extract build_version from the json 
    BUILD_VERSION=$(cat $FILE | jq ".BUILD_VERSION" | cut -d '"' -f 2)

    # only compare when SENZING_APT_INSTALL_PACKAGE pins a version, e.g. "senzingsdk-runtime=4.4.0-26242"
    if [[ "$SENZING_APT_INSTALL_PACKAGE" == *"="* ]]; then

        # replace build_version - with .
        SZ_APT_PKG_VERSION=$(echo "$SENZING_APT_INSTALL_PACKAGE" | sed 's/\(.*\)-/\1./' | cut -d "=" -f 2)

        # compare with SENZING_APT_INSTALL_PACKAGE
        if [ "$BUILD_VERSION" = "$SZ_APT_PKG_VERSION" ]; then
            echo "[INFO] Build version is the same as SENZING_APT_INSTALL_PACKAGE env."
        else
            echo "[ERROR] Build version is not the same as SENZING_APT_INSTALL_PACKAGE env."
            exit 1
        fi
    else
        echo "[INFO] SENZING_APT_INSTALL_PACKAGE is not version-pinned; installed build version is $BUILD_VERSION."
    fi
else
    echo "[ERROR] $FILE does not exist."
    exit 1
fi
