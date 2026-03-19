-- 1. БУТСТРАП LAZY.NVIM
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 2. НАСТРОЙКА ПЛАГИНОВ
require("lazy").setup({
  spec = {
    -- Тема и lualine
    { "ellisonleao/gruvbox.nvim", lazy = false, priority = 1000, config = function()
      vim.o.background = "dark"
      vim.cmd("colorscheme gruvbox")
    end },
    { "nvim-lualine/lualine.nvim", opts = { options = { theme = 'gruvbox' } } },

    -- NVIM-TREE (Кейбинд Ctrl+n)
    { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" }, config = function()
      local api = require("nvim-tree.api")
      require("nvim-tree").setup()
      local function toggle_tree_focus()
        if not api.tree.is_visible() then api.tree.open()
        else
          if vim.bo.filetype == "NvimTree" then api.tree.close()
          else api.tree.focus() end
        end
      end
      vim.keymap.set('n', '<C-n>', toggle_tree_focus, { silent = true })
    end },

    -- ТЕЛЕСКОП (Поиск)
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<C-p>', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    end },

    -- АВТОДОПОЛНЕНИЕ (Тот самый движок, которого не хватало)
    { "hrsh7th/nvim-cmp", dependencies = {
        "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip"
      }, config = function()
        local cmp = require('cmp')
        cmp.setup({
          snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
          mapping = cmp.mapping.preset.insert({
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping.select_next_item(),
            ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' }, { name = 'luasnip' }, { name = 'path' },
          }, { { name = 'buffer' } })
        })
      end
    },

    -- LSP (Логика для 0.11+)
    { "neovim/nvim-lspconfig", config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local servers = { 'pyright', 'clangd', 'dockerls', 'yamlls' }
      local lsp_configs = require('lspconfig.configs')
      for _, name in ipairs(servers) do
        if not vim.lsp.config[name] and lsp_configs[name] then
           vim.lsp.config[name] = lsp_configs[name].default_config
        end
        if vim.lsp.config[name] then
            vim.lsp.config[name].capabilities = capabilities
            vim.lsp.enable(name)
        end
      end
    end },

    -- TREESITTER (Подсветка)
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = function()
        local ok, configs = pcall(require, "nvim-treesitter.configs")
        local ts = ok and configs or require("nvim-treesitter")
        ts.setup({
          ensure_installed = { "python", "bash", "c", "lua", "markdown" },
          highlight = { enable = true },
        })
      end
    },

    -- Радужные скобки
    { "HiPhish/rainbow-delimiters.nvim", dependencies = { "nvim-treesitter/nvim-treesitter" }, config = function()
        require('rainbow-delimiters.setup').setup({})
      end
    },

    -- Утилиты
    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
    { "akinsho/toggleterm.nvim", version = "*", opts = { 
        size = 20, open_mapping = [[<C-`>]], direction = 'float', float_opts = { border = 'rounded' }
    } },
  },
  rocks = { enabled = false }
})

--- 3. БАЗОВЫЕ НАСТРОЙКИ ---
vim.opt.number = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.g.mapleader = " "

-- Автосейв
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = function()
    if vim.bo.modified and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
      vim.api.nvim_command('silent update')
    end
  end,
})

-- Запуск через uv
function _run_python()
  local file = vim.fn.expand("%")
  vim.cmd("TermExec cmd='uv run " .. file .. "'")
end
vim.keymap.set('n', '<leader>r', '<cmd>lua _run_python()<CR>')

