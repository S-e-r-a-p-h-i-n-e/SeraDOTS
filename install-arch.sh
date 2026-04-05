#!/bin/sh
# -----------------------------------------------------------------------------
# SeraDOTS — Arch Linux Package Installer
# Called by deploymentTool.sh after dotfiles have been copied.
# Reads package lists from PKGLIST (must live alongside this script).
# Accepts the compositor profile as its first argument.
# POSIX-compliant — compatible with bash, zsh, dash, sh
# -----------------------------------------------------------------------------
# Usage: install-arch.sh <compositor> [--aur-helper <helper>] [--dry-run]
#   compositor: core | sway | swayfx | hyprland | hyprland-quickshell | niri
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
PKGLIST="$SCRIPT_DIR/PKGLIST"

COMPOSITOR=""
AUR_HELPER=""
DRY_RUN=0

# --- Visual Helpers ---
log_info() { printf '\033[0;34m[INFO]\033[0m %s\n' "$1"; }
log_done() { printf '\033[0;32m[DONE]\033[0m %s\n' "$1"; }
log_warn() { printf '\033[0;33m[WARN]\033[0m %s\n' "$1"; }
log_err()  { printf '\033[0;31m[ERR ]\033[0m %s\n' "$1" >&2; }

die() { log_err "$1"; exit 1; }

execute() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '\033[0;35m[DRY-RUN]\033[0m Would execute: %s\n' "$*"
    else
        "$@"
    fi
}

# --- Argument Parsing ---
while [ $# -gt 0 ]; do
    case "$1" in
        core|sway|swayfx|hyprland|hyprland-quickshell|niri)
            COMPOSITOR="$1"
            ;;
        --aur-helper)
            shift
            AUR_HELPER="$1"
            ;;
        --dry-run|-d)
            DRY_RUN=1
            ;;
        *)
            die "Unknown argument: $1"
            ;;
    esac
    shift
done

[ -z "$COMPOSITOR" ] && die "No compositor specified. Usage: install-arch.sh <compositor>"
[ -f "$PKGLIST" ]    || die "Package list not found at: $PKGLIST"

[ "$DRY_RUN" -eq 1 ] && printf '\033[0;35m--- DEBUG MODE: NO PACKAGES WILL BE INSTALLED ---\033[0m\n'

# =============================================================================
# Package List Parser
#
# Reads packages from a named section in seradots-pkglist.txt.
# Sections are identified by their [N] tag in the header comment.
#
# Usage:  pkgs_from_section <section_index> [aur|pacman|all]
#   section_index:  0=core, 1=sway, 2=swayfx, 3=hyprland, 4=hyprland-qs, 5=niri
#   filter:         "aur"    — only AUR-tagged packages
#                   "pacman" — only non-AUR packages
#                   "all"    — all packages (default)
#
# Package line rules (must all be true to count as a package):
#   - Does not start with whitespace or #  (skips comment-only lines)
#   - First field starts with [a-z0-9]    (skips stray # from continuation comments)
#   - Not blank
# =============================================================================
pkgs_from_section() {
    section_idx="$1"
    filter="${2:-all}"

    awk -v idx="$section_idx" -v filter="$filter" '
        $0 ~ ("^# \\[" idx "\\]") { in_section=1; next }
        /^# \[[0-9]/ && in_section { exit }
        !in_section                { next }
        /^[[:space:]]*#/           { next }
        /^[[:space:]]*$/           { next }
        $1 !~ /^[a-z0-9]/         { next }
        filter == "aur"    &&  /\[AUR\]/ { print $1; next }
        filter == "pacman" && !/\[AUR\]/ { print $1; next }
        filter == "all"                  { print $1; next }
    ' "$PKGLIST"
}

# Map compositor name to its section index in the pkglist
compositor_to_idx() {
    case "$1" in
        sway)                echo 1 ;;
        swayfx)              echo 2 ;;
        hyprland)            echo 3 ;;
        hyprland-quickshell) echo 4 ;;
        niri)                echo 5 ;;
        *)                   echo "" ;;
    esac
}

# =============================================================================
# AUR Helper Detection
# =============================================================================
detect_aur_helper() {
    if [ -n "$AUR_HELPER" ]; then
        command -v "$AUR_HELPER" >/dev/null 2>&1 || die "Specified AUR helper '$AUR_HELPER' not found."
        log_info "Using AUR helper: $AUR_HELPER"
        return
    fi

    for helper in yay paru pikaur trizen aurman; do
        if command -v "$helper" >/dev/null 2>&1; then
            AUR_HELPER="$helper"
            log_info "Detected AUR helper: $AUR_HELPER"
            return
        fi
    done

    log_warn "No AUR helper found — AUR packages will be skipped."
    log_warn "Install yay or paru first, then re-run to get AUR packages."
    AUR_HELPER=""
}

# =============================================================================
# Package Installation Helpers
# Both read a newline-separated package list from stdin.
# =============================================================================

pacman_install() {
    pkgs="$(cat)"
    [ -z "$pkgs" ] && return
    log_info "pacman: $(printf '%s' "$pkgs" | tr '\n' ' ')"
    # word-split intentional here — each line is one package name
    # shellcheck disable=SC2086
    execute sudo pacman -S --needed --noconfirm $pkgs
}

aur_install() {
    pkgs="$(cat)"
    [ -z "$pkgs" ] && return
    if [ -z "$AUR_HELPER" ]; then
        log_warn "Skipping AUR packages (no helper): $(printf '%s' "$pkgs" | tr '\n' ' ')"
        return
    fi
    log_info "aur ($AUR_HELPER): $(printf '%s' "$pkgs" | tr '\n' ' ')"
    # shellcheck disable=SC2086
    execute "$AUR_HELPER" -S --needed --noconfirm $pkgs
}

# Install all packages from a given pkglist section index.
install_section() {
    section_idx="$1"
    label="$2"
    log_info "Installing $label packages..."
    pkgs_from_section "$section_idx" pacman | pacman_install
    pkgs_from_section "$section_idx" aur    | aur_install
}

# =============================================================================
# Main
# =============================================================================

detect_aur_helper

# Core is always installed regardless of compositor choice
install_section 0 "Core"

# Compositor-specific section (skip if profile is core-only)
if [ "$COMPOSITOR" != "core" ]; then
    idx="$(compositor_to_idx "$COMPOSITOR")"
    [ -z "$idx" ] && die "Unknown compositor: $COMPOSITOR"
    install_section "$idx" "$COMPOSITOR"
fi

log_done "Package installation complete for profile: $COMPOSITOR"
