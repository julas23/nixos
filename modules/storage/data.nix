# /data Directory Structure
#
# Centralizes all user data, runtimes, and package managers outside of $HOME
# to keep the home directory clean and allow easy backup/migration per directory.
#
# Directory layout:
#   /data/
#   ├── appimage/        AppImage binaries
#   ├── docker/          Docker data root (images, volumes, containers)
#   ├── python/
#   │   ├── venvs/       Python virtual environments
#   │   └── packages/    pip user installs (PYTHONUSERBASE)
#   ├── node/
#   │   ├── npm/         npm global packages (PREFIX)
#   │   └── yarn/        yarn global packages
#   ├── rust/
#   │   ├── cargo/       Cargo home (registry, binaries)
#   │   └── rustup/      Rustup toolchains
#   ├── flatpak/         Flatpak data root
#   └── projects/        General development projects

{ config, lib, pkgs, ... }:

let
  username = config.system.config.user.name;

  # All /data subdirectories to create (owner: user, group: users, mode: 0755)
  dataDirs = [
    "/data"
    "/data/appimage"
    "/data/docker"
    "/data/python"
    "/data/python/venvs"
    "/data/python/packages"
    "/data/node"
    "/data/node/npm"
    "/data/node/yarn"
    "/data/rust"
    "/data/rust/cargo"
    "/data/rust/rustup"
    "/data/flatpak"
    "/data/projects"
  ];

in

{
  # ── 1. Create all /data directories via systemd-tmpfiles ──────────────────
  systemd.tmpfiles.rules =
    map (dir: "d ${dir} 0755 ${username} users -") dataDirs;

  # ── 2. Docker: redirect data root to /data/docker ─────────────────────────
  virtualisation.docker.daemon.settings = lib.mkIf config.virtualisation.docker.enable {
    "data-root" = "/data/docker";
  };

  # ── 3. Flatpak: redirect installation to /data/flatpak ───────────────────
  # (Flatpak system installation remains in /var/lib/flatpak;
  #  user data goes to /data/flatpak via the environment variable below)

  # ── 4. Environment variables: redirect all package managers to /data ──────
  environment.sessionVariables = {
    # Python pip user installs
    PYTHONUSERBASE = "/data/python/packages";
    PIP_USER       = "1";

    # Node.js npm global prefix
    NPM_CONFIG_PREFIX = "/data/node/npm";

    # Yarn global folder
    YARN_GLOBAL_FOLDER = "/data/node/yarn";

    # Rust / Cargo
    CARGO_HOME  = "/data/rust/cargo";
    RUSTUP_HOME = "/data/rust/rustup";

    # Flatpak user data
    FLATPAK_USER_DIR = "/data/flatpak";
  };

  # ── 5. Add /data/node/npm/bin and /data/rust/cargo/bin to PATH ───────────
  environment.extraInit = ''
    export PATH="/data/node/npm/bin:/data/rust/cargo/bin:$PATH"
  '';

  # ── 6. Shell profile: ensure variables are set in interactive shells ───────
  # Written to /etc/profile.d/ so it applies to bash, zsh, and any POSIX shell
  environment.etc."profile.d/data-dirs.sh".text = ''
    # /data directory environment — managed by modules/storage/data.nix
    export PYTHONUSERBASE="/data/python/packages"
    export PIP_USER="1"
    export NPM_CONFIG_PREFIX="/data/node/npm"
    export YARN_GLOBAL_FOLDER="/data/node/yarn"
    export CARGO_HOME="/data/rust/cargo"
    export RUSTUP_HOME="/data/rust/rustup"
    export FLATPAK_USER_DIR="/data/flatpak"
    export PATH="/data/node/npm/bin:/data/rust/cargo/bin:$PATH"
  '';
}
