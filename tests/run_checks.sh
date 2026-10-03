#!/usr/bin/env bash
# Optional Linux/macOS runner: also catches engine errors that do not set exit code.
set -euo pipefail
cd "$(dirname "$0")/.."
energy_logs=$(mktemp -d)
trap 'rm -rf "$energy_logs"' EXIT
run_check() {
    local label="$1"
    shift
    if ! "$@" > "$energy_logs/$label.log" 2>&1; then
        cat "$energy_logs/$label.log"
        return 1
    fi
    cat "$energy_logs/$label.log"
    if grep -Eq 'SCRIPT ERROR:|^ERROR:|FAIL:' "$energy_logs/$label.log"; then
        return 1
    fi
}
run_check import godot --headless --editor --path . --quit
run_check integration godot --headless --path . --script tests/run_tests.gd
run_check production godot --headless --path . --script tests/production_tests.gd
run_check startup godot --headless --path . --quit-after 180
