-- 1. БАЗОВЫЕ НАСТРОЙКИ
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.undofile = true

vim.g.mapleader = " "

-- Таймер автосейва (миллисекунды)
vim.opt.updatetime = 500

-- Тема
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")

-- 2. LUALINE
require('lualine').setup { options = { theme = 'gruvbox' } }

-- 3. NVIM-TREE (Файловый менеджер)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
local api = require("nvim-tree.api")
require("nvim-tree").setup()

-- ИСПРАВЛЕННАЯ ЛОГИКА WIN+N (Без is_focused)
local function toggle_tree_focus()
  if not api.tree.is_visible() then
    api.tree.open()
  else
    -- Проверяем, находится ли фокус сейчас на дереве
    if vim.bo.filetype == "NvimTree" then
      api.tree.close()
    else
      api.tree.focus()
    end
  end
end

vim.keymap.set('n', '<C-n>', toggle_tree_focus, { silent = true })

-- 4. TREESITTER
require'nvim-treesitter.configs'.setup {
  highlight = { enable = true },
  indent = { enable = true },
}

-- 5. LSP
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local servers = { 'pyright', 'nixd', 'clangd', 'dockerls', 'yamlls' }

-- Функция для добавления дефолтных конфигов из lspconfig в vim.lsp.config
-- Это хак для clean setup на unstable версиях
local lsp_configs = require('lspconfig.configs')

for _, name in ipairs(servers) do
  -- Если конфига еще нет в глобальной таблице vim, берем дефолтный из плагина
  if not vim.lsp.config[name] and lsp_configs[name] then
     vim.lsp.config[name] = lsp_configs[name].default_config
  end
  
  -- Добавляем capabilities (автодополнение)
  if vim.lsp.config[name] then
      vim.lsp.config[name].capabilities = capabilities
      -- Включаем сервер
      vim.lsp.enable(name)
  end
end

-- 6. AUTOPAIRS
require('nvim-autopairs').setup{}

-- 7. CMP (Автодополнение)
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  })
})

-- 8. АВТОСЕЙВ (Работает по таймеру updatetime)
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("autosave", {}),
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
      vim.api.nvim_command('silent update')
    end
  end,
})

-- 9. RAINBOW DELIMITERS
require('rainbow-delimiters.setup').setup { }

-- 10. Keybinds
vim.keymap.set('n', '<space>e', function() 
  vim.diagnostic.open_float({ 
    border = "rounded", 
    source = "always", 
    header = "" 
  }) 
end, { desc = "Показать текст ошибки с рамкой" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Предыдущая ошибка" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Следующая ошибка" })

-- 11. TELESCOPE
local builtin = require('telescope.builtin')

-- Ctrl+Shift+P: Панель команд (все действия)
-- Примечание: В некоторых терминалах C-S-p может быть занят, 
-- если не сработает, попробуй настроить hotkey в Kitty.
vim.keymap.set('n', '<C-S-p>', builtin.commands, { desc = "Панель команд" })

-- Поиск файлов (как Ctrl+P в VS Code)
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = "Поиск файлов" })

-- Поиск текста во всем проекте (Live Grep)
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Поиск текста в файлах" }) 

-- 12. TOGGLETERM (Встроенный терминал)
require("toggleterm").setup({
  size = 20,
  open_mapping = [[<C-`>]], -- Тот самый Ctrl + `
  direction = 'float',      -- Всплывающее окно (можно сменить на 'horizontal')
  float_opts = {
    border = 'rounded',
  },
})

-- Функция для быстрого запуска Python файла
function _run_python()
  local file = vim.fn.expand("%")
  -- Используем uv run, так как ты работаешь с ним
  vim.cmd("TermExec cmd='uv run " .. file .. "'")
end

-- Привязываем запуск на <leader>r (пробел + r)
vim.keymap.set('n', '<leader>r', '<cmd>lua _run_python()<CR>', { desc = "Запустить Python файл" })
