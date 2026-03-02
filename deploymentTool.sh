# --- SeraDOTS Configuration Deployment Tool ---
# Target: Arch Linux, Void Linux
# Design: Path-Remapping Dotfile Engine

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
readonly SERA_CONFIG="$HOME/.config/SeraDOTS"
readonly USER_BIN="$HOME/.local/bin"
DRY_RUN=0

# --- Visual Helpers ---
log_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
log_done() { echo -e "\033[0;32m[DONE]\033[0m $1"; }
log_warn() { echo -e "\033[0;33m[WARN]\033[0m $1"; }

execute() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo -e "\033[0;35m[DRY-RUN]\033[0m Would execute: $*"
    else
        "$@"
    fi
}

# --- New: Zsh Redirection ---
setup_zsh_bootstrap() {
    log_info "Bootstrapping ZSH to ~/.config/zsh..."
    local zshenv_content='export ZDOTDIR="$HOME/.config/zsh"'
    
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo -e "\033[0;35m[DRY-RUN]\033[0m Would create ~/.zshenv with: $zshenv_content"
    else
        echo "$zshenv_content" > "$HOME/.zshenv"
        log_done "Created ~/.zshenv"
    fi
}

# --- Deployment Engine ---
deploy() {
    local src="$SCRIPT_DIR/$1"
    local dest="$2"
    local rename="$3"

    [[ ! -e "$src" ]] && { log_warn "Source missing: $1"; return; }

    execute mkdir -p "$dest"
    
    if [[ -n "$rename" ]]; then
        log_info "Mapping $1 -> $dest/$rename"
        execute cp -rn "$src" "$dest/$rename"
    else
        log_info "Mapping $1 -> $dest/"
        execute cp -rn "$src/." "$dest/"
    fi
}

# --- 1. Core Logic ---
install_core() {
    log_info "PHASE: Deploying SeraDOTS Core & Services..."
    
    # Target directory for all environment variables
    local env_dest="$SERA_CONFIG/env"

    # 1. Deploy contents of core/env -> SeraDOTS/env/
    deploy "core/env" "$env_dest"
    
    # 2. Deploy contents of overrides/env-overrides -> SeraDOTS/env/
    # We use the subpath to avoid nesting the folder itself
    deploy "overrides/env-overrides" "$env_dest"

    execute mkdir -p "$USER_BIN"
    [[ -f "$SCRIPT_DIR/core/session/session.sh" ]] && \
        execute cp -n "$SCRIPT_DIR/core/session/session.sh" "$USER_BIN/"

    log_info "Flattening all services into $USER_BIN..."
    execute find "$SCRIPT_DIR/services" -type f -name "*.sh" -exec cp -n {} "$USER_BIN/" \;
    execute chmod +x "$USER_BIN"/*.sh
    
    setup_zsh_bootstrap
}

# --- 2. Environment & Extensions ---
install_env_layer() {
    log_info "PHASE: Deploying Userland & Shared Extensions..."
    deploy "userland" "$HOME/.config"
    deploy "extensions/waybar" "$HOME/.config" "waybar"
    deploy "extensions/xdg-desktop-portal" "$HOME/.config" "xdg-desktop-portal"
}

install_compositor() {
    local comp=$1
    log_info "PHASE: Deploying $comp Extension..."
    case $comp in
        "sway")    deploy "baseline/sway" "$HOME/.config" "sway" ;;
        "swayfx")  deploy "extensions/swayfx" "$HOME/.config" "sway" ;;
        "hyprland") deploy "extensions/hypr" "$HOME/.config" "hypr" ;;
        "niri")    deploy "extensions/niri" "$HOME/.config" "niri" ;;
    esac
}

# --- 3. Dynamic Contracts ---
apply_contracts() {
    log_info "Applying hardware/monitor contracts..."
    local primary=$(hyprctl monitors | awk '/Monitor/ {print $2}' | head -n 1 2>/dev/null)
    [[ -z "$primary" ]] && primary=$(basename $(dirname $(grep -l "^connected$" /sys/class/drm/*/status | head -n 1 2>/dev/null)) | sed 's/card[0-9]-//' 2>/dev/null)

    if [[ -n "$primary" ]]; then
        log_done "Primary monitor detected: $primary"
        execute find "$HOME/.config" -type f \( -name "*.conf" -o -name "*.kdl" -o -name "*.jsonc" \) -exec sed -i "s/__PRIMARY__/$primary/g" {} +
    fi

    if [[ -d /sys/class/power_supply/BAT0 ]]; then
        log_done "Chassis: Laptop detected."
        execute sed -i 's/IS_LAPTOP=false/IS_LAPTOP=true/g' "$SERA_CONFIG/00-core.env" 2>/dev/null || true
    fi
}

# --- Main Execution ---
for arg in "$@"; do
    [[ "$arg" == "--dry-run" || "$arg" == "-d" ]] && DRY_RUN=1
done

[[ "$DRY_RUN" -eq 1 ]] && echo -e "\033[0;35m--- DEBUG MODE: NO FILES WILL BE MODIFIED ---\033[0m"

echo -e "\nSeraDOTS Deployer:"
echo "1) Core Only"
echo "2) Baseline (Core + Sway + Userland)"
echo "3) Extension (Core + SwayFX + Userland)"
echo "4) Extension (Core + Hyprland + Userland)"
echo "5) Extension (Core + Niri + Userland)"
echo "q) Quit"
read -p "Selection: " choice

case $choice in
    1) install_core ;;
    2) install_core; install_env_layer; install_compositor "sway" ;;
    3) install_core; install_env_layer; install_compositor "swayfx" ;;
    4) install_core; install_env_layer; install_compositor "hyprland" ;;
    5) install_core; install_env_layer; install_compositor "niri" ;;
    *) exit 0 ;;
esac

apply_contracts
log_done "SeraDOTS configuration deployed."