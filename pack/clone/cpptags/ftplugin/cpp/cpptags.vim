" cpp_tagfunc.vim: Sets up a cpp savvy tagfunc
" GetLatestVimScripts: 6124 1 :AutoInstall: cpptags.vmb

if empty(&filetype) || exists("b:did_ftplugin_cpp_tagfunc")
  finish
endif
" note that b:did_ftplugin is already set by the builtin version
let b:did_ftplugin_cpp_tagfunc = 1
" asocciate the customize tagfunc
setl tagfunc=cpptags#CppTagFunc
