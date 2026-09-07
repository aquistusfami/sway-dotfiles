# ==============================================================================
# ZSH Configuration - Optimized for Foot Terminal & Acid Dark Theme
# ==============================================================================

# Ensure environment variables are loaded
[ -f "$HOME/.zprofile" ] && source "$HOME/.zprofile"
export EDITOR="nvim"
export VISUAL="nvim"
export NNN_OPTS="eEd"
export NNN_OPENER="${NNN_OPENER:-$HOME/.config/nnn/open}"

# ------------------------------------------------------------------------------
# 1. Directory Navigation & Shell Behavior
# ------------------------------------------------------------------------------
setopt AUTO_CD              # Type directory name to cd into it
setopt AUTO_PUSHD           # Push visited dirs to stack
setopt PUSHD_IGNORE_DUPS    # Do not push duplicates
setopt PUSHD_SILENT         # Suppress dir stack output
setopt EXTENDED_GLOB        # Enable extended globbing (#, ~, ^)
setopt PROMPT_SUBST         # Enable parameter expansion in prompt
setopt NO_BEEP              # Disable audio bell/beep

# ------------------------------------------------------------------------------
# 2. Optimized History Settings
# ------------------------------------------------------------------------------
HISTFILE="$HOME/.cache/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY       # Save timestamps with commands
setopt SHARE_HISTORY          # Share history between active sessions
setopt HIST_EXPIRE_DUPS_FIRST # Delete oldest duplicates when full
setopt HIST_IGNORE_DUPS       # Do not record duplicate of previous event
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries from history
setopt HIST_FIND_NO_DUPS      # Do not show duplicates during search
setopt HIST_IGNORE_SPACE      # Prefix command with space to omit from history
setopt HIST_SAVE_NO_DUPS      # Do not write duplicated events to file
setopt HIST_REDUCE_BLANKS     # Clean superfluous blanks from commands
setopt HIST_VERIFY            # Do not execute immediately when using history expansion

# ------------------------------------------------------------------------------
# 3. High-Performance Tab Completion (Caching)
# ------------------------------------------------------------------------------
autoload -Uz compinit
# Rebuild zcompdump once per day only for instant shell startup
if [[ -n "$HOME/.cache/zsh/zcompdump"(#qN.mh+24) ]]; then
    compinit -d "$HOME/.cache/zsh/zcompdump"
else
    compinit -C -d "$HOME/.cache/zsh/zcompdump"
fi

# Case-insensitive tab completion & colored list
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true

# ------------------------------------------------------------------------------
# 4. Modern Keybindings (Foot Terminal & Standard)
# ------------------------------------------------------------------------------
bindkey -e  # Emacs mode default

# Navigation
bindkey '^[[H' beginning-of-line          # Home
bindkey '^[[F' end-of-line                # End
bindkey '^[[1;5C' forward-word             # Ctrl + Right
bindkey '^[[1;5D' backward-word            # Ctrl + Left
bindkey '^[[3~' delete-char               # Delete
bindkey '^H' backward-kill-word           # Ctrl + Backspace
bindkey '^A' beginning-of-line            # Ctrl + A
bindkey '^E' end-of-line                  # Ctrl + E

# ------------------------------------------------------------------------------
# 5. Native XBPS Plugins (Direct Sourcing for Zero Latency)
# ------------------------------------------------------------------------------
# zsh-autosuggestions
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#686868'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# zsh-history-substring-search (Up/Down arrow substring search)
if [ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^P' history-substring-search-up
    bindkey '^N' history-substring-search-down
fi

# zsh-syntax-highlighting (Must be sourced last among plugins)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
fi

# ------------------------------------------------------------------------------
# 6. Aliases & Enhancements
# ------------------------------------------------------------------------------
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias fetch='fastfetch'
alias neofetch='fastfetch'

# ------------------------------------------------------------------------------
# 7. nnn File Manager (cd-on-quit wrapper)
# ------------------------------------------------------------------------------
n() {
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    export EDITOR="nvim"
    export VISUAL="nvim"
    export NNN_OPTS="eEd"
    export NNN_OPENER="${NNN_OPENER:-$HOME/.config/nnn/open}"
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

# ------------------------------------------------------------------------------
# 8. Starship Prompt Initialization
# ------------------------------------------------------------------------------
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi
