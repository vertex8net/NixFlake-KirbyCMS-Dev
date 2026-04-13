# Caddy & PHP-FPM Development Suite

A portable, isolated development environment powered by Nix Flakes and Process-Compose.

## 🚀 Quick Setup

1. **Authorize Direnv**:
   ```bash
   direnv allow
   ```
   *This automatically primes your shell with Caddy, PHP 8.3, Composer, Git, and the GitHub CLI.*

2. **Launch the Services**:
   ```bash
   nix run .
   ```
   *This will validate your configs and open a unified TUI showing logs for both Caddy and PHP-FPM.*

## 🛠 Workflow

### Adding a New Kirby (or PHP) Project
This suite is designed to host multiple projects inside the `public/` directory.

1. **Clone your project**:
   ```bash
   cd public
   gh repo clone user/project
   ```
2. **Start the suite**:
   ```bash
   cd ..
   nix run .
   ```
   *The runner will automatically detect the new `composer.json` and run `composer install` for you if there's a composer file in public/ or its direct children.*

3. **Access it**:
   Open `http://localhost:8080/project` in your browser.

## 📂 Project Structure

- `public/`: Place your PHP projects here.
- `flakeConf/`:
  - `Caddyfile`: Global and site configuration for Caddy.
  - `php-fpm.conf`: PHP-FPM pool and logging settings.
  - `process-compose.yml`: Service orchestration.
- `flake.nix`: The engine. Change ports or PHP versions here.
- `.run/`: (Gitignored) Contains local unix sockets and generated configs.

## 💡 Expert Tips

- **Validation**: Every time you run `nix run .`, your Caddy and PHP configs are automatically validated for syntax errors.
- **Cleanup**: Hit `Ctrl+C` in the process-compose TUI to gracefully stop all services and clean up sockets.
- **Port Conflicts**: If you need to run another project suite simultaneously, change `devPort = 8080` at the top of `flake.nix`.
