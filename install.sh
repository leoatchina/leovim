#!/usr/bin/env bash
############################  SETUP PARAMETERS
app_name='leovim'
[ -z "$APP_PATH" ] && APP_PATH="$PWD"
############################  BASIC SETUP TOOLS
msg() {
    printf '%b\n' "$1" >&2
}
success() {
    if [ "$ret" -eq '0' ]; then
        msg "\33[32m[✔]\33[0m ${1}${2}"
    fi
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
        msg "An error occurred in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }
    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi
    return 0
}

variable_set() {
    if [ -z "$1" ]; then
        error "You must have your HOME environmental variable set to continue."
    fi
}

lnif() {
    if [ -e "$1" ]; then
        if [ -f "$2" ] || [ -L "$2" ]; then
            echo "replace $2 with symbol link from $1."
            rm "$2"
        fi
        ln -sf "$1" "$2"
    fi
    ret="$?"
}
############################ SETUP FUNCTIONS
create_vimrc(){
    local vimrc="$1"
    [ -f $vimrc ] && rm -f $vimrc
    cat << EOF > $vimrc
if filereadable(expand("~/.vimrc.test"))
    source ~/.vimrc.test
else
    source ~/.leovim.conf/init.vim
endif
EOF
    success "Setted up vimrc $vimrc"
}

create_symlinks() {
    local source_path="$1"
    local target_path="$2"
    lnif  "$source_path"  "$target_path"
    ret="$?"
    success "Setted up vim symlinks $source_path $target_path"
}

setup_plug() {
    local system_shell="$SHELL"
    export SHELL='/bin/sh'
    echo
    msg "Starting update/install plugins for $1"
    "$1" +MyPlugInstall +qall
    export SHELL="$system_shell"
    success "Successfully updated/installed plugins using vim-plug for $1"
}

############################ MAIN()
variable_set "$HOME"
mkdir -p "$HOME/.cache/tags"
mkdir -p "$HOME/.cache/session"
mkdir -p "$HOME/.config/nvim"
update_vim_plug='0'
ret='0'
if [ -d $HOME/.vimrc.local ];then
    read -p "Do you want to update leoathina's vim config  (Y/y for Yes , any other key for No)? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]];then
        git pull
        success "Update to the latest version of leovim"
        update_vim_plug='1'
    fi
else
    update_vim_plug='1'
fi

echo
if [ "$APP_PATH" == "$HOME/.leovim.conf" ]; then
    echo "leovim is already installed in $HOME/.leovim.conf"
else
    echo "leovim is going to be linked to $HOME/.leovim.conf"
    create_symlinks "$APP_PATH" "$HOME/.leovim.conf"
fi

echo
create_symlinks "$APP_PATH/clean.sh"  "$HOME/.leovim.clean"
create_symlinks "$APP_PATH/update.sh" "$HOME/.leovim.update"

echo
create_vimrc "$HOME/.vimrc"
create_vimrc "$HOME/.gvimrc"
create_vimrc "$HOME/.config/nvim/init.vim"

if program_exists "vim"; then
    setup_plug "vim"
fi

if program_exists "nvim"; then
    setup_plug "nvim"
fi

if program_exists "gvim"; then
    setup_plug "gvim"
fi

echo

if [ -f $HOME/.vimrc.local ];then
    success "$HOME/.vimrc.local exists. You can modify it."
else
    cp $APP_PATH/local.vim $HOME/.vimrc.local
    success "$HOME/.vimrc.local does not exist, copy it."
    if program_exists "vim"; then
        vim $HOME/.vimrc.local
    fi
fi
msg "\nThanks for installing leoatchina's vim config"
msg "© `date +%Y` https://github.com/leoatchina/leovim"
