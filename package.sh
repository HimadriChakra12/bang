# Reflactor
curl -L "https://github.com/HimadriChakra12/SayArcHi/raw/refs/heads/Sayo/package/reflactor.sh" \
    -o "$HOME/reflactor.sh"
bash reflactor.sh

# package install section
sudo pacman -S git nvim imlib2 ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts base-devel github-cli lazygit fzf

# self package-section
mkdir pkg
cd pkg

url="https://github.com/HimadriChakra12"
git clone $url/hsxiv    sxiv
git clone $url/sxat	    sxat
git clone $url/px	    px
git clone $url/fetch	fetch

cd sxiv
bash install.sh
cd ..

cd sxat
bash install.sh
cd ..

cd px
sudo make install
cd ..

cd fetch
sudo make install
cd ..
