#!/usr/bin/env bash

HYPR_MONITORS_LUA="hypr/monitors.lua"
HYPR_WORKSPACES_LUA="hypr/workspaces.lua"

_displaysMonitorsLua() {
  cat <<'EOF'
-- Monitors (written by the Quickshell display panel, ALT + D)
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
EOF
}

_displaysWorkspacesLua() {
  cat <<'EOF'
-- Workspaces (written by the Quickshell display panel, ALT + D)
-- Entry N is the monitor workspace N lives on; the first workspace of each monitor is its default.

local assignment = {
}

local seen = {}
for workspace, output in ipairs(assignment) do
	hl.workspace_rule({ workspace = tostring(workspace), monitor = output, default = not seen[output] })
	seen[output] = true
end

return assignment
EOF
}

displaysConfigureUser() {
  local repo="$1"
  [[ -e "${repo}/${HYPR_MONITORS_LUA}" ]] || _displaysMonitorsLua | writeFile "${repo}/${HYPR_MONITORS_LUA}"
  [[ -e "${repo}/${HYPR_WORKSPACES_LUA}" ]] || _displaysWorkspacesLua | writeFile "${repo}/${HYPR_WORKSPACES_LUA}"
}
