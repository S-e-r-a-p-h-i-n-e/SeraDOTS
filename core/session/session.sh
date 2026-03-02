# 1. Source the modular environment you already built
# This ensures 01-toolkits.env and 99-user-prefs.sh run correctly
[ -f "$HOME/.config/SeraDOTS/env/env.sh" ] && . "$HOME/.config/SeraDOTS/env/env.sh"

# 2. Exec your compositor (pass the compositor name as an argument)
# e.g., sera-session sway
exec "$@"