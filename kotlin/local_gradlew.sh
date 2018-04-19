#!/usr/bin/env bash
# change into the local directory
cd "$(dirname "$0")"
# run gradlew with args
./gradlew "$@"
