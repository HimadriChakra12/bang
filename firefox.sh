mkdir -p $HOME/pkg
cd $HOME/pkg

url="https://github.com/HimadriChakra12"
git clone $url/userChrome   userChrome

cd userChrome
for branch in $(git branch -r | grep -v HEAD | grep -v master | grep -v main | sed 's/origin\///'); do git checkout -b $branch origin/$branch; done
bash firefox.sh
