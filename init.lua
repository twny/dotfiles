-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })

local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  -- LSP / Autocompletion
  use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            { 'williamboman/mason.nvim' },
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        }
    }

  -- Diagnostics & Code Actions
  use ({
      'kosayoda/nvim-lightbulb',
      requires = 'antoinemadec/FixCursorHold.nvim',
      config = function() 
        local bulb = require('nvim-lightbulb')
        bulb.setup({autocmd = {enabled = true}})
      end
  })

  -- DAP
  use 'mfussenegger/nvim-dap'
  use 'leoluz/nvim-dap-go'
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
  use 'theHamsta/nvim-dap-virtual-text'
  use 'nvim-telescope/telescope-dap.nvim'

  -- Treesitter
  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- UI
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'nvim-lualine/lualine.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'kyazdani42/nvim-tree.lua'
  use 'rhysd/git-messenger.vim'
  use {
    'lewis6991/gitsigns.nvim',
    -- tag = 'release' -- To use the latest release
  }
  use 'psliwka/vim-smoothie'
  use 'lukas-reineke/indent-blankline.nvim'

  -- Utils
  use 'tpope/vim-fugitive'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use 'skywind3000/asyncrun.vim'
  use 'numToStr/Comment.nvim'

  -- Colorschemes
  use({ "catppuccin/nvim", as = "catppuccin" })
  use 'norcalli/nvim-colorizer.lua'
  use 'cormacrelf/dark-notify'

  -- Languages
  use 'sebdah/vim-delve'
  use 'ludovicchabant/vim-gutentags'

  -- Misc
  use 'LnL7/vim-nix'
end)

vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

vim.o.hlsearch = true
vim.wo.number = true

vim.o.mouse = 'a'
vim.o.clipboard = "unnamedplus"
vim.o.breakindent = true
vim.opt.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'
vim.o.completeopt = 'menuone,noselect'
vim.o.winbar = "%=%m %f"
vim.o.laststatus = 3
vim.o.splitbelow = true
vim.o.cmdheight = 0

-- latte, frappe, macchiato, mocha
vim.g.catppuccin_flavour = "latte"
-- vim.g.catppuccin_flavour = "mocha"
vim.cmd[[colorscheme catppuccin]]


vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set({'n'},  '<CR>', ':nohlsearch<cr>', {silent = true})

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set({'t'}, '<Esc>', "<C-\\><C-n>", { silent = true })


-- Telescope
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers)
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find)
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags)
vim.keymap.set('n', '<leader>st', require('telescope.builtin').tags)
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').grep_string)
vim.keymap.set('n', '<leader>sp', require('telescope.builtin').live_grep)
vim.keymap.set('n', '<leader>bb', function() require('telescope.builtin').live_grep({grep_open_files=true}) end)
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles)
vim.keymap.set('n', '<leader>sf', function()
  require('telescope.builtin').find_files { previewer = false }
end)
vim.keymap.set('n', '<leader>so', function()
  require('telescope.builtin').tags { only_current_buffer = true }
end)

-- Diagnostics
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float)
-- :lua vim.diagnostic.goto_next()
-- vim.diagnostic.open_float(0, {scope="line"})
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = false,
    signs = true,
    update_in_insert = true
  }
)

local signs = {
  { name = "DiagnosticSignError", text = "" },
  { name = "DiagnosticSignWarn", text = "" },
  { name = "DiagnosticSignHint", text = "" },
  { name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end


-- LSP settings

local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
    'tsserver',
    'gopls',
    'bashls',
    'pyright',
    'clangd',
    'rust_analyzer',
})

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr }
  -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations, opts)
  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)

  -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  -- vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
end)

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

lsp.setup()

-- Debugger
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<Leader>bp", ":DlvToggleBreakpoint<CR>")
vim.keymap.set("n", "<F5>", ":DlvExec ./tilectl . --\\ server<CR>")
vim.g.delve_new_command = 'new' -- open dlv in a horiztonal split
vim.api.nvim_create_user_command("GoFmt", "!gofmt -w %", {})
vim.api.nvim_create_user_command("GoBuild", "AsyncRun -mode=term -pos=bottom -rows=10 go build -gcflags='all=-N -l' ./cmd/tilectl", {})


-- DAP
-- vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
-- vim.keymap.set("n", "<F10>", ":lua require'dap'.step_over()<CR>")
-- vim.keymap.set("n", "<F11>", ":lua require'dap'.step_into()<CR>")
-- vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>")
-- vim.keymap.set("n", "<Leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
-- vim.keymap.set("n", "<Leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
-- vim.keymap.set("n", "<Leader>lp", ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
-- vim.keymap.set("n", "<Leader>dr", ":lua require'dap'.repl.open()<CR>")
-- vim.keymap.set("n", "<Leader>dl", ":lua require'dap'.run_last()<CR>")
-- vim.keymap.set("n", "<Leader>dl", ":lua require'dap'.run_last()<CR>")
-- vim.keymap.set("n", "<Leader>td", ":lua require('dap-go').debug_test()<CR>")
--
-- require('dap-go').setup()
-- require("dapui").setup()
-- require('nvim-dap-virtual-text').setup()
--
-- local dap, dapui = require("dap"), require("dapui")
-- dap.listeners.after.event_initialized["dapui_config"] = function()
--   dapui.open()
-- end
-- dap.listeners.before.event_terminated["dapui_config"] = function()
--   dapui.close()
-- end
-- dap.listeners.before.event_exited["dapui_config"] = function()
--   dapui.close()
-- end

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

require('Comment').setup()
require('indent_blankline').setup {
  char = '│',
  show_trailing_blankline_indent = false,

}

require('gitsigns').setup {}

-- Telescope
local action_layout = require("telescope.actions.layout")
local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    layout_strategy = 'vertical',
    path_display={"smart"},
    layout_config = {
      preview_cutoff = 1,
    },
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<C-space>'] = action_layout.toggle_preview,
        ['<C-q>'] = actions.send_to_qflist,
      },
      n = {
        ['<C-space>'] = action_layout.toggle_preview,
        ['<C-q>'] = actions.send_to_qflist,
      }
    },
  },
}
require('telescope').load_extension 'fzf'

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}


-- luasnip setup
local luasnip = require 'luasnip'

local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
}

vim.api.nvim_command([[
  augroup Ruby    
    autocmd FileType ruby abbreviate <buffer> pry require 'pry'; binding.pry    
    autocmd BufNewFile,BufRead *.json.jbuilder set ft=ruby    
  augroup END
]])

--vim.o.statusline = "%#Separator#%#Contents#%t%#Separator# %#Separator#%#Modified#%{&modified?'●':''}%#NotModified#%{&modified?'':'●'}%#Separator#%= %#Separator#%#Contents#%l,%c%#Separator# %#Separator#%#Contents#%p%%%#Separator# %#Separator#%#Contents#%Y%#Separator#"

require('lualine').setup {
  options = {
    -- theme = 'auto',
    theme = 'catppuccin',
    component_separators = '|',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      { 'mode', separator = { left = '' }, right_padding = 2 },
    },
    lualine_b = { 'filename', 'branch' },
    lualine_c = { 'fileformat' },
    lualine_x = {},
    lualine_y = { 'filetype', 'progress' },
    lualine_z = {
      { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },
  tabline = {},
  extensions = {},
}

require'nvim-tree'.setup {}

require('colorizer').setup(nil, { css = true; })
