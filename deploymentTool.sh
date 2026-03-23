#!/bin/sh
# -----------------------------------------------------------------------------
# SeraDOTS Configuration Deployment Tool
# Target:  Arch Linux, Void Linux
# Design:  Path-Remapping Dotfile Engine
# POSIX-compliant — compatible with bash, zsh, dash, sh
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
SERA_CONFIG="$HOME/.config/SeraDOTS"
USER_BIN="$HOME/.local/bin"
readonly SCRIPT_DIR SERA_CONFIG USER_BIN
DRY_RUN=0
INSTALL_PKGS=0
AUR_HELPER_ARG=""

# --- Visual Helpers ---
log_info() { printf '\033[0;34m[INFO]\033[0m %s\n' "$1"; }
log_done() { printf '\033[0;32m[DONE]\033[0m %s\n' "$1"; }
log_warn() { printf '\033[0;33m[WARN]\033[0m %s\n' "$1"; }

execute() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '\033[0;35m[DRY-RUN]\033[0m Would execute: %s\n' "$*"
    else
        "$@"
    fi
}

# --- Zsh Redirection ---
setup_zsh_bootstrap() {
    log_info "Bootstrapping ZSH to ~/.config/zsh..."
    local_zshenv='export ZDOTDIR="$HOME/.config/zsh"'

    if [ "$DRY_RUN" -eq 1 ]; then
        printf '\033[0;35m[DRY-RUN]\033[0m Would create ~/.zshenv with: %s\n' "$local_zshenv"
    else
        printf '%s\n' "$local_zshenv" > "$HOME/.zshenv"
        log_done "Created ~/.zshenv"
    fi
}

# --- Deployment Engine ---
# Usage: deploy <src_subpath> <dest_dir> [rename]
deploy() {
    src="$SCRIPT_DIR/$1"
    dest="$2"
    rename="$3"

    if [ ! -e "$src" ]; then
        log_warn "Source missing: $1"
        return
    fi

    execute mkdir -p "$dest"

    if [ -n "$rename" ]; then
        log_info "Mapping $1 -> $dest/$rename"
        execute cp -rn "$src" "$dest/$rename"
    else
        log_info "Mapping $1 -> $dest/"
        execute cp -rn "$src/." "$dest/"
    fi
}

# --- Phase 1: Core ---
install_core() {
    log_info "PHASE: Deploying SeraDOTS Core & Services..."

    env_dest="$SERA_CONFIG/env"

    deploy "core/env"                "$env_dest"
    deploy "overrides/env-overrides" "$env_dest"
    deploy "wallpapers"              "$SERA_CONFIG" "wallpapers"

    execute mkdir -p "$USER_BIN"

    if [ -f "$SCRIPT_DIR/core/session/session.sh" ]; then
        execute cp -n "$SCRIPT_DIR/core/session/session.sh" "$USER_BIN/"
    fi

    log_info "Flattening all services into $USER_BIN..."
    execute find "$SCRIPT_DIR/services" -type f -name "*.sh" -exec cp -n {} "$USER_BIN/" \;
    execute chmod +x "$USER_BIN/"*.sh

    setup_zsh_bootstrap
}

# --- Phase 2: Userland & Extensions ---
install_env_layer() {
    log_info "PHASE: Deploying Userland & Shared Extensions..."
    deploy "userland"                      "$HOME/.config"
    deploy "extensions/xdg-desktop-portal" "$HOME/.config" "xdg-desktop-portal"
    
    log_info "Pruning wallust from userland drop (compositor-specific deployment pending)..."
    execute rm -rf "$HOME/.config/wallust"
}

# --- Phase 3: Compositor ---
# Also deploys the wallust templates specific to the selected compositor.
install_compositor() {
    log_info "PHASE: Deploying $1..."
    case $1 in
        sway)
            deploy "baseline/sway"                                      "$HOME/.config" "sway"
            deploy "userland/wallust/templates/sway.template"           "$HOME/.config/wallust/templates" "sway.template"
            ;;
        swayfx)
            deploy "extensions/swayfx"                                  "$HOME/.config" "sway"
            deploy "userland/wallust/templates/swayfx.template"         "$HOME/.config/wallust/templates" "swayfx.template"
            ;;
        hyprland)
            deploy "extensions/hypr"                                    "$HOME/.config" "hypr"
            deploy "userland/wallust/templates/hyprland.template"       "$HOME/.config/wallust/templates" "hyprland.template"
            ;;
        hyprland-quickshell)
            deploy "extensions/hyprland-quickshell/hypr"                "$HOME/.config" "hypr"
            deploy "extensions/hyprland-quickshell/quickshell"          "$HOME/.config" "quickshell"
            deploy "userland/wallust/templates/hyprland.template"       "$HOME/.config/wallust/templates" "hyprland.template"
            ;;
        niri)
            deploy "extensions/niri"                                    "$HOME/.config" "niri"
            deploy "userland/wallust/templates/niri.template"           "$HOME/.config/wallust/templates" "niri.template"
            ;;
        *)
            log_warn "Unknown compositor: $1"
            ;;
    esac

    # Deploy shared wallust config and any non-WM-specific templates
    deploy "userland/wallust/wallust-dark.toml" "$HOME/.config/wallust" "wallust-dark.toml"
    deploy "userland/wallust/wallust-light.toml" "$HOME/.config/wallust" "wallust-light.toml"
    # Copy the contents of the shared templates folder into the main templates folder
    deploy "userland/wallust/templates/shared" "$HOME/.config/wallust/templates"
}

# --- Dynamic Contracts ---
apply_contracts() {
    log_info "Applying hardware/monitor contracts..."
    primary=""

    if command -v hyprctl >/dev/null 2>&1; then
        primary="$(hyprctl monitors 2>/dev/null | awk '/Monitor/ {print $2}' | head -n 1)"
    fi

    if [ -z "$primary" ]; then
        primary="$(find /sys/class/drm -name status 2>/dev/null \
            | xargs grep -l '^connected$' 2>/dev/null \
            | head -n 1 \
            | xargs dirname 2>/dev/null \
            | xargs basename 2>/dev/null \
            | sed 's/card[0-9]*-//')"
    fi

    if [ -n "$primary" ]; then
        log_done "Primary monitor detected: $primary"
        # Added *.json to include Quickshell layout configs
        execute find "$HOME/.config" \
            -type f \( -name "*.conf" -o -name "*.kdl" -o -name "*.jsonc" -o -name "*.json" \) \
            -exec sed -i "s/__PRIMARY__/$primary/g" {} +
    else
        log_warn "Could not detect primary monitor — __PRIMARY__ left unreplaced."
    fi

    if [ -d /sys/class/power_supply/BAT0 ]; then
        log_done "Chassis: Laptop detected."
        execute sed -i 's/IS_LAPTOP=false/IS_LAPTOP=true/g' \
            "$SERA_CONFIG/env/00-core.env" 2>/dev/null || true
    fi
}

# --- Package Installation ---
# Calls install-arch.sh, which must live alongside this script.
run_installer() {
    compositor="$1"
    installer="$SCRIPT_DIR/install-arch.sh"

    if [ ! -f "$installer" ]; then
        log_warn "install-arch.sh not found at $SCRIPT_DIR — skipping package installation."
        return
    fi

    if [ ! -x "$installer" ]; then
        execute chmod +x "$installer"
    fi

    installer_args="$compositor"
    [ "$DRY_RUN" -eq 1 ] && installer_args="$installer_args --dry-run"
    [ -n "$AUR_HELPER_ARG" ] && installer_args="$installer_args --aur-helper $AUR_HELPER_ARG"

    log_info "PHASE: Installing packages for profile: $compositor"
    execute "$installer" $installer_args
}

# --- Argument Parsing ---
for arg in "$@"; do
    case $arg in
        --dry-run|-d)      DRY_RUN=1 ;;
        --install-pkgs|-i) INSTALL_PKGS=1 ;;
        --aur-helper=*)    AUR_HELPER_ARG="${arg#*=}" ;;
    esac
done

[ "$DRY_RUN" -eq 1 ] && printf '\033[0;35m--- DEBUG MODE: NO FILES WILL BE MODIFIED ---\033[0m\n'

# --- Menu ---
printf '\nSeraDOTS Deployer:\n'
printf '  1) Core Only\n'
printf '  2) Baseline  (Core + Sway + Userland)\n'
printf '  3) Extension (Core + SwayFX + Userland)\n'
printf '  4) Extension (Core + Hyprland + Userland)\n'
printf '  5) Extension (Core + Hyprland & Quickshell + Userland)\n'
printf '  6) Extension (Core + Niri + Userland)\n'
printf '  q) Quit\n'
printf 'Selection: '
read -r choice

# If --install-pkgs was not passed as a flag, ask interactively.
if [ "$INSTALL_PKGS" -eq 0 ] && [ "$choice" != "q" ] && [ "$choice" != "Q" ]; then
    printf '\nInstall required packages via pacman/AUR? [y/N] '
    read -r pkg_choice
    case "$pkg_choice" in
        y|Y|yes|Yes) INSTALL_PKGS=1 ;;
    esac
fi

case $choice in
    1)
        install_core
        [ "$INSTALL_PKGS" -eq 1 ] && run_installer "core"
        ;;
    2)
        install_core; install_env_layer; install_compositor "sway"
        [ "$INSTALL_PKGS" -eq 1 ] && run_installer "sway"
        ;;
    3)
        install_core; install_env_layer; install_compositor "swayfx"
        [ "$INSTALL_PKGS" -eq 1 ] && run_installer "swayfx"
        ;;
    4)
        install_core; install_env_layer; install_compositor "hyprland"
        [ "$INSTALL_PKGS" -eq 1 ] && run_installer "hyprland"
        ;;
    5)
        install_core; install_env_layer; install_compositor "hyprland-quickshell"
        [ "$INSTALL_PKGS" -eq 1 ] && run_installer "hyprland-quickshell"
        ;;
    6)
        install_core; install_env_layer; install_compositor "niri"
        [ "$INSTALL_PKGS" -eq 1 ] && run_installer "niri"
        ;;
    *)
        exit 0
        ;;
esac

apply_contracts
log_done "SeraDOTS configuration deployed."
