local M = {}

local keymaps = {
    {
        "n",
        "<Leader>x",
        function()
            vim.cmd([[source %]])
            vim.notify("Sourced current file")
        end,
        desc = "Source current file",
    },

    -- Make Y behave like C or D
    { "n", "Y", "y$" },

    -- Keep window centered when going up/down
    { "n", "<C-d>", "<C-d>zz" },
    { "n", "<C-u>", "<C-u>zz" },

    -- Keep window centered when searching
    { "n", "n", "nzzzv" },
    { "n", "N", "Nzzzv" },

    -- Clear search with <esc> and <C-L>
    { { "i", "n" }, "<esc>", "<cmd>noh<cr><esc>" },
    { { "i", "n" }, "<C-L>", "<cmd>noh<cr><C-L>" },

    -- better indenting
    { "v", "<", "<gv" },
    { "v", ">", ">gv" },

    -- Swap lines matching indentation
    { "n", "<C-j>", "<cmd>m .+1<cr>==", desc = "Move line down" },
    { "n", "<C-Down>", "<cmd>m .+1<cr>==", desc = "Move line down" },
    { "n", "<C-k>", "<cmd>m .-2<cr>==", desc = "Move line up" },
    { "n", "<C-Up>", "<cmd>m .-2<cr>==", desc = "Move line up" },
    { "i", "<C-j>", "<esc><cmd>m .+1<cr>==gi", desc = "Move line down" },
    { "i", "<C-Down>", "<esc><cmd>m .+1<cr>==gi", desc = "Move line down" },
    { "i", "<C-k>", "<esc><cmd>m .-2<cr>==gi", desc = "Move line up" },
    { "i", "<C-Up>", "<esc><cmd>m .-2<cr>==gi", desc = "Move line up" },
    { "v", "<C-j>", ":m '>+1<cr>gv=gv", desc = "Move selection down" },
    { "v", "<C-Down>", ":m '>+1<cr>gv=gv", desc = "Move selection down" },
    { "v", "<C-k>", ":m '<-2<cr>gv=gv", desc = "Move selection up" },
    { "v", "<C-Up>", ":m '<-2<cr>gv=gv", desc = "Move selection up" },

    -- Navigate between quickfix items
    { "n", "<Leader>qn", "<cmd>cnext<CR>zz", desc = "[q]fixlist [n]ext" },
    { "n", "<Leader>qp", "<cmd>cprev<CR>zz", desc = "[q]fixlist [p]revious" },

    -- Buffer
    { "n", "<Leader>bn", "<cmd>bnext<cr>", desc = "[B]uffer [n]ext" },
    { "n", "<Leader>bp", "<cmd>bprevious<cr>", desc = "[B]uffer [p]revious" },
    { "n", "<Leader>bo", "<cmd>e #<cr>", desc = "[B]uffer [o]ther" },
    { "n", "<Leader>bc", "<cmd>bdelete<cr>", desc = "[B]uffer [c]lose" },
    { "n", "<Leader>bd", "<cmd>bdelete!<cr>", desc = "[B]uffer [d]elete" },

    -- Window
    { "n", "<Leader>wj", "<cmd>wincmd j<cr>", desc = "Move to [w]indow below" },
    { "n", "<Leader>wk", "<cmd>wincmd k<cr>", desc = "Move to [w]indow above" },
    { "n", "<Leader>wl", "<cmd>wincmd l<cr>", desc = "Move to [w]indow left" },
    { "n", "<Leader>wh", "<cmd>wincmd h<cr>", desc = "Move to [w]indow right" },
}

local apply_keymap = function()
    for _, t in ipairs(keymaps) do
        vim.keymap.set(t[1], t[2], t[3], { desc = t.desc })
    end
end

local git_branch = function()
    -- Get branch name from git (and redirect stderr to NUL if command fails)
    local branch = vim.fn.system([[git rev-parse --abbrev-ref HEAD 2>NUL]])
    if string.len(branch) > 0 then
        return branch:gsub("\n", "") -- trim any newline character
    else
        return ":"
    end
end

local get_status_line = function()
    -- List color names by running :hi
    local set_color_1 = "%#PmenuSel#"
    local branch = git_branch()
    local set_color_2 = "%#LineNr#"
    local filename = "%f"
    local modified = "%m"
    local align_right = "%="
    local set_color_3 = "%#VisualNOS#"
    local fileencoding = " %{&fileencoding?&fileencoding:&encoding}"
    local fileformat = " [%{&fileformat}]"
    local filetype = " %y"
    local percentage = " %p%%"
    local linecol = " %l:%c"

    return string.format(
        "%s %s %s %s%s%s%s%s%s%s%s%s ",
        set_color_1,
        branch,
        set_color_2,
        filename,
        modified,
        align_right,
        set_color_3,
        fileencoding,
        fileformat,
        filetype,
        percentage,
        linecol
    )
end

local default_opts = {
    keymap = true,
    scrolloff = 5,
}

local get_merged_opts = function(user_opts)
    local merged_opts = default_opts
    if user_opts ~= nil then
        for k, v in pairs(user_opts) do
            merged_opts[k] = v
        end
    end
    return merged_opts
end

M.setup = function(user_opts)
    user_opts = get_merged_opts(user_opts)

    if user_opts.keymap then
        apply_keymap()
    end

    vim.cmd("colorscheme habamax")

    local opt = vim.opt
    -- 24 bit terminal colors
    opt.termguicolors = true
    -- No line wrap
    opt.wrap = false
    -- Number of columns to scroll horizontally
    opt.sidescroll = 1
    -- Number of columns of context for side scrolling
    opt.sidescrolloff = 2
    -- Line numbers
    opt.number = true
    -- Relative line numbers
    opt.relativenumber = true
    -- Backspace and <C-w> behavior
    opt.backspace = { "indent", "eol", "start" }
    -- Prevent from searching include files when auto-complete
    opt.complete:remove({ "-" })
    -- Lines of context when moving up or down
    opt.scrolloff = 5
    -- Disable case sensitive search by default
    opt.ignorecase = true
    -- Case sensitive search only if using an upper case char in the search
    opt.smartcase = true
    -- Match previous line indent
    opt.autoindent = true
    -- Better indenting for C style languages
    opt.smartindent = true
    -- Use spaces instead of tab in insert mode
    opt.expandtab = true
    -- Use spaces instead of tab
    opt.smarttab = true
    -- How many spaces to use per tab character
    opt.shiftwidth = 4
    -- Incremental search
    opt.incsearch = true
    -- Use tab to autocomplete command-line
    opt.wildmenu = true
    -- Save undo state to a file
    opt.undofile = true
    -- Highlight previous searches
    opt.hlsearch = true
    -- Set default spelling language and turn on spell check
    opt.spelllang = { "en" }
    opt.spell = true
    -- Put new windows below current
    opt.splitbelow = true
    -- Put new windows right of current
    opt.splitright = true
    -- Don't auto-insert comments on new line (see :h fo-table)
    opt.formatoptions:remove("o")
     -- Don't wrap lines after textwidth
    opt.formatoptions:remove("c")
    -- Always show the signcolumn, an alternative is 'number', see :h signcolumn
    opt.signcolumn = "yes"

    -- Only one status line and set window separator color to none
    opt.laststatus = 3
    vim.cmd([[highlight WinSeparator guibg=None]])

    -- Set winbar contents
    opt.winbar = [[%=%#NonText#%f %m %#LineNr#%n ]]

    -- Only one status line and set window separator color to none
    opt.laststatus = 3
    vim.cmd([[highlight WinSeparator guibg=None]])

    -- Defines signs
    vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
    vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
    vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
    vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

    if user_opts.statusline then
        opt.statusline = get_status_line()
    end
end

return M
