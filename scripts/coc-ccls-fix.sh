set -x
existing=~/.leovim.d/coc/extensions/node_modules/coc-ccls/node_modules/ws/lib/extension.js
missing=~/.leovim.d/coc/extensions/node_modules/coc-ccls/lib/extension.js
if [[ -e "$existing" && ! -e "$missing" ]]; then
    mkdir -p $(dirname $missing)
    ln -s $existing $missing
fi
set +x