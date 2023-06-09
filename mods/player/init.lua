local disable_flags = {"healthbar", "crosshair", "wielditem", "breathbar", "basic_debug"}
minetest.register_on_joinplayer(function(player)

    -- Disable all minetest-like hud elements
    for _,flag in ipairs(disable_flags) do
        player:hud_set_flags({
            [flag] = false
        })
    end

    
end)


