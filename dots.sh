# dotfiles
declare -A dotfiles=(
    ["$HOME/bang/dots/mimeapps.list"]="$HOME/.config/mimeapps.list"
    ["$HOME/bang/dots/mango"]="$HOME/.config/mango"
    ["$HOME/bang/dots/foot"]="$HOME/.config/foot"
    ["$HOME/bang/dots/waybar"]="$HOME/.config/waybar"
    ["$HOME/bang/dots/.bashrc"]="$HOME/.bashrc"
    ["$HOME/bang/dots/.tmux.conf"]="$HOME/.tmux.conf"
)

for src in "${!dotfiles[@]}"; do
    tgt="${dotfiles[$src]}"
    echo "Linking $src → $tgt"
    rm -rf "$tgt"
    ln -sf "$src" "$tgt"
done
