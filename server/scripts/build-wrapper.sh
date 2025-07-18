#!/usr/bin/env bash
# Wrapper script to invoke gradle from meson
set -e

# Do not execute gradle when ninja is called as root (it would download the
# whole gradle world in /root/.gradle).
# This is typically useful for calling "sudo ninja install" after a "ninja
# install"
if [[ "$EUID" == 0 ]]
then
    echo "Checking if running as root..." >&2
    echo "(not invoking gradle, since we are root)" >&2
    exit 0
fi

echo "Extracting build parameters..." >&2
PROJECT_ROOT="$1"
OUTPUT="$2"
BUILDTYPE="$3"

echo "PROJECT_ROOT: $PROJECT_ROOT" >&2
echo "OUTPUT: $OUTPUT" >&2
echo "BUILDTYPE: $BUILDTYPE" >&2

# gradlew is in the parent of the server directory
GRADLE=${GRADLE:-$PROJECT_ROOT/../gradlew}
echo "Using gradle wrapper: $GRADLE" >&2

if [[ "$BUILDTYPE" == debug ]]
then
    echo "Building debug version..." >&2
    "$GRADLE" -p "$PROJECT_ROOT" assembleDebug
    echo "Copying debug APK to output location..." >&2
    cp "$PROJECT_ROOT/build/outputs/apk/debug/server-debug.apk" "$OUTPUT"
    echo "Debug build completed successfully!" >&2
else
    echo "Building release version..." >&2
    "$GRADLE" -p "$PROJECT_ROOT" assembleRelease
    echo "Copying release APK to output location..." >&2
    cp "$PROJECT_ROOT/build/outputs/apk/release/server-release-unsigned.apk" "$OUTPUT"
    echo "Release build completed successfully!" >&2
fi
