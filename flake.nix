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
        phpPkg = pkgs.php83;
        devPort = 8080;
        prodPort = 80;
        # =====================
        
        # Helper to create a start script for process-compose
        mkRunner = envName: port: logLevel:
          pkgs.writeShellScriptBin "start-${envName}" ''
            export APP_ENV="${envName}"
            export CADDY_PORT="${toString port}"
            export CADDY_LOG_LEVEL="${logLevel}"
            export PHP_SOCKET="/tmp/php-fpm-${envName}.sock"
            
            echo "Starting ${envName} environment (Caddy on port $CADDY_PORT)..."
            ${pkgs.process-compose}/bin/process-compose -p ''${PC_PORT:-8080} -f process-compose.yml up
          '';

      in
      {
        packages = {
          default = self.packages.${system}.dev;
          dev = mkRunner "dev" devPort "DEBUG";
          prod = mkRunner "prod" prodPort "INFO";
        };

        apps = {
          default = flake-utils.lib.mkApp { drv = self.packages.${system}.dev; };
          dev = flake-utils.lib.mkApp { drv = self.packages.${system}.dev; };
          prod = flake-utils.lib.mkApp { drv = self.packages.${system}.prod; };
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
              export PHP_SOCKET="/tmp/php-fpm-dev.sock"
              
              echo "Caddy & PHP Development Environment"
              echo "Run 'nix run .#dev' or 'process-compose up' to start the services."
            '';
          };
          
          prod = pkgs.mkShell {
            buildInputs = [
              pkgs.caddy
              phpPkg
              phpPkg.packages.composer
              pkgs.process-compose
            ];

            shellHook = ''
              export APP_ENV="prod"
              export CADDY_PORT="${toString prodPort}"
              export CADDY_LOG_LEVEL="INFO"
              export PHP_SOCKET="/tmp/php-fpm-prod.sock"
              
              echo "Caddy & PHP Production Environment"
              echo "Run 'nix run .#prod' to start the services."
            '';
          };
        };
      }
    );
}
