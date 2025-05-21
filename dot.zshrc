# ~/.zshrc
# ==============================================================================
# Main configuration file for Zsh.
# ==============================================================================

# --- Environment Variables ---
export PATH="$HOME/.rbenv/bin:$PATH" # Add rbenv to PATH for Ruby version management
export LANG=ja_JP.UTF-8             # Set locale to Japanese UTF-8
export EDITOR=emacs                 # Set default editor to Emacs (CLI)
export REPORTTIME=3                 # Report commands taking longer than 3 seconds

# --- History ---
HISTFILE=$HOME/.zsh-history         # Path to the history file
HISTSIZE=100000                     # Number of lines of history to keep in memory
SAVEHIST=100000                     # Number of lines of history to save to HISTFILE

# --- Zsh Options (setopt / unsetopt) ---
# Behavior
unsetopt promptcr                   # Do not add a carriage return after printing the prompt (allows RPROMPT on same line)
setopt auto_cd                      # If a command is a directory, cd to it automatically
setopt auto_pushd                   # Automatically pushd on cd
setopt pushd_ignore_dups            # Don't push multiple copies of the same directory onto the stack
setopt auto_resume                  # If a suspended process's command is run again, resume it
setopt long_list_jobs               # Display PID when listing jobs (jobs -l by default)
setopt nobeep                       # Disable audible beep on errors
setopt print_eight_bit              # Pass 8-bit characters through (important for UTF-8)
limit coredumpsize 102400           # Limit core dump size to 100MB

# Globbing (filename generation)
setopt extended_glob                # Treat #, ~, and ^ as special globbing characters
setopt numeric_glob_sort            # Sort filenames numerically when globbing, if applicable

# History
setopt extended_history             # Write beginning/ending timestamps to history file
setopt hist_ignore_dups             # Don't save duplicate consecutive commands in history
setopt hist_verify                  # Show command from history and allow editing before execution
setopt share_history                # Share history between all active Zsh sessions

# Input/Output & Completions
setopt auto_list                    # Automatically list choices on ambiguous completion
setopt auto_menu                    # Automatically use menu completion after a TAB press
setopt auto_param_keys              # Automatically complete parameters like parentheses, quotes, etc.
setopt auto_param_slash             # Automatically add a trailing slash to completed directory names
setopt equals                       # Perform =command expansion (e.g., =git becomes /usr/bin/git)
setopt magic_equal_subst            # Perform filename expansion after = in command position
setopt list_types                   # Show file types in completion lists (e.g., / for directory, * for executable)
setopt prompt_subst                 # Allow parameter expansion, command substitution, and arithmetic expansion in prompts

# --- Completions ---
autoload -U compinit  # Autoload compinit function for completion system
compinit              # Initialize the completion system

# Style for completion selection menu
zstyle ':completion:*:default' menu select=1
# Use LS_COLORS for coloring completion suggestions
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# --- Keybindings ---
bindkey '^P' history-beginning-search-backward   # Search history backward starting with current input (Ctrl+P)
bindkey '^N' history-beginning-search-forward    # Search history forward starting with current input (Ctrl+N)
bindkey '^X^F' forward-word                       # Move forward one word (Ctrl+X Ctrl+F)
bindkey '^X^B' backward-word                      # Move backward one word (Ctrl+X Ctrl+B)
bindkey '^R' history-incremental-pattern-search-backward # Incremental search backward (Ctrl+R)
bindkey '^S' history-incremental-pattern-search-forward # Incremental search forward (Ctrl+S)

# Custom keybinding for copying current command line to clipboard (macOS pbcopy)
# Usage: Ctrl+X Ctrl+P
pbcopy-buffer() {
    print -rn -- "$BUFFER" | pbcopy # Use -- to handle commands starting with -
    zle -M "pbcopy: ${BUFFER}"     # Display message in Zsh line editor
}
zle -N pbcopy-buffer # Register the widget
bindkey '^x^p' pbcopy-buffer

# --- Functions ---

# Get current Git branch name
# Used in prompt if needed, or directly.
function current_branch() {
  local ref
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

# Get current rbenv Ruby version for prompt
# Example output: [2.7.0]
function ruby_prompt_info() {
    local result
    if command -v rbenv >/dev/null; then # Check if rbenv command exists
        result=$(rbenv version-name 2>/dev/null) # Use version-name for simpler output
        if [ -n "$result" ] && [ "$result" != "system" ]; then # Only show if a version is set and it's not system
            echo "[$result]"
        fi
    fi
}

# --- Prompt Customization ---
# Load colors and vcs_info (Version Control System information)
autoload -U colors; colors # Enable named colors
autoload -Uz vcs_info     # Load VCS information framework

# Prompt Color Variables
local COLOR_USER_PROMPT=$'%{\e[38;5;199m%}'  # Color for username
local COLOR_HOST_PROMPT=$'%{\e[38;5;190m%}'  # Color for hostname
local COLOR_PATH_PROMPT=$'%{\e[38;5;61m%}'   # Color for current path
local COLOR_RUBY_PROMPT=$'%{\e[38;5;31m%}'   # Color for Ruby version info
local COLOR_VCS_PROMPT=$'%{\e[38;5;248m%}'    # Color for VCS information
local COLOR_YELLOW_PROMPT=$'%{$fg[yellow]%}'
local COLOR_GREEN_PROMPT=$'%{$fg[green]%}'
local COLOR_CYAN_PROMPT=$'%{$fg[cyan]%}'
local COLOR_RESET=$'%{$reset_color%}'       # Reset to default terminal color

# VCS (Version Control System) Information Styling
# For a list of available %-escapes, see: zsh.sourceforge.net/Doc/Release/User-Contributions.html#Version-Control-Information
zstyle ':vcs_info:*' enable git # Enable only for git, can add hg, svn, etc.
zstyle ':vcs_info:*' formats "${COLOR_VCS_PROMPT}[%b]${COLOR_RESET}"                 # Default format: [branch_name]
zstyle ':vcs_info:*' actionformats "${COLOR_VCS_PROMPT}[%b (%a)]${COLOR_RESET}"      # Format during action (e.g. rebase): [branch_name (action)]

# Git specific VCS styling
zstyle ':vcs_info:git:*' check-for-changes true    # Check for unstaged/staged changes
zstyle ':vcs_info:git:*' unstagedstr '!'           # Character for unstaged changes (was ¹)
zstyle ':vcs_info:git:*' stagedstr '+'             # Character for staged changes (was ²)
# Format for git: [branch_name] <staged_char> <unstaged_char>
zstyle ':vcs_info:git:*' formats "${COLOR_VCS_PROMPT}[%b]%c%u${COLOR_RESET}"
# Action format for git: [branch_name|action_name] <staged_char> <unstaged_char>
zstyle ':vcs_info:git:*' actionformats "${COLOR_VCS_PROMPT}[%b|%a]%c%u${COLOR_RESET}"

# precmd hook: Function executed just before each prompt is displayed
precmd() {
    # Prepare an array `psvar` for prompt variables. vcs_info populates this.
    # psvar[1] is typically used for VCS info.
    psvar=()
    vcs_info # Gather VCS information. Stores result in $vcs_info_msg_0_ (and others if defined)
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="${vcs_info_msg_0_}"
}

# Prompt components
local PROMPT_USER="${COLOR_USER_PROMPT}%n${COLOR_RESET}" # Username
local PROMPT_HOST="${COLOR_GREEN_PROMPT}%m${COLOR_RESET}" # Hostname (short)
local PROMPT_PATH="${COLOR_CYAN_PROMPT}%~${COLOR_RESET}"  # Current directory (~)
local PROMPT_RUBY_VERSION="${COLOR_RUBY_PROMPT}$(ruby_prompt_info)${COLOR_RESET}" # Ruby version
local PROMPT_VCS_INFO='%1(v|%F{green}%1v%f|)' # VCS info from psvar[1] (green if present)

# Random Pictogram and Face Characters for Fun
# These arrays store characters that will be randomly selected for the prompt.
local PICTO_CHARS=('😮' '😯' '😦' '😧' '😲' '🫠' '😵‍💫' '💫' '✨' '🔥' '💯' '🎉' '🍀' '🍄' '💎' '🍕' '🚀' '🤖' '👾' '🤡')
local FACE_CHARS=("(='.'=)" "(^o^)" "(>_<)" "(*_*)" "(^_^;)" "(T_T)" "orz" "m(_ _)m") # Added some common kaomoji

local PROMPT_PICTO="${PICTO_CHARS[$((RANDOM % ${#PICTO_CHARS[@]} + 1))]}"
local PROMPT_FACE="${FACE_CHARS[$((RANDOM % ${#FACE_CHARS[@]} + 1))]}"
# Dynamic color for the face, cycles through some ANSI colors
local PROMPT_FACE_COLORED='%{\e[$[32+$RANDOM % 6]m%}' # Selects a color from 32 (green) to 37 (white)

# Assembling the Prompt (PROMPT and RPROMPT)
# RPROMPT: Right-side prompt
RPROMPT="${PROMPT_RUBY_VERSION} ${PROMPT_VCS_INFO}"

# PROMPT: Main left-side prompt
# Line 1: Username Pictogram Hostname Path VCS_Info (from RPROMPT, but shown if RPROMPT too long or for clarity)
# Line 2: Random_Face_Character #
PROMPT="${PROMPT_USER}${PROMPT_PICTO} ${PROMPT_HOST} ${PROMPT_PATH} "
PROMPT+="\n${PROMPT_FACE_COLORED}${PROMPT_FACE}${COLOR_RESET} %# " # %# is '#' for root, '%' for normal user

# --- Shell Integration (iTerm2 specific, and similar terminals) ---
# These functions use special escape codes to inform the terminal about commands being executed.
# This enables features like command status, current directory reporting, and more.
# See: https://iterm2.com/documentation-shell-integration.html

_PROMPT_SAVE_PS1="" # To save original PS1
_PROMPT_SAVE_PS2="" # To save original PS2
_prompt_executing="" # Flag to track command execution state

# __prompt_precmd: Executed before the prompt is displayed (after a command finishes)
function __prompt_precmd() {
    local ret="$?" # Save the exit status of the last command

    # If not already in "executing" state (i.e., after a command has run)
    # Wrap PS1 and PS2 with iTerm2 prompt marks if they haven't been saved yet.
    # This is a bit of a guard, original PS1/PS2 are saved in __prompt_preexec.
    if test "$_prompt_executing" != "0"; then
      _PROMPT_SAVE_PS1="$PROMPT" # Using PROMPT here, as PS1 might be dynamically built
      _PROMPT_SAVE_PS2="$PS2"    # Standard PS2
      # P;k=i: Mark for prompt input start (k=i seems to be 'input')
      # B: Mark for end of prompt
      # 122;>: Custom mark, purpose might be specific to user's setup or another terminal feature
      PS1=$'%{\e]133;P;k=i\a%}'$PROMPT$'%{\e]133;B\a\e]122;> \a%}'
      # P;k=s: Mark for prompt secondary prompt (PS2) start (k=s seems to be 'secondary')
      PS2=$'%{\e]133;P;k=s\a%}'$PS2$'%{\e]133;B\a%}'
    fi

    # If a command was executed (_prompt_executing is set)
    if test "$_prompt_executing" != ""; then
       # D;<ret>;aid=<pid>: Mark for command finished with exit status <ret>
       # aid seems to be Application ID (current process ID)
       printf "\033]133;D;%s;aid=%s\007" "$ret" "$$"
    fi

    # A;cl=m;aid=<pid>: Mark for prompt start (A)
    # cl=m might mean "clear mark" or "command line mode"
    printf "\033]133;A;cl=m;aid=%s\007" "$$"
    _prompt_executing=0 # Reset flag, ready for next command
}

# __prompt_preexec: Executed just before a command is executed
function __prompt_preexec() {
    # Save the current PROMPT/PS2 if they haven't been saved or if they were the dynamic iTerm ones
    # This ensures we restore the *user-defined* prompt, not the iTerm2-wrapped one.
    if [ -z "$_PROMPT_SAVE_PS1" ] || [[ "$PROMPT" == *'\e]133;P;k=i\a'* ]]; then
        _PROMPT_SAVE_PS1="$PROMPT" # This should ideally capture the user-defined PROMPT
    fi
    if [ -z "$_PROMPT_SAVE_PS2" ] || [[ "$PS2" == *'\e]133;P;k=s\a'* ]]; then
        _PROMPT_SAVE_PS2="$PS2"
    fi

    # Restore the original prompt strings before command execution, removing iTerm2 marks.
    # This is important so the command output doesn't get messed up by prompt escape codes.
    PS1="$_PROMPT_SAVE_PS1"
    PS2="$_PROMPT_SAVE_PS2"

    # C;: Mark for command execution start (C)
    printf "\033]133;C;\007"
    _prompt_executing=1 # Set flag indicating a command is about to execute
}

# Add these functions to Zsh's precmd and preexec hooks
precmd_functions+=(__prompt_precmd)
preexec_functions+=(__prompt_preexec)

# --- Initializers ---
# Source aliases from ~/.aliases file
if [ -f ~/.aliases ]; then
  source ~/.aliases
fi

# Initialize rbenv (Ruby version manager)
# This command sets up rbenv shims and autocompletion.
if command -v rbenv >/dev/null; then # Check if rbenv command exists
  eval "$(rbenv init - zsh)" # Use 'zsh' for zsh specific init
fi

# (Optional) If you use nvm (Node Version Manager)
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
