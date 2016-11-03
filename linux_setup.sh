#!/bin/bash

##########################################################
#This script will determine you system
#Install packages based on your package.conf file
#If there is no such file you can create one with follwing format
#
# e.g.
#
# #option config
# SYSTEM_PACKAGE_INSTALL_ALWAYS_YES 0
#
# PACKAGES:
# git
# tmux
# vim
#
##########################################################

#global variables
#config default file name
config_file="package.conf"

#installation command
installation_command=""

#start installation command
declare -i start_install=0

#declare associative array to hold all the config key/value pair
declare -A system_config


function determine_system {
    if [ -f /etc/debian_version ]; then
        echo "This is a Debian based liux"
        installation_command="apt-get install"
    fi
}

function run_generic_command {
    $($@)
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
        exit 100;
    fi
    return $status
}

function run_install_command {
    $($installation_command ${system_config[always_yes]} $1)
    local status=$
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
        exit 100;
    fi
    return $status
}

function print_simple_help {
    echo "No $config_file detected"
    echo "Please create a package.conf in the same directory"
    echo "e.g."
    echo "#option config"
    echo "SYSTEM_PACKAGE_INSTALL_ALWAYS_YES 0"
    echo "PACKAGES:"
    echo "git"
    echo "tmux"
    echo "vim"
    echo -e "\nFor detailed option explanations use -h"
}

function print_detailed_help {
    echo "A file named $config_file should exist in the same dir"
    echo "The file formats are"
    echo -e "\n"
    echo "<OPTION1> <VALUE1>"
    echo "<OPTION2> <VALUE2>"
    echo "<OPTION3> <VALUE3>"
    echo "..."
    echo "PACKAGES: "
    echo "<SOFTWARE PACKAGE NAME1>"
    echo "<SOFTWARE PACKAGE NAME2>"
    echo "<SOFTWARE PACKAGE NAME3>"
    echo "..."
    echo -e "\n"
    echo "Possible OPTIONS are:"
}

function triage_config {
    echo "Read in: $1"
    if [[ $1 == PACKAGE* ]]; then
        echo "Installation package start from here"
        start_install=1
    fi
    return $start_install
}

#################################################

if [ "$BASH_VERSINFO" < 4 ]; then
    echo "require bash version 4+ to work"
    exit 100
fi

while getopts ":hf:" opt; do
    case $opt in
        f)
            config_file="$2"
            echo "this is $config_file"
            ;;
        h)
            print_detailed_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            print_simple_help
            exit 100
            ;;
        :)
            echo "need a valid config file"
    esac
done

if [ ! -f $config_file ]; then
    print_simple_help
    exit 100
fi

determine_system

while IFS='' read -r line || [[ -n "$line" ]]; do
    triage_config $line
done < "$config_file"

#echo "installing some essential tools"
#run_command sudo apt-get install vim git tmux clang clang++ cmake ack-grep 
#
#echo "installing custome scripts"
#run_command cd ~
#run_command echo $PWD
#run_command git clone https://github.com/Werror/neat-vim.git
#run_command echo "source ~/neat-vim/.vimrc" >> .vimrc
#run_command git clone https://github.com/Werror/neat-bash.git
#run_command echo "source ~/neat-bash/.bashrc_USER" >> .bashrc
#run_command git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#run_command sudo apt-get install exuberant-ctags
#run_command sudo apt-get install ack-grep
#run_command sudo apt-get install cmake
#run_command git clone https://github.com/magicmonty/bash-git-prompt.git
#run_command echo "GIT_PROMPT_ONLY_IN_REPO=1" >> .bashrc
#run_command echo "source ~/bash-git-prompt/gitprompt.sh" >> .bashrc
