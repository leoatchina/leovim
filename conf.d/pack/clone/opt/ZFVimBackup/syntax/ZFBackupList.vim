if exists("b:current_syntax")
    finish
endif
let b:current_syntax = 'ZFBackupList'

syntax match ZFBackupList_comment '^[ \t]*#.*$'

highlight default link ZFBackupList_comment Comment

