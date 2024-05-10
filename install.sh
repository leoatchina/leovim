#!/usr/bin/env bash
############################  SETUP PARAMETERS
app_name='leovim'
[ -z "$APP_PATH" ] && APP_PATH="$PWD"
############################  BASIC SETUP TOOLS

msg() {
    printf '%b\n' "$1" >&2
}

info() {
    msg "\33[33m[I]\33[0m ${1}${2}"
}

success() {
    msg "\33[32m[✔]\33[0m ${1}${2}"
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
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
        exit 1
    fi
}

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
}
############################ SETUP FUNCTIONS
create_vimrc(){
    local vimrc="$1"
    [[ -f "$vimrc" || -L "$vimrc" ]] && rm -f $vimrc
    cat << EOF > $vimrc
if filereadable(expand("~/.vimrc.test"))
    source ~/.vimrc.test
else
    source ~/.leovim/boostup/init.vim
endif
EOF
success "Setted up $vimrc"
}

create_symlinks() {
    local source_path="$1"
    local target_path="$2"
    lnif  "$source_path"  "$target_path"
    ret="$?"
    success "Setted up symlinks from $source_path to $target_path"
}

setup_plug() {
    local system_shell="$SHELL"
    export SHELL='/bin/sh'
    echo
    info "Starting update/install plugins for $1"
    "$1" +PlugUpdate +qall
    export SHELL="$system_shell"
    success "Successfully updated/installed plugins for $1"
}

############################ MAIN() #################################
variable_set "$HOME"

mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.local/bin"

# install extended softwares
if [ $# -gt 0 ]; then
    mode=$1
    if [ $# -gt 1 ]; then
        installplug=$2
    else
        installplug="yes"
    fi
    # leotmux
    if [[ $mode == 'all' || $mode == 'leotmux' ]]; then
        if [ -d ~/.leotmux ]; then
            info "leotmux already installed."
        else
            git clone https://gitee.com/leoatchina/leotmux.git ~/.leotmux > /dev/null 2>&1
            ln -sf ~/.leotmux/tmux.conf ~/.tmux.conf
            success "leotmux installed"
        fi
        [ $mode == 'leotmux' ] && exit 0
    fi
    # z.lua
    if [[ $mode == 'all' || $mode == 'z.lua' ]]; then
        if [ -d ~/z.lua ]; then
            info "z.lua already installed."
        else
            git clone https://github.com/skywind3000/z.lua ~/z.lua
            success "z.lua installed"
        fi
        [ $mode == 'z.lua' ] && exit 0
    fi
    # neovim
    if [[ $mode == 'all' || $mode == 'neovim' ]]; then
        if [ -d ~/.local/nvim-linux64 ]; then
            info "neovim already installed"
        else
            cd ~/.local
            wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
            tar xvf nvim-linux64.tar.gz
            rm nvim-linux64.tar.gz
            success "neovim installed"
        fi
        [ $mode == 'neovim' ] && exit 0
    fi
    # nodejs
    if [[ $mode == 'all' || $mode == 'nodejs' ]]; then
        node_link=~/.local/node
        if [ -L $node_link ]; then
            info "$node_link already linked"
        else
            url=`wget -qO- https://nodejs.cn/download/current | grep -oP 'href="\K[^"]*linux-x64.tar.xz' | head -n 1`
            cd ~/.local
            rm -rf node*
            wget $url
            node="${url##*/}"
            tar xvf $node && rm $node && ln -sf ${node%.*.*} node
            success "$node_link linked"
        fi
        [ $mode == 'nodejs' ] && exit 0
    fi
    # bashrc
    if [[ $mode == 'all' ]]; then
        if [ -f ~/.bashrc ]; then
            read -p "Do you want to move .bashrc? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                mv -f ~/.bashrc ~/.bashrc.bak
                success "bashrc moved."
            else
                info "bashrc not moved."
            fi
        fi
    fi
else
    installplug='yes'
fi

# my config
[ ! -f ~/.bashrc ] && cp $APP_PATH/scripts/bashrc $HOME/.bashrc && success "bashrc copied."
cp -n $APP_PATH/scripts/inputrc $HOME/.inputrc
cp -n $APP_PATH/scripts/configrc $HOME/.configrc

# z scripts is for history file browser
cp -n $APP_PATH/scripts/z.sh $HOME/.local/bin

# vim run scripts
cp -n $APP_PATH/scripts/v.sh $HOME/.local/bin
cp -n $APP_PATH/scripts/vi.sh $HOME/.local/bin
cp -n $APP_PATH/scripts/nv.sh $HOME/.local/bin
cp -n $APP_PATH/scripts/nvi.sh $HOME/.local/bin

# dirdiff
ln -sf $APP_PATH/scripts/dirdiff $HOME/.local/bin

# leovim command
echo "#!/usr/bin/env bash" > $HOME/.local/bin/leovim
echo "export leovim=$HOME/.leovim" >> $HOME/.local/bin/leovim
echo 'cd $leovim && git pull' >> $HOME/.local/bin/leovim
echo '$SHELL' >> $HOME/.local/bin/leovim && chmod 755 $HOME/.local/bin/leovim

# leovimd command
echo "#!/usr/bin/env bash" > $HOME/.local/bin/leovimd
echo "export LEOVIM_D=$HOME/.leovim.d" >> $HOME/.local/bin/leovimd
echo 'cd $LEOVIM_D' >> $HOME/.local/bin/leovimd
echo '$SHELL' >> $HOME/.local/bin/leovimd && chmod 755 $HOME/.local/bin/leovimd

# clone tools
if [ -d ~/.leovim.unix ]; then
    cd ~/.leovim.unix && git pull > /dev/null 2>&1
    success "~/.leovim.unix updated"
else
    git clone https://github.com/leoatchina/leovim-unix ~/.leovim.unix > /dev/null 2>&1
    success "~/.leovim.unix cloned"
fi

# set variable
ret='0'
echo
if [ "$APP_PATH" == "$HOME/.leovim" ]; then
    info "leovim has been already installed in $HOME/.leovim"
else
    info "leovim is going to be linked to $HOME/.leovim"
    rm -rf $HOME/.leovim
    create_symlinks "$APP_PATH" "$HOME/.leovim"
    success "leovim has been linked to $HOME/.leovim"
fi

echo
create_symlinks "$APP_PATH/clean.sh" "$HOME/.leovim.clean"
create_symlinks "$APP_PATH/jetbrains/idea.vim" "$HOME/.ideavimrc"
create_vimrc "$HOME/.vimrc"
create_vimrc "$HOME/.gvimrc"
create_vimrc "$HOME/.config/nvim/init.vim"
create_vimrc "$HOME/.config/nvim/ginit.vim"

echo
if [ -f $HOME/.vimrc.opt ];then
    info "$HOME/.vimrc.opt exists. You can modify it."
else
    cp $APP_PATH/boostup/optional/opt.vim $HOME/.vimrc.opt
    success "$HOME/.vimrc.opt copied."
fi

# install plugs
if [ $installplug != 'no' ]; then
    if program_exists "vim"; then
        setup_plug "vim"
    fi
    setup_plug "$HOME/.local/bin/nv.sh"
    setup_plug "$HOME/.local/bin/nvi.sh"
fi

echo
success "Thanks for installing leoatchina's vim config. ©`date +%Y` https://github.com/leoatchina/leovim"
