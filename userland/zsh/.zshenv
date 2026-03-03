# Zsh environment bootstrap
# MUST be minimal and side-effect free

# Safety net ONLY — not authoritative
[ -f "$HOME/.config/SeraDOTS/env/env.sh" ] && . "$HOME/.config/SeraDOTS/env/env.sh"

# Ensure ZDOTDIR is respected
export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"