-- Workspaces (written by the Quickshell display panel, ALT + D)
-- Entry N is the monitor workspace N lives on; the first workspace of each monitor is its default.

local assignment = {
	"HDMI-A-1",
	"DP-3",
	"DP-3",
	"DP-3",
	"DP-3",
	"DP-3",
	"DP-3",
	"DP-3",
	"DP-3",
	"DP-3",
}

local seen = {}
for workspace, output in ipairs(assignment) do
	hl.workspace_rule({ workspace = tostring(workspace), monitor = output, default = not seen[output] })
	seen[output] = true
end

return assignment
