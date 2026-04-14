# KirbyCMS Development Suite

A portable, isolated KirbyCMS development environment powered by Nix Flakes and Process-Compose.

## ✨ Key Features

- **🔥 Hot Reload**: Automatically detects new folders, generates configs, installs dependencies, and reloads Caddy—no restart required.
- **🚀 Dynamic Subdomains**: Automatically scans your `sites/` folder and creates `http://project-name.localhost:8080` for every subdirectory.
- **🏠 Project Index**: A central landing page at `http://localhost:8080` that lists all your active projects.
- **🌐 Auto-Open**: Your default browser opens/refreshes automatically to show updates.
- **📦 Composer Autopilot**: Automatically detects and runs `composer install` in your project folders.
- **🛠 Isolated Environment**: Ships with PHP 8.3 (with Kirby-ready extensions), Caddy, and Composer.

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
   *Starts the environment and opens the project index in your browser.*

## 🛠 Workflow

### Adding a New Kirby Project
Everything inside the `sites/` directory is automatically picked up by the watcher.

1. **Clone a project** (Example: Kirby Starterkit):
   ```bash
   cd sites
   gh repo clone getkirby/starterkit
   ```
2. **Automatic Detection**:
   The suite will instantly:
   - Generate `http://my-new-site.localhost:8080`.
   - Run `composer install` inside the new folder.
   - Reload Caddy gracefully.
   - Re-open your browser to the project index.

3. **Access it**:
   Simply click the link on the landing page or visit your new subdomain directly.

## 📂 Project Structure

- `sites/`: Place your PHP projects here. Every subdirectory becomes a subdomain.
- `flakeConf/`:
  - `reload-all.sh`: The orchestration script that handles hot-reloading.
  - `generate-configs.sh`: Builds the Caddy routes and the landing page.
  - `install-deps.sh`: Handles automatic composer dependency installation.
- `flake.nix`: Main environment definition and startup sequence.
- `.run/`: (Gitignored) Contains local unix sockets, generated Caddy rules, and the landing page.

## 💡 Expert Tips

- **Validation**: Every configuration change is validated for syntax errors before reloading.
- **Subdomain Sanitization**: Folders like `My Site` are automatically turned into `my-site.localhost`.
- **Port Conflicts**: Change `devPort = 8080` in `flake.nix` if you need to run multiple suites.


