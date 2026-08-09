-- Environment variables
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("DRI_BACKEND", "radeonsi")
hl.env("GDK_SCALE", "1")
-- hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")
