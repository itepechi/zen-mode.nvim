local M = {}

function M.gitsigns(state, disable)
  local gs = require("gitsigns")
  local config = require("gitsigns.config").config
  -- https://github.com/lewis6991/gitsigns.nvim/blob/f4648dcc055a10573f36e83343592824155ab466/teal/gitsigns/actions.tl#L74-L108
  local configs = {
    "signcolumn",
    "numhl",
    "linehl",
    "word_diff",
    "current_line_blame",
    "show_deleted",
  }
  for _, name in ipairs(configs) do
    if disable then
      state[name] = config[name]
      config[name] = false
    else
      config[name] = state[name]
    end
  end
  gs.refresh()
end

function M.options(state, disable, opts)
  for key, value in pairs(opts) do
    if key ~= "enabled" then
      if disable then
        state[key] = vim.o[key]
        vim.o[key] = value
      else
        vim.o[key] = state[key]
      end
    end
  end
end

-- changes the kitty font size
-- it's a bit glitchy, but it works
function M.kitty(state, disable, opts)
  if not vim.fn.executable("kitty") then
    return
  end
  local cmd = "kitty @ --to %s set-font-size %s"
  local socket = vim.fn.expand("$KITTY_LISTEN_ON")
  if disable then
    vim.fn.system(cmd:format(socket, opts.font))
  else
    vim.fn.system(cmd:format(socket, "0"))
  end
  vim.cmd([[redraw]])
end

function M.twilight(state, disable)
  if disable then
    state.enabled = require("twilight.view").enabled
    require("twilight").enable()
  else
    if not state.enabled then
      require("twilight").disable()
    end
  end
end

function M.tmux(state, disable, opts)
  if not vim.env.TMUX then
    return
  end
  if disable then
    vim.fn.system([[tmux set status off]])
    vim.fn.system([[tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z]])
  else
    vim.fn.system([[tmux set status on]])
    vim.fn.system([[tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z]])
  end
end

return M
