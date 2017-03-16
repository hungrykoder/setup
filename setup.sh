#!/bin/bash
# WARNING!!! This utility is provided as if, and author assumes no responsibility
# for any damage this script may cause

# curl -sL https://goo.gl/LLVzv9 | bash -s update
# curl -sL https://tinyurl.com/b4t-shell | bash -s update

in_arg="${1}"
OLDWD=`pwd`
finish() {
    cd $OLDWD
}

echo_red()  {
    if [ ! -z "$1" ]; then
        echo -e "\033[0;31m$1\033[0;31m"
    fi
}


echo_green()  {
    if [ ! -z "$1" ]; then
        echo -e "\033[0;32m$1\033[0;31m"
    fi
}

echo_yellow()  {
    if [ ! -z "$1" ]; then
        echo -e "\033[0;33m$1\033[0;31m"
    fi
}

trap finish exit
setup() {
    local OWN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    local config_dir="$HOME/user-config"

    mkdir "${config_dir}" 2> /dev/null || true
    cd "${config_dir}"

    if [[ ! -d "${HOME}/bin" ]]; then
        echo "${HOME}/bin doesn't exist"
        mkdir "${HOME}/bin" ||  echo_red "Failed to create bin directory." && exit 1
    fi

    [ ! -f "${config_dir}/tmx" ] || [ "${in_arg}" = "update" ] && \
        wget --no-verbose -O tmx https://raw.githubusercontent.com/hungrykoder/setup/master/tmx

    chmod a+x tmx

    local bin_files=("tmx")
    # ~/bin/already exist, so just create symlink for tmx into existing bin
    for bin_file_name in "${bin_files[@]}"
    do

        if [ -f "${config_dir}/${bin_file_name}" ]; then
            chmod +x "${config_dir}/${bin_file_name}"
            if [ ! -f "${HOME}/bin/${bin_file_name}" ]; then
                echo "Creating symlink:  ${HOME}/bin/${bin_file_name} -> ${config_dir}/${bin_file_name}"
                ln -s "${config_dir}/bin/${bin_file_name}" "${config_dir}/${bin_file_name}"
            else
                echo_yellow "${HOME}/bin/${bin_file_name} already exist."
            fi
        fi
    done

    [ ! -f "${config_dir}/.bash_profile" ]  || [ "${in_arg}" = "update" ] && \
        wget --no-verbose -O .bash_profile https://raw.githubusercontent.com/hungrykoder/setup/master/.bash_profile

    [ ! -f "${config_dir}/.tmux.conf" ] || [ "${in_arg}" = "update" ] && \
        wget --no-verbose -O .tmux.conf https://raw.githubusercontent.com/hungrykoder/setup/master/.tmux.conf


    local files_to_link=(".bash_profile" ".tmux.conf" ".vimrc")
    for file_name in "${files_to_link[@]}"
    do
        if [ -f "${config_dir}/${file_name}" ]; then
            if [ ! -f "${HOME}/${file_name}" ]; then
                echo "Creating symlink:  ${HOME}/${file_name} -> ${config_dir}/${file_name}"
                ln -s "${config_dir}/${file_name}" "${HOME}/${file_name}"
            else
                echo_yellow "${HOME}/${file_name} already exist."
                if [[ "${file_name}" = ".bash_profile" ]]; then
                    # check if its a different bash_profile already present in home directory
                    if ! [ "${HOME}/.bash_profile" -ef "${config_dir}/.bash_profile" ]; then
                        exist=$(grep "user-config/.bash_profile" "${HOME}/.bash_profile")
                        if [ -z "${exist}" ]; then
                            echo_yellow "Existing $HOME/.bash_profile found. Adding statement to source ${config_dir}/.bash_profile in there"
                            echo "[[ -f \"${config_dir}/.bash_profile\" ]] && . ${config_dir}/.bash_profile" >> "${HOME}/.bash_profile"
                        fi
                    fi
                fi
            fi
        fi
    done
    source $HOME/.bash_profile
    echo_green "Done!!!"
}

setup
