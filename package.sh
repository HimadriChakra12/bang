# reflactor
bash $HOME/bang/reflactor.sh

# package install section
sudo pacman -S git imlib2 ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts base-devel github-cli lazygit fzf zoxide starship

# self package-section
mkdir $HOME/pkg
cd $HOME/pkg

url="https://github.com/HimadriChakra12"
git clone $url/hsxiv    sxiv
git clone $url/sxat	    sxat
git clone $url/px	    px
git clone $url/fetch	fetch
git clone $url/dtop	    dtop
git clone $url/whot	    whot
git clone $url/determinant	    det

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

cd dtop
sudo make install
cd ..

cd det
sudo make install
cd ..

cd whot
sudo make install
cd ..

git clone https://github.com/resslr/aurc.git
cd aurc
sudo make install
cd ..

