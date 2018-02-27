apt-get install vim-gtk
apt-get install git
mkdir my_defaults
git clone https://github.com/secmeant/sets ./my_defaults/sets
apt-get install g++
cp -rf gvim $HOME/.vim
cp $HOME/.vim/vimrc $HOME/.vimrc
mkdir $HOME/vimtmp
