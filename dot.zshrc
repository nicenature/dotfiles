export PATH="$HOME/.rbenv/bin:$PATH"
export LANG=ja_JP.UTF-8
export EDITOR=emacs
HISTFILE=$HOME/.zsh-history
HISTSIZE=100000
SAVEHIST=100000

### prompt
unsetopt promptcr
setopt prompt_subst
autoload -U colors; colors
autoload -Uz vcs_info

local HOSTNAME_COLOR=$'%{\e[38;5;190m%}'
local USERNAME_COLOR=$'%{\e[38;5;199m%}'
local PATH_COLOR=$'%{\e[38;5;61m%}'
local RUBY_COLOR=$'%{\e[38;5;31m%}'
local VCS_COLOR=$'%{\e[38;5;248m%}'

zstyle ':vcs_info:*' formats '[%b]'
zstyle ':vcs_info:*' actionformats '[%b] (%a)'

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '¹'  # display ¹ if there are unstaged changes
zstyle ':vcs_info:git:*' stagedstr '²'    # display ² if there are staged changes
zstyle ':vcs_info:git:*' formats '[%b]%c%u'
zstyle ':vcs_info:git:*' actionformats '[%b|%a]%c%u'

function ruby_prompt {
    result=`rbenv version | sed -e 's/ .*//'`
    if [ "$result" ] ; then
        echo "[$result]"
    fi
}

precmd () {
    psvar=()
    vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}

RUBY_INFO=$'%{$RUBY_COLOR%}$(ruby_prompt)%{${reset_color}%}'
FACE_CHAR=("orz")
PICT_CHAR=($'\U1F4A0 ' $'\U1F531 ' $'\U1F640 ' $'\U1F300 ' $'\U1F47B ' $'\U1F383 ' $'\U1F47D ' $'\U1F4AB ' $'\U1F31F ' $'\U2728 ' $'\U1F49A ' $'\U1F49C ' $'\U1F499 ' $'\U1F49B ' $'\U1F431 ' $'\U1F436 ' $'\U1F42F ' $'\U1F63B ' )
RPROMPT="${RUBY_INFO}%{${reset_color}%}"
PROMPT=$'%{$fg[yellow]%}%n$PICT_CHAR[$[$RANDOM % ${#PICT_CHAR[@]} + 1]]$fg[green]%}%m %{$fg[cyan]%}%~ %1(v|%F{green}%1v%f|)\n%{\e[$[32+$RANDOM % 5]m%}$FACE_CHAR[$[$RANDOM % ${#FACE_CHAR[@]} + 1]] %{$fg[green]%}#%{$reset_color%} '

# http://www.machu.jp/diary/20040329.html#p01
# プロンプトを’[user@hostname] $ ’の形式で表示　一般ユーザは $ でrootは # にする
# プロンプトに色を付ける
#local GREEN=$'%{\e[1;32m%}'
#local BLUE=$'%{\e[1;34m%}'
#local DEFAULT=$'%{\e[1;m%}'
#PROMPT=$BLUE'[${USER}@${HOSTNAME}] %(!.#.$) '$DEFAULT
#RPROMPT=$GREEN'[%~]'$DEFAULT
#setopt PROMPT_SUBST

## 補完機能の強化
autoload -U compinit
compinit

# 第1引数がディレクトリだと自動的に cd を補完
setopt auto_cd

## コアダンプサイズを制限
limit coredumpsize 102400

## 出力の文字列末尾に改行コードが無い場合でも表示
unsetopt promptcr

## 色を使う
setopt prompt_subst

## ビープを鳴らさない
setopt nobeep

## 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs

## 補完候補一覧でファイルの種別をマーク表示
setopt list_types

## サスペンド中のプロセスと同じコマンド名を実行した場合はリジューム
setopt auto_resume

## 補完候補を一覧表示
setopt auto_list

## 直前と同じコマンドをヒストリに追加しない
setopt hist_ignore_dups

## cd 時に自動で push
setopt autopushd

## 同じディレクトリを pushd しない
setopt pushd_ignore_dups

## ファイル名で #, ~, ^ の 3 文字を正規表現として扱う
setopt extended_glob

## TAB で順に補完候補を切り替える
setopt auto_menu

## zsh の開始, 終了時刻をヒストリファイルに書き込む
setopt extended_history

## =command を command のパス名に展開する
setopt equals

## --prefix=/usr などの = 以降も補完
setopt magic_equal_subst

## ヒストリを呼び出してから実行する間に一旦編集
setopt hist_verify

# ファイル名の展開で辞書順ではなく数値的にソート
setopt numeric_glob_sort

## 出力時8ビットを通す
setopt print_eight_bit

## ヒストリを共有
setopt share_history

## 補完候補のカーソル選択を有効に
zstyle ':completion:*:default' menu select=1

## 補完候補の色づけ
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

## カッコの対応などを自動的に補完
setopt auto_param_keys

## ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash

## スペルチェック
#setopt correct

# ディレクトリ移動履歴保存
setopt auto_pushd

# alias
source ~/.aliases

# do brew install rbenv
eval "$(rbenv init -)"

## http://d.hatena.ne.jp/hiboma/20120315/1331821642
## Ctrl + X Crtl + Pでコマンドラインをクリップボードに登録
pbcopy-buffer(){
    print -rn $BUFFER | pbcopy
    zle -M "pbcopy: ${BUFFER}"
}

zle -N pbcopy-buffer
bindkey '^x^p' pbcopy-buffer

# bindkey
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^X^F' forward-word
bindkey '^X^B' backward-word
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward

EDITOR='vim'
REPORTTIME=3

function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

_prompt_executing=""
function __prompt_precmd() {
    local ret="$?"
    if test "$_prompt_executing" != "0"
    then
      _PROMPT_SAVE_PS1="$PS1"
      _PROMPT_SAVE_PS2="$PS2"
      PS1=$'%{\e]133;P;k=i\a%}'$PS1$'%{\e]133;B\a\e]122;> \a%}'
      PS2=$'%{\e]133;P;k=s\a%}'$PS2$'%{\e]133;B\a%}'
    fi
    if test "$_prompt_executing" != ""
    then
       printf "\033]133;D;%s;aid=%s\007" "$ret" "$$"
    fi
    printf "\033]133;A;cl=m;aid=%s\007" "$$"
    _prompt_executing=0
}
function __prompt_preexec() {
    PS1="$_PROMPT_SAVE_PS1"
    PS2="$_PROMPT_SAVE_PS2"
    printf "\033]133;C;\007"
    _prompt_executing=1
}
preexec_functions+=(__prompt_preexec)
precmd_functions+=(__prompt_precmd)
