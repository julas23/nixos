case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth:erasedups
export original_user=${SUDO_USER:-$(pstree -lsu "$$" | sed -n "s/.*(([^)]*)).*($USER)[^(]*$/1/p")}
export export HISTTIMEFORMAT="<%F %T> (${original_user:-$USER}) "

shopt -s histappend

HISTSIZE=1000000
HISTFILESIZE=2000000

shopt -s checkwinsize

export EDITOR=nano
export VISUAL=nano

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
Linha1="\n\[\033[38;5;6m\]\d\[\033[38;5;6m\] \t\[\033[38;5;1m\] [\[\033[38;5;11m\]\s\[\033[38;5;1m\]] \[\033[38;5;1m\]{\[\033[38;5;11m\]\$?\[\033[38;5;1m\]}"
Linha2="\[$(tput sgr0)\] \$(parse_git_branch)"
Linha3="\n\[$(tput sgr0)\]\[\033[38;5;11m\]\u\[$(tput sgr0)\]\[\033[38;5;9m\]@\[$(tput sgr0)\]\[\033[38;5;27m\]\h\[\033[38;5;11m\]:\[\033[38;5;39m\]\w"
Linha4="\n\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"
PROMPT=`echo $Linha1 $Linha2 $Linha3 $Linha4`

if [ "$color_prompt" = yes ]; then
    PS1=$PROMPT
else
    PS1=$PROMPT
fi
unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1=$PROMPT
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then

    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

fi

export JAVA_TOOL_OPTIONS="-Dcom.eteks.sweethome3d.j3d.useOffScreen3DView=true"
export RUNLEVEL=3

source ~/.aliasrc

#source '/home/juliano/.bash_completions/open-webui.sh'
export PATH="$HOME/.cargo/bin:$PATH"
