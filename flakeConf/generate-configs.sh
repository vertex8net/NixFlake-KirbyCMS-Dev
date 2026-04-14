#!/usr/bin/env bash

# This script generates the dynamic Caddyfile and index.html for the KirbyCMS suite.
# It expects PROJECT_ROOT and CADDY_PORT environment variables to be set.

if [ -z "$PROJECT_ROOT" ] || [ -z "$CADDY_PORT" ]; then
    echo "Error: PROJECT_ROOT or CADDY_PORT is not set."
    exit 1
fi

DYNAMIC_WWW="$PROJECT_ROOT/.run/www"
DYNAMIC_CADDYFILE="$PROJECT_ROOT/.run/Caddyfile.dynamic"

mkdir -p "$DYNAMIC_WWW"

# --- Generate Index.html ---
cat > "$DYNAMIC_WWW/index.html" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Kirby Projects</title>
    <style>
        body { font-family: system-ui, -apple-system, sans-serif; margin: 40px auto; max-width: 600px; line-height: 1.6; background: #f9f9f9; color: #333; }
        h1 { border-bottom: 2px solid #eaeaea; padding-bottom: 10px; color: #222; }
        ul { list-style-type: none; padding: 0; }
        li { margin: 15px 0; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); transition: transform 0.1s; }
        li:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        a { text-decoration: none; color: #0366d6; font-size: 18px; font-weight: 500; display: block; }
        a:hover { color: #0056b3; }
        .subdomain { font-family: monospace; font-size: 14px; color: #666; margin-top: 4px; }
    </style>
</head>
<body>
    <h1>Local Kirby Projects</h1>
    <ul>
EOF

# --- Generate Caddyfile.dynamic ---
echo "# Auto-generated subdomains" > "$DYNAMIC_CADDYFILE"

# Scan sites/ and its immediate children for projects
for dir in "$PROJECT_ROOT/sites/"*/; do
    if [ -d "$dir" ]; then
        basename=$(basename "$dir")
        # skip if it's just a glob literal if sites is empty
        if [ "$basename" = "*" ]; then continue; fi
        
        sanitized=$(echo "$basename" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')
        
        if [ ! -z "$sanitized" ]; then
            url="http://$sanitized.localhost:$CADDY_PORT"
            echo "<li><a href=\"$url\">$basename</a><div class=\"subdomain\">$url</div></li>" >> "$DYNAMIC_WWW/index.html"
            
            cat >> "$DYNAMIC_CADDYFILE" <<EOF
http://$sanitized.localhost:{\$CADDY_PORT} {
    import common
    import kirby
    root * {\$PROJECT_ROOT}/sites/$basename
    log
}
EOF
        fi
    fi
done

echo "    </ul>
</body>
</html>" >> "$DYNAMIC_WWW/index.html"

echo "Configurations generated in .run/"
