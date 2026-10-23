-- Decoration
-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    decoration = {
        rounding = 18,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled           = true,
            size              = 2,
            passes            = 2,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = true,
        },
        active_opacity     = 1.0,
        inactive_opacity   = 0.95,
        fullscreen_opacity = 1.0,
    },
})
