# Optional XDG user directories
# The system should work without this, if it doesn't then something is wrong, I just can't prove and find it yet

if command -v xdg-user-dir >/dev/null 2>&1; then
  XDG_DESKTOP_DIR="$(xdg-user-dir DESKTOP)"
  XDG_DOWNLOAD_DIR="$(xdg-user-dir DOWNLOAD)"
  XDG_TEMPLATES_DIR="$(xdg-user-dir TEMPLATES)"
  XDG_PUBLICSHARE_DIR="$(xdg-user-dir PUBLICSHARE)"
  XDG_DOCUMENTS_DIR="$(xdg-user-dir DOCUMENTS)"
  XDG_MUSIC_DIR="$(xdg-user-dir MUSIC)"
  XDG_PICTURES_DIR="$(xdg-user-dir PICTURES)"
  XDG_VIDEOS_DIR="$(xdg-user-dir VIDEOS)"

  export \
    XDG_DESKTOP_DIR \
    XDG_DOWNLOAD_DIR \
    XDG_TEMPLATES_DIR \
    XDG_PUBLICSHARE_DIR \
    XDG_DOCUMENTS_DIR \
    XDG_MUSIC_DIR \
    XDG_PICTURES_DIR \
    XDG_VIDEOS_DIR
fi