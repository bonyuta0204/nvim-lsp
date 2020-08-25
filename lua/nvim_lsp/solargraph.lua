local configs = require 'nvim_lsp/configs'
local util = require 'nvim_lsp/util'
local server_name = "solargraph"
local bin_name = "solargraph"

local vim=vim
local api = vim.api

local function make_installer()
  local install_dir = util.path.join{util.base_install_dir, server_name}
  local solargraph_bin_dir = util.path.join(install_dir, "bin")
  local solargraph_bin = util.path.join{solargraph_bin_dir, bin_name}

  local X = {}
  function X.install()
    local install_info = X.info()
    if install_info.is_installed then
      print(server_name, "is already installed")
      return
    end

    if not (util.has_bins("gem")) then
      api.nvim_err_writeln('Installation requires "gem"')
    end

    local script = string.format("gem install --install-dir %s --bindir %s %s", install_dir, solargraph_bin_dir, bin_name)

    print(script)
    util.sh(script, vim.loop.os_homedir())
  end

  function X.info()
    return {
      is_installed = util.has_bins(solargraph_bin);
      install_dir = install_dir;
      cmd = { solargraph_bin };
    }
  end

  return X
end


local installer = make_installer()

if vim.fn.has('win32') == 1 then
  bin_name = bin_name..'.bat'
end
configs.solargraph = {
  default_config = {
    cmd = {bin_name, "stdio"};
    filetypes = {"ruby"};
    root_dir = util.root_pattern("Gemfile", ".git");
  };
  docs = {
    package_json = "https://raw.githubusercontent.com/castwide/vscode-solargraph/master/package.json";
    description = [[
https://solargraph.org/

solargraph, a language server for Ruby

You can install solargraph via gem install.

```sh
gem install solargraph
```
    ]];
    default_config = {
      root_dir = [[root_pattern("Gemfile", ".git")]];
    };
  };
};

configs[server_name].install      = installer.install
configs[server_name].install_info = installer.info
-- vim:et ts=2 sw=2
