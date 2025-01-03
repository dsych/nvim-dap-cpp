vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.wo.number = true

vim.g.mapleader = ','
vim.g.maplocalleader = ','
vim.o.shell = 'bash'

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'neanias/everforest-nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('everforest').setup()
      vim.cmd([[colorscheme everforest]])
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
  {
    'mfussenegger/nvim-dap',
    version = '0.9.0',
    lazy = true,
    dependencies = {
      'nvim-neotest/nvim-nio',
      {
        'rcarriga/nvim-dap-ui',
        version = 'v4.0.0',
        dependencies = { 'nvim-neotest/nvim-nio' },
        config = function()
          local dap = require('dap')
          local dapui = require('dapui')
          dapui.setup()
          dap.listeners.after.event_initialized['dapui_config'] = dapui.open
          dap.listeners.before.event_terminated['dapui_config'] = dapui.close
          dap.listeners.before.event_exited['dapui_config'] = dapui.close
        end,
      },
      {
        'theHamsta/nvim-dap-virtual-text',
        dependencies = {
          'nvim-treesitter/nvim-treesitter',
        },
        opts = {},
      },
    },
  },
  {
    dir = '/workspaces/nvim-dap-cpp',
    dependencies = { 'mfussenegger/nvim-dap' },
    build = 'make setup',
    opts = {
      configurations = {
        {
          name = 'Build and debug active file (gdb dap)',
          type = 'gdbdbg',
          request = 'launch',
          program = 'a.out',
          build = { 'g++', '-g', '-O0', vim.fn.expand('%') },
        },
      },
    },
    ft = { 'cpp' },
  },
})

vim.defer_fn(function()
  require('nvim-treesitter.configs').setup({
    ensure_installed = { 'cpp' },
  })
end, 0)

vim.keymap.set('n', '<F5>', function()
  require('dap').continue()
end)
vim.keymap.set('n', '<F10>', function()
  require('dap').step_over()
end)
vim.keymap.set('n', '<F11>', function()
  require('dap').step_into()
end)
vim.keymap.set('n', '<F12>', function()
  require('dap').step_out()
end)
vim.keymap.set('n', '<Leader>db', function()
  require('dap').toggle_breakpoint()
end)
vim.keymap.set('n', '<Leader>dB', function()
  require('dap').set_breakpoint()
end)
vim.keymap.set('n', '<Leader>lp', function()
  require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end)
vim.keymap.set('n', '<Leader>dr', function()
  require('dap').repl.open()
end)
vim.keymap.set('n', '<Leader>dl', function()
  require('dap').run_last()
end)
