-- =====================
-- 基础设置
-- =====================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.scrolloff = 8
vim.opt.updatetime = 300

-- 代码折叠配置
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldenable = true

-- 普通模式：复制整行到系统剪贴板
vim.keymap.set('n', '<D-c>', '"+yy', { desc = 'Copy line to system clipboard' })

-- 可视化模式：复制选中内容到系统剪贴板（正确！不会删）
vim.keymap.set('v', '<D-c>', '"+y', { desc = 'Copy selection to system clipboard' })

-- 插入模式也能用 Cmd+C 复制
vim.keymap.set('i', '<D-c>', '<Esc>"+yyi', { desc = 'Copy line in insert' })

-- 可选：Cmd+X 剪切（保留）
vim.keymap.set('v', '<D-x>', '"+d', { desc = 'Cut to system clipboard' })
vim.keymap.set('n', '<D-x>', '"+dd', { desc = 'Cut line' })

-- Cmd+V 粘贴（全模式）
vim.keymap.set('n', '<D-v>', '"+p', { desc = 'Paste' })
vim.keymap.set('i', '<D-v>', '<C-r>+', { desc = 'Paste in insert' })
vim.keymap.set('v', '<D-v>', '"+p', { desc = 'Paste' })

-- =====================
-- 安装 Lazy.nvim 插件管理器
-- =====================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- =====================
-- 插件列表
-- =====================
require("lazy").setup({
  -- 主题
{
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1500,
  config = function()
    vim.cmd.colorscheme("catppuccin-frappe")
  end
},

  -- 文件树
  { "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" } },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { icons = { show = { file = true, folder = true } } },
        actions = { open_file = { quit_on_open = false } },
      })
    end
  },

  -- 模糊查找
  { "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find Text" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
    },
  },

  -- LSP + 补全
  { "neovim/nvim-lspconfig",
    config = function()
      -- TypeScript/JavaScript
      vim.lsp.config("ts_ls", {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
      })

      -- Vue
      vim.lsp.config("volar", {
        cmd = { "vue-language-server", "--stdio" },
        filetypes = { "vue" },
      })

      -- 启用 LSP
      vim.lsp.enable({ "ts_ls", "volar" })

      -- 全局快捷键
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = "Find references" })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover" })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename" })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code action" })
    end
  },
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end
  },

  -- 自动格式化
  { "stevearc/conform.nvim", event = "BufWritePre", config = function()
    require("conform").setup({
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    })
  end },

  -- 语法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "vue", "javascript", "typescript", "css", "html",
        "lua", "json", "bash", "markdown"
      })

      -- 为所有文件类型启用 treesitter 高亮
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end
  },

  -- Markdown 渲染预览
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = function(_, opts)
      require("render-markdown").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = "nc"
          vim.keymap.set("n", "<leader>mp", "<cmd>RenderMarkdown toggle<cr>", {
            buffer = event.buf,
            desc = "Toggle Markdown Preview",
          })
        end,
      })
    end,
  },

  -- 状态栏
  { "nvim-lualine/lualine.nvim", config = function()
  require("lualine").setup({
    theme = "catppuccin",
    options = {
      component_separators = "|",
      section_separators = "",
    },
  })
end },
})
