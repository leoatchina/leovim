if exists('g:floaterm_enhance_loaded')
    finish
endif
let g:floaterm_enhance_loaded = 1
let g:floaterm_prog_postion = get(g:, 'floaterm_prog_postion', 'auto')
let g:floaterm_prog_col_row_ratio = get(g:, 'floaterm_prog_col_row_ratio', 3)
let g:floaterm_prog_prog_ratio = get(g:, 'floaterm_prog_ratio', 0.38)
let g:floaterm_prog_float_ratio = get(g:, 'floaterm_prog_float_ratio', 0.45)
" registry runners
let g:asyncrun_runner = get(g:, 'asyncrun_runner', {})
let g:asyncrun_runner.floaterm_right  = function('floaterm#asyncrun#right')
let g:asyncrun_runner.floaterm_float  = function('floaterm#asyncrun#float')
let g:asyncrun_runner.floaterm_bottom = function('floaterm#asyncrun#bottom')
let g:asyncrun_runner.floaterm_left   = function('floaterm#asyncrun#left')
let g:asyncrun_runner.floaterm_top    = function('floaterm#asyncrun#top')
let g:asyncrun_runner.floaterm_topleft= function('floaterm#asyncrun#topleft')
let g:asyncrun_runner.floaterm_center = function('floaterm#asyncrun#center')
" list term
command! FloatermList call floaterm#enhance#term_list()
