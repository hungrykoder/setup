#!/bin/bash
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
        wget --no-verbose -O tmx https://gist.githubusercontent.com/hungrykoder/2f6fd7742dacf54f304a4492b8f67351/raw/f53d49653ff8e67afa17b6e0da02524e6b5c7ca3/tmx

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
        wget --no-verbose -O .bash_profile https://gist.github.com/hungrykoder/739edf831fe260033ccb0684afa0f13c/raw/1455a8b45571c6c061da71c36a58024f439c4e5f/.bash_profile

    [ ! -f "${config_dir}/.tmux.conf" ] || [ "${in_arg}" = "update" ] && \
        wget --no-verbose -O .tmux.conf https://gist.githubusercontent.com/hungrykoder/a895dd98340a66054aed157e8fb87e63/raw/5d52986aa6f39fb1400ac867fb16e1a2fcee4c79/tmux.conf


    local files_to_link=(".bash_profile" ".tmux.conf" ".vimrc")
    for file_name in "${files_to_link[@]}"
    do
        if [ -f "${config_dir}/${file_name}" ]; then
            if [ ! -f "${HOME}/${file_name}" ]; then
                echo "Creating symlink:  ${HOME}/${file_name} -> ${config_dir}/${file_name}"
                ln -s "${config_dir}/${file_name}" "${config_dir}/${file_name}"
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
    echo_green "Done!!!"
}

setup
