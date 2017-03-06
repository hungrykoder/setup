#!/bin/bash
setup() {
    local OWN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

    if [ ! -d "${HOME}/bin" ]; then
        echo "Creating symlink: ${HOME}/bin -> ${OWN_DIR}/bin"
        ln -s "${OWN_DIR}/bin" "$HOME/bin"
    else
        # ~/bin/already exist, so just create symlink for tmx into existing bin
        if [ ! -f "${HOME}/bin/tmx" ]; then
            echo "${HOME}/bin directory already exist. Creating symlink:  ${HOME}/bin/tmx -> ${OWN_DIR}/bin/tmx"
            ln -s "${OWN_DIR}/bin/tmx" "${HOME}/bin/tmx"
        else
            echo "${HOME}/bin/tmx already exist."
        fi
    fi

    local files_to_link=(".bash_profile" ".tmux.conf" ".vimrc")
    for file_name in "${files_to_link[@]}"
    do
        if [ -f "${OWN_DIR}/${file_name}" ]; then
            if [ ! -f "${HOME}/${file_name}" ]; then
                echo "Creating symlink:  ${HOME}/${file_name} -> ${OWN_DIR}/${file_name}"
                ln -s "${OWN_DIR}/${file_name}" "${HOME}/${file_name}"
            else
                echo "${HOME}/${file_name} already exist."
            fi
        fi
    done
}

setup
