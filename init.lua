vim.loader.enable() -- enable early bytecode compilation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      opts = {
        integrations = { blink_cmp = true },
      },
    },
    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      config = function()
        local state = require("telescope.actions.state")
        local actions = require("telescope.actions")
        local telescope = require("telescope")
        telescope.setup({
          pickers = {
            find_files = {
              mappings = {
                i = {
                  ["<C-s>"] = {
                    function(_bufnr)
                      vim.system({ "open", state.get_selected_entry()[1] })
                      actions.close(_bufnr)
                    end,
                    type = "action",
                    opts = { nowait = true, silent = true },
                  },
                },
              },
            },
          },
        })
        telescope.load_extension("fzf")
      end,
      dependencies = {
        "nvim-lua/plenary.nvim",
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
        },
      },
    },
    {
      "mbbill/undotree",
      cmd = "UndotreeToggle",
    },
    {
      "L3MON4D3/LuaSnip",
      dependencies = { "honza/vim-snippets" },
      -- follow latest release.
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
      config = function()
        local ls = require("luasnip")
        require("luasnip.loaders.from_snipmate").lazy_load()
        vim.keymap.set("i", "<c-j>", ls.expand_or_jump)
        vim.keymap.set("i", "<c-n>", function()
          ls.jump(1)
        end)
        vim.keymap.set("i", "<c-p>", function()
          ls.jump(-1)
        end)

        -- LaTeX item snipper (deindents as well)
        local s = ls.snippet
        local f = ls.function_node
        local i = ls.insert_node

        -- LaTeX item snipper (deindents as well)
        ls.add_snippets("tex", {
          s({
            -- Matches the start of the line (^), captures all whitespace (%s*), followed by 'it'
            trig = "^(%s*)it",
            trigEngine = "pattern",
            priority = 2000,
          }, {
            f(function(_, snip)
              -- snip.captures[1] contains the whitespace captured by (%s*)
              local indent = snip.captures[1]
              local sw = vim.o.shiftwidth

              -- Trim 'sw' number of spaces from the captured indent
              local new_indent = indent:sub(sw + 1)

              return new_indent .. "\\item "
            end),
            -- Drops your cursor right after the space so you can start typing
            i(1),
          }),
        })
      end,
      event = "InsertEnter",
    },
    {
      "lewis6991/gitsigns.nvim",
      event = "VeryLazy",
      opts = {
        on_attach = function(bufnr)
          local gitsigns = require("gitsigns")

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gitsigns.nav_hunk("next")
            end
          end)

          map("n", "[c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gitsigns.nav_hunk("prev")
            end
          end)

          -- Actions
          map("n", "<leader>hs", gitsigns.stage_hunk)
          map("n", "<leader>hr", gitsigns.reset_hunk)
          map("v", "<leader>hs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end)
          map("v", "<leader>hr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end)
          map("n", "<leader>hS", gitsigns.stage_buffer)
          map("n", "<leader>hu", gitsigns.undo_stage_hunk)
          map("n", "<leader>hR", gitsigns.reset_buffer)
          map("n", "<leader>hp", gitsigns.preview_hunk)
          map("n", "<leader>hb", function()
            gitsigns.blame_line({ full = true })
          end)
          map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
          map("n", "<leader>hd", gitsigns.diffthis)
          map("n", "<leader>hD", function()
            gitsigns.diffthis("~")
          end)
          map("n", "<leader>td", gitsigns.toggle_deleted)

          -- Text object
          map({ "o", "x" }, "ih", "<Cmd><C-U>Gitsigns select_hunk<CR>")
        end,
      },
    },
    {
      "rhysd/conflict-marker.vim",
      config = function()
        vim.g.conflict_marker_enable_mappings = 0
        vim.g.conflict_marker_highlight_group = ""

        -- Set conflict marker patterns
        vim.g.conflict_marker_begin = "^<<<<<<<\\+ .*$"
        vim.g.conflict_marker_common_ancestors = "^|||||||\\+ .*$"
        vim.g.conflict_marker_end = "^>>>>>>>\\+ .*$"

        -- Define highlight groups
        vim.api.nvim_set_hl(0, "ConflictMarkerBegin", { bg = "#2a4e4c" })
        vim.api.nvim_set_hl(0, "ConflictMarkerOurs", { bg = "#283d2a" })
        vim.api.nvim_set_hl(0, "ConflictMarkerTheirs", { bg = "#26355a" })
        vim.api.nvim_set_hl(0, "ConflictMarkerEnd", { bg = "#1e4055" })
        vim.api.nvim_set_hl(0, "ConflictMarkerCommonAncestorsHunk", { bg = "#36274d" })

        vim.keymap.set("n", "<leader>ct", "<Cmd>ConflictMarkerThemselves<CR>")
        vim.keymap.set("n", "<leader>cO", "<Cmd>ConflictMarkerOurselves<CR>")
        vim.keymap.set("n", "<leader>cb", "<Cmd>ConflictMarkerBoth<CR>")
        vim.keymap.set("n", "<leader>cB", "<Cmd>ConflictMarkerBoth!<CR>")
        vim.keymap.set("n", "<leader>cn", "<Cmd>ConflictMarkerNone<CR>")
        vim.keymap.set("n", "]x", "<Cmd>ConflictMarkerNextHunk<CR>")
        vim.keymap.set("n", "[x", "<Cmd>ConflictMarkerPrevHunk<CR>")
      end,
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")
        local cond = require("nvim-autopairs.conds")
        npairs.setup({
          fast_wrap = {
            map = "<C-f>",
            chars = { "{", "[", "(", '"', "'", "$" },
          },
        })
        npairs.get_rule("'")[1].not_filetypes = { "latex", "tex", "rust" }
        npairs.add_rules({
          Rule("\\{", "\\}", "tex"),
          Rule("$", "$", { "tex", "latex" })
            -- pair only if no backslashes in front
            :with_pair(cond.not_before_text("\\"))
            -- pair only if no matching end bracket
            :with_pair(
              cond.not_after_regex([=[[%w%%%'%[%"%.%`%$]]=])
            )
            -- pair only if not in math mode
            :with_pair(function()
              return vim.api.nvim_call_function("vimtex#syntax#in_mathzone", {}) == 0
            end)
            -- move right when repeating $
            :with_move(cond.not_before_text("\\")),
        })
      end,
    },
    {
      "windwp/nvim-ts-autotag",
      ft = {
        "html",
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "svelte",
        "vue",
        "jsx",
        "rescript",
        "xml",
        "php",
        "markdown",
        "astro",
        "glimmer",
        "handlebars",
        "hbs",
      },
      config = true,
    },
    {
      "nvim-tree/nvim-tree.lua",
      cmd = { "NvimTreeToggle", "NvimTreeOpen" },
      config = true,
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
      "tpope/vim-fugitive",
      cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gedit" },
    },
    {
      "neovim/nvim-lspconfig",
    },
    -- ltex lsp plugin
    {
      "barreiroleo/ltex-extra.nvim",
      lazy = true,
    },
    -- clangd lsp plugin
    {
      "p00f/clangd_extensions.nvim",
      lazy = true,
    },
    {
      "nvimdev/lspsaga.nvim",
      cmd = "Lspsaga",
      config = function()
        require("lspsaga").setup({
          symbol_in_winbar = {
            enable = false,
          },
          ui = {
            border = "rounded",
          },
          code_action = {
            extend_gitsigns = true,
          },
        })
      end,
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
      "saghen/blink.cmp",
      version = "*",
      event = { "InsertEnter", "CmdLineEnter" },
      opts = {
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
          per_filetype = {
            tex = { "omni", "path", "snippets", "buffer" },
          },
        },
        keymap = {
          preset = "enter",
          ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
          ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
          ["<C-p>"] = {},
          ["<C-n>"] = {},
          ["<C-k>"] = {},
        },
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
          menu = {
            draw = {
              treesitter = { "lsp" },
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
          },
        },
        snippets = { preset = "luasnip" },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        cmdline = {
          completion = {
            menu = {
              auto_show = true,
            },
            list = {
              selection = {
                preselect = false,
                auto_insert = true,
              },
            },
          },
          keymap = {
          },
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      branch = "main",
      config = function()
        local ts = require("nvim-treesitter")
        local used_languages = {
          "c",
          "cpp",
          "python",
          "javascript",
          "typescript",
          "html",
          "css",
          "lua",
          "markdown",
          "markdown_inline",
          "json",
        }
        ts.install(used_languages)
        vim.api.nvim_create_autocmd("FileType", {
          pattern = used_languages,
          callback = function()
            vim.treesitter.start()
          end,
        })
      end,
    },
    {
      "brenoprata10/nvim-highlight-colors",
      config = true,
      event = "BufReadPre",
    },
    {
      "davidmh/mdx.nvim",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      event = "VeryLazy",
      branch = "main",
      config = function()
        require("nvim-treesitter-textobjects").setup({
          select = {
            lookahead = true,
          },
        })
        vim.keymap.set("n", "<leader>sn", function()
          require("nvim-treesitter-textobjects.swap").swap_next({ "@parameter.inner", "@function.outer" })
        end)
        vim.keymap.set("n", "<leader>sp", function()
          require("nvim-treesitter-textobjects.swap").swap_previous({ "@parameter.outer", "@function.outer" })
        end)
        vim.keymap.set({ "x", "o" }, "af", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
        end)
        vim.keymap.set({ "x", "o" }, "if", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
        end)
        vim.keymap.set({ "x", "o" }, "ac", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
        end)
        vim.keymap.set({ "x", "o" }, "ic", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
        end)
        -- You can also use captures from other query groups like `locals.scm`
        vim.keymap.set({ "x", "o" }, "as", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
        end)
        vim.keymap.set({ "n", "x", "o" }, "]m", function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
        end)
        vim.keymap.set({ "n", "x", "o" }, "]]", function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
        end)
        -- You can also pass a list to group multiple queries.
        vim.keymap.set({ "n", "x", "o" }, "]o", function()
          require("nvim-treesitter-textobjects.move").goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
        end)
        -- You can also use captures from other query groups like `locals.scm` or `folds.scm`
        vim.keymap.set({ "n", "x", "o" }, "]s", function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
        end)
        vim.keymap.set({ "n", "x", "o" }, "]z", function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
        end)

        vim.keymap.set({ "n", "x", "o" }, "]M", function()
          require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
        end)
        vim.keymap.set({ "n", "x", "o" }, "][", function()
          require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
        end)

        vim.keymap.set({ "n", "x", "o" }, "[m", function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
        end)
        vim.keymap.set({ "n", "x", "o" }, "[[", function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
        end)

        vim.keymap.set({ "n", "x", "o" }, "[M", function()
          require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
        end)
        vim.keymap.set({ "n", "x", "o" }, "[]", function()
          require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
        end)

        -- Go to either the start or the end, whichever is closer.
        -- Use if you want more granular movements
        vim.keymap.set({ "n", "x", "o" }, "]d", function()
          require("nvim-treesitter-textobjects.move").goto_next("@conditional.outer", "textobjects")
        end)
        vim.keymap.set({ "n", "x", "o" }, "[d", function()
          require("nvim-treesitter-textobjects.move").goto_previous("@conditional.outer", "textobjects")
        end)
      end,
    },
    {
      "kylechui/nvim-surround",
      version = "*", -- Use for stability; omit to use `main` branch for the latest features
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({
          -- Configuration here, or leave empty to use defaults
        })
      end,
    },
    {
      "akinsho/toggleterm.nvim",
      config = function()
        require("toggleterm").setup({
          open_mapping = [[<c-\>]],
        })
        -- settings for terminal
        -- if you only want these mappings for toggle term use term://*toggleterm#* instead
        vim.api.nvim_create_autocmd({ "TermOpen" }, {
          pattern = "term://*",
          callback = function()
            local opts = { buffer = 0 }
            vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
            vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
          end,
        })
      end,
      keys = {
        { [[<C-\>]], desc = "Toggle terminal" },
      },
      cmd = "ToggleTerm",
    },
    {
      url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git",
      config = function()
        require("rainbow-delimiters.setup").setup({
          highlight = {
            "RainbowDelimiterBlue",
            "RainbowDelimiterViolet",
            "RainbowDelimiterOrange",
            "RainbowDelimiterYellow",
            "RainbowDelimiterCyan",
            "RainbowDelimiterGreen",
          },
        })
      end,
    },
    {
      "nanozuki/tabby.nvim",
      config = function()
        -- tabby
        vim.api.nvim_set_hl(0, "TabLineFill", { fg = "#a9b1d6", bg = "#000000" })
        vim.api.nvim_set_hl(0, "TabLine", { fg = "#a9b1d6", bg = "#000000" })
        vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#c0caf5", bg = "#1a1b26", bold = true })
        local theme = {
          fill = "TabLineFill",
          head = "TabLine",
          current_tab = "TabLineSel",
          tab = "TabLine",
          current_win = "TabLineSel",
          win = "TabLine",
          tail = "TabLine",
        }

        local themeBg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg#")
        local themeFill = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(theme.fill)), "bg#")

        require("tabby.tabline").set(function(line)
          local num_wins = #line.api.get_tab_wins(line.api.get_current_tab())
          local win_no = 0
          return {
            line.tabs().foreach(function(tab)
              local hl = tab.is_current() and theme.current_tab or theme.tab
              local filename = require("tabby.filename").tail(vim.api.nvim_tabpage_get_win(tab.id))
              local extension = vim.fn.fnamemodify(filename, ":e")
              local fileicon, color =
                require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
              local bgcolor = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl)), "bg#")
              return {
                {
                  tab.number() == 1 and (tab.is_current() and "█" or "") or "",
                  hl = {
                    fg = (tab.number() == 1 and not tab.is_current()) and themeBg or bgcolor,
                    bg = themeFill,
                  },
                },
                tab.number(),
                { fileicon, hl = { fg = color, bg = bgcolor } },
                tab.name(),
                tab.close_btn(""),
                line.sep("", hl, theme.fill),
                hl = hl,
                margin = " ",
              }
            end),
            line.spacer(),
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
              local hl = win.is_current() and theme.current_win or theme.win
              local filename = require("tabby.filename").tail(win.id)
              local extension = vim.fn.fnamemodify(filename, ":e")
              local fileicon, color =
                require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
              local bgcolor = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl)), "bg#")
              win_no = win_no + 1
              return {
                line.sep("", hl, theme.fill),
                { fileicon, hl = { fg = color, bg = bgcolor } },
                win.buf_name(),
                {
                  win_no == num_wins and (win.is_current() and "█" or "") or "",
                  hl = {
                    fg = (win_no == num_wins and not win.is_current()) and themeBg or bgcolor,
                    bg = themeFill,
                  },
                },
                hl = hl,
                margin = " ",
              }
            end),
            hl = theme.fill,
          }
        end)
      end,
      event = "TabNew",
      cmd = "Tabby",
      dependencies = "nvim-tree/nvim-web-devicons",
    },
    {
      "lervag/vimtex",
      config = function()
        vim.g.vimtex_view_method = "skim"
        vim.g.vimtex_quickfix_mode = 0

        vim.g.vimtex_fold_enabled = true
        vim.g.vimtex_compiler_progname = "nvr"
        vim.g.vimtex_compiler_latexmk = {
          options = {
            "-shell-escape",
            "-verbose",
            "-file-line-error",
            "-synctex=1",
            "-interaction=nonstopmode",
          },
        }

        local ns = vim.api.nvim_create_namespace("vimtex_diagnostics")

        local function set_vimtex_diagnostics()
          local qf = vim.fn.getqflist()
          if not qf or vim.tbl_isempty(qf) then
            vim.diagnostic.reset(ns)
            return
          end

          local diagnostics_by_buf = {}

          for _, item in ipairs(qf) do
            if item.bufnr and item.bufnr > 0 and item.lnum > 0 then
              local severity = vim.diagnostic.severity.ERROR
              if item.type == "W" then
                severity = vim.diagnostic.severity.WARN
              elseif item.type == "I" then
                severity = vim.diagnostic.severity.INFO
              end

              local diag = {
                lnum = item.lnum - 1,
                col = math.max(item.col - 1, 0),
                message = item.text or "",
                severity = severity,
                source = "vimtex",
              }

              diagnostics_by_buf[item.bufnr] = diagnostics_by_buf[item.bufnr] or {}
              table.insert(diagnostics_by_buf[item.bufnr], diag)
            end
          end

          vim.diagnostic.reset(ns)
          for bufnr, diags in pairs(diagnostics_by_buf) do
            vim.diagnostic.set(ns, bufnr, diags)
          end
        end

        vim.api.nvim_create_autocmd("User", {
          pattern = { "VimtexEventCompileFailed", "VimtexEventCompileSuccess" },
          callback = set_vimtex_diagnostics,
        })
      end,
      ft = "tex",
      cmd = "VimtexInverseSearch",
    },
    {
      "julian/lean.nvim",
      event = { "BufReadPre *.lean", "BufNewFile *.lean" },
      opts = { -- see below for full configuration options
        mappings = true,
      },
    },
    {
      "mfussenegger/nvim-lint",
      config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
          tex = { "chktex" },
        }
        vim.api.nvim_create_autocmd({ "BufRead", "BufWritePost", "InsertLeave", "TextChanged" }, {
          callback = function()
            lint.try_lint()
          end,
        })
      end,
      -- change this if we add more linters
      ft = "tex",
    },
    {
      "folke/trouble.nvim",
      branch = "main", -- IMPORTANT!
      event = "LspAttach",
      keys = {
        {
          "<leader>xx",
          "<cmd>Trouble diagnostics toggle<cr>",
          desc = "Diagnostics (Trouble)",
        },
        {
          "<leader>xX",
          "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
          desc = "Buffer Diagnostics (Trouble)",
        },
        {
          "<leader>cs",
          "<cmd>Trouble symbols toggle focus=false<cr>",
          desc = "Symbols (Trouble)",
        },
        {
          "<leader>cl",
          "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
          desc = "LSP Definitions / references / ... (Trouble)",
        },
        {
          "<leader>xL",
          "<cmd>Trouble loclist toggle<cr>",
          desc = "Location List (Trouble)",
        },
        {
          "<leader>xq",
          "<cmd>Trouble qflist toggle<cr>",
          desc = "Quickfix List (Trouble)",
        },
      },
      config = true,
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      config = function()
        require("ibl").setup({ scope = { enabled = false } })
      end,
    },
    {
      "stevearc/conform.nvim",
      keys = {
        {
          "<leader>af",
          function()
            require("conform").format({ async = true })
          end,
          desc = "Format file",
        },
      },
      opts = {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
          cpp = { "clang-format" },
          c = { "clang-format" },
          tex = { "latexindent" },
          bib = { "tex-fmt" },
          -- prettier
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          markdown = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          yaml = { "prettier" },
          json = { "prettier" },
          astro = { "prettier" },

          ["_"] = { "trim_whitespace" },
        },
        formatters = {
          ["clang-format"] = {
            prepend_args = { "--style={BasedOnStyle: LLVM, IndentWidth: 4}" },
          },
          stylua = {
            prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          },
          latexindent = {
            args = { "-m", "-" },
            stdin = true,
          },
        },
      },
    },
    {
      "https://codeberg.org/andyg/leap.nvim.git",
      lazy = true,
      keys = {
        { "<leader>\\", "<Plug>(leap)", mode = { "n", "x", "o" } },
        { "<leader>j", "<Plug>(leap-from-window)" },
      },
    },
  },
  install = { colorscheme = { "catppuccin-mocha" } },
})

vim.cmd.syntax("on")
vim.cmd.colorscheme("catppuccin-mocha")
-- no logging
vim.lsp.log.set_level("off")

local set = vim.opt
set.encoding = "utf-8"
set.cursorline = true
set.hidden = true
set.incsearch = true
set.hlsearch = true
set.ignorecase = true
set.smartcase = true
set.mouse = "a"
set.showmode = false
set.number = true
set.relativenumber = true
set.showcmd = true
set.undodir = vim.fs.normalize("~/.local/share/nvim/undo")
set.undofile = true
set.completeopt = "menu,menuone,noselect"
set.tabstop = 8
set.shiftwidth = 4
-- so that we scroll by screen line
set.smoothscroll = true
set.exrc = true
set.expandtab = true
-- don't refresh screen during macros
set.lazyredraw = true
set.wrap = true
set.linebreak = true
-- So that I can fast-forward with auto pairs
set.scrolloff = 1
-- lines to scroll when using mouse
set.mousescroll = "ver:2,hor:5"
-- folding
set.foldmethod = "expr"
set.foldexpr = "v:lua.vim.treesitter.foldexpr()"
set.foldenable = false
-- global statusline
set.laststatus = 3

set.breakindent = true
set.breakindentopt = "shift:2"
set.showbreak = "↳"

-- Jump to last location
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  pattern = { "*" },
  callback = function()
    local ft = vim.opt_local.filetype:get()
    -- don't apply to git messages
    if ft:match("commit") or ft:match("rebase") then
      return
    end
    -- get position of last saved edit
    local markpos = vim.api.nvim_buf_get_mark(0, '"')
    local line = markpos[1]
    local col = markpos[2]
    -- if in range, go there
    if (line > 1) and (line <= vim.api.nvim_buf_line_count(0)) then
      vim.api.nvim_win_set_cursor(0, { line, col })
    end
  end,
})

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "󰌶",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  virtual_text = {
    prefix = "●",
  },
})

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { silent = true })
vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { silent = true })
vim.keymap.set("n", "gh", "<cmd>Lspsaga finder<CR>", { silent = true })
vim.keymap.set("n", "gr", "<cmd>Lspsaga rename<CR>", { silent = true })
vim.keymap.set("n", "gR", "<cmd>Lspsaga rename ++project<CR>", { silent = true })
vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })
vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })
-- toggle inlay hint
vim.keymap.set("n", "gi", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { silent = true })
-- Show line diagnostics
-- You can pass argument ++unfocus to
-- unfocus the show_line_diagnostics floating window
vim.keymap.set("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>")

-- Show buffer diagnostics
vim.keymap.set("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")

-- Show workspace diagnostics
vim.keymap.set("n", "<leader>sw", "<cmd>Lspsaga show_workspace_diagnostics<CR>")

-- Show cursor diagnostics
vim.keymap.set("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")
-- Diagnostic jump with filters such as only jumping to an error
vim.keymap.set("n", "[E", function()
  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "]E", function()
  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
-- Outline
vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { silent = true })

-- code action
vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })
vim.keymap.set("v", "<leader>ca", "<cmd><C-U>Lspsaga range_code_action<CR>", { silent = true })
-- incoming/outgoing calls
vim.keymap.set("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
vim.keymap.set("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")

vim.keymap.set({ "n", "t" }, "∂", "<cmd>Lspsaga term_toggle<CR>", { silent = true })

local capabilities = {
  textDocument = {
    completion = {
      completionItem = {
        commitCharactersSupport = false,
        deprecatedSupport = true,
        documentationFormat = { "markdown", "plaintext" },
        insertReplaceSupport = true,
        insertTextModeSupport = {
          valueSet = { 1 },
        },
        labelDetailsSupport = true,
        preselectSupport = false,
        resolveSupport = {
          properties = { "documentation", "detail", "additionalTextEdits", "command", "data" },
        },
        snippetSupport = true,
        tagSupport = {
          valueSet = { 1 },
        },
      },
      completionList = {
        itemDefaults = { "commitCharacters", "editRange", "insertTextFormat", "insertTextMode", "data" },
      },
      contextSupport = true,
      insertTextMode = 1,
    },
  },
}
-- python
vim.lsp.config("ty", {
  capabilities = capabilities,
  settings = {
    environment = {
      python = "python3"
    }
  },
  on_attach = function()
    vim.lsp.inlay_hint.enable(true)
  end
})
vim.lsp.enable("ty")
-- javascript
vim.lsp.config("tsgo", {
  capabilities = capabilities,
  cmd = {"tsc", "--lsp", "--stdio"},
  settings = {
    javascript = {
      inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = false,
      },
    },
    typescript = {
      inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = false,
      },
    },
  },
  on_attach = function()
    vim.lsp.inlay_hint.enable(true)
  end,
})
vim.lsp.enable("tsgo")

vim.lsp.config("astro", {
  capabilities = capabilities,
  init_options = {
    typescript = {
      tsdk = "/opt/homebrew/lib/node_modules/typescript/lib/",
    },
  },
  on_attach = function()
    vim.lsp.inlay_hint.enable(true)
  end,
})
vim.lsp.enable("astro")

-- c, cpp
local cpp_first_time = true
vim.lsp.config("clangd", {
  capabilities = capabilities,
  on_attach = function()
    if cpp_first_time then
      require("clangd_extensions").setup({
      })
      cpp_first_time = false
    end
    vim.lsp.inlay_hint.enable(true)
  end,
})
vim.lsp.enable("clangd")

-- grammar checker for markdown, latex
local ltex_first_time = true
vim.lsp.config("ltex_plus", {
  filetypes = { "tex" },
  settings = {
    ltex = {
      enabled = { "latex", "markdown" },
      ["ltex.latex.commands"] = {
        ["\\texttt{}"] = "dummy",
        ["\\newcounter{}[]"] = "ignore",
        ["\\PassOptionsToPackage{}{}"] = "ignore",
        ["\\SetKwData{}{}"] = "ignore",
        ["\\SetKwArray{}{}"] = "ignore",
        ["\\includepdf[]{}"] = "ignore",
        ["\\newcommand{}{}"] = "ignore",
        ["\\setmonofont[]{}"] = "ignore",
        ["\\setmonofont{}"] = "ignore",
        ["\\tcbset{}"] = "ignore",
        ["\\pgfplotsset{}"] = "ignore",
        ["\\DeclareFontShape{}{}{}{}{}{}"] = "ignore",
        ["\\DeclarePairedDelimiter{}{}{}"] = "ignore",
        ["\\DeclarePairedDelimiterX{}[]{}{}{}"] = "ignore",
        ["\\newenvironment{}{}{}"] = "ignore",
        ["\\newenvironment{}[][]{}{}"] = "ignore",
        ["\\renewenvironment{}{}{}"] = "ignore",
        ["\\renewenvironment{}[][]{}{}"] = "ignore",
        ["\\usepgfplotslibrary{}"] = "ignore",
        ["\\pgfdeclareplotmark{}{}"] = "ignore",
        ["\\NewEnviron{}{}"] = "ignore",
        ["\\microtypecontext{}"] = "ignore",
        ["\\usegdlibrary{}"] = "ignore",
        ["\\newtcbox{}{}"] = "ignore",
      },
      ["ltex.latex.environments"] = {
        algorithm = "ignore",
        quantikz = "ignore",
        forest = "ignore",
      },
    },
  },
  on_attach = function()
    if ltex_first_time then
      ltex_first_time = false
      require("ltex_extra").setup({
        load_langs = { "en-US" },
        init_check = true,
        path = "~/.local/share/nvim/dictionary/",
      })
    end
  end,
})
vim.lsp.enable("ltex_plus")

-- This is so that ltex would not open in a lspsaga hover window
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    if vim.api.nvim_win_get_config(0).relative == "" and not vim.bo[vim.api.nvim_win_get_buf(0)].readonly then
      vim.lsp.start({ name = "ltex_plus", cmd = { "ltex-ls-plus" }, root_dir = "." })
    end
  end,
})

local symbols = nil
function symbols_has()
  if symbols ~= nil then
    return symbols.has()
  end
  if package.loaded["trouble"] ~= nil then
    local trouble = require("trouble")
    symbols = trouble.statusline({
      mode = "lsp_document_symbols",
      groups = {},
      title = false,
      filter = { range = true },
      format = "{kind_icon}{symbol.name:Normal}",
      -- The following line is needed to fix the background color
      -- Set it to the lualine section you want to use
      hl_group = "lualine_c_normal",
    })
    return symbols.has()
  end
  return false
end

require("lualine").setup({
  options = {
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = {
      "filename",
      {
        function()
          return symbols.get()
        end,
        cond = symbols_has,
      },
    },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

-- telescope keymappings
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { silent = true })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { silent = true })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { silent = true })
vim.keymap.set("n", "<leader>fw", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { silent = true })

-- nvimtree
vim.keymap.set("n", "<leader>tr", "<cmd>NvimTreeToggle<cr>", { silent = true, noremap = true })

-- undo tree
vim.keymap.set("n", "<leader>ut", "<cmd>UndotreeToggle<cr>", { silent = true, noremap = true })

-- Toogle diagnostics
local toggle_diagnostics = function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end

vim.keymap.set("n", "<leader>d", toggle_diagnostics)

local tty = vim.uv.new_tty(1, false)
if tty ~= nil then
  -- set bg color
  local update_count = 0

  local reset = function()
    if os.getenv("TMUX") then
      tty:write("\x1bPtmux;\x1b\x1b]111\x07\x1b\\")
    elseif os.getenv("TERM") == "xterm-kitty" then
      for _ = 1, update_count do
        tty:write("\x1b]30101\x07")
      end
    else
      tty:write("\x1b]111\x07")
    end
  end

  local update = function()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false, create = false })
    local bg = normal.bg
    local fg = normal.fg
    if bg == nil then
      return reset()
    end
    local bghex = string.format("#%06x", bg)
    local fghex = string.format("#%06x", fg)
    if os.getenv("TERM") == "xterm-kitty" then
      tty:write("\x1b]30001\x07")
    end

    if os.getenv("TMUX") then
      tty:write("\x1bPtmux;\x1b\x1b]11;" .. bghex .. "\x07\x1b\\")
      tty:write("\x1bPtmux;\x1b\x1b]12;" .. fghex .. "\x07\x1b\\")
    else
      tty:write("\x1b]11;" .. bghex .. "\x07")
      tty:write("\x1b]12;" .. fghex .. "\x07")
    end
    update_count = update_count + 1
  end

  vim.api.nvim_create_autocmd({ "ColorScheme", "UIEnter" }, { callback = update })
  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, { callback = reset })
end
