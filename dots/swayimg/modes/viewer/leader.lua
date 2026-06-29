--------------------------------------------------
-- Leader System (nsxiv-style Ctrl-x)
--------------------------------------------------

local leader = false

swayimg.viewer.on_key("Ctrl-x", function() leader = true swayimg.text.set_status("leader") end)
local function bind(key, fn) swayimg.viewer.on_key(key, function() if not leader then return end leader = false fn() end) end

local keymap = {

    -- copy image to clipboard
    y = function()
        local img = swayimg.viewer.get_image()
        if img then
            os.execute("wl-copy --type image/png < '" .. img.path .. "'")
        end
    end,

    w = function()
        local img = swayimg.viewer.get_image()
        if not img then return end

        local target = os.getenv("HOME") .. "/.dotfiles/i3/Wallpaper/Wallpaper"
        os.execute("rm -f '" .. target .. "'")
        os.execute("ln -s '" .. img.path .. "' '" .. target .. "'")
        swayimg.text.set_status("Wallpaper set")
    end,

    e = function()
        local img = swayimg.viewer.get_image()
        if img then
            os.execute("urxvt -e sh -c \"exiv2 pr -q -pa '" .. img.path .. "' | less\" &")
        end
    end,

    a = function()
        local img = swayimg.viewer.get_image()
        if img then
            os.execute("swat -r '" .. img.path .. "'")
        end
    end,
}

for key, fn in pairs(keymap) do
    bind(key, fn)
end
