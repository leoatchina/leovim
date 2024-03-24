source ~/.leovim/main/set.vim
source ~/.leovim/main/map.vim
set clipboard+=unnamed
set history=100000
" select模式下复制
if has("clipboard")
    xnoremap <C-C> "+y
endif
" action back/forword
nnoremap <C-O> <ESC>:action Back<CR>
nnoremap <C-I> <ESC>:action Forward<CR>
nnoremap <C-D> <C-D>zz
nnoremap <C-U> <C-U>zz
nnoremap J <ESC>:action EditorJoinLines<CR>
nnoremap H ^
nnoremap L $
" Ctrl+某个按键
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Delete>
" idea smart join
set ideajoin
" jump between brackets
nnoremap <Cr> g%
xnoremap <Cr> g%
nnoremap <C-j> %
xnoremap <C-j> %
" Quit normal mode
nnoremap <space>q :q<CR>
nnoremap <space>Q :qa!<CR>
" tab and recentfile
nnoremap <space>o :action ReopenClosedTab<Cr>
nnoremap <space>m :action RecentFiles<Cr>
" To navigate between split panes
nnoremap <A-]> :action NextSplitter<Cr>
nnoremap <A-[> :action PrevSplitter<Cr>
" Tabs
nnoremap <Tab>p :action PreviousTab<Cr>
nnoremap <Tab>n :action NextTab<Cr>
nnoremap <Tab>h <C-w>h
nnoremap <Tab>j <C-w>j
nnoremap <Tab>k <C-w>k
nnoremap <Tab>l <C-w>l
nnoremap <Tab>H <C-w>H
nnoremap <Tab>J <C-w>J
nnoremap <Tab>K <C-w>K
nnoremap <Tab>L <C-w>L
" Splits manipulation
nnoremap <Tab>s :action SplitHorizontally<Cr>
nnoremap <Tab>v :action SplitVertically<Cr>
" tab
nnoremap <Tab><Tab> <C-i>
xnoremap <Tab><Tab> <C-i>
" Search
nnoremap <space>/  :action Find<Cr>
nnoremap <space>ff :action FindInPath<Cr>
nnoremap <space>fp :action ShowFilePath<Cr>
nnoremap <space>fr :action RenameFile<Cr>
nnoremap s/        :action SearchEverywhere<Cr>
" Navigation
nnoremap K         :action ShowPopupMenu<Cr>
nnoremap <C-p>     :action ProjectViewPopupMenu<CR>
nnoremap <A-;>     :action ShowUsages<Cr>
nnoremap <A-S-;>   :action FindUsages<Cr>
nnoremap <space>ic :action InspectCode<CR>
nnoremap <space>oi :action OptimizeImports<CR>
" symbol
nnoremap f<Cr>   :action FileStructurePopup<Cr>
nnoremap <A-/>   :action StructureViewPopupMenu<Cr>
nnoremap <A-S-/> :action GotoSymbol<Cr>
nnoremap <A-\>   :action NavBarToolBar<Cr>
nnoremap <A-S-\> :action ShowProjectStructureSettings<Cr>
" goto
nnoremap gd :action GotoDefinition<Cr>
nnoremap gh :action GotoTypeDeclaration<Cr>
nnoremap gl :action GotoDeclaration<Cr>
nnoremap gm :action GotoImplementation<Cr>
nnoremap ga :action GotoAction<Cr>
nnoremap gf :action GotoFile<Cr>
nnoremap gc :action GotoClass<Cr>
nnoremap gt :action GotoTest<Cr>
nnoremap gb :action JumpToLastChange<Cr>
" 实现方法
nnoremap gi :action ImplementMethods<CR>
" 重写方法"
nnoremap go :action OverrideMethods<CR>
" method
nnoremap gs :action SuperMethod<Cr>
nnoremap [m :action MethodUp<Cr>
nnoremap ]m :action MethodDown<Cr>
" reformat
nnoremap == :action ReformatCode<CR>
xnoremap == :action ReformatCode<CR>
" Terminal
nnoremap <A--> :action ActivateTerminalToolWindow<Cr>
" maven
nnoremap <space>am :action ActivateMavenProjectsToolWindow<Cr>
" Errors
nnoremap <space>ad :action ShowErrorDescription<Cr>
nnoremap <space>at :action AnalyzeStacktraceOnError<Cr>
nnoremap <space>e  :action GoToErrorGroup<Cr>
nnoremap ]e :action GotoNextError <Cr>
nnoremap [e :action GotoPreviousError<Cr>
" VCS operations
nnoremap <C-g>s :action Vcs.Show.Local.Changes<Cr>
nnoremap <C-g>p :action Vcs.QuickListPopupAction<Cr>
nnoremap <C-g>a :action Annotate<Cr>
nnoremap <C-g>l :action Vcs.Show.Log<Cr>
nnoremap <C-g>c :action Compare.LastVersion<Cr>
nnoremap <C-g>r :action Git.ResolveConflicts<Cr>
nnoremap <C-g>r :action Git.ResolveConflicts<CR>
nnoremap <C-g>a :action Annotate<CR>
nnoremap [g :action VcsShowPrevChangeMarker<Cr>
nnoremap ]g :action VcsShowNextChangeMarker<Cr>
" breakpoints
nnoremap <space>b :action ToggleLineBreakpoint<Cr>
nnoremap <space>l :action ViewBreakpoints<Cr>
" comments
" Use default map of <c-/> for that.
nnoremap <space>cc :action CommentByLineComment<Cr>
" compile
nnoremap <space>cd :action CompileDirty<Cr>
nnoremap <space>cp :action Compile<Cr>
nnoremap <space>cP :action CompileProject<Cr>
" rename
nnoremap <space>re :action RenameElement<Cr>
" run
nnoremap <space>rr :action Run<Cr>
nnoremap <space>rt :action RunTargetAction<Cr>
nnoremap <space>rg :action RunContextGroup<Cr>
nnoremap <space>rp :action RunContextPopupGroup<Cr>
nnoremap <space>rc :action RunCoverage<Cr>
nnoremap <space>rq :action Stop<Cr>
nnoremap <space>cr :action ChooseRunConfiguration<Cr>
nnoremap <space>R  :action RunAnything<Cr>
nnoremap <space>C  :action RunClass<Cr>
nnoremap <space>T  :action RerunTests<Cr>
" debug
nnoremap <space>dd :action Debug<Cr>
nnoremap <space>dc :action DebugClass<Cr>
nnoremap <space>cd :action ChooseDebugConfiguration<Cr>
" =========================================
" Emulated Plugins
" =========================================
set surround
nnoremap <Space>st :action SurroundWith<Cr>
xnoremap <Space>st :<c-u>action SurroundWith<Cr>
nnoremap <Space>se :action SurroundWithEmmet<Cr>
xnoremap <Space>se :<c-u>action SurroundWithEmmet<Cr>
nnoremap <Space>sl :action SurroundWithLiveTemplate<Cr>
xnoremap <Space>sl :<c-u>action SurroundWithLiveTemplate<Cr>
" Multiple cursors support
set multiple-cursors
nnoremap <C-n> <Plug>NextWholeOccurrence
xnoremap <C-n> <Plug>NextWholeOccurrence
nnoremap <C-k> <Plug>SkipOccurrence
xnoremap <C-k> <Plug>SkipOccurrence
nnoremap <C-h> <Plug>RemoveOccurrence
xnoremap <C-h> <Plug>RemoveOccurrence
nnoremap ]o <Plug>NextOccurrence
xnoremap ]o <Plug>NextOccurrence
nnoremap [o <Plug>PreviousOccurrence
xnoremap [o <Plug>PreviousOccurrence
" easymotion
set easymotion
source ~/.leovim/main/settings/easymotion.vim
" sneak
set sneak
" which-key
set which-key
set notimeout
set timeoutlen=500
" set input switch
set keep-english-in-normal-and-restore-in-insert
" other extensions
set match.it
set argtextobj.vim
set vim-textobj-entire
set ReplaceWithRegister
set vim-highlightedyank
