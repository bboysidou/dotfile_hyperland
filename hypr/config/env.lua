-- Environment variables
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GDK_SCALE", "1")

-- GPU-specific vars (AQ_DRM_DEVICES, NVIDIA video vars...)
-- are generated per machine by install/lib/gpu.sh into config/env-gpu.lua
pcall(require, "config/env-gpu")
