# dotfiles
declare -A dotfiles=(
    ["$HOME/bang/mimeapps.list"]="$HOME/.config/mimeapps.list"
    ["$HOME/bang/mango"]="$HOME/.config/mango"
    ["$HOME/bang/foot"]="$HOME/.config/foot"
    ["$HOME/bang/waybar"]="$HOME/.config/waybar"
)

for src in "${!dotfiles[@]}"; do
    tgt="${dotfiles[$src]}"
    echo "Linking $src → $tgt"
    rm -rf "$tgt"
    ln -sf "$src" "$tgt"
done
