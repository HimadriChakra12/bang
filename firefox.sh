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
curl -L "https://github.com/HimadriChakra12/penboot/raw/refs/heads/main/livefiles/firefox/userChrome.css" \
    -o "$path/chrome/userChrome.css"
curl -L "https://github.com/HimadriChakra12/penboot/raw/refs/heads/main/livefiles/firefox/user.js" \
    -o "$path/user.js"
