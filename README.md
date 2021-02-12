LLLLLLLLLLL             EEEEEEEEEEEEEEEEEEEEEE     OOOOOOOOO     VVVVVVVV           VVVVVVVVIIIIIIIIIIMMMMMMMM               MMMMMMMM
L:::::::::L             E::::::::::::::::::::E   OO:::::::::OO   V::::::V           V::::::VI::::::::IM:::::::M             M:::::::M
L:::::::::L             E::::::::::::::::::::E OO:::::::::::::OO V::::::V           V::::::VI::::::::IM::::::::M           M::::::::M
LL:::::::LL             EE::::::EEEEEEEEE::::EO:::::::OOO:::::::OV::::::V           V::::::VII::::::IIM:::::::::M         M:::::::::M
  L:::::L                 E:::::E       EEEEEEO::::::O   O::::::O V:::::V           V:::::V   I::::I  M::::::::::M       M::::::::::M
  L:::::L                 E:::::E             O:::::O     O:::::O  V:::::V         V:::::V    I::::I  M:::::::::::M     M:::::::::::M
  L:::::L                 E::::::EEEEEEEEEE   O:::::O     O:::::O   V:::::V       V:::::V     I::::I  M:::::::M::::M   M::::M:::::::M
  L:::::L                 E:::::::::::::::E   O:::::O     O:::::O    V:::::V     V:::::V      I::::I  M::::::M M::::M M::::M M::::::M
  L:::::L                 E:::::::::::::::E   O:::::O     O:::::O     V:::::V   V:::::V       I::::I  M::::::M  M::::M::::M  M::::::M
  L:::::L                 E::::::EEEEEEEEEE   O:::::O     O:::::O      V:::::V V:::::V        I::::I  M::::::M   M:::::::M   M::::::M
  L:::::L                 E:::::E             O:::::O     O:::::O       V:::::V:::::V         I::::I  M::::::M    M:::::M    M::::::M
  L:::::L         LLLLLL  E:::::E       EEEEEEO::::::O   O::::::O        V:::::::::V          I::::I  M::::::M     MMMMM     M::::::M
LL:::::::LLLLLLLLL:::::LEE::::::EEEEEEEE:::::EO:::::::OOO:::::::O         V:::::::V         II::::::IIM::::::M               M::::::M
L::::::::::::::::::::::LE::::::::::::::::::::E OO:::::::::::::OO           V:::::V          I::::::::IM::::::M               M::::::M
L::::::::::::::::::::::LE::::::::::::::::::::E   OO:::::::::OO              V:::V           I::::::::IM::::::M               M::::::M
LLLLLLLLLLLLLLLLLLLLLLLLEEEEEEEEEEEEEEEEEEEEEE     OOOOOOOOO                 VVV            IIIIIIIIIIMMMMMMMM               MMMMMMMM

## 中文介绍

这里是本人的 vim 配置，在近四年的使用时间里，我不断调整，从其他人的配置中吸取经验，对参数进行微调，以适应在不同的系统环境条件下达到较好的使用体验。在`macOS` `windows` `linx`下都可以安装使用，已经可作为一个小型轻量 **IDE** 使用。
**PLEASE FORGIVE ME FOR MY POOR ENGLISH!!**
**And the short key now is modified, and I will find some time to rewrite this readme**

## Requirements
`Git 1.7` and `Vim7.3` is at least required. `Vim8.2` or `neovim-0.4.2` and `Git 2.0+` is prefered for advanced features.
And I wish you have a basic understanding of vim, know how to read the config files to find what I have not mentioned in README.

## Install
### Linux, \*nix, Mac OSX
```bash
git clone https://gitee.com/leoatchina/leovim.git
cd leovim
./install.sh
```
### windows
```bash
git clone https://gitee.com/leoatchina/leovim.git
cd leovim
click install.cmd with administrator rights
open vim, do `:MyPlugInstall` or `:PlugInstall`
```

## Upgrade plugins
### Linux, \*nix, Mac OSX
```bash
cd leovim
./updata.sh
```
OR
```bash
~/.vimrc.update
```
OR
```bash
open vim; do :MyPlugUpdate
```

### windows

```bash
open vim; do :MyPlugUpdate
```

## Delete
### Linux, \*nix, Mac OSX
```bash
cd leovim
./uninstall.sh
```

### Windows
```bash
click uninstall.cmd with administrator right
```

## TODO
- [x] fixed GetPyxVerion when not has 'execute'
- [x] `tab drop problem` in legacy vim
- [x] better lightline schemes
- [x] m<tab> to show marks list
- [x] m<Cr> to clear mark current line
- [x] leaderf popup ratio
- [x] leaderf grep postion keeped on right if not has `popup` or `floating window`
    - <M-f>p to change
- [x] Better register insert
    - <leader>p, ,<p>
- [x] eclim for java only
    - <leader>o to map
- [x] Easymotion, within line jump
    - gj, gk, gl,etc
    - s<tab> t<tab>
- [x] far.vim
    - c/f + <tab>
- [x] fern.vim as tree_browser
- [x] fly_grep using leaderf or fzf
    - <leader>/,;.
- [x] auto choose yes to kill job when confirm quit termina
    - using <M-q>
- [x] MyPlug to install plunins in to $INSTALL_PATH by default
    - [x] fix bugs in install and upgrade scripts
- [x] leaderf as default fuzzy_finder when with python3 support, other wise fzf or ctrlp 
- [x] fix coc.nvim vsplitly open definition declaration etc.
- [x] settings plugins to install list in ./install/plugs.vim
- [x] Copy && Paste using tmux
- [ ] fzf yank 
- [ ] floaterm repl config 
- [ ] rewrite readme
