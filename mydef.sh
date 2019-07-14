sudo apt-get install vim-gtk -y
sudo apt-get install git -y
sudo apt-get install g++ -y
sudo apt-get install clang -y
sudo apt-get install clang-format -y
sudo apt-get install build-essential -y
sudo apt-get install cmake -y

if [[ "$(git remote show origin | head -n 2 | tail -n 1)" == *"https://github.com/secmeant/sets"* ]]; then
	path_prefix="$(git rev-parse --show-toplevel)"
else
  mkdir my_defaults
	git clone https://github.com/secmeant/sets ./my_defaults/sets
	path_prefix="./my_defaults/sets"
fi

echo "path_prefix=$path_prefix"

cp -rf "$path_prefix/gvim" $HOME/.vim
cp $HOME/.vim/vimrc $HOME/.vimrc
mkdir $HOME/.vimtmp

cp -f $path_prefix/linux/.bashrc $HOME/.bashrc
