#!/usr/bin/env bash
############################  SETUP PARAMETERS
app_name='leovim'
[ -z "$APP_PATH" ] && APP_PATH="$PWD"
############################  BASIC SETUP TOOLS

msg() {
    printf '%b\n' "$1" >&2
}

note() {
    echo "==================================================================="
    msg "\33[30m\33[0m ${1}${2}"
    echo "==================================================================="
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
if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
else
    source ~/.leovim/conf.d/init.vim
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
    info "Starting update/install plugins for $1"
    "$1" +PlugOptUpdate +qall
    success "Successfully updated/installed plugins for $1"
}

############################ MAIN() #################################
variable_set "$HOME"
OS=$(uname)
ARCH=$(uname -m)
os="linux" # default value

if [ "$OS" = "Darwin" ]; then
    if [ "$ARCH" = "arm64" ]; then
        os="macos-arm64"
    elif [ "$ARCH" = "x86_64" ]; then
        os="macos-x64"
    fi
fi

mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.local/bin"

# z scripts is for history file browser
cp -n $APP_PATH/scripts/z.sh $HOME/.local/bin

# enhanced config
cp -n $APP_PATH/scripts/inputrc $HOME/.inputrc
cp -n $APP_PATH/scripts/configrc $HOME/.configrc


note "Set links, create (neo)vim's configs, and cp start scripts"

# set links
if [ "$APP_PATH" == "$HOME/.leovim" ]; then
    info "leovim has been already installed in $HOME/.leovim"
else
    info "leovim is going to be linked to $HOME/.leovim"
    rm -rf $HOME/.leovim
    create_symlinks "$APP_PATH" "$HOME/.leovim"
    success "leovim has been linked to $HOME/.leovim"
fi
create_symlinks "$APP_PATH/clean.sh" "$HOME/.leovim.clean"

# create config
create_vimrc "$HOME/.vimrc"
create_vimrc "$HOME/.config/nvim/init.vim"
[ ! -f $HOME/.gvimrc ] && echo '" set guifont=CascadiaCode\ Code:h11' > $HOME/.gvimrc && echo '" set guifont=CascadiaCode\ Nerd\ Font:h11.5' >> $HOME/.gvimrc

# vim run scripts
cp -n $APP_PATH/scripts/v.sh  $HOME/.local/bin
cp -n $APP_PATH/scripts/vi.sh $HOME/.local/bin
cp -n $APP_PATH/scripts/nv.sh $HOME/.local/bin
cp -n $APP_PATH/scripts/ni.sh $HOME/.local/bin

# dirdiff
cp -n $APP_PATH/scripts/dirdiff $HOME/.local/bin

# leovim command
if [ $os == 'linux' ]; then
    if [ $SHELL == 'sh' ]; then
        bash
    fi
    shell=bash
else
    shell=zsh
fi

echo "#!/usr/bin/env $shell" > $HOME/.local/bin/leovim
echo "export leovim=$HOME/.leovim" >> $HOME/.local/bin/leovim
echo 'cd $leovim && git pull' >> $HOME/.local/bin/leovim
echo "$shell" >> $HOME/.local/bin/leovim && chmod 755 $HOME/.local/bin/leovim

# leovimd command
echo "#!/usr/bin/env $shell" > $HOME/.local/bin/leovimd
echo "export LEOVIMD=$HOME/.leovim.d" >> $HOME/.local/bin/leovimd
echo 'cd $LEOVIMD' >> $HOME/.local/bin/leovimd
echo "$shell" >> $HOME/.local/bin/leovimd && chmod 755 $HOME/.local/bin/leovimd

########################### install softwares #####################################
if [ $# -gt 0 ]; then
    mode=$1
    if [ $# -gt 1 ]; then
        installplug=$2
    else
        installplug="yes"
    fi
    # leotmux
    if [[ $mode == 'leotmux' ]]; then
        note "Install leotmux"
        if [ -d ~/.leotmux ]; then
            info "leotmux already installed."
            cd ~/.leotmux && git pull
            exit 0
        else
            git clone https://gitee.com/leoatchina/leotmux.git ~/.leotmux > /dev/null 2>&1
            ln -sf ~/.leotmux/tmux.conf ~/.tmux.conf
            success "leotmux installed"
            exit 0
        fi
    # copy configrc
    elif [[ $mode == 'rc' ]]; then

        if [ -f ~/.bashrc ] && [ $os == 'linux' ]; then
            read -p "Do you want to move .bashrc? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                mv -f ~/.bashrc ~/.bashrc.bak
                success "~/.bashrc moved."
            else
                info "~/.bashrc not moved."
            fi
            if  [ ! -f ~/.bashrc ] && [ $os == 'linux' ]; then
                cp $APP_PATH/scripts/bashrc $HOME/.bashrc
                success "bashrc copied."
                $shell
            fi
        elif [ -f ~/.zshrc ]; then
            read -p "Do you want to move .zshrc? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                mv -f ~/.zshrc ~/.zshrc.bak
                success "~/.zshrc moved."
            else
                info "~/.zshrc not moved."
            fi
            if [ ! -f ~/.zshrc ] && program_exists zsh; then
                cp $APP_PATH/scripts/zshrc $HOME/.zshrc
                success "zshrc copied."
                $shell
            fi
        fi
        exit 0
    else
        note "Install softwares"
    fi
    # z.lua
    if [[ $mode == 'all' || $mode == 'z.lua' ]]; then
        if [ -d ~/z.lua ]; then
            info "z.lua already installed."
            cd ~/z.lua && git pull
        else
            git clone https://github.com/skywind3000/z.lua ~/z.lua
            success "z.lua installed"
        fi
        [[ $mode == 'z.lua' ]] && exit 0
    fi
    # neovim
    if [[ $mode == 'all' || $mode == 'neovim' ]]; then
        if [ -d ~/.local/nvim-linux64 ] && [ $mode == 'all' ]; then
            info "neovim already installed"
        else
            cd ~/.local
            rm -rf nvim-*
            # wget according to os
            case "$os" in
                "macos-arm64")
                    wget https://github.com/neovim/neovim/releases/download/stable/nvim-macos-arm64.tar.gz
                    tar xzf nvim-macos-arm64.tar.gz
                    ;;
                "macos-x64")
                    wget https://github.com/neovim/neovim/releases/download/stable/nvim-macos-x86_64.tar.gz
                    tar xzf nvim-macos-x86_64.tar.gz
                    ;;
                *)
                    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
                    tar xzf nvim-linux64.tar.gz
                    ;;
            esac
            rm nvim-*.tar.gz
            success "neovim installed"
        fi
        [[ $mode == 'neovim' ]] && exit 0
    fi
    # nvm
    if [[ $mode == 'all' || $mode == 'nodejs' ]]; then
        node_link=~/.local/node
        if [ -L $node_link ] && [ $mode == 'all' ]; then
            info "$node_link already linked"
        else
            cd ~/.local
            rm -rf node*
            # wget according to os
            case "$os" in
                "macos-arm64")
                    url=$(curl -s https://nodejs.cn/download/current/ | grep -o 'href="[^"]*darwin-arm64.tar.gz"' | cut -d'"' -f2)
                    ;;
                "macos-x64")
                    url=$(curl -s https://nodejs.cn/download/current/ | grep -o 'href="[^"]*darwin-x64.tar.gz"' | cut -d'"' -f2)
                    ;;
                *)
                    url=$(curl -s https://nodejs.cn/download/current/ | grep -o 'href="[^"]*linux-x64.tar.xz"' | cut -d'"' -f2)
                    ;;
            esac
            wget $url
            node="${url##*/}"
            tar xvf $node && rm $node && ln -sf ${node%.*.*} node
            success "$node_link linked"
        fi
        [ $mode == 'nodejs' ] && exit 0
    elif [ $mode == 'nvm' ]; then
        nvm_dir=~/.nvm
        if [ -d $nvm_dir ] && [ $mode == 'all' ] ; then
            info "nvm already installed"
        else
            curl -fsSL https://gitee.com/sdq/nvm/raw/master/install.sh | bash
            success "nvim install to $nvm_dir"
        fi
        exit 0
    fi
else
    mode=normal
    installplug='yes'
fi


# clone unix tools for (neo)vim
note "Install/update leovim.unix"
if [ -d ~/.leovim.unix ]; then
    cd ~/.leovim.unix && git pull > /dev/null 2>&1
    success "~/.leovim.unix updated"
else
    git clone https://gitee.com/leoatchina/leovim-unix ~/.leovim.unix > /dev/null 2>&1
    success "~/.leovim.unix cloned"
fi

############################################## set optional config #####################################
if [ -f $HOME/.vimrc.opt ];then
    info "$HOME/.vimrc.opt exists. You can modify it."
else
    cp $APP_PATH/conf.d/cfg/opt.vim $HOME/.vimrc.opt
    success "$HOME/.vimrc.opt copied."
fi

############################### install plugins ##################################
if [ $installplug != 'no' ]; then
    note "Install (neo)vim plugins"
    if [ -f $HOME/.vimrc.local ]; then
        setup_plug "$HOME/.local/bin/vi.sh"
    else
        setup_plug "vim"
    fi
    setup_plug "$HOME/.local/bin/nv.sh"
    setup_plug "$HOME/.local/bin/ni.sh"
fi

echo
success "Thanks for installing leoatchina's vim config. `date +%Y` https://github.com/leoatchina/leovim"
