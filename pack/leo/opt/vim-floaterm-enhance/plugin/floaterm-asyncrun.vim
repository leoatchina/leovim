let g:asyncrun_runner = get(g:, 'asyncrun_runner', {})
" registry runners
let g:asyncrun_runner.floaterm_right  = function('floaterm#asyncrun#right')
let g:asyncrun_runner.floaterm_float  = function('floaterm#asyncrun#float')
let g:asyncrun_runner.floaterm_bottom = function('floaterm#asyncrun#bottom')
let g:asyncrun_runner.floaterm_left   = function('floaterm#asyncrun#left')
let g:asyncrun_runner.floaterm_top    = function('floaterm#asyncrun#top')
let g:asyncrun_runner.floaterm_topleft= function('floaterm#asyncrun#topleft')
let g:asyncrun_runner.floaterm_center = function('floaterm#asyncrun#center')