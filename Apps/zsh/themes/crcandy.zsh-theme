# crcandy - grayscale + pure red prompt

# Colors
CR_WHITE=$'\e[38;2;255;255;255m'
CR_LIGHT=$'\e[38;5;250m'
CR_GIT=$'\e[38;5;244m'
CR_RED=$'\e[38;2;255;0;0m'
CR_RESET=$'\e[0m'

PROMPT=$'
%{${CR_WHITE}%}%n@%m %{${CR_LIGHT}%}%D{[%H:%M:%S]} %{${CR_LIGHT}%}[%~]%{${CR_RESET}%} $(git_prompt_info)\
%{${CR_RED}%}->%{${CR_RED}%} %#%{${CR_RESET}%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{${CR_GIT}%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{${CR_RESET}%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{${CR_RED}%}*%{${CR_GIT}%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""