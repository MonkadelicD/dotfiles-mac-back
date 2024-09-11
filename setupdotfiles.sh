#!/bin/zsh
## setupdotfiles.sh
## Automate configuration of dotfiles, ie:
## create .zshrc.d if not present and place zsh customizations
## there. Also add stanza to .zshrc to look in .zshrc.d if not present

## BEGIN VARIABLES

# variable containing line to source customized zsh script
dtfls_rc_add="[ -r ~/.zshrc.sh ] && source ~/.zshrc.sh"

# create variables to hold markers for config blocks managed by this script
dtfls_mng_head="### BEGIN DOTFILES MANAGED BLOCK"
dtfls_mng_tail="### END DOTFILES MANAGED BLOCK"
# What is the path to this script?
script_dir=$(dirname "$0")

# VIM paths
vimIndentLinePath="$HOME"/.vim/pack/vendor/start/indentLine
vimTerraformPath="$HOME"/.vim/pack/plugins/start/vim-terraform
vimCocVimPath="$HOME"/.vim/pack/coc/start/coc.nvim
vimDimColorSchemePath="$HOME"/.vim/pack/plugins/start/vim-dim

## END VARIABLES

## BEGIN FUNCTIONS

# DNF install the package passed as an argument
run_dnf () {
sudo dnf install -y "$1"
}

# APT update package cache and install the package passed as an argument
run_apt () {
sudo apt update && sudo apt install -y "$1"
}

## END FUNCTIONS

## BEGIN PREREQUISITES

# ensure $HOME/bin exists
if [[ ! -d "$HOME"/bin ]]; then
  mkdir -p "$HOME"/bin
fi

## END PREREQUISITES

## START ZSH SETUP

# Change to directory containing dotfiles
if [ "$script_dir" != "$PWD" ]; then
  cd "$script_dir" || { echo "Failed changing directory to $script_dir"; exit 1; }
  script_dir="$PWD"
fi

# Create an array of custom zsh config files
zshrc_configs=("$(ls -1 zshrc.*)")

if [ ! -e "$HOME"/.zshrc ]; then
  touch "$HOME"/.zshrc
fi

if [ "${#zshrc_configs[@]}" -gt 0 ]; then
  # if the following block isn't present insert it
  # this is taken from the default user .zshrc in Fedora 32
  grep -q "$dtfls_mng_head" "$HOME"/.zshrc
  zshrc_already_modified=$?
  if [ "$zshrc_already_modified" -gt 0 ]; then
    echo "$dtfls_mng_head" >> "$HOME"/.zshrc
    echo "$dtfls_rc_add" >> "$HOME"/.zshrc
    echo "$dtfls_mng_tail" >> "$HOME"/.zshrc
  else
    # delete managed block if found
    sed -i '' "/$dtfls_mng_head/,/$dtfls_mng_tail/{/.*/d;}" "$HOME"/.zshrc
    # write the managed block back in with header and footer markers
    echo "$dtfls_mng_head" >> "$HOME"/.zshrc
    echo "# source my custom zsh stuffs" >> "$HOME"/.zshrc
    echo "$dtfls_rc_add" >> "$HOME"/.zshrc
    echo "$dtfls_mng_tail" >> "$HOME"/.zshrc
  fi
fi

# create or replace a softlink to our zshrc.sh script and config file directory
# remove an existing soft link
if [ -h "$HOME"/.zshrc.sh ]; then
  unlink "$HOME"/.zshrc.sh
fi
ln -sf "$script_dir"/zshrc.sh "$HOME"/.zshrc.sh
# remove an existing soft link
if [ -x "$HOME"/.zshrc.d ] && [ ! -h "$HOME"/.zshrc.d ]; then
  cp -f ./zshrc.d/* "$HOME"/.zshrc.d/
else
  unlink "$HOME"/.zshrc.d
  ln -sf "$script_dir"/zshrc.d "$HOME"/.zshrc.d
fi

## END ZSH SETUP

## BEGIN INSTALL UTILITIES

# Ensure git is installed
if [[ ! -x /usr/bin/git ]] && [[ ! -x /opt/homebrew/bin/git ]]; then
  brew install git
fi

# Ensure node is present
if [[ ! $(command -v node) ]]; then
  # if not, verify nvm is present
  if [[ ! $(command -v nvm ) ]]; then
    export NVM_DIR="$HOME/.nvm" && rm -rf "$NVM_DIR" && (
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    git -c advice.detachedHead=false checkout $(git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1))
    ) && \. "$NVM_DIR/nvm.sh"
  fi
  # install latest LTS node
  nvm install --lts
fi

# Ensure vim is installed
if [[ ! -x /usr/bin/vim ]] && [[ ! -x /opt/homebrew/bin/vim ]]; then
  brew install macvim
fi

# Ensure tmux is installed
if [[ ! -x /usr/bin/tmux ]] && [[ ! -x /opt/homebrew/bin/tmux ]]; then
  brew install tmux
fi

# Ensure tree is installed
if [[ ! -x /usr/bin/tree ]] && [[ ! -x /opt/homebrew/bin/tree ]]; then
  brew install tree
fi

# Ensure htop is installed
if [[ ! -x /usr/bin/htop ]] && [[ ! -x /opt/homebrew/bin/htop ]]; then
  brew install htop
fi

## END INSTALL UTILITIES

## START TMUX CUSTOMIZATIONS

# Create an array of tmux config files
tmux_configs=($(ls -1d .tmux*))

# Find all tmux related stuff
if [ "${#tmux_configs[@]}" -gt 0 ]; then
  # loop through each item found
  for tmux_file in "${tmux_configs[@]}"; do
    # if it's a directory copy recursively
    if [ -d "$tmux_file" ]; then
      cp -fr "$tmux_file" "$HOME"/
    # otherwise copy each file
    else
      cp -f "$tmux_file" "$HOME"/
    fi
  done
fi

## END TMUX CUSTOMIZATIONS

## BEGIN VIM CUSTOMIZATIONS

# install vim-dim colorscheme
rm -rf "$vimDimColorSchemePath"
git clone --branch 1.x https://github.com/jeffkreeftmeijer/vim-dim.git "$vimDimColorSchemePath"

# if .vim directory is missing create it and the vendor and plugins directory trees
if [ ! -d "$HOME"/.vim ]; then
  mkdir -p "$HOME"/.vim/pack/{plugins,vendor}/start
fi

# install indentLine vim plugin
rm -rf "$vimIndentLinePath"
git clone https://github.com/Yggdroot/indentLine.git "$vimIndentLinePath"
vim -u NONE -c "helptags  $vimIndentLinePath/doc" -c "q"

# install coc-nvim
rm -rf "$vimCocVimPath"
git clone --branch release https://github.com/neoclide/coc.nvim.git --depth=1 "$vimCocVimPath"
vim -c "helptags $vimCocVimPath/doc/ | q"
# copy coc-settings.json
cp -f .vim/coc-settings.json "$HOME"/.vim/
cp -f .coc.vimrc "$HOME"/
# install coc language servers
vim -c "CocInstall coc-markdownlint coc-tsserver coc-json coc-html coc-css coc-pyright coc-yaml | q"

# copy vimrc file if present
if [ -f .vimrc ]; then
  cp -f .vimrc "$HOME"/
fi

## END VIM CUSTOMIZATIONS
echo "All done!"
echo
echo "To activeate shell customizations run:"
echo "        source ~/.zshrc.sh"
