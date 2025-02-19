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
      "folke/tokyonight.nvim",
      branch = "main",
    },
    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      config = function()
        local state = require("telescope.actions.state")
        local actions = require("telescope.actions")
        require("telescope").setup({
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
                    opts = { nowait = true, slient = true },
                  },
                },
              },
            },
          },
        })
      end,
      dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
      "mbbill/undotree",
      cmd = "UndotreeToggle",
    },
    {
      "L3MON4D3/LuaSnip",
      dependencies = { "mireq/luasnip-snippets" },
      -- follow latest release.
      -- version = "<CurrentMajor>.*",
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
      config = function()
        require("luasnip_snippets.common.snip_utils").setup()
        local luasnip = require("luasnip")
        require("luasnip.loaders.from_snipmate").lazy_load()
        vim.keymap.set("i", "<c-j>", luasnip.expand_or_jump)
        vim.keymap.set("i", "<c-n>", function()
          luasnip.jump(1)
        end)
        vim.keymap.set("i", "<c-p>", function()
          luasnip.jump(-1)
        end)
      end,
      event = "InsertEnter",
    },
    -- {
    --     "SirVer/ultisnips",
    --     dependencies = {"quangnguyen30192/cmp-nvim-ultisnips"},
    --     config = function()
    --         vim.g.UltiSnipsExpandTrigger = "<c-j>"
    --         vim.g.UltiSnipsJumpForwardTrigger = "<c-n>"
    --         vim.g.UltiSnipsJumpBackwardTrigger = "<c-p>"
    --     end
    -- },
    -- {
    -- 	"airblade/vim-gitgutter",
    -- },
    {
      "lewis6991/gitsigns.nvim",
      event = "VeryLazy",
      opts = {
        on_attach = function()
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
      -- for viewing git conflicts
      "akinsho/git-conflict.nvim",
    },
    -- {
    -- 	"ellisonleao/gruvbox.nvim",
    -- },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")
        local cond = require("nvim-autopairs.conds")
        -- local basic_rule = require('nvim-autopairs.rules.basic')
        npairs.setup({
          fast_wrap = {
            map = "<C-f>",
            chars = { "{", "[", "(", '"', "'", "$" },
          },
        })
        -- local bracket = basic_rule.bracket_creator(npairs.config)
        npairs.get_rule("'")[1].not_filetypes = { "latex", "tex" }
        npairs.add_rules({
          Rule("\\{", "\\}", "tex"),
          -- bracket("{", "}", "tex"):with_pair(cond.not_before_text("\\")):with_move(cond.not_before_text("\\")),
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
          -- disable adding a newline when you press <cr>
          -- :with_cr(cond.none()),
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
      cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit" },
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
      event = "LspAttach",
      config = function()
        -- symbol in winbar text colors
        vim.api.nvim_set_hl(0, "SagaWinbarFileName", { fg = "#c0caf5" })
        vim.api.nvim_set_hl(0, "SagaWinbarFolderName", { fg = "#c0caf5" })
        require("lspsaga").setup({
          symbol_in_winbar = {
            enable = false,
            -- separator = "  ",
            -- hide_keyword = true,
            -- show_file = true,
            -- folder_level = 2,
            -- respect_root = false,
            -- color_mode = true,
          },
          ui = {
            border = "rounded",
            -- colors = {
            --     normal_bg = "#1e2021",
            --     blue = "#83a598"
            -- },
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
      event = "InsertEnter",
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
        },
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
          }
        },
        snippets = { preset = "luasnip" },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
      },
    },
    -- {
    --   "hrsh7th/nvim-cmp",
    --   event = { "InsertEnter", "CmdLineEnter" },
    --   dependencies = {
    --     "hrsh7th/cmp-cmdline",
    --     "hrsh7th/cmp-buffer",
    --     "hrsh7th/cmp-nvim-lsp",
    --     "hrsh7th/cmp-omni",
    --     "petertriho/cmp-git",
    --     "hrsh7th/cmp-path",
    --   },
    --   config = function()
    --     local has_words_before = function()
    --       local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    --       return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    --     end
    --
    --     local cmp = require("cmp")
    --     local lspkind = require("lspkind")
    --     -- local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
    --     cmp.setup({
    --       formatting = {
    --         format = lspkind.cmp_format({
    --           mode = "symbol_text",
    --         }),
    --       },
    --       snippet = {
    --         -- expand = function(args)
    --         --     vim.fn["UltiSnips#Anon"](args.body)
    --         -- end
    --         expand = function(args)
    --           require("luasnip").lsp_expand(args.body)
    --         end,
    --       },
    --       -- window = {
    --       -- 	documentation = cmp.config.window.bordered(),
    --       -- 	completion = cmp.config.window.bordered(),
    --       -- },
    --       mapping = {
    --         ["<C-Space>"] = cmp.mapping.confirm({
    --           behavior = cmp.ConfirmBehavior.Insert,
    --           select = true,
    --         }),
    --         ["<Tab>"] = cmp.mapping(function(fallback)
    --           if cmp.visible() then
    --             cmp.select_next_item()
    --           elseif has_words_before() then
    --             cmp.complete()
    --           else
    --             fallback()
    --           end
    --         end, { "i", "s" }),
    --         ["<S-Tab>"] = cmp.mapping(function(fallback)
    --           if cmp.visible() then
    --             cmp.select_prev_item()
    --           else
    --             fallback()
    --           end
    --         end, { "i", "s" }),
    --         ["<C-e>"] = cmp.mapping.abort(),
    --         ["<CR>"] = cmp.mapping.confirm({ select = false }),
    --         ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    --         ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    --         ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
    --         ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
    --       },
    --       sources = cmp.config.sources({
    --         { name = "nvim_lsp" },
    --         -- {name = "ultisnips"}, -- For ultisnips users.
    --         { name = "luasnip" },
    --         { name = "nvim_lsp_signature_help" },
    --       }, {
    --         { name = "buffer" },
    --         { name = "path" },
    --       }),
    --     })
    --
    --     -- Set configuration for specific filetype.
    --     cmp.setup.filetype("gitcommit", {
    --       sources = cmp.config.sources({
    --         { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
    --       }, {
    --         { name = "buffer" },
    --         { name = "path" },
    --       }),
    --     })
    --
    --     -- tex files use omni
    --     cmp.setup.filetype("tex", {
    --       formatting = {
    --         format = function(entry, vim_item)
    --           vim_item.menu = ({
    --             omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
    --             buffer = "[Buffer]",
    --             -- formatting for other sources
    --           })[entry.source.name]
    --           return vim_item
    --         end,
    --       },
    --       sources = cmp.config.sources({
    --         { name = "omni" },
    --         -- {name = "ultisnips"}
    --         { name = "luasnip" },
    --       }, {
    --         { name = "buffer" },
    --         { name = "path" },
    --       }),
    --     })
    --
    --     -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
    --     cmp.setup.cmdline("/", {
    --       mapping = cmp.mapping.preset.cmdline(),
    --       sources = {
    --         { name = "buffer" },
    --       },
    --     })
    --
    --     -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    --     cmp.setup.cmdline(":", {
    --       mapping = cmp.mapping.preset.cmdline(),
    --       sources = cmp.config.sources({
    --         { name = "path" },
    --       }, {
    --         { name = "cmdline" },
    --       }),
    --     })
    --
    --     cmp_autopairs = require("nvim-autopairs.completion.cmp")
    --     cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    --
    --     -- local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    --   end,
    -- },
    -- {
    --   "ray-x/lsp_signature.nvim",
    --   event = "InsertEnter",
    --   opts = function()
    --     require("lsp_signature").on_attach({
    --       bind = true,
    --       handler_opts = {
    --         border = "rounded",
    --       },
    --     })
    --   end,
    -- },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
    },
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      event = "VeryLazy",
      config = function()
        require("nvim-treesitter.configs").setup({
          textobjects = {
            select = {
              enable = true,
              lookahead = true,
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                -- You can optionally set descriptions to the mappings (used in the desc parameter of
                -- nvim_buf_set_keymap) which plugins like which-key display
                ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                -- You can also use captures from other query groups like `locals.scm`
                ["as"] = {
                  query = "@local.scope",
                  query_group = "locals",
                  desc = "Select language scope",
                },
              },
              selection_modes = {
                ["@parameter.outer"] = "v", -- charwise
                ["@function.outer"] = "V", -- linewise
                ["@class.outer"] = "<c-v>", -- blockwise
              },
            },
            swap = {
              enable = true,
              swap_next = {
                ["<leader>sn"] = "@parameter.inner",
              },
              swap_previous = {
                ["<leader>sp"] = "@parameter.inner",
              },
            },
            move = {
              enable = true,
              set_jumps = true, -- whether to set jumps in the jumplist
              goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = { query = "@class.outer", desc = "Next class start" },
                --
                -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
                -- ["]o"] = "@loop.*",
                -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
                ["]o"] = "@loop.outer",
                --
                -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
                -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
                ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
                ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                ["]d"] = { -- Custom keybinding for moving to the next conditional start
                  query = "@conditional.outer",
                  desc = "Jump to next conditional (if, else if, else, switch)",
                },
              },
              goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
              },
              goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
                ["[s"] = { query = "@local.scope", query_group = "locals", desc = "pPrevious scope" },
                ["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
                ["[d"] = { -- Custom keybinding for moving to the next conditional start
                  query = "@conditional.outer",
                  desc = "Jump to next conditional (if, else if, else, switch)",
                },
                ["[o"] = "@loop.outer",
              },
              goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
              },
              -- Below will go to either the start or the end, whichever is closer.
              -- Use if you want more granular movements
              -- Make it even more gradual by adding multiple queries and regex.
              -- goto_next = {
              --   ["]d"] = "@conditional.outer",
              -- },
              -- goto_previous = {
              --   ["[d"] = "@conditional.outer",
              -- },
            },
          },
        })
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
    -- {
    --     "vim-autoformat/vim-autoformat",
    --     config = function()
    --         vim.g.formatdef_latexindent = '"latexindent -m -"'
    --     end,
    --     cmd = {"Autoformat", "AutoformatLine"}
    -- },
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
          -- fill = { fg='#32302f', bg='#1d2021', style='italic' },
          head = "TabLine",
          current_tab = "TabLineSel",
          tab = "TabLine",
          current_win = "TabLineSel",
          win = "TabLine",
          tail = "TabLine",
        }

        -- function darken_color(hex_str)
        -- 	local factor = 0.55
        -- 	local r = tonumber(hex_str:sub(2, 3), 16)
        -- 	local g = tonumber(hex_str:sub(4, 5), 16)
        -- 	local b = tonumber(hex_str:sub(6, 7), 16)
        --
        -- 	r = math.floor(r * factor)
        -- 	g = math.floor(g * factor)
        -- 	b = math.floor(b * factor)
        --
        -- 	r = math.min(r, 255)
        -- 	g = math.min(g, 255)
        -- 	b = math.min(b, 255)
        --
        -- 	return string.format("#%02x%02x%02x", r, g, b)
        -- end

        require("tabby.tabline").set(function(line)
          return {
            -- {
            --   { '  ', hl = theme.head },
            --   line.sep('', theme.head, theme.fill),
            -- },
            line.tabs().foreach(function(tab)
              local hl = tab.is_current() and theme.current_tab or theme.tab
              local filename = require("tabby.filename").tail(vim.api.nvim_tabpage_get_win(tab.id))
              local extension = vim.fn.fnamemodify(filename, ":e")
              -- local fileicon = require'nvim-web-devicons'.get_icon(filename, extension, {default = true})
              local fileicon, color =
                require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
              -- if tab.is_current() then
              -- 	color = darken_color(color)
              -- end
              local bgcolor = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl)), "bg#")
              return {
                -- line.sep("█", hl, theme.fill),
                line.sep("", hl, theme.fill),
                -- tab.is_current() and '' or '',
                tab.number(),
                -- fileicon,
                { fileicon, hl = { fg = color, bg = bgcolor } },
                tab.name(),
                tab.close_btn(""),
                -- line.sep("█", hl, theme.fill),
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
              -- if win.is_current() then
              -- 	color = darken_color(color)
              -- end
              local bgcolor = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl)), "bg#")
              return {
                line.sep("", hl, theme.fill),
                -- win.is_current() and '' or '',
                -- win.file_icon(),
                { fileicon, hl = { fg = color, bg = bgcolor } },
                win.buf_name(),
                line.sep("", hl, theme.fill),
                hl = hl,
                margin = " ",
              }
            end),
            -- {
            --   line.sep('', theme.tail, theme.fill),
            --   { '  ', hl = theme.tail },
            -- },
            hl = theme.fill,
          }
        end)
      end,
      event = "TabNew",
      dependencies = "nvim-tree/nvim-web-devicons",
    },
    {
      "lervag/vimtex",
      config = function()
        -- vim.g.vimtex_view_method = "sioyek"
        -- vim.g.vimtex_view_sioyek_options = "--execute-command toggle_synctex"
        vim.g.vimtex_view_method = "skim"
        -- vim.g.vimtex_quickfix_enabled = 0
        vim.g.vimtex_quickfix_mode = 0
        vim.g.vimtex_fold_enabled = true
        vim.g.vimtex_compiler_progname = "nvr"
        -- vim.g.vimtex_compiler_latexmk_engines = {
        -- 	["_"] = "-xelatex",
        -- }
        vim.g.vimtex_compiler_latexmk = {
          options = {
            "-shell-escape",
            "-verbose",
            "-file-line-error",
            "-synctex=1",
            "-interaction=nonstopmode",
          },
        }
      end,
      ft = "tex",
      cmd = "VimtexInverseSearch",
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
          haskell = { "ormolu" },
          cpp = { "clang-format" },
          c = { "clang-format" },
          tex = { "tex-fmt" },
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

          ["_"] = { "trim_whitespace" },
        },
        formatters = {
          ["clang-format"] = {
            prepend_args = { "-style='{BasedOnStyle: LLVM, IndentWidth: 4}'" },
          },
          stylua = {
            prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          },
        },
      },
    },
    {
      "onsails/lspkind.nvim",
      lazy = true,
    },
    -- {
    --        --haskell
    -- 	"mrcjkb/haskell-tools.nvim",
    -- 	version = "^3", -- Recommended
    -- 	lazy = false, -- This plugin is already lazy
    -- },
    -- ARCHIVED
    -- {
    -- 	"jose-elias-alvarez/null-ls.nvim",
    -- 	config = function()
    -- 		local null_ls = require("null-ls")
    -- 		null_ls.setup({
    -- 			sources = {
    -- 				null_ls.builtins.formatting.latexindent.with({
    -- 					extra_args = { "-m" },
    -- 				}),
    -- 				null_ls.builtins.formatting.prettier.with({
    -- 					extra_args = { "--prose-wrap", "always" },
    -- 				}),
    -- 				null_ls.builtins.formatting.stylua,
    -- 				null_ls.builtins.formatting.black,
    -- 				null_ls.builtins.formatting.isort,
    -- 				--null_ls.builtins.formatting.clang_format.with({
    -- 				--	extra_args = {  "--style", "{BasedOnStyle: llvm, IndentWidth: 4}" },
    -- 				--}),
    -- 				null_ls.builtins.diagnostics.chktex,
    -- 				-- null_ls.builtins.code_actions.gitsigns,
    -- 			},
    -- 		})
    -- 		vim.keymap.set({ "n", "v" }, "<leader>af", vim.lsp.buf.format)
    -- 	end,
    -- },
  },
  install = { colorscheme = { "tokyonight-night" } },
})

-- require("gruvbox").setup({
-- 	undercurl = true,
-- 	underline = true,
-- 	bold = true,
-- 	italic = {
-- 		strings = true,
-- 		comments = true,
-- 		operators = false,
-- 		folds = true,
-- 	},
-- 	strikethrough = true,
-- 	invert_selection = true,
-- 	invert_signs = false,
-- 	invert_tabline = false,
-- 	invert_intend_guides = false,
-- 	inverse = true, -- invert background for search, diffs, statuslines and errors
-- 	contrast = "hard", -- can be "hard", "soft" or empty string
-- 	palette_overrides = {},
-- 	overrides = {
--         GitSignsCurrentLineBlame = {fg="#868686"}
--     },
-- 	dim_inactive = false,
-- 	transparent_mode = false,
-- })

vim.cmd.syntax("on")
-- tokyonight colorscheme (defined earlier)
vim.cmd.colorscheme("tokyonight-night")
-- vim.cmd.colorscheme("gruvbox")
-- no logging
vim.lsp.set_log_level("off")

local set = vim.opt
set.encoding = "utf-8"
-- set.autoindent = true
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
set.undodir = "/Users/ericye/.local/share/nvim/undo"
set.undofile = true
set.completeopt = "menu,menuone,noselect"
-- set.tabstop = 4
set.shiftwidth = 4
-- set.softtabstop = 4
set.expandtab = true
-- set.splitbelow = true
-- set.splitright = true
-- set.termguicolors = true
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
-- fold text highlighting
-- vim.o.foldtext = ''
-- vim.o.fillchars = 'fold: '
-- global statusline
set.laststatus = 3

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

-- local signs = { Error = "", Warn = "", Hint = "󰌵", Information = "󰋼" }
local signs = { Error = "", Warn = "", Hint = "", Information = "" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
-- airline use power line fonts
-- vim.g.airline_powerline_fonts = true

-- vim.g.UltiSnipsExpandTrigger = '<c-j>'
-- vim.g.UltiSnipsJumpForwardTrigger = '<c-n>'
-- vim.g.UltiSnipsJumpBackwardTrigger = '<c-p>'

-- python3 path - change this if version changes
vim.g.python3_host_prog = "/opt/homebrew/bin/python3.11"

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

local lspconfig = require("lspconfig")
-- python
lspconfig.basedpyright.setup({
  cmd = { "/opt/homebrew/lib/node_modules/basedpyright/langserver.index.js", "--stdio" },
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard",
      },
    },
  },
  on_attach = function()
    vim.lsp.inlay_hint.enable(true)
  end,
  --   local underscore_comparator = function(entry1, entry2)
  --     local w1 = string.sub(entry1:get_word(), 1, 1)
  --     local w2 = string.sub(entry2:get_word(), 1, 1)
  --     if w1 == "_" and w2 ~= "_" then
  --       return false
  --     end
  --     if w1 ~= "_" and w2 == "_" then
  --       return true
  --     end
  --     return nil
  --   end
  --   local lsp_types = require("cmp.types").lsp
  --   local parameter_comparator = function(entry1, entry2)
  --     local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
  --     local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]
  --     local p1 = kind1 == "Variable" and entry1:get_completion_item().label:match("%w*=")
  --     local p2 = kind2 == "Variable" and entry2:get_completion_item().label:match("%w*=")
  --     if p1 and not p2 then
  --       return true
  --     end
  --     if p2 and not p1 then
  --       return false
  --     end
  --     return nil
  --   end
  --   local cmp = require("cmp")
  --   cmp.setup.filetype("python", {
  --     sorting = {
  --       comparators = {
  --         cmp.config.compare.offset,
  --         cmp.config.compare.exact,
  --         cmp.config.compare.recently_used,
  --         parameter_comparator,
  --         underscore_comparator,
  --         cmp.config.compare.sort_text,
  --         cmp.config.compare.length,
  --         cmp.config.compare.order,
  --       },
  --     },
  --   })
})
-- javascript
lspconfig.ts_ls.setup({
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

-- c, cpp
local cpp_first_time = true
lspconfig.clangd.setup({
  on_attach = function()
    if cpp_first_time then
      require("clangd_extensions").setup({
        -- inlay_hints = {
        -- 	inline = true,
        -- 	show_parameter_hints = true,
        -- 	parameter_hints_prefix = "← ",
        -- 	other_hints_prefix = " ",
        -- },
      })
      -- cpp files sorting
      -- local cmp = require("cmp")
      -- cmp.setup.filetype("cpp", {
      --   sorting = {
      --     comparators = {
      --       cmp.config.compare.offset,
      --       cmp.config.compare.exact,
      --       cmp.config.compare.recently_used,
      --       require("clangd_extensions.cmp_scores"),
      --       cmp.config.compare.kind,
      --       cmp.config.compare.sort_text,
      --       cmp.config.compare.length,
      --       cmp.config.compare.order,
      --     },
      --   },
      -- })
      cpp_first_time = false
    end
    vim.lsp.inlay_hint.enable(true)
  end,
})

-- haskell
lspconfig.hls.setup({
  filetypes = { "haskell", "lhaskell", "cabal" },
})

-- grammar checker for markdown, latex
local ltex_first_time = true
lspconfig.ltex.setup({
  filetypes = { "tex" },
  settings = {
    ltex = {
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

-- lspconfig.texlab.setup{
--     settings = {
--         texlab = {
--             chktex = {
--                 onEdit = true,
--             },
--             latexindent = {
--                 modifyLineBreaks = true
--             }
--         }
--     }
-- }

-- This is so that ltex would not open in a lspsaga hover window
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    if vim.api.nvim_win_get_config(0).relative == "" and not vim.bo[vim.api.nvim_win_get_buf(0)].readonly then
      vim.cmd("LspStart ltex")
    end
  end,
})

require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all"
  ensure_installed = { "c", "cpp", "python", "javascript", "html", "css", "lua", "markdown", "markdown_inline" },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    disable = { "latex", "typescript" },
    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "c", "rust" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = { "latex" },
  },
})
-- local function diff_source()
-- 	local gitsigns = vim.b.gitsigns_status_dict
-- 	if gitsigns then
-- 		return {
-- 			added = gitsigns.added,
-- 			modified = gitsigns.changed,
-- 			removed = gitsigns.removed,
-- 		}
-- 	end
-- end
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
      format = " {kind_icon}{symbol.name:Normal}",
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
      statusline = { "NvimTree", "packer", "sagaoutline", "undotree", "vimtex-toc", "trouble" },
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
-- local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { silent = true })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { silent = true })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { silent = true })

-- nvimtree
vim.keymap.set("n", "<leader>tr", "<cmd>NvimTreeToggle<cr>", { silent = true, noremap = true })

-- undo tree
vim.keymap.set("n", "<leader>ut", "<cmd>UndotreeToggle<cr>", { silent = true, noremap = true })

-- git conflict
require("git-conflict").setup({
  default_mappings = false,
})
vim.keymap.set("n", "<leader>co", "<Plug>(git-conflict-ours)")
vim.keymap.set("n", "<leader>ct", "<Plug>(git-conflict-theirs)")
vim.keymap.set("n", "<leader>cb", "<Plug>(git-conflict-both)")
vim.keymap.set("n", "<leader>cB", "<Cmd>GitConflictChooseBase<CR>")
vim.keymap.set("n", "<leader>c0", "<Plug>(git-conflict-none)")
vim.keymap.set("n", "[x", "<Plug>(git-conflict-prev-conflict)")
vim.keymap.set("n", "]x", "<Plug>(git-conflict-next-conflict)")
