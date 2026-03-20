{ pkgs, ... }:

{
  # NVim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Ставим плагины через Nix
    plugins = with pkgs.vimPlugins; [
      # --- UI и Внешний вид ---
      gruvbox-nvim
      lualine-nvim          # Замена airline
      nvim-web-devicons     # Иконки для файлов
      nvim-tree-lua         # Замена NERDTree
      rainbow-delimiters-nvim

      # --- Основа (LSP и Treesitter) ---
      nvim-treesitter.withAllGrammars  # Умная подсветка для всего
      nvim-lspconfig        # Настройки LSP серверов

      # --- Автодополнение ---
      nvim-cmp              # Движок автодополнения
      cmp-nvim-lsp          # Источник: LSP
      cmp-buffer            # Источник: слова из буфера
      cmp-path              # Источник: пути к файлам
      luasnip               # Сниппеты (нужны для cmp)
      cmp_luasnip

      # --- Утилиты ---
      nvim-autopairs        # Авто-скобки
      comment-nvim          # Быстрое комментирование (gcc)


      telescope-nvim        # Поиск (панель действий)
      plenary-nvim          # Зависимость для telescope
      toggleterm-nvim       # Удобный терминал
    ];

    extraLuaConfig = builtins.readFile ../../home/terminal/nvim/init.lua;
  };
}
