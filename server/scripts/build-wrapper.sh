#!/usr/bin/env bash
#
# Build Wrapper Script for scrcpy-server
# =====================================
#
# Chức năng chính:
# - Wrapper script để gọi gradle từ meson build system
# - Xây dựng scrcpy-server Android APK (debug hoặc release)
# - Kiểm tra quyền root và tránh download gradle dependencies vào /root/.gradle
# - Nhận tham số: PROJECT_ROOT, OUTPUT_PATH, BUILD_TYPE từ meson
# - Sử dụng gradlew wrapper để build Android project
# - Copy APK đã build vào vị trí output được chỉ định
#
# Tham số đầu vào:
# $1 - PROJECT_ROOT: Đường dẫn thư mục source của server
# $2 - OUTPUT: Đường dẫn file output APK
# $3 - BUILDTYPE: Loại build (debug/release)
#
# Đầu ra:
# - Debug: server-debug.apk
# - Release: server-release-unsigned.apk
#
# Wrapper script to invoke gradle from meson
set -e

echo "🐸 Build wrapper script started!" >&2
echo "🐸 Script arguments received:" >&2
echo "🐸   Total arguments: $#" >&2
echo "🐸   All arguments: $*" >&2
echo "🐸   Argument 1 (PROJECT_ROOT): '$1'" >&2
echo "🐸   Argument 2 (OUTPUT): '$2'" >&2
echo "🐸   Argument 3 (BUILDTYPE): '$3'" >&2
echo "🐸 Current working directory: $(pwd)" >&2
echo "🐸 Script path: $0" >&2

# Check Java version
echo "🐸 Checking Java version..." >&2
if command -v java &> /dev/null; then
    java -version >&2
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo "🐸 Java version: $JAVA_VERSION" >&2

    # Extract major version number
    JAVA_MAJOR_VERSION=$(echo $JAVA_VERSION | sed -E 's/^([0-9]+).*/\1/')
    if [[ -z "$JAVA_MAJOR_VERSION" ]]; then
        # Handle versions like "1.8.0_XXX"
        JAVA_MAJOR_VERSION=$(echo $JAVA_VERSION | sed -E 's/^1\.([0-9]+).*/\1/')
    fi

    echo "🐸 Java major version: $JAVA_MAJOR_VERSION" >&2

    # Check if Java version is compatible with Gradle
    if [[ "$JAVA_MAJOR_VERSION" -gt 17 ]]; then
        echo "🐸 Warning: Java version $JAVA_MAJOR_VERSION might be too high for Gradle. Gradle typically works best with Java 8-17." >&2
        echo "🐸 If build fails with 'Unsupported class file major version', try using Java 17 or lower." >&2

        # Try to check for alternative Java installations
        echo "🐸 Checking for alternative Java installations..." >&2
        if command -v /usr/libexec/java_home &> /dev/null; then
            echo "🐸 Available Java versions:" >&2
            /usr/libexec/java_home -V >&2
        fi
    fi
else
    echo "🐸 Java not found in PATH! Please install Java." >&2
fi

# Check JAVA_HOME
echo "🐸 JAVA_HOME: $JAVA_HOME" >&2

# Do not execute gradle when ninja is called as root (it would download the
# whole gradle world in /root/.gradle).
# This is typically useful for calling "sudo ninja install" after a "ninja
# install"
if [[ "$EUID" == 0 ]]
then
    echo "🐸 Checking if running as root..." >&2
    echo "🐸 (not invoking gradle, since we are root)" >&2
    exit 0
fi

echo "🐸 Extracting build parameters..." >&2
PROJECT_ROOT="$1"
OUTPUT="$2"
BUILDTYPE="$3"

echo "🐸 PROJECT_ROOT: $PROJECT_ROOT" >&2
echo "🐸 OUTPUT: $OUTPUT" >&2
echo "🐸 BUILDTYPE: $BUILDTYPE" >&2

# gradlew is in the parent of the server directory
GRADLE=${GRADLE:-$PROJECT_ROOT/../gradlew}
echo "🐸 Using gradle wrapper: $GRADLE" >&2

# Show Gradle version
echo "🐸 Checking Gradle version..." >&2
"$GRADLE" -p "$PROJECT_ROOT" -v >&2

if [[ "$BUILDTYPE" == debug ]]
then
    echo "🐸 Building debug version..." >&2
    "$GRADLE" -p "$PROJECT_ROOT" assembleDebug --stacktrace
    echo "🐸 Copying debug APK to output location..." >&2
    cp "$PROJECT_ROOT/build/outputs/apk/debug/server-debug.apk" "$OUTPUT"
    echo "🐸 Debug build completed successfully!" >&2
else
    echo "🐸 Building release version..." >&2
    "$GRADLE" -p "$PROJECT_ROOT" assembleRelease --stacktrace
    echo "🐸 Copying release APK to output location..." >&2
    cp "$PROJECT_ROOT/build/outputs/apk/release/server-release-unsigned.apk" "$OUTPUT"
    echo "🐸 Release build completed successfully!" >&2
fi
