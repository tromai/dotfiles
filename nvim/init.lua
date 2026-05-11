vim.g.mapleader = " "
vim.g.maplocalleader = " "
local opt = vim.opt

vim.opt.clipboard = "unnamedplus"

opt.number = true -- Line numbers
opt.relativenumber = true -- Relative numbers
opt.mouse = "a" -- Mouse support
opt.ignorecase = true -- Search case insensitivity
opt.smartcase = true -- Case sensitive if capital used
opt.termguicolors = true -- 24-bit RGB colors
opt.tabstop = 4 -- Tab width
opt.shiftwidth = 4 -- Indent width
opt.expandtab = true -- Tabs to spaces
opt.showmode = false
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.cursorline = true
opt.scrolloff = 10

-- Indentation
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Smart dd. Credit: https://www.reddit.com/r/neovim/comments/w0jzzv/comment/igfjx5y
vim.keymap.set("n", "dd", function()
    if vim.api.nvim_get_current_line():match "^%s*$" then
        return '"_dd'
    else
        return "dd"
    end
end, { noremap = true, expr = true })

-- Source: https://github.com/ThePrimeagen/init.lua
-- Mimicking Alt + arrow to move a line.
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Custom Netrw Toggle (Requirement: <leader>pv)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Project View (Netrw)" })

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
    -- tmux navigation
    {
        "christoomey/vim-tmux-navigator",
        lazy = false, -- Load immediately for navigation
    },

    -- which-key: show which key is available
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
        end,
    },

    -- showing git hunks in your file
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup {
                signs = {
                    add = { text = "+" },
                    change = { text = "~" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                },
                on_attach = function(bufnr)
                    local gs = require "gitsigns"

                    local function map(mode, l, r, desc)
                        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                    end

                    local next_hunk = function()
                        if vim.wo.diff then
                            vim.cmd.normal { "[c", bang = true }
                        else
                            gs.nav_hunk "next"
                        end
                    end
                    local prev_hunk = function()
                        if vim.wo.diff then
                            vim.cmd.normal { "]c", bang = true }
                        else
                            gs.nav_hunk "prev"
                        end
                    end

                    map("n", "[c", next_hunk, "next hunk")
                    map("n", "]c", prev_hunk, "prev hunk")
                    map("n", "<Leader>hp", gs.preview_hunk, "preview hunk")
                    map({ "n", "v" }, "<Leader>hr", gs.reset_hunk, "reset hunk")
                    map({ "n", "v" }, "<Leader>hs", gs.stage_hunk, "stage hunk")
                    map("n", "<Leader>hu", gs.undo_stage_hunk, "undo stage hunk")
                end,
            }
        end,
    },

    -- telescope for fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require "telescope.builtin"
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Find Files" })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Live Grep" })
            vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Find Buffers" })
            vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Find Help" })
        end,
    },

    -- tree sitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup {
                ensure_installed = { "lua", "go", "python", "yaml", "markdown", "bash", "vimdoc" },
                highlight = { enable = true },
                indent = { enable = true },
            }
        end,
    },

    -- editor theme catppuccin
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000, -- Make sure it loads before other plugins
        config = function()
            require("catppuccin").setup {
                flavour = "latte", -- latte, frappe, macchiato, mocha
                transparent_background = false,
                term_colors = true,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    treesitter = true,
                    notify = false,
                    mini = {
                        enabled = true,
                        indentscope_color = "",
                    },
                },
            }

            -- Set the colorscheme
            vim.cmd.colorscheme "catppuccin"
        end,
    },

    -- auto formatter
    {
        "stevearc/conform.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            formatters_by_ft = {
                python = { "ruff", "stylua" },
            },
            -- format_on_save = {
            --     timeout_ms = 500,
            --     lsp_fallback = true,
            -- },
        },
    },

    -- lsp config
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            -- 1. Initialize Mason
            require("mason").setup()

            -- 2. Define your servers and their custom settings
            local servers = {
                lua_ls = {
                    settings = {
                        Lua = { diagnostics = { globals = { "vim" } } },
                    },
                },
                pyright = {
                    settings = {
                        python = {
                            analysis = {
                                extraPaths = { "lib", "./lib" },
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                            },
                        },
                    },
                },
                ts_ls = {},
            }

            -- 3. Modern 0.12+ Native Integration
            -- This part ensures Mason has them and Neovim knows their "superpowers" (capabilities)
            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_keys(servers),
            })

            -- This tells the LSP that we have a completion menu (nvim-cmp)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- We loop through our table to register and enable them
            for server_name, server_config in pairs(servers) do
                -- Inject the completion capabilities into the server config
                server_config.capabilities = capabilities

                -- Register the template and turn it on
                vim.lsp.config[server_name] = server_config
                vim.lsp.enable(server_name)
            end

            -- 4. Global Keymaps (Optional but recommended)
            -- These trigger only when an LSP actually attaches to a buffer
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
                callback = function(event)
                    -- This helper function 'map' is defined locally inside the callback
                    -- so it has access to 'event.buf' (the current file)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    -- The Mappings
                    map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
                    map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                    map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
                    map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
                    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
                    map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
                    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
                    map("K", vim.lsp.buf.hover, "Hover Documentation")
                    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                end,
            })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp", -- The bridge
            "L3MON4D3/LuaSnip",     -- Required: Snippet engine
            "saadparwaiz1/cmp_luasnip", 
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                -- This is the crucial part!
                -- It tells the menu to look at your LSP for suggestions.
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                }),
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(), -- Force open menu
                    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept suggestion
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
            })
        end,
    }
}
