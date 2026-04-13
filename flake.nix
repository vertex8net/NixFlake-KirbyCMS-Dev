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
            PROJECT_ROOT=$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || pwd)
            cd "$PROJECT_ROOT"

            export APP_ENV="${envName}"
            export CADDY_PORT="${toString port}"
            export CADDY_LOG_LEVEL="${logLevel}"
            mkdir -p "$PROJECT_ROOT/.run"
            export PHP_SOCKET="$PROJECT_ROOT/.run/php-fpm-${envName}.sock"
            
            # Composer Auto-Install: Scan public/ and public/* for composer.json
            echo "Checking for composer.json in public/..."
            ${pkgs.findutils}/bin/find public -maxdepth 2 -name composer.json -exec dirname {} \; | while read dir; do
                if [ ! -d "$dir/vendor" ]; then
                    echo "Running composer install in $dir..."
                    (cd "$dir" && ${phpPkg.packages.composer}/bin/composer install)
                else
                    echo "Composer vendor already exists in $dir, skipping install."
                fi
            done

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
