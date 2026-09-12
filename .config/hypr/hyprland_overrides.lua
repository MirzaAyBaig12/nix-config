hl.env("XCURSOR_THEME", "Bibata-Material-Lilac")
hl.env("XCURSOR_SIZE", "24")

hl.config({
  cursor = {
    no_hardware_cursors = false,
  },
})

-- matches the real session's scale (1x on the eDP-1 1920x1080
-- panel — "auto" was picking 1.5x, way too big for a login/lock
-- screen too).
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
