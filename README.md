# nvim-dap-cpp

`nvim-dap-cpp` is a Neovim plugin that extends the functionality of `nvim-dap` to provide debugging support for C and C++ programs.

## Installation

[`lazy.nvim`][3]:

```lua
{
  'goropikari/nvim-dap-cpp',
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  build = 'make setup', -- not necessary if you use mason.
  opts = {
    -- default value
    codelldb = {
      path = vim.fn.stdpath('data') .. '/nvim-dap-cpp.nvim/extension/adapter/codelldb',
      -- for mason
      -- path = require('mason-registry').get_package('codelldb'):get_install_path()
    },
    configurations = {},
  },
  ft = { 'c', 'cpp' },
}
```

## License

This plugin is released under the MIT License.

[1]: https://github.com/mfussenegger/nvim-dap
[2]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools
[3]: https://github.com/folke/lazy.nvim
