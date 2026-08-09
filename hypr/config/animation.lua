-- Animations
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

-- Bezier curves (legacy "bezier = name, x0, y0, x1, y1")
hl.curve("smooth",    { type = "bezier", points = { { 0.25, 1 }, { 0.5,  1     } } })
hl.curve("smoothIn",  { type = "bezier", points = { { 0.15, 1 }, { 0.3,  1     } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 }, { 0.66, -0.56 } } })
hl.curve("liner",     { type = "bezier", points = { { 1,    1 }, { 1,    1     } } })

hl.config({ animations = { enabled = true } })

-- (legacy "animation = leaf, enabled, speed, curve[, style]")
hl.animation({ leaf = "windows",     enabled = true, speed = 6,  bezier = "smooth",    style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 6,  bezier = "smoothIn",  style = "slidefade 30%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 4,  bezier = "smoothOut", style = "slidefade 30%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,  bezier = "smooth",    style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 2,  bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 50, bezier = "liner",     style = "loop" })
hl.animation({ leaf = "fade",        enabled = true, speed = 6,  bezier = "smooth" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "smooth",    style = "slidefade 40%" })

-- Blur (re-enabled here, matching the legacy setup where animation.conf
-- overrode decoration.conf)
hl.config({
    decoration = {
        blur = {
            enabled           = true,
            size              = 2,
            passes            = 2,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = true,
        },
    },
})
