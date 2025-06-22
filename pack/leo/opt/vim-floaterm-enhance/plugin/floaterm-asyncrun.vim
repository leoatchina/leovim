let g:asyncrun_runner = get(g:, 'asyncrun_runner', {})
" registry runners
let g:asyncrun_runner.floaterm_right  = function('floaterm#asyncrun#right')
let g:asyncrun_runner.floaterm_float  = function('floaterm#asyncrun#float')
let g:asyncrun_runner.floaterm_bottom = function('floaterm#asyncrun#bottom')
