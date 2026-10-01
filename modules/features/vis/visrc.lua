-- load standard vis module, providing parts of the Lua API
require('vis')

-- vis ships no lexers for these, so without an entry the window has no
-- syntax and vis-lspc never starts a server for it.
vis.ftdetect.filetypes.nix = { ext = { '%.nix$' } }
vis.ftdetect.filetypes.odin = { ext = { '%.odin$' } }

local lspc = require('plugins/vis-lspc')

-- Keyed by vis syntax name; the servers are on the wrapper's PATH.
lspc.ls_map.nix = { name = 'nixd', cmd = 'nixd', roots = { 'flake.nix' } }
lspc.ls_map.rust = { name = 'rust-analyzer', cmd = 'rust-analyzer', roots = { 'Cargo.toml' } }
lspc.ls_map.csharp = { name = 'csharp-ls', cmd = 'csharp-ls' }
lspc.ls_map.sql = { name = 'sqls', cmd = 'sqls' }
lspc.ls_map.odin = { name = 'ols', cmd = 'ols', roots = { 'ols.json' } }
lspc.ls_map.python = {
	name = 'basedpyright',
	cmd = 'basedpyright-langserver --stdio',
	roots = { 'pyproject.toml', 'setup.py', 'requirements.txt' },
}

vis.events.subscribe(vis.events.INIT, function()
	-- Your global configuration options
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win) -- luacheck: no unused args
	-- Your per window configuration options e.g.
	-- vis:command('set number')
end)
