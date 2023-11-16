-- Neovim Lua config (:help lua-guide)
-- Based upon nvim-lua/kickstart.nvim


--------------------------------------------------------------------------------
-- Initialisation --
--------------------------------------------------------------------------------

-- Leader key (:help mapleader)
vim.g.mapleader = ' '                                                           -- sets global leader to space key
vim.g.maplocalleader = ' '                                                      -- sets local leader to space key

-- Install Lazy package manager (:help lazy.nvim.txt)
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',                                                          -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)


--------------------------------------------------------------------------------
-- Plugin management via Lazy --
--------------------------------------------------------------------------------

require('lazy').setup({

  -- Misc
  --'stevearc/dressing.nvim',                                                     -- fancy boarders for popups (can't figure out how to work)
  --'ThePrimeagen/harpoon',                                                       -- quickly switch between files in buffer
  'tpope/vim-fugitive',                                                         -- Git control from command line
  'tpope/vim-rhubarb',                                                          -- Github browsing
  'tpope/vim-sleuth',                                                           -- adjusts shiftwidth and expandtab based on current or nearby files
  { 'folke/which-key.nvim', opts = {} },                                        -- shows pending keybinds
  { 'karb94/neoscroll.nvim', opts = { easing_function = 'quadratic' } },        -- smooth scrolling
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },           -- adds indentation guides
  { 'numToStr/Comment.nvim', opts = {} },                                       -- "gc" to comment visual regions/lines
  { 'nvim-tree/nvim-web-devicons', opts = { color_icons = false } },            -- developer icons for plugins using nerd font 

  -- Colour scheme
  --{ 'catppuccin/nvim', name = 'catppuccin', lazy = false, priority = 1000 },    -- catppuccin colour scheme (catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha)
  --{ 'ellisonleao/gruvbox.nvim', name = 'gruvbox', lazy = false, priority = 1000, config = true }, -- gruvbox colour scheme
  --{ 'folke/tokyonight.nvim', name = 'tokyonight', lazy = false, priority = 1000, opts = { transparent = true } }, -- Tokyo Night colour scheme (tokyonight, tokyonight-night, tokyonight-storm, tokyonight-day, tokyonight-moon)
  {
    'maxmx03/dracula.nvim',                                                     -- unoffical dracula colour scheme for nvim
    name = 'dracula',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'dracula'
    end,
    opts = { },
  },

  -- Column
  {
    'lukas-reineke/virt-column.nvim',                                           -- adds a character to colorcolumn
    opts = {
      char = '▕',
      highlight = 'InactiveIndent',
      virtcolumn = "80",
    },
  },

  -- CSV column highlighting
  {
    'cameron-wags/rainbow_csv.nvim',                                            -- highlights separate columns in .csv files for easier reading
    config = true,
    ft = {
      'csv',
      'tsv',
      'csv_semicolon',
      'csv_whitespace',
      'csv_pipe',
      'rfc_csv',
      'rfc_semicolon'
    },
    cmd = {
      'RainbowDelim',
      'RainbowDelimSimple',
      'RainbowDelimQuoted',
      'RainbowMultiDelim'
    }
  },

  -- File explorer
  {
    'nvim-tree/nvim-tree.lua',                                                  -- tree-style file explorer
    version = '*',
    lazy = false,
    opts = {
      update_focused_file = {
        enable = true,
      },
    },
  },

  -- Fuzzy Finder
  {
    'nvim-telescope/telescope.nvim',                                            -- list fuzzy finder
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',                                                  -- Lua coroutines
      {
        'nvim-telescope/telescope-fzf-native.nvim',                             -- fuzzy finder algorithm
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
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
    'neovim/nvim-lspconfig',                                                    -- built-in LSP client
    dependencies = {
      --'williamboman/mason.nvim',                                                -- manages LSPs. Requires apt npm, apt python3-venv
      --'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },                                       -- LSP status updates
      'folke/neodev.nvim',
    },
  },

  -- LSP autocompletion
  {
    'hrsh7th/nvim-cmp',                                                         -- autocompletion recommended by neovim
    dependencies = {
      'L3MON4D3/LuaSnip',                                                       -- snippets plugin
      'saadparwaiz1/cmp_luasnip',                                               -- snippets source for nvim-cmp
      'hrsh7th/cmp-nvim-lsp',                                                   -- LSP source for nvim-cmp
      'rafamadriz/friendly-snippets',                                           -- snippets for a range of languages
    },
  },

  -- Scroll bar
  {
    'dstein64/nvim-scrollview',                                                 -- scrollbar
    opts = {
      excluded_filetypes = {'NvimTree'},
      current_only = true,
      scrollview_winblend = 50,
      --diagnostics_severities = {vim.diagnostic.severity.ERROR},
    },
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',                                                -- custom status line
    opts = {
      options = {
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { { 'mode', separator = { left = '', right = ''}, }, },   -- uses semi-circle nerdfont symbol for beggining of statusline
        lualine_y = { { 'progress', fmt = function(str) return string.format(' %3s', str) end }, },
        lualine_z = { { 'location', fmt = function(str) return string.format('%s', str) end, separator = { left = '', right = '' }, }, }, -- uses semi-circle nerdfont symbol for end of statusline
      },
    },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- UI
  {
    'folke/noice.nvim',                                                         -- replaces UI for messages, cmdline, and popupmenu
    event = 'VeryLazy',
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      presets = {
        bottom_search = false, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
      -- views = {
      --   mini = {
      --     win_options = {
      --       winblend = 0,
      --     },
      --   },
      -- },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module='...'` entries
      'MunifTanjim/nui.nvim',
      {
        'rcarriga/nvim-notify',
        opts = {
          --background_colour = 'Normal',
          fps = 60,
          stages = 'fade',
          timeout = 1000,
        },
      },
    },
  },

}, {})


--------------------------------------------------------------------------------
-- General settings --
--------------------------------------------------------------------------------

-- Built-in options
vim.g.loaded_netrw = 1                                                          -- disables netrw for nvim-tree to work
vim.g.loaded_netrwPlugin = 1                                                    -- disables netrw for nvim-tree to work
--vim.o.clipboard = 'unnamedplus'                                                 -- sync clipboard between OS and Neovim
--vim.o.background = 'dark'                                                       -- set background colour to dark or light
vim.o.breakindent = true                                                        -- keeps indent when wrapping
vim.o.completeopt = 'menuone,noselect'                                          -- completeopt, something to do with completion idk
vim.o.cursorline = true                                                         -- highlights current line
vim.o.guicursor = 'n-v-c:hor20,i-ci-ve:ver25,r-cr:block,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'  -- changes cursor appearance for each mode
vim.o.ignorecase = true                                                         -- case-insensitive search
vim.o.laststatus = 3                                                            -- sets global statusline for all windows 
vim.o.mouse = 'a'                                                               -- enables mouse mode
--vim.o.pumblend = 25                                                             -- sets transparency for popup menus
vim.o.relativenumber = true                                                     -- displays line numbers relative to current line
vim.o.scrolloff = 5                                                             -- keeps 5 lines above/below cursor when scrolling files
vim.o.smartcase = true                                                          -- case-sensitive search if \C or upper case character is included
vim.o.termguicolors = true                                                      -- enables 24-bit colour
vim.o.timeoutlen = 300                                                          -- time in ms to wait for a mapped sequence to complete
vim.o.undofile = true                                                           -- save undo history
vim.o.updatetime = 250                                                          -- time in ms after which if nothing is typed, writes to swap file
vim.wo.number = true                                                            -- displays line numbers
vim.wo.wrap = false                                                             -- disables line wrapping

vim.o.hlsearch = false-- Set highlight on search
vim.wo.signcolumn = 'yes'-- Keep signcolumn on by default

-- Filetype associations
vim.filetype.add({
  extension = {
    h = 'fortran',
  },
  filename = {
    ['.fortls'] = 'jsonc',
  }
})

-- Highlight groups for setting colours of indent guides and virtual column
local highlight = {
  'ActiveIndent',
  'InactiveIndent',
}
local hooks = require 'ibl.hooks'
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, 'ActiveIndent', { fg = '#62646C' })
  vim.api.nvim_set_hl(0, 'InactiveIndent', { fg = '#3E404A' })
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
vim.api.nvim_create_autocmd({'VimLeave', 'VimSuspend'}, {
  pattern = '*',
  callback = function()
    vim.opt.guicursor = 'a:ver25-blinkwait175-blinkoff150-blinkon150'
  end
})


--------------------------------------------------------------------------------
-- Key mappings --
--------------------------------------------------------------------------------

-- nvim-tree
vim.keymap.set('n', '<leader>tt', require('nvim-tree.api').tree.toggle, { desc = '[T]ree [T]oggle' })

-- terminal
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])

-- Keymaps for better default experience (:help vim.keymap.set()) (idk)
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Wrapping (idk)
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostics (:help vim.diagnostic.*)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

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

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = {git_root},
    })
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

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
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
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
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
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

-- list of LSPs to use if not using Mason
local servers = {
  'clangd',
  'fortls',
  'julials',
  'pyright',
  --'lua_ls',
}

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
--require('mason').setup()
--require('mason-lspconfig').setup()

-- Enable some language servers with the additional completion capabilities
--   offered by nvim-cmp via Mason (see :h lspconfig-all for list of available LSPs, and
--   https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md 
--   for installation instructions. Check :Mason, :MasonLog, :checkhealth Mason
--   if issues arise)
-- local servers = {
--   clangd = {},
--   fortls = {},
--   julials = {},
--   pyright = {},
--   lua_ls = {
--     Lua = {
--       workspace = { checkThirdParty = false },
--       telemetry = { enable = false },
--       diagnostics = {
--         disable = { "missing-fields" },
--       },
--     },
--   },
-- }

-- Setup neovim lua configuration
require('neodev').setup()

-- Broadcast nvim-cmp's additional completion capabilities to language servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- -- Install and configure language servers via Mason 
-- local mason_lspconfig = require 'mason-lspconfig'
-- mason_lspconfig.setup {
--   ensure_installed = vim.tbl_keys(servers),
-- }
-- mason_lspconfig.setup_handlers {
--   function(server_name)
--     require('lspconfig')[server_name].setup {
--       capabilities = capabilities,
--       on_attach = on_attach,
--       settings = servers[server_name],
--       filetypes = (servers[server_name] or {}).filetypes,
--     }
--   end,
-- }

-- Configure LSPs if not using Mason
for _, server_name in ipairs(servers) do
  require 'lspconfig'[server_name].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = servers[server_name],
    filetypes = (servers[server_name] or {}).filetypes,
  }
end

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    --['<C-u>'] = cmp.mapping.scroll_docs(-4),                                    -- up
    --['<C-d>'] = cmp.mapping.scroll_docs(4),                                     -- down
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}


-------------------------------------------------------------------------------
-- Other plugin configurations --
-------------------------------------------------------------------------------

-- Indent Blankline
require 'ibl'.setup {
  indent = {
    char = '▏',
    highlight = 'InactiveIndent'
  },
  scope = {
    highlight = 'ActiveIndent'
  }
}

-- Treesitter (:help nvim-treesitter)
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'julia' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true, disable = { 'fortran' } },
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
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
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

-- which-key (document existing key chains)
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]ree', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}

