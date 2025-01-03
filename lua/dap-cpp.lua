local dap = require('dap')

local M = {}

local function notify(msg, levels, opts)
  vim.schedule(function()
    vim.notify(msg, levels, opts)
  end)
end

---@class CppDapConfiguration : dap.Configuration
---@field build string[]
---@field args? string[]
---@field stdin? string|string[]

---@class PluginConfiguration
---@field codelldb table<string,string>
---@field dap_configurations CppDapConfiguration

---@type PluginConfiguration
---@diagnostic disable-next-line
local internal_global_config = {}

local default_config = {
  codelldb = {
    path = vim.fn.stdpath('data') .. '/nvim-dap-cpp.nvim/extension/adapter/codelldb',
  },
  dap_configurations = {},
}

local function codelldb_path()
  return internal_global_config.codelldb.path
end

-- https://github.com/leoluz/nvim-dap-go/blob/5511788255c92bdd845f8d9690f88e2e0f0ff9f2/lua/dap-go.lua#L34-L42
---@param prompt string
local function ui_input_list(prompt)
  return coroutine.create(function(dap_run_co)
    local args = {}
    vim.ui.input({ prompt = prompt }, function(input)
      args = vim.split(input or '', ' ')
      coroutine.resume(dap_run_co, args)
    end)
  end)
end

local function ui_input(prompt)
  return coroutine.create(function(dap_run_co)
    vim.ui.input({ prompt = prompt }, function(input)
      coroutine.resume(dap_run_co, input)
    end)
  end)
end

local function get_arguments()
  return ui_input_list('Args: ')
end

local function get_stdio()
  local stdio = { nil, nil, nil }

  local stdin = ui_input('stdin: ')
  if stdin ~= '' then
    stdio[1] = stdin
  end
  local stdout = ui_input('stdout: ')
  if stdin ~= '' then
    stdio[2] = stdout
  end
  local stderr = ui_input('stderr: ')
  if stdin ~= '' then
    stdio[3] = stderr
  end

  return stdio
end

local function default_build()
  if vim.bo.filetype == 'cpp' then
    return { 'g++', '-ggdb3', '-O0', vim.fn.expand('%'), '-o', vim.fn.expand('%:r') }
  elseif vim.bo.filetype == 'c' then
    return { 'gcc', '-ggdb3', '-O0', vim.fn.expand('%'), '-o', vim.fn.expand('%:r') }
  end
end

local function setup_adapter()
  dap.adapters.lldb = { -- for vscode cpp debug
    id = 'lldb',
    type = 'executable',
    command = codelldb_path(),

    ---@param config CppDapConfiguration
    ---@param on_config fun(CppDapConfiguration)
    enrich_config = function(config, on_config)
      local final_config = vim.deepcopy(config)
      if config.build ~= nil then
        local build_command = config.build == "default" and default_build() or config.build
        vim.system(build_command, { text = true }, function(out)
          if out.code ~= 0 then
            notify(out.stderr, vim.log.levels.ERROR)
            return
          end
          vim.schedule(function()
            on_config(final_config)
          end)
        end)
      end
    end,
  }
end

---@param plugin_config PluginConfiguration
local function setup_dap_configurations(plugin_config)
  dap.configurations.cpp = dap.configurations.cpp or {}
  local common_configurations = {
    {
      name = 'Build and debug active file',
      type = 'lldb',
      request = 'launch',
      program = '${fileDirname}/${fileBasenameNoExtension}',
      build = nil,
      cwd = '${fileDirname}',
    },
    {
      name = 'Build and debug active file with arguments',
      type = 'lldb',
      request = 'launch',
      program = '${fileDirname}/${fileBasenameNoExtension}',
      cwd = '${fileDirname}',
      build = nil,
      args = get_arguments,
    },
    {
      name = 'Build and debug active file with stdio and args',
      type = 'lldb',
      request = 'launch',
      program = '${fileDirname}/${fileBasenameNoExtension}',
      cwd = '${fileDirname}',
      build = nil,
      args = get_arguments,
      stdio = get_stdio,
    },
  }

  vim.list_extend(dap.configurations.cpp, common_configurations)
  vim.list_extend(dap.configurations.cpp, plugin_config.dap_configurations)

  dap.configurations.c = dap.configurations.c or {}
  vim.list_extend(dap.configurations.c, dap.configurations.cpp)
end

---@param opts PluginConfiguration
function M.setup(opts)
  internal_global_config = vim.tbl_deep_extend('force', default_config, opts or {})
  setup_adapter()
  setup_dap_configurations(internal_global_config)
end

---@return PluginConfiguration
function M.get_config()
  return internal_global_config
end

return M
