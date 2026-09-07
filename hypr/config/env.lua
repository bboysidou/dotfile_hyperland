-- Environment variables
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("GDK_SCALE", "1")

-- GPU-specific vars (LIBVA_DRIVER_NAME, DRI_BACKEND, AQ_DRM_DEVICES...)
-- are generated per machine by install/gpu.sh into config/env-gpu.lua
pcall(require, "config/env-gpu")
