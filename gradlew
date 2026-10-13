#!/bin/sh

# Gradle wrapper bootstrap script.
# Downloads the Gradle distribution recorded in gradle/wrapper/gradle-wrapper.properties
# and runs it. Requires java on PATH.

set -e

APP_HOME=$(cd "$(dirname "$0")" && pwd)
PROPS="$APP_HOME/gradle/wrapper/gradle-wrapper.properties"
DIST_DIR="$APP_HOME/gradle/wrapper/dists"

if [ ! -f "$PROPS" ]; then
  echo "ERROR: $PROPS not found." >&2
  exit 1
fi

DIST_URL=$(sed -n 's/^distributionUrl=//p' "$PROPS" | sed 's/\\\\:/:/g')
if [ -z "$DIST_URL" ]; then
  echo "ERROR: no distributionUrl found in $PROPS." >&2
  exit 1
fi

DIST_NAME=$(basename "$DIST_URL")
DIST_HASH=$(printf '%s' "$DIST_URL" | cksum | tr -d ' ')

if ! command -v java >/dev/null 2>&1; then
  echo "ERROR: java was not found on PATH. Install JDK 21 and try again." >&2
  exit 1
fi

INSTALL_DIR="$DIST_DIR/$DIST_HASH"
GRADLE_HOME="$INSTALL_DIR/$(printf '%s' "$DIST_NAME" | sed 's/-bin.zip$//')"

if [ ! -x "$GRADLE_HOME/bin/gradle" ]; then
  mkdir -p "$INSTALL_DIR"
  ZIP="$INSTALL_DIR/$DIST_NAME"
  if [ ! -f "$ZIP" ]; then
    echo "Downloading $DIST_URL"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "$DIST_URL" -o "$ZIP"
    elif command -v wget >/dev/null 2>&1; then
      wget -q "$DIST_URL" -O "$ZIP"
    else
      echo "ERROR: neither curl nor wget is available to download Gradle." >&2
      exit 1
    fi
  fi
  echo "Unpacking Gradle"
  if command -v unzip >/dev/null 2>&1; then
    unzip -q -o "$ZIP" -d "$INSTALL_DIR"
  elif command -v jar >/dev/null 2>&1; then
    (cd "$INSTALL_DIR" && jar xf "$ZIP")
  else
    echo "ERROR: neither unzip nor jar is available to unpack Gradle." >&2
    exit 1
  fi
fi

if [ ! -x "$GRADLE_HOME/bin/gradle" ]; then
  echo "ERROR: Gradle did not unpack as expected under $INSTALL_DIR." >&2
  exit 1
fi

exec "$GRADLE_HOME/bin/gradle" "$@"
