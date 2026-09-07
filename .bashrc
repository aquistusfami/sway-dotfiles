# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '


# Added by Antigravity CLI installer
export PATH="/home/aquistus/.local/bin:$PATH"
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
