-- Neovim Lua config (:help lua-guide)
-- Inspiration taken from nvim-lua/kickstart.nvim


--------------------------------------------------------------------------------
-- Initialisation --
--------------------------------------------------------------------------------

-- Leader key (:help mapleader)
vim.g.mapleader = ' '                                                           -- sets global leader to space key
vim.g.maplocalleader = ' '                                                      -- sets local leader to space key

-- Install Lazy package manager (:help lazy.nvim.txt)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",                                                          -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


--------------------------------------------------------------------------------
-- Plugin management via Lazy --
--------------------------------------------------------------------------------

require("lazy").setup({

  -- Colour scheme
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },    -- catppuccin colour scheme (catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha)
  { "ellisonleao/gruvbox.nvim", name = "gruvbox", lazy = false, priority = 1000, config = true }, -- gruvbox colour scheme
  { "maxmx03/dracula.nvim", name = "dracula", lazy = false, priority = 1000 },  -- unoffical dracula colour scheme for nvim
  
  -- CSV column highlighting
  {
    "cameron-wags/rainbow_csv.nvim",                                            -- highlights separate columns in .csv files for easier reading
    config = true,
    ft = {
      "csv",
      "tsv",
      "csv_semicolon",
      "csv_whitespace",
      "csv_pipe",
      "rfc_csv",
      "rfc_semicolon"
    },
    cmd = {
      "RainbowDelim",
      "RainbowDelimSimple",
      "RainbowDelimQuoted",
      "RainbowMultiDelim"
    }
  },

  -- Fuzzy finder
  { 
    "nvim-telescope/telescope.nvim",                                            -- list fuzzy finder
    branch = "0.1.x",
    dependencies = { 
      "nvim-lua/plenary.nvim",                                                  -- Lua coroutines
      {
        "nvim-telescope/telescope-fzf-native.nvim",                             -- fuzzy finder algorithm
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
    },
  },

  -- Git Signs (:help gitsigns.txt)
    {
    'lewis6991/gitsigns.nvim',                                                  -- Adds git related signs to the gutter, as well as utilities for managing changes
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
      end,
    },
  },

  -- LSP
  { 
    "neovim/nvim-lspconfig",                                                    -- built-in LSP client
    dependencies = {
      --{ "j-hui/fidget.nvim", tag = "legacy", event = "LspAttach", opts = {} },  -- LSP status updates, doesn't seem to work with fortls
      "folke/neodev.nvim",                                                      -- configures lua-language-server for Neovim config, runtime and plugin directories
    },
  },

  -- LSP autocompletion
  { 
    "hrsh7th/nvim-cmp",                                                         -- autocompletion recommended by neovim
    dependencies = {
      "L3MON4D3/LuaSnip",                                                       -- snippets plugin
      "saadparwaiz1/cmp_luasnip",                                               -- snippets source for nvim-cmp
      "hrsh7th/cmp-nvim-lsp",                                                   -- LSP source for nvim-cmp
      "rafamadriz/friendly-snippets",                                           -- snippets for a range of languages
    },
  },

  -- Misc
  { "folke/which-key.nvim", opts = {} },                                        -- shows pending keybinds
  { "karb94/neoscroll.nvim", opts = { easing_function = "quadratic" } },        -- smooth scrolling
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },           -- add indentation guides
  { "lukas-reineke/virt-column.nvim", opts = {} },                              -- adds a character to colorcolumn
  { "numToStr/Comment.nvim", opts = {} },                                       -- "gc" to comment visual regions/lines
  { "nvim-tree/nvim-web-devicons", opts = { color_icons = false } },            -- developer icons for plugins using nerd font 
  --"lewis6991/satellite.nvim",                                                   -- fancy scrollbar (Neovim >= 0.10 only)
  --"stevearc/dressing.nvim",                                                     -- fancy boarders for popups (can't figure out how to work)
  --"ThePrimeagen/harpoon",                                                       -- quickly switch between files in buffer
  "tpope/vim-fugitive",                                                         -- Git control from command line
  "tpope/vim-rhubarb",                                                          -- Github browsing
  "tpope/vim-sleuth",                                                           -- adjusts shiftwidth and expandtab based on current or nearby files

  -- Status line
  {
    "nvim-lualine/lualine.nvim",                                                -- custom status line
    opts = {
      options = {
        section_separators = { left = '', right = '' },
        -- section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        -- component_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "", right = ""}, }, },   -- uses semi-circle nerdfont symbol for beggining of statusline
        -- lualine_a = { { "mode", separator = { left = "", right = ""}, }, },   -- uses semi-circle nerdfont symbol for beggining of statusline
        lualine_y = { { "progress", fmt = function(str) return string.format(" %3s", str) end }, },
        --lualine_z = { { function() return string.format("%3d:%-3d", vim.fn.line("."), vim.fn.col(".")) end, separator = { left = "", right = "" }, }, },
        lualine_z = { { "location", fmt = function(str) return string.format("%s", str) end, separator = { left = "", right = "" }, }, }, -- uses semi-circle nerdfont symbol for end of statusline
        -- lualine_z = { { "location", fmt = function(str) return string.format("%s", str) end, separator = { left = "", right = "" }, }, }, -- uses semi-circle nerdfont symbol for end of statusline
      },
      --winbar = {
        --lualine_c = { "filename", fmt = function(str) return string.format("%s %s", require"nvim-web-devicons".get_icon(str, str:match("[^.]+$")), str) end},
      --},
    },
  },

  -- UI
  {
    "folke/noice.nvim",                                                         -- replaces UI for messages, cmdline, and popupmenu
    event = "VeryLazy",
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
      }
  },

  -- Highlight, edit, and navigate code
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

}, {})


--------------------------------------------------------------------------------
-- General settings --
--------------------------------------------------------------------------------

-- Built-in options
vim.cmd.colorscheme "dracula"                                                   -- sets colour scheme
--vim.opt.background = "dark"                                                     -- set background colour to dark or light
vim.opt.breakindent = true                                                      -- keeps indent when wrapping
vim.opt.completeopt = "menuone,noselect"                                        -- completeopt, something to do with completion idk
vim.opt.colorcolumn = "80"                                                      -- colours a column
vim.opt.cursorline = true                                                       -- highlights current line
vim.opt.guicursor = "n-v-c:hor20,i-ci-ve:ver25,r-cr:block,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"  -- changes cursor appearance for each mode
vim.opt.ignorecase = true                                                       -- case-insensitive search
vim.opt.number = true                                                           -- displays line numbers
vim.opt.laststatus = 3                                                          -- sets global statusline for all windows 
vim.opt.relativenumber = true                                                   -- displays line numbers relative to current line
vim.opt.scrolloff = 5                                                           -- keeps 5 lines above/below cursor when scrolling files
vim.opt.smartcase = true                                                        -- case-sensitive search if \C or upper case character is included
vim.opt.termguicolors = true                                                    -- enables 24-bit colour
vim.opt.timeoutlen = 300                                                        -- time in ms to wait for a mapped sequence to complete
vim.opt.updatetime = 250                                                        -- time in ms after which is nothing is typed, writes to swap file
vim.wo.wrap = false                                                             -- disables line wrapping

-- Filetype associations
vim.filetype.add({
  extension = {
    h = "fortran",
  },
  filename = {
    [".fortls"] = "jsonc",
  }
})

-- Highlight groups for setting colours of indent guides and virtual column
local highlight = {
  "ActiveIndent",
  "InactiveIndent",
}
local hooks = require "ibl.hooks"
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "ActiveIndent", { fg = "#62646C" })
  vim.api.nvim_set_hl(0, "InactiveIndent", { fg = "#3E404A" })
end)

-- Highlight on yank (:help vim.highlight.on_yank())
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Reset terminal cursor upon exiting Neovim
vim.api.nvim_create_autocmd({"VimLeave", "VimSuspend"}, {
  pattern = "*",
  callback = function()
    vim.opt.guicursor = "a:ver25-blinkwait175-blinkoff150-blinkon150"
  end
})


--------------------------------------------------------------------------------
-- Key mappings --
--------------------------------------------------------------------------------

-- Keymaps for better default experience (:help vim.keymap.set()) (idk)
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Wrapping (idk)
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostics (:help vim.diagnostic.*)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- which-key
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}

-- Telescope (:help telescope and :help telescope.setup())
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })


-------------------------------------------------------------------------------
-- Commands --
-------------------------------------------------------------------------------

-- Open init.lua configuration file
vim.api.nvim_create_user_command(
  'Config',
  'e ~/.config/nvim/init.lua',
  {
    desc = 'Open init.lua configuration file'
  }
)


-------------------------------------------------------------------------------
-- Language server --
-------------------------------------------------------------------------------

-- LSP related local key mappings that are applied when an LSP connects to a buffer
local on_attach = function(_, bufnr)

  -- Convenient function for defining below LSP related key mappings 
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end
  
  -- Buffer local mappings
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

end

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 
  "fortls",
  "pyright",
}

-- neodev setup
require "neodev".setup()

-- Broadcast nvim-cmp's additional completion capabilities to language servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require "cmp_nvim_lsp".default_capabilities(capabilities)

local lspconfig = require "lspconfig"

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- nvim-cmp setup
local cmp = require "cmp"
local luasnip = require "luasnip"
require "luasnip.loaders.from_vscode".lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),                                    -- up
    ["<C-d>"] = cmp.mapping.scroll_docs(4),                                     -- down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
}


-------------------------------------------------------------------------------
-- Other plugin configurations --
-------------------------------------------------------------------------------

-- neoscroll
local t = {}
-- Syntax: t[keys] = {function, {function arguments}}
-- Use the "sine" easing function
t['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', '350', [['sine']]}}
t['<C-d>'] = {'scroll', { 'vim.wo.scroll', 'true', '350', [['sine']]}}
-- Use the "circular" easing function
t['<C-b>'] = {'scroll', {'-vim.api.nvim_win_get_height(0)', 'true', '500', [['circular']]}}
t['<C-f>'] = {'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', '500', [['circular']]}}
-- Pass "nil" to disable the easing animation (constant scrolling speed)
t['<C-y>'] = {'scroll', {'-0.10', 'false', '100', nil}}
t['<C-e>'] = {'scroll', { '0.10', 'false', '100', nil}}
-- When no easing function is provided the default easing function (in this case "quadratic") will be used
t['zt']    = {'zt', {'300'}}
t['zz']    = {'zz', {'300'}}
t['zb']    = {'zb', {'300'}}
require "neoscroll.config".set_mappings(t)

-- Treesitter
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require "nvim-treesitter.configs".setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = {
      enable = true,
      disable = { "fortran" },                                                  -- disables treesitter syntax highlighting for Fortran files
    },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,                                                       -- automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true,                                                       -- whether to set jumps in the jumplist
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
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- Indent Blankline
require "ibl".setup {
  indent = {
    char = "▏",
    highlight = "InactiveIndent"
  },
  scope = {
    highlight = "ActiveIndent"
  }
}

-- virt-column
require "virt-column".setup({
  char = "▕",
  highlight = "InactiveIndent"
})

-------------------------------------------------------------------------------
