# firefox section
curl "https://raw.githubusercontent.com/HimadriChakra12/.dotfiles/refs/heads/master/firefox/policies.json" -o "$HOME/Downloads/policies.json"
if [ ! -f /usr/lib/firefox/distribution/policies.json ]; then
    sudo cp $HOME/Downloads/policies.json /usr/lib/firefox/distribution/policies.json
fi
FIREFOX_DIR="$HOME/.config/mozilla/firefox"

mkdir -p "$FIREFOX_DIR"

echo "Select Firefox profile:"
profile=$(
    find "$FIREFOX_DIR" -maxdepth 1 -type d -printf '%f\n' |
    grep -E '\.default$|\.default-release$' |
    fzf --prompt="Firefox Profile > "
)
[[ -z "$profile" ]] && {
    echo "No profile selected"
    exit 1
}
path="$FIREFOX_DIR/$profile"
echo "Using profile: $path"
rm -rf "$path/chrome"
mkdir -p "$path/chrome"

declare -A dotfiles=(
    ["$HOME/bang/dots/firefox/userChrome.css"]="$path/chrome/userChrome.css"
    ["$HOME/bang/dots/firefox/user.js"]="$path/user.js"
)

for src in "${!dotfiles[@]}"; do
    tgt="${dotfiles[$src]}"
    echo "Linking $src → $tgt"
    rm -rf "$tgt"
    ln -sf "$src" "$tgt"
done
