for each in `find ~/.local/share/nvim/coc -type f | grep coc-symbol-line | grep vim$`; do
  echo "change $each encoding to unix by vim"
  vim -c "set ff=unix" -c wq! $each
done
