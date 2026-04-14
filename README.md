# KirbyCMS Development Suite

A portable, isolated KirbyCMS development environment powered by Nix Flakes and Process-Compose.

## ✨ Key Features

- **🚀 Dynamic Subdomains**: Automatically scans your `sites/` folder and creates `http://project-name.localhost:8080` for every subdirectory.
- **🏠 Project Index**: A central landing page at `http://localhost:8080` that lists all your active projects.
- **🌐 Auto-Open**: Your default browser opens automatically to the project index upon startup.
- **📦 Composer Autopilot**: Automatically detects and runs `composer install` in your project folders.
- **🛠 Isolated Environment**: Ships with PHP 8.3 (with Kirby-ready extensions), Caddy, and Composer—nothing else needed on your host system.

## 🚀 Quick Setup

1. **Authorize Direnv**:
   ```bash
   direnv allow
   ```
   *Primes your shell with Caddy, PHP 8.3, Composer, and Git.*

2. **Launch the Services**:
   ```bash
   nix run .
   ```
   *Starts the environment, generates configurations, and opens the suite in your browser.*

## 🛠 Workflow

### Adding a New Kirby Project
Everything inside the `sites/` directory is automatically served.

1. **Drop your project in**:
   ```bash
   cd sites
   gh repo clone user/project
   ```
2. **Restart/Start the suite**:
   ```bash
   nix run .
   ```
   *The suite will detect the new folder, generate its subdomain, and ensure its dependencies are installed.*

3. **Access it**:
   Click your project link on the landing page at `http://localhost:8080` or go directly to `http://<your-folder-name>.localhost:8080`.

## 📂 Project Structure

- `sites/`: Place your PHP projects here. Every subdirectory becomes a subdomain.
- `flakeConf/`:
  - `generate-configs.sh`: The magic that builds the Caddy routes and the landing page.
  - `Caddyfile` / `php-fpm.conf`: Core service configurations.
- `flake.nix`: Main environment definition and startup sequence.
- `.run/`: (Gitignored) Contains local unix sockets, generated Caddy rules, and the landing page.

## 💡 Expert Tips

- **Validation**: Every `nix run .` validates your Caddy and PHP configs before starting.
- **Subdomain Sanitization**: Folders with spaces or weird characters are automatically sanitized into lowercase-dashed subdomains (e.g., `My Site` → `my-site.localhost`).
- **Port Conflicts**: Change `devPort = 8080` in `flake.nix` if you need to run multiple suites.

