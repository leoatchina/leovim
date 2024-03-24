set -x
existing=~/.local/share/nvim/coc/extensions/node_modules/coc-ccls/node_modules/ws/lib/extension.js
missing=~/.local/share/nvim/coc/extensions/node_modules/coc-ccls/lib/extension.js
if [[ -e "$existing" && ! -e "$missing" ]]; then
    mkdir -p $(dirname $missing)
    ln -s $existing $missing
fi
set +x
