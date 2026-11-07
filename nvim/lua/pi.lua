-- pi.nvim — run pi in a split terminal and send selections to it
-- Keymaps (leader = space):
--   <leader>pp        open / focus the pi split
--   <leader>ps        (visual) send selection to pi, ask your question there
--   <leader>pa        (visual) prompt for a question, send selection + question
--   <leader>pa        (normal) prompt for a question, send whole file + question
--   <leader>pd        close the pi split (keeps the session buffer around)
--
-- Navigation out of the pi terminal split:
--   <C-w>h       back to the editor window
--   <C-w>l       focus right split
--   <C-w>d       close the pi window
--   <Esc><Esc>   escape to terminal-normal mode (then use any <C-w> command)
--   <C-h/j/k/l>  navigate out via vim-tmux-navigator (works across nvim splits,
--                the pi terminal, and tmux panes; pi never sees these keys)

local M = {}

local chan = nil
local buf = nil

local PI_CMD = vim.fn.executable("pi") == 1 and "pi" or nil
if not PI_CMD then
  vim.notify("pi not found on PATH", vim.log.levels.ERROR)
  return M
end

local function in_pi_win()
  local ok, is_term = pcall(function()
    return vim.bo.buftype == "terminal"
  end)
  return ok and is_term and buf and vim.api.nvim_get_current_buf() == buf
end

function M.open()
  -- Reuse the existing pi buffer if it's alive
  if buf and vim.api.nvim_buf_is_valid(buf) then
    -- Find its window, or open a split showing it
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
      vim.api.nvim_set_current_win(win)
    else
      vim.cmd("vertical sbuffer " .. buf)
    end
  else
    vim.cmd("vsplit")
    vim.cmd("terminal " .. PI_CMD)
    buf = vim.api.nvim_get_current_buf()
    chan = vim.b.terminal_job_id
  end
  -- If the user had scrolled back (terminal-normal mode), jump to the bottom.
  -- In terminal mode ("t") :normal is illegal, and pi follows its own output anyway.
  local m = vim.fn.mode()
  if m ~= "t" then
    pcall(vim.cmd, "normal! G")
  end
  -- Back to terminal mode so you can type immediately
  if m ~= "t" then
    vim.cmd("startinsert")
  end
  return buf
end

---Send text into the pi prompt and submit it.
--Multiline text is wrapped in a bracketed paste so pi treats it as one paste.
function M.send(text)
  M.open()
  if not chan then
    return
  end
  local paste = "\27[200~" .. text .. "\27[201~"
  vim.fn.chansend(chan, paste)
  vim.defer_fn(function()
    if chan then
      vim.fn.chansend(chan, "\r") -- Enter submits the prompt
      -- No scrolling here: we are in terminal mode at this point, and
      -- pi's TUI follows its own output.
    end
  end, 100)
end

-- Helper: visual selection respecting start/end columns
local function get_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then
    return ""
  end
  local start_col, end_col = start_pos[3], end_pos[3]
  if vim.o.selection == "exclusive" then
    end_col = end_col - 1
  end
  -- Only trim columns on single-line selections; multiline block edge-cases
  -- are rare and pi doesn't care about trailing characters
  if #lines == 1 then
    lines[1] = lines[1]:sub(start_col, end_col)
  end
  return table.concat(lines, "\n")
end

local function ask_with(question_fn)
  local q = vim.fn.input("pi> ")
  if q == "" then
    return
  end
  local context = question_fn()
  if context and context ~= "" then
    M.send(context .. "\n\n" .. q)
  else
    M.send(q)
  end
end

-- ── Keymaps ─────────────────────────────────────────────────────────────

-- Open / focus pi
vim.keymap.set("n", "<leader>pp", M.open, { desc = "pi: open/focus split" })

-- Send visual selection, no question: pi opens with the text in the prompt
-- so you can continue typing your question in pi itself
vim.keymap.set("v", "<leader>ps", function()
  M.send(get_selection())
end, { desc = "pi: send selection" })

-- Ask about the visual selection
vim.keymap.set("v", "<leader>pa", function()
  local sel = get_selection()
  ask_with(function()
    return "```\n" .. sel .. "\n```"
  end)
end, { desc = "pi: ask about selection" })

-- Ask about the whole current file
vim.keymap.set("n", "<leader>pa", function()
  local lines = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  ask_with(function()
    return "```\n" .. lines .. "\n```"
  end)
end, { desc = "pi: ask about file" })

-- Close the pi window without killing the session buffer (reopen with <leader>pp)
vim.keymap.set("n", "<leader>pd", function()
  if buf and vim.api.nvim_buf_is_valid(buf) then
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { desc = "pi: close split" })

-- From inside the pi terminal split (terminal mode):
--   <Esc><Esc>   escape to terminal-normal mode
--   <C-w>h       jump to the editor window (left split)
--   <C-w>l       jump to the right split
--   <C-w>d       close the pi window (session buffer survives; <leader>pp reopens)
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]],         { desc = "pi: escape to normal mode" })
vim.keymap.set("t", "<C-w>d",    [[<C-\><C-n><C-w>c]], { desc = "pi: close split" })
vim.keymap.set("t", "<C-w>h",    [[<C-\><C-n><C-w>h]], { desc = "pi: back to editor" })
vim.keymap.set("t", "<C-w>l",    [[<C-\><C-n><C-w>l]], { desc = "pi: focus right split" })

-- Seamless Ctrl-h/j/k/l across editor splits, the pi terminal, and tmux panes.
-- <Cmd> mappings run the navigator command directly from terminal mode:
-- no mode escape, no risk of command text leaking into pi's input, and
-- vim-tmux-navigator still handles the tmux-pane edge cases.
vim.keymap.set("t", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>",  { desc = "tmux: navigate left" })
vim.keymap.set("t", "<C-j>", "<Cmd>TmuxNavigateDown<CR>",  { desc = "tmux: navigate down" })
vim.keymap.set("t", "<C-k>", "<Cmd>TmuxNavigateUp<CR>",    { desc = "tmux: navigate up" })
vim.keymap.set("t", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { desc = "tmux: navigate right" })

-- Strip trailing whitespace from yanks made inside the pi terminal split.
-- Pi pads every rendered line to the full terminal width; without this,
-- yanked text carries a tail of spaces on each line.
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.bo.buftype ~= "terminal" then return end
    local reg = vim.v.event.regname == "" and '"' or vim.v.event.regname
    local text = vim.fn.getreg(reg)
    local trimmed = text:gsub("[ \t]+\n", "\n"):gsub("[ \t]+$", "")
    if trimmed == text then return end
    vim.fn.setreg(reg, trimmed, vim.fn.getregtype(reg))
    -- Keep the OSC-52 clipboard registers in sync (clipboard=unnamedplus)
    vim.fn.setreg("+", trimmed)
    vim.fn.setreg("*", trimmed)
  end,
  desc = "pi: strip trailing whitespace from terminal yanks",
})

-- When focus returns to the pi terminal buffer (from another split or a
-- tmux pane), drop straight back into terminal mode so pi is ready to type.
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "term://*",
  command = "startinsert",
})
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  command = "startinsert",
})

return M
