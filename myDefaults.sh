apt-get install vim-gtk
apt-get install git
apt-get install g++
mkdir my_defaults
git clone https://github.com/secmeant/sets ./my_defaults/sets
cp -rf my_defaults/sets/gvim $HOME/.vim
cp $HOME/.vim/vimrc $HOME/.vimrc
mkdir $HOME/vimtmp
