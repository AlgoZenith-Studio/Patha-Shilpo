#!/usr/bin/env bash
# Pairs and connects to a phone over wireless ADB using values from .env,
# then optionally installs and launches the release APK.
#
# Reads pathashilpo_frontend/.env (see .env.example for the format and where
# each value comes from on your phone). Never hardcodes an IP, port, pairing
# code, or SDK path — every developer keeps their own .env locally and it is
# git-ignored.
#
# Usage:
#   ./scripts/wireless_connect.sh              # pair + connect only
#   ./scripts/wireless_connect.sh --install     # pair + connect + install + launch

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "No .env found at $ENV_FILE" >&2
  echo "Copy .env.example to .env and fill in your own pairing/connect values." >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a; source "$ENV_FILE"; set +a

require() {
  local name="$1"
  local value="${!name:-}"
  if [[ -z "$value" ]]; then
    echo "Missing $name in .env — copy .env.example and fill it in from your phone's Wireless debugging screen." >&2
    exit 1
  fi
  echo "$value"
}

PAIR_HOST=$(require ADB_PAIR_HOST)
PAIR_PORT=$(require ADB_PAIR_PORT)
PAIR_CODE=$(require ADB_PAIR_CODE)
CONNECT_HOST=$(require ADB_CONNECT_HOST)
CONNECT_PORT=$(require ADB_CONNECT_PORT)
APP_ID="${APP_ID:-com.example.pathashilpa}"

# --- locate adb: explicit SDK root in .env, else common install locations, else PATH ---
ADB=""
if [[ -n "${ANDROID_SDK_ROOT:-}" && -x "$ANDROID_SDK_ROOT/platform-tools/adb" ]]; then
  ADB="$ANDROID_SDK_ROOT/platform-tools/adb"
else
  for candidate in \
    "$HOME/Library/Android/sdk/platform-tools/adb" \
    "$HOME/Android/Sdk/platform-tools/adb" \
    "$LOCALAPPDATA/Android/sdk/platform-tools/adb.exe"
  do
    if [[ -x "$candidate" ]]; then ADB="$candidate"; break; fi
  done
fi
if [[ -z "$ADB" ]] && command -v adb >/dev/null 2>&1; then
  ADB="$(command -v adb)"
fi
if [[ -z "$ADB" ]]; then
  echo "Could not find adb. Set ANDROID_SDK_ROOT in .env to your Android SDK folder." >&2
  exit 1
fi

echo "Using adb: $ADB"

echo "Pairing with $PAIR_HOST:$PAIR_PORT ..."
if ! "$ADB" pair "$PAIR_HOST:$PAIR_PORT" "$PAIR_CODE"; then
  echo "Pairing failed — the pairing code/port are shown fresh each time you open 'Pair device with pairing code' on the phone. Update .env and retry." >&2
  exit 1
fi

echo "Connecting to $CONNECT_HOST:$CONNECT_PORT ..."
"$ADB" connect "$CONNECT_HOST:$CONNECT_PORT"

echo
echo "Devices:"
"$ADB" devices -l

if [[ "${1:-}" == "--install" ]]; then
  APK="$REPO_ROOT/build/app/outputs/flutter-apk/app-release.apk"
  if [[ ! -f "$APK" ]]; then
    echo "No release APK at $APK — run 'flutter build apk --release' first." >&2
    exit 1
  fi
  DEVICE="$CONNECT_HOST:$CONNECT_PORT"
  echo
  echo "Installing $APK to $DEVICE ..."
  "$ADB" -s "$DEVICE" install -r "$APK"
  echo "Launching $APP_ID ..."
  "$ADB" -s "$DEVICE" shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null
  echo "Done."
fi
