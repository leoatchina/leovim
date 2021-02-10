program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }
    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi
    return 0
}

msg() {
    printf '%b\n' "$1" >&2
}

if program_exists "vim"; then
    echo
    msg "Starting update plugins for vim"
    vim +MyPlugUpdate +qall
fi
if program_exists "nvim"; then
    echo
    msg "Starting update plugins for nvim"
    nvim +MyPlugUpdate +qall
fi
if program_exists "gvim"; then
    echo
    msg "Starting update plugins for gvim"
    gvim +MyPlugUpdate +qall
fi
