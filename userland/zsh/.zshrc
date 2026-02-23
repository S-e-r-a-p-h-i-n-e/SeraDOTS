# =========================
# Zsh Interactive Config
# =========================

# If not interactive, exit early
[[ -o interactive ]] || return

# --- History ---
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# --- Completion ---
autoload -Uz compinit
compinit

# --- Keybindings ---
bindkey -e

# --- Prompt (temporary, simple) ---
PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '

# --- Aliases (safe, optional) ---
alias ls='ls --color=auto'
alias ll='ls -lah'

# --- Sanity check helper (remove later) ---
alias envcheck='env | sort | less'