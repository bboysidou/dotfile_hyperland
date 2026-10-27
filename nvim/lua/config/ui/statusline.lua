local c = require("config.colors")

local M = {}

local CAP_LEFT = "\u{e0b6}"
local CAP_RIGHT = "\u{e0b4}"
local ARROW_RIGHT = "\u{e0b0}"
local ARROW_LEFT = "\u{e0b2}"
local THIN_RIGHT = "\u{e0b1}"
local THIN_LEFT = "\u{e0b3}"
local TRANSPARENT = "NONE"

local MODES = {
  n = { "NORMAL", c.fg },
  i = { "INSERT", c.green },
  v = { "VISUAL", c.magenta },
  V = { "V-LINE", c.magenta },
  ["\22"] = { "V-BLOCK", c.magenta },
  s = { "SELECT", c.magenta },
  c = { "COMMAND", c.yellow },
  R = { "REPLACE", c.red },
  t = { "TERMINAL", c.green },
}

local GIT_COUNTS = { { "added", "+" }, { "changed", "!" }, { "removed", "-" } }

local DIAGNOSTICS = {
  { vim.diagnostic.severity.ERROR, " ", c.red },
  { vim.diagnostic.severity.WARN, " ", c.yellow },
  { vim.diagnostic.severity.INFO, " ", c.blue },
  { vim.diagnostic.severity.HINT, "󰌵 ", c.cyan },
}

local function escape(text)
  return (text:gsub("%%", "%%%%"))
end

local function color(spec)
  local name = ("FrameSeg_%s_%s%s"):format((spec.fg:gsub("#", "")), (spec.bg:gsub("#", "")), spec.bold and "_b" or "")
  vim.api.nvim_set_hl(0, name, spec)
  return "%#" .. name .. "#"
end

local function chunk(text, fg, bold)
  return { text = text, fg = fg, bold = bold }
end

local function mode()
  local entry = MODES[vim.api.nvim_get_mode().mode:sub(1, 1)] or MODES.n
  return { bg = entry[2], chunks = { chunk("\u{f303} " .. entry[1], c.bg, true) } }
end

local function path()
  local name = vim.api.nvim_buf_get_name(0)
  local shown = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":~:.")
  local modified = vim.bo.modified and " ●" or ""
  return { bg = c.bg_lighter, chunks = { chunk("\u{f07c} %<" .. escape(shown .. modified), c.fg_bright, true) } }
end

local function git()
  local head = vim.b.gitsigns_head
  if not head or head == "" then
    return nil
  end
  local signs = vim.b.gitsigns_status_dict or {}
  local parts = { "\u{e0a0} " .. head }
  for _, entry in ipairs(GIT_COUNTS) do
    local count = signs[entry[1]] or 0
    if count > 0 then
      parts[#parts + 1] = entry[2] .. count
    end
  end
  local bg = #parts > 1 and c.yellow or c.green
  return { bg = bg, chunks = { chunk(escape(table.concat(parts, " ")), c.bg) } }
end

local function diagnostics()
  local counts = vim.diagnostic.count(0)
  local chunks = {}
  for _, entry in ipairs(DIAGNOSTICS) do
    local count = counts[entry[1]]
    if count then
      local gap = #chunks > 0 and " " or ""
      chunks[#chunks + 1] = chunk(gap .. entry[2] .. count, entry[3])
    end
  end
  return #chunks > 0 and { bg = c.bg_lighter, chunks = chunks } or nil
end

local function filetype()
  local ft = vim.bo.filetype
  if ft == "" then
    return nil
  end
  local icon = require("nvim-web-devicons").get_icon_by_filetype(ft, { default = true })
  return { bg = c.bg_lighter, chunks = { chunk(icon .. " " .. ft, c.fg_bright) } }
end

local function position()
  return { bg = c.fg, chunks = { chunk("%l:%c", c.bg, true) } }
end

local function body(segment)
  local parts = { color({ fg = segment.chunks[1].fg, bg = segment.bg }) .. " " }
  for _, part in ipairs(segment.chunks) do
    parts[#parts + 1] = color({ fg = part.fg, bg = segment.bg, bold = part.bold }) .. part.text
  end
  parts[#parts + 1] = " "
  return table.concat(parts)
end

local function compact(...)
  local segments = {}
  for index = 1, select("#", ...) do
    local segment = select(index, ...)
    if segment then
      segments[#segments + 1] = segment
    end
  end
  return segments
end

local function left(segments)
  local parts = { color({ fg = segments[1].bg, bg = TRANSPARENT }) .. CAP_LEFT }
  for index, segment in ipairs(segments) do
    parts[#parts + 1] = body(segment)
    local next_segment = segments[index + 1]
    if not next_segment then
      parts[#parts + 1] = color({ fg = segment.bg, bg = TRANSPARENT }) .. ARROW_RIGHT
    elseif next_segment.bg == segment.bg then
      parts[#parts + 1] = color({ fg = c.fg_muted, bg = segment.bg }) .. THIN_RIGHT
    else
      parts[#parts + 1] = color({ fg = segment.bg, bg = next_segment.bg }) .. ARROW_RIGHT
    end
  end
  return table.concat(parts)
end

local function right(segments)
  local parts = { color({ fg = segments[1].bg, bg = TRANSPARENT }) .. ARROW_LEFT }
  for index, segment in ipairs(segments) do
    local previous = segments[index - 1]
    if previous and previous.bg == segment.bg then
      parts[#parts + 1] = color({ fg = c.fg_muted, bg = segment.bg }) .. THIN_LEFT
    elseif previous then
      parts[#parts + 1] = color({ fg = segment.bg, bg = previous.bg }) .. ARROW_LEFT
    end
    parts[#parts + 1] = body(segment)
  end
  parts[#parts + 1] = color({ fg = segments[#segments].bg, bg = TRANSPARENT }) .. CAP_RIGHT
  return table.concat(parts)
end

function M.render()
  local start = left(compact(mode(), path(), git()))
  local finish = right(compact(diagnostics(), filetype(), position()))
  return "%#FrameLine#╰─ " .. start .. "%#FrameLine# %= " .. finish .. "%#FrameLine# ─╯"
end

return M
