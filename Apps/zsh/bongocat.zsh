# Bongo cat in the kitty/hyprbars title bar
[[ -n $KITTY_WINDOW_ID ]] || return 0

zmodload zsh/datetime
autoload -Uz add-zle-hook-widget

# oh-my-zsh would overwrite the title
precmd_functions=(${precmd_functions:#omz_termsupport_precmd})
preexec_functions=(${preexec_functions:#omz_termsupport_preexec})

# ---- calibration (tune these, see below) ----
typeset -g _cat_cellw=10     # px per terminal column
typeset -g _cat_spacew=4     # px width of one space in the bar font
typeset -g _cat_catw=70      # px width of the cat text
typeset -g _cat_margin=24    # px gap between the cat and the right edge

typeset -g  _cat_frame=""    # current cat frame
typeset -g  _cat_sent=""     # last title actually sent
typeset -g  _cat_prev=""
typeset -g  _cat_flip=0
typeset -gF _cat_last=0
typeset -g  _cat_idle_frame=$'\ue000'
typeset -ga _cat_paws=($'\ue001' $'\ue002')

# build "spaces + cat" so the centered string ends at the right edge
_cat_send() {
  _cat_frame=$1
  local barw=$(( COLUMNS * _cat_cellw + 40 ))   # +40 = kitty window padding
  local n=$(( (barw - 2 * _cat_margin - _cat_catw) / _cat_spacew ))
  (( n < 0 )) && n=0
  local title="${(l:$n:: :)}${_cat_frame}"
  [[ $_cat_sent == $title ]] && return
  _cat_sent=$title
  print -n -- "\e]2;${title}\a"
}

# every change of the typed line: alternate the paws
_cat_redraw() {
  [[ $BUFFER == $_cat_prev ]] && return
  _cat_prev=$BUFFER
  _cat_last=$EPOCHREALTIME
  (( _cat_flip = !_cat_flip ))
  _cat_send $_cat_paws[_cat_flip+1]
}

_cat_idle() { _cat_prev=""; _cat_send $_cat_idle_frame }

add-zle-hook-widget line-pre-redraw _cat_redraw
precmd_functions+=(_cat_idle)

# idle again after ~0.7s without typing
TMOUT=1
TRAPALRM() {
  (( EPOCHREALTIME - _cat_last > 0.7 )) && _cat_send $_cat_idle_frame
  return 0
}

# window resized: recompute the padding
TRAPWINCH() {
  _cat_sent=""
  _cat_send ${_cat_frame:-$_cat_idle_frame}
}