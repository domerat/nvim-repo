-- ========================================================================== --
--                                 INIT.LUA                                   --
-- ========================================================================== --

-- 1. Helper function to safely load core configurations
local function safe_require(module)
  local status_ok, err = pcall(require, module)
  if not status_ok then
    vim.notify("Error loading " .. module .. "\n" .. tostring(err), vim.log.levels.ERROR)
  end
end

-- 2. Load core user configurations
safe_require("config.options")
safe_require("config.keymaps")

-- 3. Setup lazy.nvim path
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 4. Initialize lazy.nvim using standard global call (Fixes Line 35 Error)
local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  vim.notify("Critical: Could not load lazy.nvim module!", vim.log.levels.ERROR)
  return
end

vim.diagnostic.config({
  virtual_text = true,           -- Shows errors inline at the end of the line
  signs = true,                  -- Displays error icons in the left gutter
  underline = true,              -- Underlines the exact code causing the error
  update_in_insert = false,      -- Don't flash errors while typing; wait until you leave insert mode
  severity_sort = true,          -- Always prioritize errors over warnings
})


lazy.setup({
  spec = {
      {
        'mrcjkb/rustaceanvim',
        -- To avoid being surprised by breaking changes,
        -- I recommend you set a version range
        version = '^9',
        -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
        -- No need for lazy.nvim to lazy-load it.
        lazy = false,
    },
    {
      'saghen/blink.cmp',
      -- optional: provides snippets for the snippet source
      dependencies = { 'rafamadriz/friendly-snippets' },

      version = '1.*',
      opts = {
          -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
          -- 'super-tab' for mappings similar to vscode (tab to accept)
          -- 'enter' for enter to accept
          -- 'none' for no mappings
          --
          -- All presets have the following mappings:
          -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = { preset = 'default' },

        appearance = {
            -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono'
        },

        -- (Default) Only show the documentation popup when manually triggered
        completion = { documentation = { auto_show = true } },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        signature = { enabled = true },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" }
	    },
    },
    { 
      "catppuccin/nvim", 
      name = "catppuccin", 
      priority = 1000 
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      opts = {
        filesystem = {
          use_libuv_file_watcher = true,
        },
      },
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons", -- optional, but recommended
      },
      lazy = false, -- neo-tree will lazily load itself
    }
  },
  opts_extend = { "sources.default" },
  checker = { enabled = true },
})

require'blink.cmp'.setup {
  sources = {
    { name = 'nvim_lsp_signature_help' }
  }
}

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = 'Show line diagnostics' })

vim.cmd('colorscheme unokai')