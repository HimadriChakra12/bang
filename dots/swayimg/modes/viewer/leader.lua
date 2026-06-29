local leader = false

local function leader_bind(key, fn) swayimg.viewer.on_key(key, function() if not leader then return end leader = false fn() end) end

swayimg.viewer.on_key("Ctrl-x", function() leader = true swayimg.text.set_status("<.>") end)

leader_bind("d", function()
    local img = swayimg.viewer.get_image()
    os.remove(img.path)
end)

leader_bind("r", function()
    swayimg.viewer.rotate(90)
end)

leader_bind("m", function()
    swayimg.viewer.toggle_mark()
end)

leader_bind("g", function()
    swayimg.set_mode("gallery")
end)

leader_bind("q", function()
    swayimg.exit()
end)
