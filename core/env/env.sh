# SeraDOTS environment loader

ENV_DIR="$HOME/.config/SeraDOTS/env"

[ -f "$ENV_DIR/00-core.env" ] && . "$ENV_DIR/00-core.env"
[ -f "$ENV_DIR/01-toolkits.env" ] && . "$ENV_DIR/01-toolkits.env"
[ -f "$ENV_DIR/99-user-prefs.sh" ] && . "$ENV_DIR/99-user-prefs.sh"