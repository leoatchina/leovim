#!/usr/bin/env python3
"""Exercise the real pack/plug loaders without the user's startup or network.

Run from the repository root: python3 tests/pack_loader.py
VIM/NVIM may select editor executables; Neovim defaults to ~/.local/bin/nvim
when present. Missing editors fail verification rather than count as passes.
Each scenario uses a fresh process, temporary plugins/config, no persistence,
and a 15-second timeout. This does not source conf.d/init.vim or validate R.nvim UI.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
EDITORS = {
    "vim": os.environ.get("VIM", shutil.which("vim") or "vim"),
    "nvim": os.environ.get("NVIM", str(Path.home() / ".local/bin/nvim")
                           if (Path.home() / ".local/bin/nvim").is_file()
                           else shutil.which("nvim") or "nvim"),
}


def quote(value):
    return "'" + str(value).replace("'", "''") + "'"


class PackLoader(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        for editor, binary in EDITORS.items():
            version = subprocess.run([binary, "--version"], text=True,
                                     capture_output=True, check=True, timeout=15)
            print(f"{editor}: {version.stdout.splitlines()[0]}", flush=True)

    def run_editor(self, editor, scenario, files=None, after_enter=False, before_enter=""):
        with tempfile.TemporaryDirectory(prefix="pack-loader-") as directory:
            root = Path(directory)
            for name, content in (files or {}).items():
                target = root / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(content)
            result_file = root / "result"
            setup = f"""
set nomore noswapfile noundofile noloadplugins
let &runtimepath = $VIMRUNTIME
let &packpath = ''
let $MAIN_DIR = {quote(ROOT / 'conf.d/main')}
let $CFG_DIR = {quote(root / 'cfg')}
execute 'set rtp^=' . fnameescape({quote(ROOT / 'conf.d/init')})
execute 'set rtp^=' . fnameescape($MAIN_DIR)
execute 'set rtp^=' . fnameescape({quote(root / 'runtime')})
let g:test_root = {quote(root)}
let g:trace = []
let g:pack_specs = {{}}
let g:pack_order = []
let g:pack_lazy = {{}}
let g:pack_loaded = {{}}
let g:pack_pending = {{}}
call plug#begin(g:test_root . '/home')
function! TestFinish() abort
    call writefile(empty(v:errors) ? ['PASS'] : v:errors, {quote(result_file)})
    if !empty(v:errors) | cquit | endif
    qa!
endfunction
function! TestFailure() abort
    call writefile([v:exception, v:throwpoint] + v:errors, {quote(result_file)})
    cquit
endfunction
"""
            body = "try\n" + scenario + "\ncall TestFinish()\ncatch\ncall TestFailure()\nendtry\n"
            if after_enter:
                body = "function! TestScenario() abort\n" + body + "endfunction\nautocmd VimEnter * ++once call TestScenario()\n"
            command = [EDITORS[editor]] + (["--headless", "-u", "NONE"] if editor == "nvim"
                                          else ["-Nu", "NONE", "-es"])
            command += ["-i", "NONE", "-n", "-S", "/dev/stdin"]
            result = subprocess.run(command, input=setup + before_enter + body, text=True,
                                    capture_output=True, timeout=15, cwd=ROOT)
            evidence = result_file.read_text() if result_file.exists() else "NO RESULT"
            self.assertEqual((result.returncode, evidence), (0, "PASS\n"),
                             f"{editor}: {evidence}\n{result.stdout}\n{result.stderr}")
            print(f"  {editor}: PASS {self._testMethodName}"
                  f" ({'after' if after_enter else 'before'} VimEnter)", flush=True)

    def test_dependency_forms_and_registration_copy(self):
        for editor in EDITORS:
            for deps in ("'dep'", "['dep']"):
                with self.subTest(editor=editor, deps=deps):
                    self.run_editor(editor, """
let options = {'on': [], 'deps': DEPS}
call pack#declare(g:test_root . '/dep', {'on': []})
call pack#declare(g:test_root . '/extra', {'on': []})
call pack#declare(g:test_root . '/main', options)
call pack#register('main', {'deps': ['dep', 'extra']})
call assert_equal({'on': [], 'deps': DEPS}, options)
call pack#end()
call assert_true(pack#load('main'))
call assert_equal(['dep', 'extra', 'main'], g:trace)
call assert_true(pack#loaded('dep'))
call assert_true(pack#loaded('extra'))
call assert_true(pack#loaded('main'))
""".replace('DEPS', deps), {
    "dep/plugin/dep.vim": "call add(g:trace, 'dep')\n",
    "extra/plugin/extra.vim": "call add(g:trace, 'extra')\n",
    "main/plugin/main.vim": "call add(g:trace, 'main')\n"})

    def test_missing_dependency_retry(self):
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
call pack#declare(g:test_root . '/dep', {'on': []})
call pack#declare(g:test_root . '/main', {'on': [], 'deps': 'dep', 'vim': 'probe'})
call pack#end()
call assert_false(pack#load_raw('main'))
call assert_false(pack#load('main'))
call assert_false(pack#source_vim('probe'))
call assert_false(pack#vim_sourced('probe'))
call assert_false(pack#loaded('main'))
call assert_equal([], g:trace)
call mkdir(g:test_root . '/dep/plugin', 'p')
call writefile(["call add(g:trace, 'dep')"], g:test_root . '/dep/plugin/dep.vim')
call assert_true(pack#load('main'))
call assert_equal(['dep', 'vim', 'main'], g:trace)
call assert_true(pack#loaded('dep'))
call assert_true(pack#loaded('main'))
""", {"main/plugin/main.vim": "call add(g:trace, 'main')\n",
      "cfg/probe.vim": "call add(g:trace, 'vim')\n"})

    def test_shared_group_retry_keeps_ready_init(self):
        self.run_editor("nvim", """
call pack#declare(g:test_root . '/b', {'on': [], 'deps': 'a', 'lua': 'shared', 'init': "vim.cmd([[call add(g:trace, 'init-b')]])"})
call pack#declare(g:test_root . '/a', {'on': [], 'init': "vim.cmd([[call add(g:trace, 'init-a')]])", 'lua': 'shared'})
call pack#end()
lua assert(not require('pack').load_request('a'))
lua assert(require('pack').status().node_state.a == 'ready')
call assert_equal(['a', 'init-a'], g:trace)
call mkdir(g:test_root . '/b/plugin', 'p')
call writefile(["call add(g:trace, 'b')"], g:test_root . '/b/plugin/b.vim')
call pack#load('b')
lua local s = require('pack').status(); assert(s.node_state.a == 'done' and s.node_state.b == 'done' and s.group_state.shared == 'done')
call pack#load('a')
call pack#load('b')
call assert_equal(['a', 'init-a', 'b', 'init-b', 'cfg'], g:trace)
""", {
    "a/plugin/a.vim": "call add(g:trace, 'a')\n",
    "runtime/lua/shared.lua": "vim.cmd([[call add(g:trace, 'cfg')]])\n"})

    def test_failed_chunks_are_terminal(self):
        for kind in ("init", "lua"):
            with self.subTest(kind=kind):
                self.run_editor("nvim", """
" Observe expected error notifications without turning them into Vimscript exceptions.
lua probe_errors = {}; vim.notify = function(message) probe_errors[#probe_errors + 1] = message; vim.api.nvim_out_write(message .. '\\n') end
call pack#declare(g:test_root . '/bad', {'on': [], BINDING})
call pack#end()
call assert_false(pack#load('bad'))
call assert_false(pack#load('bad'))
lua assert(require('pack').status().node_state.bad == 'failed')
call assert_equal(['bad', 'attempt'], g:trace)
lua assert(#probe_errors == 1 and probe_errors[1]:find('probe-FAILURE-failure', 1, true))
""".replace('BINDING', "'init': \"vim.cmd([[call add(g:trace, 'attempt')]]); error('probe-init-failure')\""
            if kind == "init" else "'lua': 'badcfg'").replace('FAILURE', 'init' if kind == 'init' else 'cfg') + (
    "\nlua assert(require('pack').status().group_state.badcfg == 'failed')"
    if kind == "lua" else ""), {
    "bad/plugin/bad.vim": "call add(g:trace, 'bad')\n",
    "runtime/lua/badcfg.lua": "vim.cmd([[call add(g:trace, 'attempt')]]); error('probe-cfg-failure')\n"})

    def test_dependency_and_cross_group_cycles(self):
        cases = [
            ("{'deps': 'b'}", "{'deps': 'a'}", "{}", "dependency cycle"),
            ("{'deps': 'b', 'lua': 'x'}", "{'lua': 'y'}",
             "{'deps': 'a', 'lua': 'y'}", "cross-cfg init cycle"),
        ]
        for a, b, c, error in cases:
            with self.subTest(error=error):
                self.run_editor("nvim", """
call pack#declare(g:test_root . '/a', A)
call pack#declare(g:test_root . '/b', B)
call pack#declare(g:test_root . '/c', C)
try
    call pack#end()
    call assert_report('cycle was accepted')
catch
    call assert_match('EXPECTED', v:exception)
endtry
""".replace(" A)", " " + a + ")").replace(" B)", " " + b + ")")
   .replace(" C)", " " + c + ")").replace('EXPECTED', error))

    def test_direct_init_reentry(self):
        self.run_editor("nvim", """
lua probe_errors = {}; vim.notify = function(message) probe_errors[#probe_errors + 1] = message; vim.api.nvim_out_write(message .. '\\n') end
call pack#declare(g:test_root . '/a', {'on': [], 'init': "require('pack').load_request('a')"})
call pack#end()
call assert_false(pack#load('a'))
lua assert(require('pack').status().node_state.a == 'failed')
lua assert(#probe_errors == 1 and probe_errors[1]:find('initialization re-entry: a', 1, true))
""", {"a/plugin/a.vim": "call add(g:trace, 'a')\n"})

    def test_missing_command_proxy_retry_and_replay(self):
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
call pack#declare(g:test_root . '/cmd', {'on': 'ProbeCommand'})
call pack#end()
ProbeCommand first
call assert_equal([], g:trace)
call assert_equal(2, exists(':ProbeCommand'))
call assert_false(pack#load('cmd'))
call mkdir(g:test_root . '/cmd/plugin', 'p')
call writefile(['command -nargs=* -range -bang ProbeCommand call add(g:trace, [<q-bang>, <line1>, <line2>, <q-args>, <q-mods>])'], g:test_root . '/cmd/plugin/cmd.vim')
call setline(1, ['one', 'two'])
silent 1,2ProbeCommand! hello world
call assert_equal([['!', 1, 2, 'hello world', 'silent']], g:trace)
call assert_true(pack#loaded('cmd'))
""")

    def test_request_batch_attempts_every_name(self):
        self.run_editor("nvim", """
call pack#declare(g:test_root . '/missing', {'on': []})
call pack#declare(g:test_root . '/ok', {'on': []})
call pack#end()
lua assert(not require('pack').load_request({'missing', 'ok'}))
lua assert(require('pack').load_request({}))
call assert_equal(['ok'], g:trace)
lua local ok, e = pcall(require('pack').load_request, 'unknown'); assert(not ok and e:find('unknown plugin request', 1, true))
lua local ok, e = pcall(require('pack').load_request, 42); assert(not ok and e:find('load request must be', 1, true))
""", {"ok/plugin/ok.vim": "call add(g:trace, 'ok')\n"})

    def test_command_proxy_exception_restores_only_when_absent(self):
        for real_command in (False, True):
            with self.subTest(real_command=real_command):
                self.run_editor("nvim", """
call pack#declare(g:test_root . '/bad', {'on': 'ProbeCommand', 'init': "error('probe-init-failure')"})
call pack#end()
try
    ProbeCommand
    call assert_report('expected init notification exception')
catch
    call assert_match('probe-init-failure', v:exception)
endtry
call assert_equal(2, exists(':ProbeCommand'))
CHECK
""".replace("CHECK", "ProbeCommand\ncall assert_equal(['real'], g:trace)"
            if real_command else "call assert_match('pack#lod_cmd', execute('command ProbeCommand'))"), {
    "bad/plugin/bad.vim": "command ProbeCommand call add(g:trace, 'real')\n" if real_command else "\" No command defined before init fails.\n"})

    def test_native_filetype_and_scheduler_loading(self):
        for after_enter in (False, True):
            for trigger in ("set ft=probeft", "call assert_true(pack#load('native'))"):
                with self.subTest(after_enter=after_enter, trigger=trigger):
                    self.run_editor("nvim", """
call assert_equal(ENTERED, v:vim_did_enter)
call pack#declare(g:test_root . '/dep', {'on': []})
call pack#declare(g:test_root . '/native', {'for': 'probeft', 'deps': 'dep', 'init': "vim.cmd([[call add(g:trace, 'init')]])", 'lua': 'nativecfg'})
call pack#end()
TRIGGER
call assert_equal(2, exists(':ProbeNative'))
call assert_equal(2, exists(':ProbeConfigured'))
ProbeConfigured
call assert_equal(1, b:configured)
call assert_true(pack#loaded('dep'))
call assert_true(pack#loaded('native'))
call assert_equal(1, count(g:trace, 'native'))
set ft=probeft
doautocmd FileType probeft
call assert_equal(1, count(g:trace, 'dep'))
call assert_equal(1, count(g:trace, 'init'))
call assert_equal(1, count(g:trace, 'cfg'))
lua assert(require('pack').status().node_state.native == 'done')
""".replace('ENTERED', str(int(after_enter))).replace('TRIGGER', trigger), {
    "dep/plugin/dep.vim": "call add(g:trace, 'dep')\n",
    "native/plugin/native.vim": "call add(g:trace, 'native')\ncommand ProbeNative echo 'native'\n",
    "runtime/lua/nativecfg.lua": """vim.cmd([[call add(g:trace, 'cfg')]])
vim.api.nvim_buf_create_user_command(0, 'ProbeConfigured', function()
  vim.b.configured = (vim.b.configured or 0) + 1
end, {})
"""}, after_enter=after_enter)

    def test_prepare_queues_native_events_until_finish(self):
        self.run_editor("nvim", """
lua local ok, e = pcall(require('pack').finish); assert(not ok and e == 'pack.lua: finish before prepare')
call pack#declare(g:test_root . '/a', {'for': 'pa', 'lua': 'queued_a', 'init': "vim.cmd([[call add(g:trace, 'init-a')]])"})
call pack#declare(g:test_root . '/b', {'for': 'pb', 'lua': 'queued_b', 'init': "vim.cmd([[call add(g:trace, 'init-b')]])"})
lua require('pack').prepare(); require('pack').prepare()
call plug#end()
call plug#load('b')
call plug#load('a')
doautocmd User b
doautocmd User unrelated
call assert_equal(['b', 'a'], g:trace)
lua assert(not require('pack').status().finished)
lua require('pack').finish(); require('pack').finish()
call assert_equal(['b', 'a', 'init-b', 'cfg-b', 'init-a', 'cfg-a'], g:trace)
""", {"a/plugin/a.vim": "call add(g:trace, 'a')\n",
      "b/plugin/b.vim": "call add(g:trace, 'b')\n",
      "runtime/lua/queued_a.lua": "vim.cmd([[call add(g:trace, 'cfg-a')]])\n",
      "runtime/lua/queued_b.lua": "vim.cmd([[call add(g:trace, 'cfg-b')]])\n"})

    def test_native_pending_node_retries(self):
        self.run_editor("nvim", """
call pack#declare(g:test_root . '/dep', {'on': []})
call pack#declare(g:test_root . '/native', {'for': 'probeft', 'deps': 'dep', 'init': "vim.cmd([[call add(g:trace, 'init')]])"})
call pack#end()
set ft=probeft
lua assert(require('pack').status().node_state.native == 'pending')
call assert_equal(['native'], g:trace)
call mkdir(g:test_root . '/dep/plugin', 'p')
call writefile(["call add(g:trace, 'dep')"], g:test_root . '/dep/plugin/dep.vim')
doautocmd User native
call assert_equal(['native', 'dep', 'init'], g:trace)
lua assert(require('pack').status().node_state.native == 'done')
""", {"native/plugin/native.vim": "call add(g:trace, 'native')\n"})

    def test_reset_replaces_startup_and_native_callbacks(self):
        self.run_editor("nvim", """
call assert_equal(1, v:vim_did_enter)
doautocmd User old
call assert_equal(['new-init', 'new-cfg'], g:trace)
lua assert(require('pack').status().node_state.old == nil)
""", {
    "old/plugin/old.vim": "\" Installed old plugin.\n",
    "old_eager/plugin/old.vim": "\" Installed old startup member.\n",
    "new/plugin/new.vim": "\" Installed new plugin.\n",
    "runtime/lua/newcfg.lua": "vim.cmd([[call add(g:trace, 'new-cfg')]])\n",
}, after_enter=True, before_enter="""
call pack#declare(g:test_root . '/old', {'for': 'oldft', 'init': "error('stale-native-callback')"})
call pack#declare(g:test_root . '/old_eager', {'lua': 'oldcfg', 'init': "error('stale-startup-callback')"})
call pack#end()
lua require('pack').reset()
let g:pack_specs = {}
let g:pack_order = []
let g:pack_lazy = {}
let g:pack_loaded = {}
let g:pack_pending = {}
call plug#begin(g:test_root . '/home2')
call pack#declare(g:test_root . '/new', {'init': "vim.cmd([[call add(g:trace, 'new-init')]])", 'lua': 'newcfg'})
call pack#end()
""")

    def test_vim_config_precedes_native_script(self):
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
call pack#declare(g:test_root . '/native', {'for': 'probeft', 'vim': 'probe'})
call pack#end()
set ft=probeft
call assert_equal(['cfg', 42], g:trace)
doautocmd FileType probeft
call assert_equal(['cfg', 42], g:trace)
""", {"native/plugin/native.vim": "call add(g:trace, get(g:, 'probe_value', -1))\n",
      "cfg/probe.vim": "let g:probe_value = 42\ncall add(g:trace, 'cfg')\n"})

    def test_mixed_eager_filetype_group_keeps_whole_group_startup(self):
        self.run_editor("nvim", """
lua local s = require('pack').status(); assert(s.node_state.eager == 'done' and s.node_state.lazy == 'done' and s.group_state.mixed == 'done')
call assert_equal(['eager-init', 'lazy', 'lazy-init', 'cfg'], g:trace)
set ft=probeft
call assert_true(pack#load(['eager', 'lazy']))
call assert_equal(1, count(g:trace, 'eager-init'))
call assert_equal(1, count(g:trace, 'lazy-init'))
call assert_equal(1, count(g:trace, 'cfg'))
""", {
    "eager/plugin/eager.vim": "\" Installed eager member.\n",
    "lazy/plugin/lazy.vim": "call add(g:trace, 'lazy')\n",
    "runtime/lua/mixed.lua": "vim.cmd([[call add(g:trace, 'cfg')]])\n",
}, after_enter=True, before_enter="""
call pack#declare(g:test_root . '/eager', {'lua': 'mixed', 'init': "vim.cmd([[call add(g:trace, 'eager-init')]])"})
call pack#declare(g:test_root . '/lazy', {'for': 'probeft', 'deps': 'eager', 'lua': 'mixed', 'init': "vim.cmd([[call add(g:trace, 'lazy-init')]])"})
call pack#end()
""")

    def test_transitive_dependency_failure_blocks_scripts_and_vim_config(self):
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
call pack#declare(g:test_root . '/leaf', {'on': []})
call pack#declare(g:test_root . '/dep', {'on': [], 'deps': 'leaf'})
call pack#declare(g:test_root . '/main', {'on': [], 'deps': 'dep', 'vim': 'probe'})
call pack#end()
call assert_false(pack#load('main'))
call assert_false(pack#source_vim('probe'))
call assert_false(pack#loaded('dep'))
call assert_false(pack#loaded('main'))
call assert_false(pack#vim_sourced('probe'))
call assert_equal([], g:trace)
call mkdir(g:test_root . '/leaf/plugin', 'p')
call writefile(["call add(g:trace, 'leaf')"], g:test_root . '/leaf/plugin/leaf.vim')
call assert_true(pack#load('main'))
call assert_equal(['leaf', 'dep', 'cfg', 'main'], g:trace)
""", {"dep/plugin/dep.vim": "call add(g:trace, 'dep')\n",
      "main/plugin/main.vim": "call add(g:trace, 'main')\n",
      "cfg/probe.vim": "call add(g:trace, 'cfg')\n"})

    def test_debug_vimspector_dap_groups_source_real_cfg(self):
        "Step 1: plugin/debug.vim split into cfg/vimspector.vim + cfg/dap.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        user_opt = Path.home() / '.leovim.d' / 'pack' / 'add' / 'opt'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                for name in ('vimspector', 'nvim-dap', 'nvim-dap-ui', 'nvim-nio',
                             'mason.nvim', 'mason-nvim-dap.nvim'):
                    self.assertTrue((user_opt / name).is_dir(), f"missing {name}")
                self.run_editor(editor, """
let g:has_terminal = 1
let $CFG_DIR = REAL_CFG
call pack#declare(g:test_root . '/fzf', {'on': []})
call pack#declare(g:test_root . '/fzf.vim', {'on': []})
call pack#declare(g:test_root . '/vim-signify', {'on': []})
call pack#declare(OPT . '/vimspector', {'on': [], 'vim': 'vimspector'})
call pack#declare(OPT . '/nvim-dap', {'on': [], 'vim': 'dap'})
call pack#declare(OPT . '/nvim-dap-ui', {'on': [], 'deps': ['nvim-dap', 'nvim-nio']})
call pack#declare(OPT . '/nvim-nio', {'on': []})
call pack#declare(OPT . '/mason.nvim', {'on': []})
call pack#declare(OPT . '/mason-nvim-dap.nvim', {'on': [], 'deps': ['nvim-dap', 'mason.nvim']})
call pack#end()
call assert_true(pack#source_vim('vimspector'))
call assert_true(pack#source_vim('dap'))
call assert_true(pack#vim_sourced('vimspector'))
call assert_true(pack#vim_sourced('dap'))
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/debug.vim')
call assert_equal('vimspector', g:debug_tool)
call assert_equal(2, exists(':LoadVimspector'))
call assert_equal(2, exists(':LoadDap'))
call assert_true(exists('*debug#load_json'))
call assert_true(exists('*debug#watch'))
call assert_true(exists('*debug#vimspector_opened'))
call assert_true(exists('*debug#dapui_opened'))
call assert_notequal('', maparg('<M-e><Cr>', 'n'))
call assert_true(exists('#BufEnter'))
call assert_match('debug#vimspector_opened', execute('au BufEnter'))
call assert_equal(0, debug#vimspector_opened())
""".replace('REAL_CFG', quote(real_cfg)).replace('OPT', quote(user_opt)))

    def test_asynctasks_cfg_group_and_run_plugin_coordination(self):
        "Step 2: plugin/run.vim asynctasks block split into cfg/asynctasks.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
let g:root_patterns = ['.git']
let $CFG_DIR = REAL_CFG
call pack#declare(g:test_root . '/fzf', {'on': []})
call pack#declare(g:test_root . '/fzf.vim', {'on': []})
call pack#declare(g:test_root . '/asynctasks.vim', {'on': [], 'vim': 'asynctasks'})
call pack#end()
call assert_true(pack#source_vim('asynctasks'))
call assert_true(pack#vim_sourced('asynctasks'))
call assert_equal(2, exists(':AsyncTaskDeploy'))
call assert_equal(2, exists(':AsyncTaskProfileLoop'))
call assert_true(exists('*asynctasks#tasks_open'))
call assert_true(exists('*asynctasks#profile_loop'))
call assert_true(exists('*asynctasks#fzf_tasks'))
call assert_notequal('', maparg('<M-a>', 'n'))
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/run.vim')
call assert_equal(2, exists(':TaskRunOrRight'))
call assert_equal(2, exists(':RunQfBottom'))
""".replace('REAL_CFG', quote(real_cfg)), {
    "asynctasks.vim/plugin/asynctasks.vim": "\" asynctasks stub plugin.\n"})

    def test_gutentags_cfg_group_module_ordering(self):
        "Step 3: plugin/tags.vim gutentags params moved to cfg/gutentags.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
let g:ctags_type = 'Universal-json'
let g:root_patterns = ['.git']
let g:symbol_tool = 'vista-gutentags'
let $HOME = g:test_root . '/home'
let $CFG_DIR = REAL_CFG
call pack#declare(g:test_root . '/vim-gutentags', {'on': [], 'vim': 'gutentags'})
call pack#end()
call assert_true(pack#source_vim('gutentags'))
call assert_true(pack#vim_sourced('gutentags'))
call assert_true(exists('*gutentags#delete_tags'))
call assert_equal(2, exists(':GutentagsDelTagsAndUpdate'))
call assert_notequal('', maparg('<leader>g<Cr>', 'n'))
call assert_false(exists('g:gutentags_plus_native'))
call assert_equal(['ctags'], g:gutentags_modules)
call assert_true(stridx(g:gutentags_ctags_extra_args[0], '--fields') == 0)
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/tags.vim')
call assert_equal(['ctags'], g:gutentags_modules)
""".replace('REAL_CFG', quote(real_cfg)), {
    "vim-gutentags/plugin/gutentags.vim": "\" vim-gutentags stub plugin.\n"})

    def test_lightline_cfg_migration_and_buffer_nav_mapping(self):
        "Step 4: plugin/lightline.vim moved to cfg/lightline.vim, nav maps into buffer.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        clone_opt = ROOT / 'pack' / 'clone' / 'opt'
        fork_opt = ROOT / 'pack' / 'fork' / 'opt'
        self.assertFalse((ROOT / 'conf.d' / 'main' / 'plugin' / 'lightline.vim').exists())
        for editor in EDITORS:
            with self.subTest(editor=editor, group='installed'):
                self.run_editor(editor, """
let $CFG_DIR = REAL_CFG
call pack#declare(CLONE . '/lightline.vim', {'on': [], 'vim': 'lightline'})
call pack#declare(FORK . '/lightline-bufferline', {'on': []})
call pack#end()
call assert_true(pack#source_vim('lightline'))
call assert_true(pack#vim_sourced('lightline'))
call assert_true(exists('g:lightline'))
call assert_true(exists('*lightline#upgrade'))
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/buffer.vim')
call assert_equal('<Plug>lightline#bufferline#go_next()', maparg(';b', 'n'))
""".replace('REAL_CFG', quote(real_cfg)).replace('CLONE', quote(clone_opt)).replace('FORK', quote(fork_opt)))
            with self.subTest(editor=editor, group='missing'):
                self.run_editor(editor, """
let $CFG_DIR = REAL_CFG
call pack#declare(FORK . '/lightline-bufferline', {'on': []})
call pack#end()
call assert_false(pack#vim_sourced('lightline'))
call assert_false(exists('g:lightline'))
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/buffer.vim')
call assert_equal('', maparg(';b', 'n'))
""".replace('REAL_CFG', quote(real_cfg)).replace('FORK', quote(fork_opt)))

    def test_vista_cfg_group_params_and_plugin_mapping(self):
        "Step 5: plugin/tags.vim vista params moved to cfg/vista.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        fork_opt = ROOT / 'pack' / 'fork' / 'opt'
        for editor in EDITORS:
            with self.subTest(editor=editor, group='installed'):
                self.run_editor(editor, """
let g:ctags_type = 'Universal-json'
let g:root_patterns = ['.git']
let g:symbol_tool = 'vista-gutentags'
let $HOME = g:test_root . '/home'
let $CFG_DIR = REAL_CFG
call pack#declare(FORK . '/vista.vim', {'on': [], 'vim': 'vista'})
call pack#end()
call assert_true(pack#source_vim('vista'))
call assert_equal('kind', g:vista#renderer#ctags)
call assert_equal(35, g:vista_sidebar_width)
call assert_equal('ctags', g:vista_executive_for.go)
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/tags.vim')
call assert_notequal('', maparg('<Tab>v', 'n'))
""".replace('REAL_CFG', quote(real_cfg)).replace('FORK', quote(fork_opt)))
            with self.subTest(editor=editor, group='missing'):
                self.run_editor(editor, """
let g:ctags_type = 'Universal-json'
let g:root_patterns = ['.git']
let g:symbol_tool = 'vista-gutentags'
let $HOME = g:test_root . '/home'
let $CFG_DIR = REAL_CFG
call pack#end()
call assert_false(pack#vim_sourced('vista'))
call assert_false(exists('g:vista#renderer#ctags'))
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/tags.vim')
call assert_equal('', maparg('<Tab>v', 'n'))
""".replace('REAL_CFG', quote(real_cfg)))

    def test_startify_cfg_group_uses_temp_home(self):
        "Step 6: plugin/session.vim startify params moved to cfg/startify.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
let $HOME = g:test_root . '/home'
let $CFG_DIR = REAL_CFG
call pack#declare(g:test_root . '/vim-startify', {'on': [], 'vim': 'startify'})
call pack#end()
call assert_true(pack#source_vim('startify'))
call assert_true(pack#vim_sourced('startify'))
call assert_true(exists('g:startify_session_dir'))
call assert_true(stridx(g:startify_session_dir, g:test_root) == 0)
call assert_true(isdirectory(g:startify_session_dir))
call assert_true(exists('#User#Startified'))
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/session.vim')
call assert_notequal('', maparg('<leader>st', 'n'))
""".replace('REAL_CFG', quote(real_cfg)), {
    "vim-startify/plugin/startify.vim": "\" vim-startify stub plugin.\n"})

    def test_ale_cfg_group_params(self):
        "Step 7: plugin/diagnostic.vim ale params moved to cfg/ale.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
let g:has_popup_floating = 1
let $CFG_DIR = REAL_CFG
call pack#declare(g:test_root . '/ale', {'on': [], 'vim': 'ale'})
call pack#end()
call assert_true(pack#source_vim('ale'))
call assert_true(pack#vim_sourced('ale'))
call assert_equal('auto', g:ale_disable_lsp)
call assert_equal(['cargo'], g:ale_linters.rust)
call assert_equal(1, g:ale_virtualtext_cursor)
call assert_true(stridx(g:ale_python_flake8_options, '--ignore=E101,E302') >= 0)
call assert_true(stridx(g:ale_python_flake8_options, 'F403') >= 0)
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/diagnostic.vim')
call assert_equal(2, exists(':ALECommands'))
""".replace('REAL_CFG', quote(real_cfg)), {
    "ale/plugin/ale.vim": "\" dense-analysis/ale stub plugin.\n"})

    def test_zfdirdiff_help_opens_config_without_search(self):
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        clone_opt = ROOT / 'pack' / 'clone' / 'opt'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, r"""
let $CFG_DIR = REAL_CFG
call pack#declare(CLONE . '/ZFVimDirDiff', {'on': [], 'vim': 'zfdirdiff'})
call pack#end()
call pack#load('ZFVimDirDiff')
new
setfiletype ZFDirDiff
let @/ = 'unchanged-search-pattern'
let previous_tabs = tabpagenr('$')
call feedkeys("\<F1>", 'xt')
call assert_equal(previous_tabs + 1, tabpagenr('$'))
call assert_equal(fnamemodify($CFG_DIR . '/zfdirdiff.vim', ':p'), expand('%:p'))
call assert_equal('unchanged-search-pattern', @/)
""".replace('REAL_CFG', quote(real_cfg)).replace('CLONE', quote(clone_opt)))

    def test_floaterm_cfg_group_and_bootstrap_keys(self):
        "Step 9: plugin/terminal.vim floaterm params moved to cfg/floaterm.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        fork_opt = ROOT / 'pack' / 'fork' / 'opt'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
let g:has_terminal = 1
let g:has_popup_floating = 1
let $CFG_DIR = REAL_CFG
call pack#declare(FORK . '/vim-floaterm', {'on': '^Floaterm.*$', 'vim': 'floaterm'})
call pack#end()
call assert_true(pack#source_vim('floaterm'))
call assert_true(pack#vim_sourced('floaterm'))
call assert_equal('split', g:floaterm_wintype)
call assert_equal(' --wintype=vsplit --width=0.382', g:floaterm#parameters.right)
call assert_equal(2, exists(':FloatermOpenPos'))
call assert_true(exists('*floaterm#select_pos'))
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/terminal.vim')
call assert_notequal('', maparg('<M-->', 'n'))
call assert_equal(2, exists(':TermNewOrFzfList'))
""".replace('REAL_CFG', quote(real_cfg)).replace('FORK', quote(fork_opt)))

    def test_quickui_cfg_group_params(self):
        "Step 10: plugin/basic.vim quickui params moved to cfg/quickui.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        clone_opt = ROOT / 'pack' / 'clone' / 'opt'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
let $CFG_DIR = REAL_CFG
call pack#declare(CLONE . '/vim-quickui', {'on': [], 'vim': 'quickui'})
call pack#end()
call assert_true(pack#source_vim('quickui'))
call assert_true(pack#vim_sourced('quickui'))
call assert_equal(2, g:quickui_border_style)
call assert_true(exists('*quickui#preview_popup_file'))
call assert_equal(2, exists(':PreviewPopupFile'))
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/basic.vim')
call assert_notequal('', maparg('<M-k>m', 'n'))
call assert_notequal('', maparg('\o', 'n'))
""".replace('REAL_CFG', quote(real_cfg)).replace('CLONE', quote(clone_opt)))

    def test_coc_cfg_absorbs_diagnostic_block(self):
        "Coc diagnostics block moved from plugin/diagnostic.vim into cfg/coc.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
let g:lint_tool = 'coc'
let g:root_patterns = ['.git']
let g:clangd_exe = ''
let g:R_exe = ''
let g:cargo_exe = ''
let g:gobin_exe = ''
let g:packs = []
let g:has_popup_floating = 1
let $CFG_DIR = REAL_CFG
call pack#declare(g:test_root . '/coc.nvim', {'on': [], 'vim': 'coc'})
call pack#declare(g:test_root . '/coc-fzf', {'on': [], 'deps': 'coc.nvim', 'vim': 'coc'})
call pack#declare(g:test_root . '/ale', {'on': [], 'vim': 'ale'})
call pack#end()
call assert_true(pack#source_vim('coc'))
call assert_true(pack#vim_sourced('coc'))
call assert_equal(v:false, g:diagnostic_virtualtext_underline)
call assert_equal(2, exists(':ToggleDiagnosticsHighLight'))
call assert_equal(2, exists(':Diagnostics'))
call assert_equal(2, exists(':CocDiagnosticToggleBuffer'))
call assert_match('CocDiagnosticsHighlight', execute('au ColorScheme'))
call assert_match('coc#config', execute('au SourcePost'))
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/diagnostic.vim')
call assert_true(pack#source_vim('ale'))
call assert_equal(2, exists(':ALECommands'))
""".replace('REAL_CFG', quote(real_cfg)), {
    "coc.nvim/plugin/coc.vim": "\" coc.nvim stub plugin.\n",
    "coc-fzf/plugin/coc-fzf.vim": "\" coc-fzf stub plugin.\n",
    "ale/plugin/ale.vim": "\" dense-analysis/ale stub plugin.\n"})

    def test_search_fzf_leaderf_blocks_moved_to_cfg(self):
        "search.vim fzf/LeaderF blocks moved into cfg/fzf.vim and cfg/leaderf.vim."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        for editor in EDITORS:
            with self.subTest(editor=editor):
                self.run_editor(editor, """
let g:root_patterns = ['.git']
let g:python_version = 3.10
let g:has_popup_floating = 1
let $CFG_DIR = REAL_CFG
call pack#declare(g:test_root . '/fzf', {'on': [], 'vim': 'fzf'})
call pack#declare(g:test_root . '/fzf.vim', {'on': [], 'deps': 'fzf', 'vim': 'fzf'})
call pack#declare(g:test_root . '/LeaderF', {'on': [], 'vim': 'leaderf'})
call pack#end()
call assert_true(pack#source_vim('fzf'))
call assert_true(pack#source_vim('leaderf'))
call assert_true(pack#vim_sourced('fzf'))
call assert_true(pack#vim_sourced('leaderf'))
call assert_equal(2, exists(':FzfSearchAll'))
call assert_equal(2, exists(':FzfSearchGit'))
call assert_equal(2, exists(':LeaderfSearchAll'))
call assert_equal(2, exists(':LeaderfTODO'))
call assert_notequal('', maparg('<C-f><Cr>', 'n'))
if executable('rg')
    call assert_equal('LeaderfSearchAll', g:search_all_cmd)
endif
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/search.vim')
call assert_equal('leaderf-fzf-grep', g:search_tool)
call assert_notequal('', maparg('<M-l><M-l>', 'n'))
call assert_notequal('', maparg('<leader>/', 'n'))
call assert_notequal('', maparg('<Tab>/', 'n'))
call assert_notequal('', maparg('\?', 'n'))
call assert_notequal('', maparg('<leader>f/', 'n'))
""".replace('REAL_CFG', quote(real_cfg)), {
    "fzf/plugin/fzf.vim": "\" fzf stub plugin.\n",
    "fzf.vim/plugin/fzf.vim": "\" fzf.vim stub plugin.\n",
    "LeaderF/plugin/LeaderF.vim": "\" LeaderF stub plugin.\n"})

    def test_snippet_keys_are_smap_only(self):
        "Snippet jump keys bind in select mode only; blink/cmp integrate vsnip in their cfgs."
        real_cfg = ROOT / 'conf.d' / 'main' / 'cfg'
        self.assertFalse((ROOT / 'conf.d' / 'main' / 'plugin' / 'complete.vim').read_text().find('s:blink_snippets') >= 0)
        self.assertTrue('preset = \'vsnip\'' in (ROOT / 'conf.d' / 'main' / 'lua' / 'cfg' / 'blink.lua').read_text())
        for editor in EDITORS:
            with self.subTest(editor=editor, group='vsnip'):
                self.run_editor(editor, """
let $CFG_DIR = REAL_CFG
call pack#declare(g:test_root . '/vim-vsnip', {'on': []})
call pack#end()
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/complete.vim')
call assert_notequal('', maparg('<C-f>', 's'))
call assert_notequal('', maparg('<C-b>', 's'))
call assert_equal('', maparg('<C-f>', 'i'))
call assert_equal('', maparg('<C-b>', 'i'))
call assert_notequal('', maparg('<M-h>n', 'n'))
""".replace('REAL_CFG', quote(real_cfg)), {
    "vim-vsnip/plugin/vsnip.vim": "\" vim-vsnip stub plugin.\n"})
            with self.subTest(editor=editor, group='gate'):
                self.run_editor(editor, """
let $CFG_DIR = REAL_CFG
call pack#end()
execute 'source ' . fnameescape($MAIN_DIR . '/plugin/complete.vim')
call assert_equal('', maparg('<C-f>', 's'))
call assert_equal('', maparg('<M-h>n', 'n'))
""".replace('REAL_CFG', quote(real_cfg)))

    def test_invalid_dependency_shapes_are_rejected(self):
        for editor in EDITORS:
            for invalid in ("42", "{}"):
                with self.subTest(editor=editor, invalid=invalid):
                    self.run_editor(editor, """
try
    call pack#declare(g:test_root . '/main', {'deps': INVALID})
    call assert_report('invalid dependency shape was accepted')
catch
    call assert_match('deps must be a string or list of strings', v:exception)
endtry
""".replace('INVALID', invalid))


if __name__ == "__main__":
    unittest.main(verbosity=2)
