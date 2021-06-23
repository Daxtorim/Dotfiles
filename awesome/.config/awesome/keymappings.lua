-- Standard awesome library
local menubar = require("menubar")
local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
-- require("awful.hotkeys_popup.keys")

local t = awful.screen.focused().selected_tag

-- Mouse bindings
root.buttons(gears.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
--

-- Key bindings
globalkeys = gears.table.join(
	awful.key({ modkey, }, "s", hotkeys_popup.show_help,
		{description="show help", group="awesome"}),
	awful.key({ modkey, }, "Left", awful.tag.viewprev,
		{description = "view previous", group = "tag"}),
	awful.key({ modkey, }, "Right", awful.tag.viewnext,
		{description = "view next", group = "tag"}),
	awful.key({ modkey, }, "Escape", awful.tag.history.restore,
		{description = "go back", group = "tag"}),

	awful.key({ modkey, }, "w", function () mymainmenu:show() end,
		{description = "show main menu", group = "awesome"}),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1) end,
		{description = "swap with next client by index", group = "client"}),
	awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx( -1) end,
		{description = "swap with previous client by index", group = "client"}),
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
		{description = "focus the next screen", group = "screen"}),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
		{description = "focus the previous screen", group = "screen"}),
	awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
		{description = "jump to urgent client", group = "client"}),
	awful.key({ modkey, }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{description = "go back", group = "client"}),

	-- Standard program
	awful.key({ modkey, }, "Return", function () awful.spawn(terminal) end,
		{description = "open a terminal", group = "launcher"}),
	awful.key({ modkey, }, "b", function () awful.spawn(browser) end,
		{description = "open a browser", group = "launcher"}),
	awful.key({ modkey, }, "f", function () awful.spawn(filemanager) end,
		{description = "open a file manager", group = "launcher"}),
	awful.key({ modkey, "Control" }, "r", awesome.restart,
		{description = "reload awesome", group = "awesome"}),
	awful.key({ modkey, "Shift" }, "q", awesome.quit,
		{description = "quit awesome", group = "awesome"}),

	-- By direction client focus
	awful.key({ modkey }, "j",
		function()
			-- use index in fullscreen mode
			if awful.layout.get_tag_layout_index(t) == 2 then
				awful.client.focus.byidx(1)
			else
				awful.client.focus.global_bydirection("down")
			end
			if client.focus then client.focus:raise() end
		end,
		{description = "focus down", group = "client"}),
	awful.key({ modkey }, "k",
		function()
			-- use index in fullscreen mode
			if awful.layout.get_tag_layout_index(t) == 2 then
				awful.client.focus.byidx(-1)
			else
				awful.client.focus.global_bydirection("up")
			end
			if client.focus then client.focus:raise() end
		end,
		{description = "focus up", group = "client"}),
	awful.key({ modkey }, "h",
		function()
			awful.client.focus.global_bydirection("left")
			if client.focus then client.focus:raise() end
		end,
		{description = "focus left", group = "client"}),
	awful.key({ modkey }, "l",
		function()
			awful.client.focus.global_bydirection("right")
			if client.focus then client.focus:raise() end
		end,
		{description = "focus right", group = "client"}),

	awful.key({ modkey, "Shift" }, "l", function () awful.tag.incmwfact( 0.05) end,
		{description = "increase master width factor", group = "layout"}),
	awful.key({ modkey, "Shift" }, "h", function () awful.tag.incmwfact(-0.05) end,
		{description = "decrease master width factor", group = "layout"}),
	awful.key({ modkey, }, "space", function () awful.layout.inc( 1) end,
		{description = "select next", group = "layout"}),
	awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(-1) end,
		{description = "select previous", group = "layout"}),

	awful.key({ modkey, "Control" }, "n",
	function ()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal(
			"request::activate", "key.unminimize", {raise = true}
			)
		end
	end,
	{description = "restore minimized", group = "client"}),

	-- Prompt
	awful.key({ modkey },"r", function () awful.screen.focused().mypromptbox:run() end,
	{description = "run prompt", group = "launcher"}),

	awful.key({ modkey }, "x",
		function ()
			awful.prompt.run {
				prompt       = "Run Lua code: ",
				textbox      = awful.screen.focused().mypromptbox.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval"
			}
		end,
		{description = "lua execute prompt", group = "awesome"}),
	-- Menubar
	awful.key({ modkey }, "p", function() menubar.show() end,
		{description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
	awful.key({ modkey, }, "q", function (c) c:kill() end,
		{description = "close", group = "client"}),
	awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
		{description = "toggle floating", group = "client"}),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
		{description = "move to master", group = "client"}),
	awful.key({ modkey, }, "t", function (c) c.ontop = not c.ontop end,
		{description = "toggle keep on top", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = {description = "view tag #", group = "tag"}
		descr_toggle = {description = "toggle tag #", group = "tag"}
		descr_move = {description = "move focused client to tag #", group = "tag"}
		descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
	end
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9,
			function ()
					local screen = awful.screen.focused()
					local tag = screen.tags[i]
					if tag then
						tag:view_only()
					end
			end,
			descr_view),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9,
			function ()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,
			descr_toggle),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
						tag:view_only()
					end
				end
			end,
			descr_move),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end,
			descr_toggle_focus)
	)
end

clientbuttons = gears.table.join(
	awful.button({ }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
	end),
	awful.button({ modkey }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
