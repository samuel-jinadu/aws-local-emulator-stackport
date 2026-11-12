#!/usr/bin/env bash
set -euo pipefail

docker compose down

cd "$(dirname "${BASH_SOURCE[0]}")"

for dir in fakecloud_data stackport_data; do
    if [[ -d "$dir" ]]; then
        echo "Cleaning $dir ..."
        find "$dir" -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} +
    else
        echo "Skipping $dir (not found)"
    fi
done

echo "Done."