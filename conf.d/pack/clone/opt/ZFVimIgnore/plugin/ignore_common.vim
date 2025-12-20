
if !get(g:, 'ZFIgnore_ignore_common', 1)
    finish
endif

if !exists('g:ZFIgnoreData')
    let g:ZFIgnoreData = {}
endif
if !exists("g:ZFIgnoreData['ZFIgnore_ignore_common']")
    if !exists('g:ZFIgnoreOptionDefault')
        let g:ZFIgnoreOptionDefault = {}
    endif
    if !exists("g:ZFIgnoreOptionDefault['common']")
        let g:ZFIgnoreOptionDefault['common'] = 1
    endif
    if !exists("g:ZFIgnoreOptionDefault['bin']")
        let g:ZFIgnoreOptionDefault['bin'] = 1
    endif
    if !exists("g:ZFIgnoreOptionDefault['media']")
        let g:ZFIgnoreOptionDefault['media'] = 1
    endif
    if !exists("g:ZFIgnoreOptionDefault['hidden']")
        let g:ZFIgnoreOptionDefault['hidden'] = 1
    endif

    let g:ZFIgnoreData['ZFIgnore_ignore_common'] = {
                \   'common' : {
                \     'file' : {
                \       '*.d' : 0,
                \       '*.depend*' : 1,
                \       '*.dex' : 1,
                \       '*.iml' : 1,
                \       '*.meta' : 1,
                \       '*.pyc' : 1,
                \       '*.swp' : 1,
                \       '*.user' : 1,
                \       '.DS_Store' : 1,
                \       '.project' : 1,
                \       '.vim_tags' : 1,
                \       'local.properties' : 1,
                \       'tags' : 1,
                \     },
                \     'dir' : {
                \       '.build' : 1,
                \       '.cache' : 1,
                \       '.cxx' : 1,
                \       '.externalNativeBuild' : 1,
                \       '.git' : 1,
                \       '.gradle' : 1,
                \       '.hg' : 1,
                \       '.idea' : 1,
                \       '.release' : 1,
                \       '.settings' : 1,
                \       '.svn' : 1,
                \       '.tmp' : 1,
                \       '.vs' : 1,
                \       '.vscode' : 1,
                \       '.wing' : 1,
                \       'Pods' : 1,
                \       '__pycache__' : 1,
                \       '_build' : 1,
                \       '_cache' : 1,
                \       '_release' : 1,
                \       '_repo' : 1,
                \       '_tmp' : 1,
                \       'bin-*' : 1,
                \       'build-*' : 1,
                \       'node_modules' : 1,
                \       'vendor' : 1,
                \     },
                \   },
                \   'bin' : {
                \     'file' : {
                \       '*.a' : 1,
                \       '*.class' : 1,
                \       '*.dll' : 1,
                \       '*.dylib' : 1,
                \       '*.exe' : 1,
                \       '*.jar' : 1,
                \       '*.o' : 1,
                \       '*.so' : 1,
                \     },
                \     'dir' : {
                \       'bin' : 1,
                \     },
                \   },
                \   'media' : {
                \     'file' : {
                \       '*.avi' : 1,
                \       '*.bmp' : 1,
                \       '*.gif' : 1,
                \       '*.icns' : 1,
                \       '*.ico' : 1,
                \       '*.jpeg' : 1,
                \       '*.jpg' : 1,
                \       '*.mkv' : 1,
                \       '*.mp2' : 1,
                \       '*.mp3' : 1,
                \       '*.mp4' : 1,
                \       '*.ogg' : 1,
                \       '*.png' : 1,
                \       '*.wav' : 1,
                \       '*.webp' : 1,
                \     },
                \   },
                \   'hidden' : {
                \     'file' : {
                \       '.*' : 1,
                \       '~?*' : 1,
                \       '*?~' : 1,
                \     },
                \   },
                \ }
endif

