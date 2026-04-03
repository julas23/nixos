-- ============================================================
-- Awesome WM Configuration — Modern Hyprland-like appearance
-- ============================================================
-- Libraries: bling, lain, vicious, awesome-wm-widgets
-- Compositor: picom (blur + rounded corners via picom.conf)
-- Launcher: rofi
-- Notifications: dunst
--
-- Place this file at: ~/.config/awesome/rc.lua
-- ============================================================

-- ── Standard libraries ──────────────────────────────────────
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local menubar       = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
                      require("awful.hotkeys_popup.keys")

-- ── External libraries ──────────────────────────────────────
-- bling and lain are cloned to ~/.config/awesome/libs/ by NixOS
local libs_path = os.getenv("HOME") .. "/.config/awesome/libs"
package.path = libs_path .. "/bling/?.lua;"
            .. libs_path .. "/bling/?/init.lua;"
            .. libs_path .. "/lain/?.lua;"
            .. libs_path .. "/lain/?/init.lua;"
            .. package.path

local bling   = require("bling")
local lain    = require("lain")
local vicious = require("vicious")

-- ── Error handling ──────────────────────────────────────────
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title  = "Startup errors",
        text   = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "Runtime error",
            text   = tostring(err)
        })
        in_error = false
    end)
end

-- ── Theme ───────────────────────────────────────────────────
-- Uses the built-in theme as base; override colors for dark/modern look
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Color palette (Catppuccin Mocha — same as popular Hyprland rices)
local colors = {
    base    = "#1e1e2e",
    mantle  = "#181825",
    crust   = "#11111b",
    text    = "#cdd6f4",
    subtext = "#a6adc8",
    surface = "#313244",
    overlay = "#45475a",
    blue    = "#89b4fa",
    lavender= "#b4befe",
    sapphire= "#74c7ec",
    sky     = "#89dceb",
    teal    = "#94e2d5",
    green   = "#a6e3a1",
    yellow  = "#f9e2af",
    peach   = "#fab387",
    red     = "#f38ba8",
    mauve   = "#cba6f7",
    pink    = "#f5c2e7",
}

-- Apply colors to theme
beautiful.bg_normal     = colors.base
beautiful.bg_focus      = colors.surface
beautiful.bg_urgent     = colors.red
beautiful.bg_minimize   = colors.mantle
beautiful.bg_systray    = colors.base

beautiful.fg_normal     = colors.text
beautiful.fg_focus      = colors.blue
beautiful.fg_urgent     = colors.base
beautiful.fg_minimize   = colors.subtext

beautiful.border_width  = 2
beautiful.border_normal = colors.overlay
beautiful.border_focus  = colors.blue
beautiful.border_marked = colors.mauve

beautiful.useless_gap   = 8   -- gaps between windows (like Hyprland gaps_in)

-- Taglist / tasklist colors
beautiful.taglist_bg_focus    = colors.blue
beautiful.taglist_fg_focus    = colors.base
beautiful.taglist_bg_occupied = colors.surface
beautiful.taglist_fg_occupied = colors.text
beautiful.taglist_bg_empty    = colors.base
beautiful.taglist_fg_empty    = colors.overlay

-- Notification styling
beautiful.notification_bg           = colors.surface
beautiful.notification_fg           = colors.text
beautiful.notification_border_color = colors.blue
beautiful.notification_border_width = 2
beautiful.notification_shape        = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, 8)
end

-- Wibar (top bar) styling
beautiful.wibar_bg     = colors.mantle
beautiful.wibar_height = 36

-- ── Variables ───────────────────────────────────────────────
local terminal   = "kitty"
local editor     = os.getenv("EDITOR") or "nvim"
local modkey     = "Mod4"   -- Super key

-- ── Layouts ─────────────────────────────────────────────────
-- bling adds: mstab (tabbed), centered, vertical, horizontal, deck
awful.layout.layouts = {
    awful.layout.suit.tile,              -- Master + stack (default)
    bling.layout.mstab,                  -- Tabbed master (like Hyprland tabbed)
    bling.layout.centered,               -- Centered master
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.floating,
}

-- ── Tags (workspaces) ───────────────────────────────────────
local tag_names = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

awful.screen.connect_for_each_screen(function(s)
    awful.tag(tag_names, s, awful.layout.layouts[1])

    -- Tag preview (bling) — shows window thumbnails on hover
    bling.widget.tag_preview.enable {
        show_client_content  = true,
        x                    = 10,
        y                    = 50,
        scale                = 0.25,
        honor_padding        = true,
        honor_workarea       = true,
    }

    -- ── Wibox (top bar) ─────────────────────────────────────
    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)

    -- Taglist
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                if client.focus then client.focus:move_to_tag(t) end
            end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
        ),
    }

    -- Tasklist
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = gears.table.join(
            awful.button({}, 1, function(c)
                if c == client.focus then
                    c.minimized = true
                else
                    c:emit_signal("request::activate", "tasklist", { raise = true })
                end
            end)
        ),
    }

    -- ── Widgets (vicious) ───────────────────────────────────
    -- CPU widget
    local cpu_widget = wibox.widget.textbox()
    vicious.register(cpu_widget, vicious.widgets.cpu,
        function(_, args)
            return string.format('<span color="%s"> %d%%</span>', colors.blue, args[1])
        end, 3)

    -- Memory widget
    local mem_widget = wibox.widget.textbox()
    vicious.register(mem_widget, vicious.widgets.mem,
        function(_, args)
            return string.format('<span color="%s"> %dMB</span>', colors.green, args[2])
        end, 5)

    -- Clock
    local clock_widget = wibox.widget.textclock(
        string.format('<span color="%s"> %%H:%%M</span>  <span color="%s">%%d/%%m/%%Y</span>',
            colors.lavender, colors.subtext), 60)

    -- Separator
    local sep = wibox.widget {
        markup = string.format('<span color="%s">  │  </span>', colors.overlay),
        widget = wibox.widget.textbox,
    }

    -- Playerctl widget (bling) — shows current music
    local playerctl = bling.widget.playerctl.lib {
        player = { "spotify", "mpd", "%any" }
    }

    -- ── Wibar assembly ──────────────────────────────────────
    s.mywibar = awful.wibar({
        position = "top",
        screen   = s,
        height   = beautiful.wibar_height,
        bg       = beautiful.wibar_bg,
    })

    s.mywibar:setup {
        layout = wibox.layout.align.horizontal,
        -- Left
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.widget { markup = string.format(' <span color="%s">  </span> ', colors.blue), widget = wibox.widget.textbox },
            s.mytaglist,
            sep,
            s.mypromptbox,
        },
        -- Middle
        {
            layout = wibox.layout.fixed.horizontal,
            playerctl.widget,
        },
        -- Right
        {
            layout = wibox.layout.fixed.horizontal,
            cpu_widget,
            sep,
            mem_widget,
            sep,
            clock_widget,
            sep,
            wibox.widget.systray(),
            s.mylayoutbox,
            wibox.widget { markup = " ", widget = wibox.widget.textbox },
        },
    }
end)

-- ── Mouse bindings ──────────────────────────────────────────
root.buttons(gears.table.join(
    awful.button({}, 3, function() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))

-- ── Key bindings ────────────────────────────────────────────
local globalkeys = gears.table.join(
    -- Help
    awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

    -- Tag navigation
    awful.key({ modkey }, "Left",   awful.tag.viewprev,  { description = "previous tag", group = "tag" }),
    awful.key({ modkey }, "Right",  awful.tag.viewnext,  { description = "next tag",     group = "tag" }),
    awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "last tag", group = "tag" }),

    -- Client focus
    awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end,  { description = "focus next", group = "client" }),
    awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end, { description = "focus prev", group = "client" }),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,  { description = "swap next",     group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end, { description = "swap previous", group = "client" }),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent", group = "client" }),
    awful.key({ modkey }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end, { description = "go back", group = "client" }),

    -- Programs
    awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,         { description = "terminal",  group = "launcher" }),
    awful.key({ modkey }, "r",      function() awful.spawn("rofi -show drun") end, { description = "rofi",      group = "launcher" }),
    awful.key({ modkey }, "e",      function() awful.spawn("pcmanfm") end,         { description = "files",     group = "launcher" }),
    awful.key({ modkey }, "b",      function() awful.spawn("brave") end,           { description = "browser",   group = "launcher" }),

    -- Screenshot
    awful.key({}, "Print", function() awful.spawn("flameshot gui") end, { description = "screenshot", group = "launcher" }),

    -- Screen locker
    awful.key({ modkey }, "l", function() awful.spawn("multilockscreen -l blur") end, { description = "lock screen", group = "launcher" }),

    -- Awesome control
    awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "restart awesome", group = "awesome" }),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,    { description = "quit awesome",    group = "awesome" }),

    -- Layout resize
    awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end, { description = "decrease master", group = "layout" }),
    awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end,  { description = "increase master", group = "layout" }),

    -- Layout cycle
    awful.key({ modkey }, "space",         function() awful.layout.inc(1)  end, { description = "next layout",     group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end, { description = "previous layout", group = "layout" }),

    -- Volume (pamixer)
    awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pamixer -i 5") end,  { description = "+5%",  group = "media" }),
    awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pamixer -d 5") end,  { description = "-5%",  group = "media" }),
    awful.key({}, "XF86AudioMute",        function() awful.spawn("pamixer -t") end,    { description = "mute", group = "media" }),

    -- Media (playerctl)
    awful.key({}, "XF86AudioPlay",  function() awful.spawn("playerctl play-pause") end, { description = "play/pause", group = "media" }),
    awful.key({}, "XF86AudioNext",  function() awful.spawn("playerctl next") end,       { description = "next",       group = "media" }),
    awful.key({}, "XF86AudioPrev",  function() awful.spawn("playerctl previous") end,   { description = "previous",   group = "media" })
)

-- Tag number keys
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function()
            local s = awful.screen.focused()
            local t = s.tags[i]
            if t then t:view_only() end
        end, { description = "tag " .. i, group = "tag" }),
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local t = client.focus.screen.tags[i]
                if t then client.focus:move_to_tag(t) end
            end
        end, { description = "move to tag " .. i, group = "tag" })
    )
end

root.keys(globalkeys)

-- ── Client key bindings ─────────────────────────────────────
local clientkeys = gears.table.join(
    awful.key({ modkey }, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, { description = "fullscreen", group = "client" }),
    awful.key({ modkey }, "q",      function(c) c:kill() end,                      { description = "close",     group = "client" }),
    awful.key({ modkey }, "t",      awful.client.floating.toggle,                  { description = "toggle floating", group = "client" }),
    awful.key({ modkey }, "m",      function(c) c.maximized = not c.maximized; c:raise() end, { description = "maximize", group = "client" }),
    awful.key({ modkey, "Shift" }, "m", function(c) c.minimized = true end,        { description = "minimize",  group = "client" })
)

-- ── Client buttons ──────────────────────────────────────────
local clientbuttons = gears.table.join(
    awful.button({}, 1, function(c) c:emit_signal("request::activate", "mouse_click", { raise = true }) end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- ── Rules ───────────────────────────────────────────────────
awful.rules.rules = {
    -- All clients
    {
        rule = {},
        properties = {
            border_width     = beautiful.border_width,
            border_color     = beautiful.border_normal,
            focus            = awful.client.focus.filter,
            raise            = true,
            keys             = clientkeys,
            buttons          = clientbuttons,
            screen           = awful.screen.preferred,
            placement        = awful.placement.no_overlap + awful.placement.no_offscreen,
        }
    },
    -- Floating clients
    {
        rule_any = {
            instance = { "DTA", "copyq", "pinentry" },
            class    = { "Arandr", "Blueman-manager", "Gpick", "Pavucontrol", "Nm-connection-editor" },
            name     = { "Event Tester" },
            role     = { "AlarmWindow", "ConfigManager", "pop-up" },
        },
        properties = { floating = true }
    },
}

-- ── Signals ─────────────────────────────────────────────────
-- Rounded corners for all clients (via gears.shape)
client.connect_signal("manage", function(c)
    if awesome.startup and not c.size_hints.user_position
        and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
    -- Rounded corners (complement picom corner-radius)
    c.shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 8)
    end
end)

-- Border color on focus/unfocus
client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- ── Autostart ───────────────────────────────────────────────
local function run_once(cmd)
    local findme = cmd
    local firstspace = cmd:find(" ")
    if firstspace then findme = cmd:sub(1, firstspace - 1) end
    awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
end

run_once("picom --config ~/.config/picom/picom.conf")
run_once("nm-applet")
run_once("dunst")
run_once("clipmenud")
run_once("xss-lock -- multilockscreen -l blur")
run_once("feh --bg-fill ~/.config/awesome/wallpaper.jpg")
