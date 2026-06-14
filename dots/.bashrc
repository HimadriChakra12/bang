fetch
# ~/.bashrc
if [[ -f $HOME/wprfrc ]]; then
    source $HOME/wprfrc
fi

APP=$HOME/.local/share/applications

export PATH="$HOME/sayarchi/scripts:$PATH"
export PATH="$HOME/sayarchi/bin:$PATH"
export PATH="$HOME/.dotfiles:$PATH"
export PATH="$HOME/Music:$PATH"

source $HOME/bang/bashcomp.sh
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

eval "$(zoxide init bash)"
eval "$(starship init bash)"
eval "$(fzf --bash)"

pb(){
    cd "$HOME/penboot"
    vim $(fzf)
}

dk() {
    docker ps
    read -p "Kill: " h
    docker stop $h
    docker kill $h
}

replace-word() {
  find . -type d -name .git -prune -o -type f -exec sed -i "s/$1/$2/g" {} +
}

# File system
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
  alias l='lt -lh -T -L 2'
fi

if command -v noice &> /dev/null; then
    alias n="noice"
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

if command -v zoxide &> /dev/null; then
    alias cd="zd"
zo(){
    local items
    items=("..")
    while IFS= read -r line; do
        items+=("$line")
    done < <(ls -1)
    local selected_item
    selected_item=$(printf '%s\n' "${items[@]}" | fzf --layout=reverse --header "$(pwd)" --height 90% --preview "eza --color=always {} -T")
    if [[ -n "$selected_item" ]]; then
        if [[ -d "$selected_item" ]]; then
            cd "$selected_item" || return
            zo  # recursively call zo
        else
            xdg-open "$selected_item" &>/dev/null &
        fi
    fi
}
zd() {
    if [ $# -eq 0 ]; then
        builtin cd ~ && return
    elif [ -d "$1" ]; then
        builtin cd "$1"
    else
        z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
}
fi
clean_packages(){
    read -p "Wanna Clean Packages With config? [y/n]" $opt
    if [[ $opt == y || $opt = yes ]]; then
        sudo pacman -Rns $(pacman -Qdtq)
    else
        sudo pacman -Rs $(pacman -Qdtq)
    fi
    echo "Wanna Clean Caches?"
    read -r
    sudo pacman -Scc
}
open() {
    xdg-open "$@" >/dev/null 2>&1 &
}
alias cmus='cmus-init'

fs() {
    ls | grep "$@"
}

update() {
    notify-send "System Update!" "Started system Update"
    sudo pacman -Syyu
    notify-send "System Update!" "System Update Completed"
}

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias grep='grep --color=auto'
alias paci="sudo pacman -S"
alias pacs="sudo pacman -q"
alias yi="yay -S"
alias pi="pikaur -S"
alias ys="yay -q"
alias pks="pikaur -q"
alias sx="sxiv"

PWD=$(pwd)
alias exp="nvim $PWD"
alias Exp="pcmanfm $PWD & disown"

alias ep="$EDITOR ~/.bashrc"
alias so="source $HOME/.bashrc"
alias cd="z"

alias i="sudo pacman -S"

alias v="nvim"
alias nano="nvim"
alias q="exit"
alias c="clear"
#alias gg="nvim -c Git"
alias gg="lazygit"

alias fst="fastfetch"
alias reset="rm ~/.cache/app_launcher_cache"
alias czf="fzf --layout=reverse --header "selector" --height 50%"

cx(){
    chmod +x $(fzf)
}

gitcl(){
    repo="$1"
    path="$2"
    if [[ $1 ]]; then
        if [[ $2 ]]; then
            git clone https://github.com/$repo $2
            cd $2
        else
            git clone https://github.com/$repo
        fi
    else
        repos=$(gh repo list --limit 100 --json name --jq '.[].name' | fzf)
        git clone https://github.com/HimadriChakra12/$repos
        cd $repo
    fi
}
gogit(){
    dir=$(ls ~/.git| fzf)
    cd ~/.git/$dir
    file=$(fzf)
    nvim $file
}
flac(){
    read -p "Name of the song: " filename
    read -p "Enter the URL: " url
    yt-dlp -f bestaudio --extract-audio --audio-format flac --audio-quality 0 -o "~/Music/${filename}.flac" "$url"
}

#git aliases
alias gs="git status --short"
#!/bin/bash


# Optionally, you can run it directly by calling:
# zo
# Add this to ~/.bashrc
reg(){
    url="$1"
    if [ -z "$url" ]; then
        echo "Usage: $0 <url>"
        exit 1
    fi

    # Escape regex special characters
    escaped=$(printf '%s' "$url" | sed -e 's/[.[\*^$()+?{|]/\\&/g' -e 's/\\/\\\\/g')

    # Output anchored regex
    echo "^${escaped}\$"
}
ez() {
    # Find common archive formats and list them in fzf
    archive=$(find . -maxdepth 1 -type f \
        \( -iname "*.zip" -o -iname "*.7z" -o -iname "*.rar" -o -iname "*.tar" -o -iname "*.tar.gz" -o -iname "*.tgz" \) \
        | fzf)

        # Exit if no file selected
        [ -z "$archive" ] && return

        # Make output directory named after archive (without extension)
        dir="${archive%.*}"
        mkdir -p "$dir"

        # Extract using 7z
        7z x "$archive" -o"$dir"
    }

mkcd(){
    location="$1"
    if [ -z "$location" ]; then
        echo "Usage: $0 <url>"
        exit 1
    fi
    mkdir $location && cd $location
    # Output anchored regex
    pwd
}

gcn() {
    name="$1"
    email="$2"
    git config --global user.name "$1"
    git config --global user.email "$2"
}
export PATH="$HOME/.local/bin:$PATH"

mountit() {
    if [ -z "$1" ]; then
        echo "Usage: mountit <iso-file> [mount-name]"
        return 1
    fi

    iso="$1"
    name="${2:-$(basename "$iso" .iso)}"
    dir="/mnt/$name"

    sudo mkdir -p "$dir" || return 1

    sudo mount -o loop,ro "$iso" "$dir" && \
    echo "Mounted $iso at $dir"
}
compress(){
    echo "compress [folder] [archive]"
    folder="$1"
    archive="$2"
    7z a $archive $folder -t7z -mx=9 -m0=lzma2 -md=1024m -mfb=273 -ms=on
}

# pkgback - Automatic package tracking
if [[ -f "$HOME/.local/bin/pkgback" ]]; then
    source "$HOME/.local/bin/pkgback"
fi

mp42mp3() {
    ffmpeg -i "$1" -vn -acodec libmp3lame -ab 192k "$2"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
