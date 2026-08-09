-- General: borders, gaps, layout
-- https://wiki.hypr.land/Configuring/Basics/Variables/

local colors = require("config/colors")

hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 2,
        border_size = 3,
        col = {
            active_border   = { colors = { colors.borderActive, colors.cyan }, angle = 45 },
            inactive_border = colors.borderInactive,
        },
        layout = "master",
        -- layout = "dwindle",
    },

    dwindle = {
        -- https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
        preserve_split = true, -- you probably want this
    },

    master = {
        -- https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
        new_status = "master",
    },
})
