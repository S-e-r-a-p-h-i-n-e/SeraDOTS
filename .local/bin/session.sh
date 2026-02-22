# 1. Source the modular environment you already built
# This ensures 20-toolkits.env and 90-user-prefs.sh run correctly
[ -f "$HOME/.config/YASD/env/env.sh" ] && . "$HOME/.config/YASD/env/env.sh"

# 2. Exec your compositor (pass the compositor name as an argument)
# e.g., sera-session sway
exec "$@"