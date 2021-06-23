require("awful.autofocus")
local gears = require("gears")
local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_themes_dir() .. "zenburn/theme.lua")

modkey      = "Mod4"
terminal    = "alacritty"
editor      = "nvim"
filemanager = "pcmanfm"
browser     = "firefox"
mailclient  = ""
run_prompt  = ""
editor_cmd  = terminal .. " -e " .. editor

-- Table of layouts to cover with awful.layout.inc, order matters.
local awful = require("awful")
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.max,
}

-- Other more specific config files
require "menu"
require "wibar"
require "keymappings"
require "new_window_rules"

-- Autostart applications
awful.spawn.with_shell("~/.config/awesome/autostart.sh")

-- Error handling
-- Handle runtime errors after startup
local naughty = require("naughty")
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
