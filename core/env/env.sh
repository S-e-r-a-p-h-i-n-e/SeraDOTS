# SeraDOTS environment loader

ENV_DIR="$HOME/.config/YASD/env"

[ -f "$ENV_DIR/00-core.env" ] && . "$ENV_DIR/00-core.env"
[ -f "$ENV_DIR/20-toolkits.env" ] && . "$ENV_DIR/20-toolkits.env"
[ -f "$ENV_DIR/90-user-prefs.sh" ] && . "$ENV_DIR/90-user-prefs.sh"