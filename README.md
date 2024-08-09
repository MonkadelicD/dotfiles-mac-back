# Basic DOTFILES for zsh

## What's it do?
This repo contains a script to add zsh dotfiles customizations. It contains my preferred settings for VIM, TMUX, and some zsh customizations and aliases. The settings have been tested with macOS 14.6 on a MacBook Pro M3

git, vim, and tmux packages will be installed if not found in /usr/bin/ or /opt/homebrew/bin/.

For zsh, the only file that will be modified is the user's .zshrc file. A line will be added to run .zshrc.sh script which sources the aliases and zsh customizations from .zshrc.d. All files stay in the dotfiles directory and soft links are created for ~/.zshrc.d and ~/.zshrc.sh

After setting up the zsh stuff it moves on to tmux configs. A custom tmux theme (modified from [Ham Vocke's blog](https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/), a couple of custom layouts and some config customizations setup tmux how I like it. There are also some aliases in zshrc.d/zshrc.aliases for launching tmux. The tmux config will install [TPM - Tmux Plugin Manager](https://github.com/tmux-plugins/tpm), [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible), and [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load). These plugins are a good starting point.

Last is custom settings in .vimrc and some plugins.

## Instructions for use
1. Clone this repo to your Mac system
        git clone https://github.com/monkadelicd/dotfiles-mac.git --depth 1
2. cd to dotfiles directory
        cd dotfiles
3. run setupdotfiles.sh
        ./setupdotfiles.sh
4. source the new zshrc stuff
        source ~/.zshrc.sh
