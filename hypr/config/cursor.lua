-- Cursor
-- no_hardware_cursors:
--   false = hardware cursor. The GPU draws the cursor on its own plane, so
--           screenshots and screen recordings do not include it.
--   true  = software cursor. Hyprland draws the cursor into each frame, so
--           screenshots include it, but it works on every GPU and kernel.
-- Cursor not visible (hovers work but no pointer)? The hardware cursor is
-- broken on this GPU/kernel (for example amdgpu on Linux 7.3). Set this to
-- true, or fix the running session without editing this file:
--   hyprctl eval 'hl.config({ cursor = { no_hardware_cursors = true } })'
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})
