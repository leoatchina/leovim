if exists("b:current_syntax")
    finish
endif
let b:current_syntax = 'ZFBackupListDir'

syntax match ZFBackupListDir_comment '^[ \t]*#.*$'
syntax match ZFBackupListDir_pathHint '=>.*$'

highlight default link ZFBackupListDir_comment Comment
highlight default link ZFBackupListDir_pathHint Folded

