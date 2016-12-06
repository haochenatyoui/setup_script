#!/bin/bash

##########################################################
#This script will determine you system
#Install packages based on your package.conf file
#If there is no such file you can create one with follwing format
#
# e.g.
#
# #option config
# INSTALL_ALWAYS_YES 0
#
# PACKAGES:
# git
# tmux
# vim
#
##########################################################

#global variables
##########################################################
#config default file name
config_file="package.conf"

#installation command
installation_command=""

#keep track # of installation command
declare -i num_install=0

#number of installation failed
declare -i num_failed=0

#declare associative array to hold all the config key/value pair
declare -A system_config
system_config[INSTALL_ALWAYS_YES]="0"
system_config[TERMINATE_ON_ERROR]="0"

#functions
##########################################################
function determine_system {
    local os_type=`uname`
    if [[ "$os_type" == "Linux" ]]; then
        echo "This is a Linux based system"
        if [ -f /etc/debian_version ]; then
            echo "This is a Debian based system"
            installation_command="apt-get install"
        else
            echo "[$os_type]:[rpm?pacman] NOT SUPPORTED YET"
        fi
    elif [[ "$os_type" == "Darwin" ]]; then
        echo "This is a MacOS based system"
        installation_command="brew install"
    fi
}

function handle_command_error {
    if [ $1 -ne 0 ]; then
        echo "error with [${@:2}]" >&2
        if [ ${system_config[TERMINATE_ON_ERROR]} -eq "1" ]; then
            echo "INSTALLATION TERMINATED"
            ((num_failed++))
            exit 100;
        fi
    fi
}

function run_generic_command {
    local expanded_command="$@"
    echo "Executing generic command"
    echo "[$expanded_command]"
    eval "$expanded_command"
    local status=$?
    handle_command_error $status $expanded_command
    return $status
}

function run_install_command {
    sleep 3
    local always_yes=$([ "${system_config[INSTALL_ALWAYS_YES]}" = "1" ] && echo "-y" || echo "")
    local expanded_command="$installation_command $always_yes $1"
    echo "Executing installation command"
    echo "[$expanded_command]"
    eval "$expanded_command"
    local status=$?
    handle_command_error $status $expanded_command
    return $status
}

function print_config_file_hint {
    echo "No $config_file detected"
    echo "Please create a package.conf in the same directory"
    echo "e.g."
    echo "#option config"
    echo "INSTALL_ALWAYS_YES 0"
    echo "PACKAGES:"
    echo "git"
    echo "tmux"
    echo "vim"
}

function print_simple_help {
    echo -e "use -h to seek help"
}

function print_detailed_help {
    echo "A file named $config_file should exist in the same dir"
    echo "The file formats are"
    echo
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
    echo "-f    to specify config_file"
    echo "-h    this help page"
}

function check_bash_version {
    if [ "$BASH_VERSINFO" -lt 4 ]; then
        echo "require bash version 4+ to work"
        exit 100
    else
        echo "You are using bash version $BASH_VERSINFO"
    fi
}

function set_config {
    local key=$1
    local value=$2
    if [[ $key == INSTALL_ALWAYS_YES* ]]; then
        echo -n "INSTALL_ALWAYS_YES -> "
        system_config[INSTALL_ALWAYS_YES]=$value
        echo "${system_config[INSTALL_ALWAYS_YES]}"
    elif [[ $key == TERMINATE_ON_ERROR* ]]; then
        echo -n "TERMINATE_ON_ERROR -> "
        system_config[TERMINATE_ON_ERROR]=$value
        echo "${system_config[TERMINATE_ON_ERROR]}"
    fi
}

function installation_summary {
    ((num_install--))
    echo "---- Installation finished ----"
    echo "Installation attempts: $num_install"
    echo "Installation failed: $num_failed"
}

#start of the script
#################################################

check_bash_version

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
    print_config_file_hint
    print_simple_help
    exit 100
fi

determine_system

while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ $line == PACKAGE* ]]; then
        echo "Installation package start from here"
        ((num_install++))
        continue # Skip this line
    fi
    if [ $num_install -gt 0 ]; then
        if [[ ${line:0:1} == "#" ]]; then
            echo "Skipping $line"
        else
            run_install_command $line
            ((num_install++))
        fi
    else
        set_config $line
    fi
done < "$config_file"

installation_summary

#echo "installing custom components from github"
#run_command cd ~
#run_command echo $PWD
#run_command git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#run_command git clone https://github.com/magicmonty/bash-git-prompt.git
#run_command echo "GIT_PROMPT_ONLY_IN_REPO=1" >> .bashrc
#run_command echo "source ~/bash-git-prompt/gitprompt.sh" >> .bashrc
