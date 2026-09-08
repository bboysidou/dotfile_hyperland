-- Composition root. The only file in the config that touches vim.pack.
--
-- Plugin modules under config.plugins are inert tables: requiring one runs
-- nothing. That lets this file collect all 47 sources, hand them to a single
-- vim.pack.add() (installation parallelises within a call, not across calls),
-- and only then run each module's setup in registry order.
--
-- Recovery: NVIM_PACK_INSTALL_ONLY=1 skips every setup, so a config error in
-- one plugin still leaves a usable editor to fix it from.
local registry = require("config.pack.registry")

local GITHUB = "https://github.com/"

local function to_spec(entry)
  local spec = type(entry) == "string" and { src = entry } or entry
  return {
    src = GITHUB .. spec.src,
    version = spec.version,
    name = spec.name,
  }
end

local specs, mods = {}, {}

for _, name in ipairs(registry) do
  local mod = require("config.plugins." .. name)
  mods[#mods + 1] = mod

  -- deps precede their owner so packadd order matches lazy's semantics
  for _, dep in ipairs(mod.deps or {}) do
    specs[#specs + 1] = to_spec(dep)
  end
  specs[#specs + 1] = to_spec(mod)
end

require("config.pack.build").register(mods)

-- load = true sources plugin/ files during the call, reproducing lazy's
-- ordering (plugin/ first, then config). Without it the context-dependent
-- default defers sourcing until after init.lua.
vim.pack.add(specs, { load = true, confirm = false })

if vim.env.NVIM_PACK_INSTALL_ONLY == "1" then
  return
end

for _, mod in ipairs(mods) do
  if mod.setup then
    local ok, err = pcall(mod.setup)
    if not ok then
      vim.notify(("%s setup failed: %s"):format(mod.src, err), vim.log.levels.ERROR)
    end
  end
end
