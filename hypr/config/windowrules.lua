-- Window rules
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- Rules are evaluated top to bottom.

hl.window_rule({
    name    = "all",
    match   = { class = ".*" },
    opacity = "1 0.99",
})

-- Ignore self-maximize requests from apps (from the upstream example config)
hl.window_rule({
    name          = "suppress-maximize-events",
    match         = { class = ".*" },
    suppress_event = "maximize",
})

-- Fixes drag-and-drop from XWayland apps stealing focus with an empty window
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "ONLYOFFICE",
    match = { class = "^(ONLYOFFICE Desktop Editors)$" },
    tile  = true,
})

hl.window_rule({
    name  = "Chromium",
    match = { class = "Chromium" },
    tile  = true,
})

hl.window_rule({
    name     = "Dunst",
    match    = { class = "^(Dunst)$" },
    float    = true,
    no_focus = true,
})

hl.window_rule({
    name  = "Emulator",
    match = { class = "^(Emulator)$" },
    float = true,
})

hl.window_rule({
    name  = "pavucontrol",
    match = { class = "pavucontrol" },
    float = true,
})

-- hl.window_rule({
--     name  = "scrcpy",
--     match = { class = "scrcpy" },
--     float = true,
-- })

hl.window_rule({
    name  = "nm-connection-editor",
    match = { class = "nm-connection-editor" },
    float = true,
})

hl.window_rule({
    name         = "Rofi",
    match        = { class = "Rofi" },
    stay_focused = true,
    center       = true,
})

hl.window_rule({
    name             = "jetbrains-studio",
    match            = { class = "jetbrains-studio", title = "^win(.*)" },
    no_initial_focus = true,
})
