# Bongo cat drawn inside kitty (top right)
# - types while you type
# - types while a command is running
[[ -n $KITTY_WINDOW_ID ]] || return 0

zmodload zsh/datetime
autoload -Uz add-zle-hook-widget

# ---- settings ----
typeset -g  _cat_dir=/etc/nixos/Apps/zsh/bongocat   # idle.png left.png right.png
typeset -gi _cat_cols=24      # width in terminal columns
typeset -gi _cat_rows=6       # height in terminal rows
typeset -gi _cat_xpad=1       # columns of space from the right edge
typeset -gF _cat_speed=0.05   # seconds per paw switch while a command runs

# programs that take over the screen: the cat stays still for these
typeset -ga _cat_noanim=(
  vim nvim vi nano less more man htop btop top lazygit lazydocker
  ssh tmux cava nmtui bluetuith bluetui cmatrix pipes pipes.sh sl
  nyancat asciiquarium genact tui-globe wayscriber
)

typeset -gi _cat_cur=1
typeset -g  _cat_prev=""
typeset -gi _cat_flip=0
typeset -gF _cat_last=0
typeset -g  _cat_pid=""

# send the three PNGs to kitty once (ids 101 idle, 102 left, 103 right)
_cat_load() {
  local -a names=(idle left right)
  local i b64
  for i in 1 2 3; do
    b64=$(print -rn -- "${_cat_dir:A}/${names[i]}.png" | base64 -w0)
    printf '\e_Ga=t,f=100,t=f,i=%d,q=2;%s\e\\' $(( 100 + i )) "$b64"
  done
}

# draw frame $1 (1-3) for a terminal that is $2 columns wide
_cat_draw() {
  local id=$(( 100 + $1 ))
  local col=$(( $2 - _cat_cols - _cat_xpad + 1 ))
  (( col < 1 )) && col=1
  local o out
  printf -v out '\e7\e[1;%dH\e_Ga=p,i=%d,p=1,c=%d,r=%d,C=1,z=-1,q=2\e\\' \
    $col $id $_cat_cols $_cat_rows
  for o in 101 102 103; do
    (( o != id )) && out+=$'\e_Ga=d,d=i,i='$o$',p=1,q=2\e\\'
  done
  out+=$'\e8'
  print -rn -- "$out"
}

_cat_show() { _cat_cur=$1; _cat_draw $1 $COLUMNS }

# ---- typing at the prompt ----
_cat_redraw() {
  [[ $BUFFER == $_cat_prev ]] && return
  _cat_prev=$BUFFER
  _cat_last=$EPOCHREALTIME
  (( _cat_flip = !_cat_flip ))
  _cat_show $(( 2 + _cat_flip ))
}

# ---- while a command runs ----
_cat_anim() {
  local f=2 sz cols
  while true; do
    sz=$(stty size < /dev/tty 2>/dev/null)
    cols=${sz##* }
    [[ -n $cols ]] && _cat_draw $f $cols
    (( f = (f == 2) ? 3 : 2 ))
    sleep $_cat_speed
  done
}

_cat_stop() {
  [[ -n $_cat_pid ]] && kill $_cat_pid 2>/dev/null
  _cat_pid=""
}

_cat_preexec() {
  _cat_stop
  local -a w=(${(z)3})
  local c=${w[1]:t}
  [[ $c == (sudo|command|env|time|exec|nohup) ]] && c=${w[2]:t}
  (( ${_cat_noanim[(Ie)$c]} )) && return
  _cat_anim &!
  _cat_pid=$!
}

# ---- back to idle ----
_cat_idle() { _cat_prev=""; _cat_show 1 }

TRAPWINCH() { _cat_show $_cat_cur }

TMOUT=1
TRAPALRM() {
  if (( EPOCHREALTIME - _cat_last > 0.7 && _cat_cur != 1 )); then
    _cat_show 1
  fi
  return 0
}

zshexit() {
  _cat_stop
  local i
  for i in 101 102 103; do printf '\e_Ga=d,d=i,i=%d,q=2\e\\' $i; done
}

_cat_load
add-zle-hook-widget line-pre-redraw _cat_redraw
preexec_functions+=(_cat_preexec)
precmd_functions+=(_cat_stop _cat_idle)