let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn|vscode|idea|root|ccls)$',
            \ 'file': '\v\.(exe|so|dll|pyd|msi)$',
            \ }
let g:ctrlp_root_markers = g:root_patterns
let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:16,results:0'
