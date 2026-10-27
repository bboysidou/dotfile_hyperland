local M = {}

local LINE = "─"
local CLICK = "%%%d@v:lua.require'config.ui.tabline'.click@"

local function escape(text)
  return (text:gsub("%%", "%%%%"))
end

local function listed_buffers()
  return vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())
end

local function label(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local tail = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
  local icon = require("nvim-web-devicons").get_icon(tail, nil, { default = true })
  local modified = vim.bo[buf].modified and " ●" or ""
  return (" %s %s%s "):format(icon, tail, modified)
end

local function tab(buf, current)
  local text = label(buf)
  if buf == current then
    return {
      width = vim.fn.strdisplaywidth(text) + 2,
      render = "%#FrameLine#╯" .. CLICK:format(buf) .. "%#FrameTabActive#" .. escape(text) .. "%T%#FrameLine#╰",
    }
  end
  return {
    width = vim.fn.strdisplaywidth(text),
    render = CLICK:format(buf) .. "%#FrameTabInactive#" .. escape(text) .. "%T",
  }
end

local function fit(tabs, active, room)
  local used = 0
  for _, entry in ipairs(tabs) do
    used = used + entry.width + 1
  end
  while used > room and #tabs > 1 do
    local drop = active > #tabs / 2 and 1 or #tabs
    used = used - tabs[drop].width - 1
    table.remove(tabs, drop)
    active = drop == 1 and active - 1 or active
  end
  return used
end

function M.render()
  local current = vim.api.nvim_get_current_buf()
  local tabs, active = {}, 1
  for _, buf in ipairs(listed_buffers()) do
    tabs[#tabs + 1] = tab(buf, current)
    active = buf == current and #tabs or active
  end

  local room = vim.o.columns - 3
  local used = fit(tabs, active, room)

  local parts = { "%#FrameLine#╭" .. LINE }
  for _, entry in ipairs(tabs) do
    parts[#parts + 1] = entry.render .. "%#FrameLine#" .. LINE
  end
  parts[#parts + 1] = LINE:rep(math.max(room - used, 0)) .. "╮"
  return table.concat(parts)
end

function M.click(buf)
  vim.api.nvim_set_current_buf(buf)
end

return M
