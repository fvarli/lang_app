#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Lang App - One Command Runner
# ==============================
#
# Usage:
#   ./start_android.sh
#   AVD=Medium_Phone_API_36.1 ./start_android.sh
#   SKIP_TESTS=1 ./start_android.sh
#   SKIP_ANALYZE=1 ./start_android.sh
#   SKIP_FORMAT=1 ./start_android.sh
#   CLEAN=1 ./start_android.sh
#
# Notes:
# - Starts (or reuses) an Android emulator, then runs pub get/format/analyze/test/run.
# - Forces running on an Android device (emulator preferred).

log() { printf "✅ %s\n" "$*" >&2; }
warn() { printf "⚠️ %s\n" "$*" >&2; }
die() { printf "❌ %s\n" "$*" >&2; exit 1; }

# ---- Config ----
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_SDK="${ANDROID_HOME:-$HOME/Android/Sdk}"
EMULATOR_BIN="$ANDROID_SDK/emulator/emulator"
ADB_BIN="$ANDROID_SDK/platform-tools/adb"

BOOT_TIMEOUT_SEC="${BOOT_TIMEOUT_SEC:-180}"
BOOT_POLL_SEC="${BOOT_POLL_SEC:-2}"

AVD_NAME="${AVD:-}"                # optional: set AVD name explicitly
SKIP_TESTS="${SKIP_TESTS:-0}"
SKIP_ANALYZE="${SKIP_ANALYZE:-0}"
SKIP_FORMAT="${SKIP_FORMAT:-0}"
CLEAN="${CLEAN:-0}"

# ---- Helpers ----
require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Command not found: $1"; }
require_exec() { [ -x "$1" ] || die "Missing or not executable: $1"; }

get_running_emulator_id() {
  "$ADB_BIN" devices | awk 'NR>1 && $1 ~ /^emulator-/ && $2=="device"{print $1; exit 0}'
}

get_first_android_device_id() {
  # Prefer emulator, fallback to first physical device.
  local emu phys
  emu="$("$ADB_BIN" devices | awk 'NR>1 && $1 ~ /^emulator-/ && $2=="device"{print $1; exit 0}')"
  if [ -n "${emu:-}" ]; then
    echo "$emu"
    return 0
  fi
  phys="$("$ADB_BIN" devices | awk 'NR>1 && $1 !~ /^emulator-/ && $2=="device"{print $1; exit 0}')"
  if [ -n "${phys:-}" ]; then
    echo "$phys"
    return 0
  fi
  return 1
}

wait_for_boot() {
  local start_ts now_ts boot_completed
  start_ts=$(date +%s)

  log "Waiting for Android boot completion (timeout ${BOOT_TIMEOUT_SEC}s)..."
  while true; do
    boot_completed=$("$ADB_BIN" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)
    if [ "$boot_completed" = "1" ]; then
      log "Android boot completed."
      return 0
    fi
    now_ts=$(date +%s)
    if [ $((now_ts - start_ts)) -ge "$BOOT_TIMEOUT_SEC" ]; then
      warn "Boot did not complete in time."
      warn "Check emulator logs: /tmp/emulator.log"
      return 1
    fi
    sleep "$BOOT_POLL_SEC"
  done
}

start_emulator_if_needed() {
  require_exec "$EMULATOR_BIN"
  require_exec "$ADB_BIN"

  "$ADB_BIN" start-server >/dev/null 2>&1 || true

  local emu_id
  emu_id="$(get_running_emulator_id || true)"
  if [ -n "${emu_id:-}" ]; then
    log "Emulator already running: $emu_id"
    echo "$emu_id"
    return 0
  fi

  # Determine AVD name
  if [ -z "$AVD_NAME" ]; then
    log "Listing available AVDs..."
    AVD_NAME="$("$EMULATOR_BIN" -list-avds | head -n 1 || true)"
  fi
  [ -n "$AVD_NAME" ] || die "No AVD found. Create one in Android Studio → Device Manager."

  log "Starting emulator: $AVD_NAME"
  "$EMULATOR_BIN" -avd "$AVD_NAME" -netdelay none -netspeed full >/tmp/emulator.log 2>&1 &

  log "Waiting for emulator device..."
  "$ADB_BIN" wait-for-device

  wait_for_boot || die "Emulator boot timeout."

  emu_id="$(get_running_emulator_id || true)"
  [ -n "${emu_id:-}" ] || die "Emulator started but adb didn't report an emulator-* device."
  log "Emulator ready: $emu_id"
  echo "$emu_id"
}

# ---- Main ----
cd "$PROJECT_ROOT"
[ -f "pubspec.yaml" ] || die "pubspec.yaml not found. Are you in the Flutter project root? ($PROJECT_ROOT)"

require_cmd flutter
require_cmd dart

log "Project root: $PROJECT_ROOT"

# Optional clean
if [ "$CLEAN" = "1" ]; then
  log "Running: flutter clean"
  flutter clean
fi

# Ensure Android tooling exists
require_exec "$ADB_BIN"
require_exec "$EMULATOR_BIN"

# Start or reuse emulator
_="$(start_emulator_if_needed)" >/dev/null

# Pick Android target id (emulator preferred)
ANDROID_TARGET="$(get_first_android_device_id || true)"
[ -n "${ANDROID_TARGET:-}" ] || die "No Android device detected via adb. Is the emulator running?"

log "ANDROID_TARGET='$ANDROID_TARGET'"

# Dependencies
log "Running: flutter pub get"
flutter pub get

# Format (optional) - only lib + test
if [ "$SKIP_FORMAT" != "1" ]; then
  log "Running: dart format lib test"
  dart format lib test
else
  warn "Skipping format (SKIP_FORMAT=1)"
fi

# Analyze (optional)
if [ "$SKIP_ANALYZE" != "1" ]; then
  log "Running: flutter analyze"
  flutter analyze
else
  warn "Skipping analyze (SKIP_ANALYZE=1)"
fi

# Tests (optional)
if [ "$SKIP_TESTS" != "1" ]; then
  log "Running: flutter test"
  flutter test
else
  warn "Skipping tests (SKIP_TESTS=1)"
fi

# Run on Android target
log "Running: flutter run -d $ANDROID_TARGET"
flutter run -d "$ANDROID_TARGET"
