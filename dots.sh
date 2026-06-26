name="$1"

dotfiles=(
    "$HOME/bang/dots/mimeapps.list:$HOME/.config/mimeapps.list"
    "$HOME/bang/dots/mango:$HOME/.config/mango"
    "$HOME/bang/dots/mpv:$HOME/.config/mpv"
    "$HOME/bang/dots/foot:$HOME/.config/foot"
    "$HOME/bang/dots/waybar:$HOME/.config/waybar"
    "$HOME/bang/dots/pkgit:$HOME/.config/pkgit"
    "$HOME/bang/dots/swayimg:$HOME/.config/swayimg"
    "$HOME/bang/dots/.bashrc:$HOME/.bashrc"
    "$HOME/bang/dots/.tmux.conf:$HOME/.tmux.conf"
)


echo "Linking dotfiles..."
for entry in "${dotfiles[@]}"; do
    src="${entry%%:*}"
    tgt="${entry##*:}"
    base="$(basename "$src")"

    # If a name is provided, skip non-matching entries
    if [[ -n "$name" && "$base" != "$name" ]]; then
        continue
    fi

    echo "Linking $src → $tgt"
    rm -rf "$tgt"
    ln -sf "$src" "$tgt"
done

# xrdb -merge ~/.Xresources
