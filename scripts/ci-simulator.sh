#!/usr/bin/env bash
# Creates a fresh simulator for CI and prints its UDID.
# Usage: scripts/ci-simulator.sh "iPhone SE (3rd generation)" 17.5
# The OS argument is a version prefix ("26" picks the newest installed iOS 26.x).
# A missing iOS 17.5 runtime is installed with xcodes (Xcode 26+ can't download it).
set -euo pipefail
device_name=$1
os_prefix=$2

find_runtime() {
    xcrun simctl list runtimes -j | python3 -c '
import json, sys
prefix = sys.argv[1]
runtimes = [r for r in json.load(sys.stdin)["runtimes"]
            if r["platform"] == "iOS" and r["isAvailable"]
            and (r["version"] == prefix or r["version"].startswith(prefix + "."))]
runtimes.sort(key=lambda r: [int(p) for p in r["version"].split(".")])
print(runtimes[-1]["identifier"] if runtimes else "")' "$os_prefix"
}

runtime=$(find_runtime)
if [ -z "$runtime" ]; then
    echo "iOS $os_prefix runtime not installed; installing with xcodes" >&2
    command -v xcodes >/dev/null || brew install xcodesorg/made/xcodes >&2
    download_dir=$(mktemp -d)
    xcodes runtimes download "iOS $os_prefix" --directory "$download_dir" >&2
    xcrun simctl runtime add "$(ls "$download_dir"/*.dmg | head -1)" >&2
    runtime=$(find_runtime)
fi
[ -n "$runtime" ] || { echo "No iOS $os_prefix runtime available" >&2; exit 1; }

device_type=$(xcrun simctl list devicetypes -j | python3 -c '
import json, sys
name = sys.argv[1]
print(next(t["identifier"] for t in json.load(sys.stdin)["devicetypes"] if t["name"] == name))' "$device_name")

udid=$(xcrun simctl create "CI $device_name $os_prefix" "$device_type" "$runtime")
echo "Created $device_name on $runtime: $udid" >&2
echo "$udid"
