#!/usr/bin/env bash

# This script scans the sites/ directory for composer.json files and runs composer install.
# It is designed to be called during startup and by the hot-reload watcher.

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$PROJECT_ROOT"

echo "Scanning sites/ for composer.json..."
# Use find to locate composer.json files up to 2 levels deep
find sites -maxdepth 2 -name composer.json -exec dirname {} \; | while read dir; do
    if [ ! -d "$dir/vendor" ]; then
        echo "Running 'composer install' in $dir..."
        (cd "$dir" && composer install)
    else
        echo "Dependencies already exist in $dir, skipping."
    fi
done
