#!/usr/bin/env bash

# This script performs a full reload:
# 1. Regenerates the dynamic Caddyfile and project index.
# 2. Scans for and installs missing composer dependencies.
# 3. Tells Caddy to reload its configuration gracefully.

echo "--- Hot Reload Started ---"

# Step 1: Configs & Index
chmod +x flakeConf/generate-configs.sh
./flakeConf/generate-configs.sh

# Step 2: Dependencies
chmod +x flakeConf/install-deps.sh
./flakeConf/install-deps.sh

# Step 3: Caddy Reload
echo "Reloading Caddy..."
caddy reload --config flakeConf/Caddyfile --adapter caddyfile

# Simple browser open after reload
xdg-open "http://localhost:$CADDY_PORT"

echo "--- Hot Reload Complete ---"
