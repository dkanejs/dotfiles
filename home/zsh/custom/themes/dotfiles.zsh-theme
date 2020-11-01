ZSH_THEME_GIT_PROMPT_PREFIX=" "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{red}%F{black}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %F{green}%F{black}"
ZSH_THEME_GIT_PROMPT_ADDED=" %F{green}%F{black}"
ZSH_THEME_GIT_PROMPT_MODIFIED=" %F{blue}﮻%F{black}"
ZSH_THEME_GIT_PROMPT_DELETED=" %F{red}%F{black}"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %F{yellow}%F{black}"
ZSH_THEME_GIT_PROMPT_RENAMED=" ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED=" ═"
ZSH_THEME_GIT_PROMPT_AHEAD=" ⬆"
ZSH_THEME_GIT_PROMPT_BEHIND=" ⬇"
ZSH_THEME_GIT_PROMPT_DIVERGED=" ⬍"

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

function display_time {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  [[ $D > 0 ]] && printf '%dd' $D
  [[ $H > 0 ]] && printf '%dh' $H
  [[ $M > 0 ]] && printf '%dm' $M
  printf '%ds' $S
}

preexec() {
  cmd_timestamp=`date +%s`
}

precmd() {
  local stop=`date +%s`
  local start=${cmd_timestamp:-$stop}
  let last_exec_duration=$stop-$start
  cmd_timestamp=''
}

prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

prompt_cmd_exec_time() {
  [ $last_exec_duration -gt 5 ] && prompt_segment black white "$(display_time $last_exec_duration)"
}

prompt_custom() {
  prompt_segment black white 
}

prompt_git() {
  local ref dirty mode repo_path git_prompt
  repo_path=$(git rev-parse --git-dir 2>/dev/null)
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    prompt_segment white black
    echo -n $(git_prompt_info)$(git_prompt_status)
  fi
}

prompt_dir() {
  prompt_segment black white "${dir}%4(c:...:)%3c"
}

prompt_python() {
  local version="$(pyenv version-name)"
  if [[ $version != "system" ]]; then
    prompt_segment yellow black " $version"
  fi
}

prompt_aws() {
  if [[ -n "$AWS_PROFILE" ]]; then
    prompt_segment cyan white "☁️  $AWS_PROFILE"
  fi
}

prompt_kubernetes() {
  local context=$(kubectl config current-context 2>/dev/null)
  if [[ ! $context =~ "docker" ]]; then
    prompt_segment blue white "ﴱ $context"
  fi
}

prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="✘ $RETVAL"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡%f"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{white}%}%f"
  if [[ -n "$symbols" && $RETVAL -ne 0 ]]; then
    prompt_segment red black "$symbols"
  elif [[ -n "$symbols" ]]; then
    prompt_segment black white "$symbols"
  fi
}

build_prompt() {
  RETVAL=$?
  for segment in custom cmd_exec_time status aws kubernetes python git dir
  do
    prompt_$segment
  done
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

PROMPT=''
PROMPT="$PROMPT"$'\n''%{%f%b%k%}$(build_prompt)'$'\n''%{${fg_bold[default]}%}\$ %{$reset_color%}'
