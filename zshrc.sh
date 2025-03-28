# Note: there is no shebang in this script. This script sets my preferred shell
# configuration and should be able to be sourced from any Bash-like shell or
# from Z shell.
# If we are not running interactively do not continue loading this file.
case $- in
    *i*) ;;
      *) return;;
esac

# source any files in our ~/dotfiles/zshrc.d directory
if [ -x ~/.zshrc.d ]; then
  for zshrc_file in ~/.zshrc.d/*; do
    [ -r "$zshrc_file" ] && source "$zshrc_file"
  done
  unset zshrc_file
fi
