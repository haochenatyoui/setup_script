#!/bin/bash

function run_command {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
        exit 100;
    fi
    return $status
}

run_command cd ~
run_command echo $PWD
run_command git clone https://github.com/Werror/neat-vim.git
run_command echo "source ~/neat-vim/.vimrc" >> .vimrc
run_command git clone https://github.com/Werror/neat-bash.git
run_command echo "source ~/neat-bash/.bashrc_USER" >> .bashrc
run_command git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
run_command sudo apt-get install exuberant-ctags
run_command sudo apt-get install ack-grep
run_command sudo apt-get install cmake
run_command git clone https://github.com/magicmonty/bash-git-prompt.git
run_command echo "GIT_PROMPT_ONLY_IN_REPO=1" >> .bashrc
run_command echo "source ~/bash-git-prompt/gitprompt.sh" >> .bashrc
