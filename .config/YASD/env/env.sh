# Optional XDG user directories with POSIX-compliant Auto-Creation Guard
# Ensures structural integrity on minimal systems like Void Linux

if command -v xdg-user-dir >/dev/null 2>&1; then
    # POSIX doesn't support arrays, so we use a space-separated string
    _xdg_names="DESKTOP DOWNLOAD TEMPLATES PUBLICSHARE DOCUMENTS MUSIC PICTURES VIDEOS"

    for _name in $_xdg_names; do
        # Get the path from the utility
        _path=$(xdg-user-dir "$_name")
        
        # Ensure the directory exists before we try to use it
        if [ ! -d "$_path" ]; then
            mkdir -p "$_path"
        fi
        
        # POSIX requires assignment and export to be separate for safety
        eval "XDG_${_name}_DIR=\"$_path\""
        export "XDG_${_name}_DIR"
    done
    
    # Clean up the loop variable
    unset _xdg_names _name _path
fi