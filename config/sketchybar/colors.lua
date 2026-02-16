return {
    black = 0xff181819,
    white = 0xffe2e2e3,
    red = 0xfffc5d7c,
    green = 0xff9ed072,
    blue = 0xff76cce0,
    yellow = 0xffe7c664,
    orange = 0xfff39660,
    magenta = 0xffb39df3,
    grey = 0xff7f8490,
    transparent = 0x00000000,

    bar = {
        bg = 0xd02c2e34,
        border = 0xff2c2e34
    },
    popup = {
        bg = 0xc02c2e34,
        border = 0xff7f8490
    },
    bg1 = 0xff363944,
    bg2 = 0xff414550,

    rainbow = {
        0xfff38ba8, -- red (for red spectrum)
        0xffeba0ac, -- maroon (red-orange transition)
        0xfffab387, -- peach (orange)
        0xfff9e2af, -- yellow
        0xffa6e3a1, -- green
        0xff94e2d5, -- teal (green-blue transition)
        0xff89dceb, -- sky (light blue)
        0xff74c7ec, -- sapphire (blue)
        0xff89b4fa, -- blue (deeper blue)
        0xffb4befe, -- lavender (blue-purple transition)
        0xffcba6f7, -- mauve (purple)
        0xfff5c2e7, -- pink (purple-red transition)
    },

    with_alpha = function(color, alpha)
        if alpha > 1.0 or alpha < 0.0 then
            return color
        end
        return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
    end
}
