# setup_script


## Prerequisite
This scripts depends on Bash version 4+, especially `declare -A` the associative container. The latest linux distro should have updated, however if you are on Mac try [this](http://clubmate.fi/upgrade-to-bash-4-in-mac-os-x/).

## Usage:
1. Edit package.conf to add app the package you will need
2. execute 
`bash -c './devenv_setup.sh'`
This is to avoid any hard coded `#!` string at first line of the .sh file the default bash location differs depends on the system

## Essential package
* git
* vim
* tmux

## usuful git repo
 - https://github.com/magicmonty/bash-git-prompt
 - https://github.com/so-fancy/diff-so-fancy
    - git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    - brew install diff-so-fancy
