# reflactor
bash $HOME/bang/reflactor.sh

# package install section
sudo pacman -S git imlib2 ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts base-devel github-cli lazygit fzf zoxide starship swayimg gitu
sudo pacman -R ex-vi-compat vim

# self package-section
mkdir -p $HOME/pkg
cd $HOME/pkg

url="https://github.com/HimadriChakra12"
git clone $url/swat	    swat
git clone $url/fetch	fetch
git clone $url/dtop	    dtop
git clone $url/whot	    whot
git clone $url/determinant	    det

cd swat
bash install.sh
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

