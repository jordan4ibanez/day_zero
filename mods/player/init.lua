local disable_flags = {"healthbar", "crosshair", "wielditem", "breathbar", "basic_debug"}

minetest.register_entity("player:player", {
    initial_properties = {
        visual = "mesh",
        mesh = "player.b3d",
        textures = {
            "player.png"
        }
    }
    -- todo: needs metadata to delete self
})

local function anim(start, finish)
    return {start = start, finish = finish}
end

local player_animation_table = {
    idle = anim(0,40),
    sneak = anim(40,80),
    walk = anim(40,80),
    run = anim(80,120),
    punch = anim(120, 160)
}
local player_animation_speeds = {
    idle = 20,
    sneak = 10,
    walk = 30,
    run = 50,
    punch = 60
}
local function dispatch_animation(animation, loop)
    local p = player_animation_table
    local a = p[animation]
    if loop == nil then
        loop = true
    end
    return {x = a.start, y = a.finish}, player_animation_speeds[animation], 0, loop
end

local player_models = {}

-- Initial hook
minetest.register_on_joinplayer(function(player)

    -- Disable all minetest-like hud elements
    for _,flag in ipairs(disable_flags) do
        player:hud_set_flags({
            [flag] = false
        })
    end

    -- Disable minetest player model hardcodes
    player:set_properties({
        textures = {"dz_nothing.png"},
        visual_size = {x = 1, y = 1}
    })

    -- Now begin this hackjob to get first person body view
    local name = player:get_player_name()
    local model = minetest.add_entity(player:get_pos(), "player:player")

    if model and model:get_pos() then
        model:set_attach(player, "", vector.new(0,0,0), vector.new(0,0,0), true)
        model:set_animation(dispatch_animation("idle"))
        player_models[name] = {
            model = model,
            animation = "idle",
            timer = 0
        }
    else
        -- I dunno, kick them and lets try again I guess
        minetest.kick_player(player:get_player_name(), "My programming sucks so you have to rejoin very sorry")
    end


    -- Now disable sneaking
    player:set_physics_override({
        sneak = false
    })
    -- print(dump2(player:get_physics_override()))
end)

-- Get that garbage out of the server memory
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    if not player_models[name] then return end
    if not player_models[name].model then return end
    player_models[name].model:remove()
end)


-- This is the logic loop for animations and movement speed
minetest.register_globalstep(function(dtime)
    local name = ""
    local t = {}

    for _,player in ipairs(minetest.get_connected_players()) do
        name = player:get_player_name()

        --FIXME: Probably should check if the model exists
        t = player_models[name]

        local controls = player:get_player_control()

        local running = controls.aux1
        local sneaking = controls.sneak
        local punching = controls.LMB


        -- This is the worst logic branch I've ever seen

        -- Punching basically locks you in place for some reason
        if punching or t.animation == "punch" then
            if t.animation ~= "punch" then
                t.animation = "punch"
                t.model:set_animation(dispatch_animation("punch"))
                player:set_physics_override({
                    speed = 0.0,
                    jump = 0
                })
                -- This is definitely not going to work on servers lmao
                player:add_velocity(vector.multiply(player:get_velocity(), -1))
            end
            if t.timer < 0.75 then
                t.timer = t.timer + dtime
            else
                t.animation = ""
                t.timer = 0
            end

            print("in punch loop")
        else
            if (controls.up or controls.down or controls.left or controls.right) then

                if sneaking and t.animation ~= "sneak" then
                    t.model:set_animation(dispatch_animation("sneak"))
                    player:set_physics_override({
                        speed = 0.5,
                        jump = 1
                    })
                    t.animation = "sneak"
                elseif not running and not sneaking and t.animation ~= "walk" then
                    t.model:set_animation(dispatch_animation("walk"))
                    player:set_physics_override({
                        speed = 0.5,
                        jump = 1
                    })
                    t.animation = "walk"
                elseif running and not sneaking and t.animation ~= "run" then
                    t.model:set_animation(dispatch_animation("run"))
                    player:set_physics_override({
                        speed = 1.25,
                        jump = 1
                    })
                    t.animation = "run"
                end

            elseif t.animation ~= "idle" then
                t.model:set_animation(dispatch_animation("idle"))
                player:set_physics_override({
                    speed = 0.5,
                    jump = 1
                })
                t.animation = "idle"
            end
        end
    end
end)


