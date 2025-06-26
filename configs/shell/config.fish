# Fish Shell Configuration
# ~/.config/fish/config.fish

# Disable greeting
set -g fish_greeting

# Colors
set -g fish_color_normal normal
set -g fish_color_command green
set -g fish_color_quote yellow
set -g fish_color_redirection cyan
set -g fish_color_end magenta
set -g fish_color_error red
set -g fish_color_param blue
set -g fish_color_comment brblack
set -g fish_color_match --background=brblue
set -g fish_color_selection white --bold --background=brblack
set -g fish_color_search_match bryellow --background=brblack
set -g fish_color_history_current --bold
set -g fish_color_operator cyan
set -g fish_color_escape cyan
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_valid_path --underline
set -g fish_color_autosuggestion brblack
set -g fish_color_user brgreen
set -g fish_color_host normal
set -g fish_color_cancel -r
set -g fish_pager_color_completion normal
set -g fish_pager_color_description yellow
set -g fish_pager_color_prefix white --bold --underline
set -g fish_pager_color_progress brwhite --background=cyan

# Environment Variables
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER open
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# PATH modifications
fish_add_path ~/.local/bin
fish_add_path ~/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.poetry/bin
fish_add_path ~/.pyenv/bin
fish_add_path ~/.rbenv/bin
fish_add_path ~/.bun/bin

# Aliases
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ~ 'cd ~'

# List directory contents
alias ls 'ls --color=auto'
alias ll 'ls -alF'
alias la 'ls -A'
alias l 'ls -CF'
alias lt 'ls -ltr'
alias lh 'ls -lh'
alias ld 'ls -ld */'

# Safety aliases
alias rm 'rm -iv'
alias cp 'cp -iv'
alias mv 'mv -iv'
alias mkdir 'mkdir -pv'

# Git aliases
alias g git
alias gs 'git status'
alias ga 'git add'
alias gc 'git commit'
alias gco 'git checkout'
alias gb 'git branch'
alias gl 'git log --oneline --graph --decorate'
alias gp 'git push'
alias gpl 'git pull'
alias gd 'git diff'
alias gdc 'git diff --cached'
alias gst 'git stash'
alias gsp 'git stash pop'

# Docker aliases
alias d docker
alias dc docker-compose
alias dps 'docker ps'
alias dpsa 'docker ps -a'
alias dimg 'docker images'
alias dexec 'docker exec -it'
alias dlogs 'docker logs -f'
alias dprune 'docker system prune -a'

# Kubernetes aliases
alias k kubectl
alias kgp 'kubectl get pods'
alias kgs 'kubectl get services'
alias kgd 'kubectl get deployments'
alias kaf 'kubectl apply -f'
alias kdel 'kubectl delete'
alias klog 'kubectl logs -f'
alias kexec 'kubectl exec -it'

# Python aliases
alias py python3
alias pip pip3
alias venv 'python3 -m venv'
alias activate 'source venv/bin/activate.fish'

# System aliases
alias ports 'lsof -i -P -n | grep LISTEN'
alias myip 'curl -s https://api.ipify.org && echo'
alias localip 'ipconfig getifaddr en0'
alias flushDNS 'sudo dscacheutil -flushcache'
alias update 'brew update && brew upgrade && brew cleanup'
alias cleanup 'brew cleanup && brew doctor'

# Editor aliases
alias vi nvim
alias vim nvim
alias edit nvim
alias code cursor

# Misc aliases
alias h history
alias j 'jobs -l'
alias now 'date +"%T"'
alias nowdate 'date +"%Y-%m-%d"'
alias week 'date +%V'
alias path 'echo $PATH | tr " " "\n"'
alias reload 'source ~/.config/fish/config.fish'
alias fishconfig 'nvim ~/.config/fish/config.fish'

# Functions
# ---------

# Create directory and cd into it
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

# Extract archives
function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Find file by name
function ff
    find . -type f -iname "*$argv*"
end

# Find directory by name
function fd
    find . -type d -iname "*$argv*"
end

# Quick backup
function backup
    cp $argv[1] $argv[1].bak-(date +%Y%m%d-%H%M%S)
end

# Calculator
function calc
    echo "$argv" | bc -l
end

# Weather
function weather
    if test (count $argv) -eq 0
        set city (curl -s ipinfo.io/city)
    else
        set city $argv[1]
    end
    curl -s "wttr.in/$city" | head -7
end

# Git branch for prompt
function fish_git_prompt
    set -l branch (git branch 2>/dev/null | grep '^*' | sed 's/* //')
    if test -n "$branch"
        echo " ($branch)"
    end
end

# Custom prompt
function fish_prompt
    set -l last_status $status
    set -l cyan (set_color -o cyan)
    set -l yellow (set_color -o yellow)
    set -l green (set_color -o green)
    set -l red (set_color -o red)
    set -l blue (set_color -o blue)
    set -l normal (set_color normal)

    set -l cwd $cyan(basename (prompt_pwd))
    
    if test $last_status -eq 0
        set prompt_symbol "$green➜"
    else
        set prompt_symbol "$red➜"
    end

    echo -n -s $green(whoami) $normal @ $blue(hostname -s) $normal : $cwd $yellow(fish_git_prompt) $normal ' ' $prompt_symbol ' '
end

# Right prompt with command duration
function fish_right_prompt
    set -l yellow (set_color yellow)
    set -l normal (set_color normal)
    
    if test $CMD_DURATION
        set duration (echo "$CMD_DURATION 1000" | awk '{printf "%.3fs", $1 / $2}')
        echo -n -s $yellow "[$duration]" $normal
    end
end

# Abbreviations (like aliases but expand inline)
abbr -a gaa 'git add --all'
abbr -a gcm 'git commit -m'
abbr -a gcam 'git commit -am'
abbr -a gss 'git status -s'
abbr -a gll 'git log --oneline'
abbr -a ggpush 'git push origin (git branch --show-current)'
abbr -a ggpull 'git pull origin (git branch --show-current)'
abbr -a gco- 'git checkout -'
abbr -a gcb 'git checkout -b'
abbr -a grhh 'git reset --hard HEAD'
abbr -a grbi 'git rebase -i'
abbr -a gclean 'git clean -fd'

# FZF configuration
if type -q fzf
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --inline-info'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
end

# Starship prompt (if installed)
if type -q starship
    starship init fish | source
end

# Homebrew setup
if test -e /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -e /usr/local/bin/brew
    eval (/usr/local/bin/brew shellenv)
end

# asdf version manager
if test -e ~/.asdf/asdf.fish
    source ~/.asdf/asdf.fish
end

# direnv hook
if type -q direnv
    direnv hook fish | source
end

# Load local fish config if exists
if test -e ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
