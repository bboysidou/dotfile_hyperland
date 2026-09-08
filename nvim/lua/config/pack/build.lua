-- Build hooks. lazy.nvim ran `build` itself; vim.pack exposes the same moment
-- as the PackChanged event, which MUST be subscribed before the first add() or
-- install-time hooks never fire.
local M = {}

local function plugin_name(spec)
  return spec.name or spec.src:gsub("%.git$", ""):match("([^/]+)$")
end

function M.register(mods)
  local by_name = {}

  local function collect(spec)
    if spec.build then
      by_name[plugin_name(spec)] = spec.build
    end
  end

  for _, m in ipairs(mods) do
    collect(m)
    for _, d in ipairs(m.deps or {}) do
      if type(d) == "table" then
        collect(d)
      end
    end
  end

  vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("pack_build", { clear = true }),
    callback = function(ev)
      local kind = ev.data.kind
      if kind ~= "install" and kind ~= "update" then
        return
      end

      local cmd = by_name[ev.data.spec.name]
      if not cmd then
        return
      end

      local result = vim.system(cmd, { cwd = ev.data.path }):wait()
      if result.code ~= 0 then
        vim.notify(
          ("build failed for %s: %s"):format(ev.data.spec.name, result.stderr or ""),
          vim.log.levels.ERROR
        )
      end
    end,
  })
end

return M
