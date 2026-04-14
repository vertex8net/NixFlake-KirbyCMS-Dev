{
  description = "Caddy and PHP-FPM environment with Process Compose";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # === Configuration ===
        phpPkg = pkgs.php83.buildEnv {
          extensions = ({ enabled, all }: enabled ++ (with all; [
            gd
            imagick
            exif
            intl
            # Note: Core modules like json, hash, ctype, curl, dom, openssl, mbstring, etc.
            # are inherently built-in natively to Nix's PHP compiler by default!
          ]));
        };
        devPort = 8080;
        # =====================
        
        # Helper to create a start script for process-compose
        mkRunner = envName: port: logLevel:
          pkgs.writeShellScriptBin "start-${envName}" ''
            # Path Stabilization: Always run from the project root
            export PROJECT_ROOT=$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || pwd)
            cd "$PROJECT_ROOT"

            export APP_ENV="${envName}"
            export CADDY_PORT="${toString port}"
            export CADDY_LOG_LEVEL="${logLevel}"
            mkdir -p "$PROJECT_ROOT/.run/www"
            export PHP_SOCKET="$PROJECT_ROOT/.run/php-fpm-${envName}.sock"
            
            # Ensure all scripts are executable
            chmod +x flakeConf/*.sh
            
            # Dynamically build index and subdomains
            ./flakeConf/generate-configs.sh
            
            # Composer Auto-Install: Scan sites/ and sites/* for composer.json
            ./flakeConf/install-deps.sh

            echo "Validating configurations..."
            ${pkgs.caddy}/bin/caddy validate --config flakeConf/Caddyfile --adapter caddyfile || exit 1
            ${phpPkg}/bin/php-fpm -y flakeConf/php-fpm.conf -t || exit 1

            echo "Starting ${envName} environment (Caddy on port $CADDY_PORT)..."
            ${pkgs.process-compose}/bin/process-compose -p 0 -f flakeConf/process-compose.yml up
          '';

      in
      {
        packages = {
          default = self.packages.${system}.dev;
          dev = mkRunner "dev" devPort "DEBUG";
        };

        apps = {
          default = flake-utils.lib.mkApp { drv = self.packages.${system}.dev; };
          dev = flake-utils.lib.mkApp { drv = self.packages.${system}.dev; };
        };

        devShells = {
          default = self.devShells.${system}.dev;
          
          dev = pkgs.mkShell {
            buildInputs = [
              pkgs.caddy
              phpPkg
              phpPkg.packages.composer
              pkgs.process-compose
              pkgs.git
              pkgs.gh
              pkgs.xdg-utils
              pkgs.watchexec
            ];

            shellHook = ''
              export APP_ENV="dev"
              export CADDY_PORT="${toString devPort}"
              export CADDY_LOG_LEVEL="DEBUG"
              export PHP_SOCKET="$PWD/.run/php-fpm-dev.sock"
              
              echo "Caddy & PHP Development Environment"
              echo "Run 'nix run .#dev' or 'process-compose up' to start the services."
            '';
          };
        };
      }
    );
}
