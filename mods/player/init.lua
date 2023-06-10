local disable_flags = {"healthbar", "crosshair", "wielditem", "breathbar", "basic_debug"}

minetest.register_entity("player:player", {
    initial_properties = {
        visual = "mesh",
        mesh = "player.b3d",
        textures = {
            "player.png"
        }
    },
    on_activate = function(self)
        minetest.after(0,function()
            if self.object:get_attach() then return end
            self.object:remove()
        end)
    end
})

local function anim(start, finish)
    return {start = start, finish = finish}
end

local player_animation_table = {
    idle = anim(0,40),
    sneak = anim(40,80),
    walk = anim(40,80),
    run = anim(80,120),

    fists_up = anim(121, 160),
    fists_up_walk = anim(160, 200),

    punch = anim(200,240),
    punch_walk = anim(240,280)
    
}
local player_animation_speeds = {
    idle = 20,
    sneak = 10,
    walk = 30,
    run = 50,

    fists_up = 30,
    fists_up_walk = 30,

    punch = 60,
    punch_walk = 60
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

-- No Jumping
local jump_attempt = 0.0
-- Fast falling
local gravity = 10.0
-- General speeds
local walk_speed = 0.5
local run_speed = 1.1
local sneak_speed = 0.4

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
        visual_size = {x = 1, y = 1},
        stepheight = 1.01
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
    -- Also you can jump but it ain't gonna get you no where
    player:set_physics_override({
        sneak = false,
        jump = jump_attempt,
        gravity = gravity
    })

    player:set_lighting({
        -- This can turn the game black and white
        saturation = 0.9,

        shadows = {
            intensity = 0.4
        },
        -- I just put in a bunch of randon numbers and it looks nice
        exposure = {
            exposure_correction = 0.7,
            center_weight_power = 0.6,
            luminance_max = 5,
            luminance_min = -5,
            speed_dark_bright = 100,
            speed_bright_dark = 500
        }
    })
    
    print(dump2(player:get_lighting()))
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

    --todo If this causes problems on servers move it into loop
    local function set_animation(new_animation, loop)
        t.animation = new_animation
        if new_animation == "" then return end
        if loop == nil then
            loop = true
        end
        t.model:set_animation(dispatch_animation(new_animation, loop))
    end

    local function current_animation()
        return t.animation
    end

    for _,player in ipairs(minetest.get_connected_players()) do
        name = player:get_player_name()

        --FIXME: Probably should check if the model exists
        t = player_models[name]
        
        local function new_speed(speed)
            player:set_physics_override({
                speed = speed
            })
        end

        local function timer() return t.timer end
        local function set_timer(new_value) t.timer = new_value end

        local controls = player:get_player_control()
        local running = controls.aux1
        local sneaking = controls.sneak
        local movement = controls.up or controls.down or controls.left or controls.right


        local punching = controls.LMB
        local aiming = controls.RMB


        -- This is the worst logic branch I've ever seen

        -- Minetest has no way to do multi element animation so this looks like shit
        if aiming or current_animation() == "punch" or current_animation() == "punch_walk" then

            -- Players will be stuck at walk speeds while in combat
            if current_animation() == "punch" or current_animation() == "punch_walk" then
                if timer() < 0.6 then
                    set_timer(timer() + dtime)
                else
                    set_timer(0)
                    -- Player is out of punching animation
                    set_animation("")
                end
            elseif punching then
                -- This is a hack to stop animations from breaking flow
                if movement then
                    set_animation("punch_walk")
                    new_speed(walk_speed)
                else
                    set_animation("punch")
                    new_speed(0)
                    player:add_velocity(vector.multiply(player:get_velocity(), -1))
                end
            else
                if movement and current_animation() ~= "fists_up_walk" then
                    print("fists up walk")
                    set_animation("fists_up_walk")
                    new_speed(walk_speed)
                elseif not movement and current_animation() ~= "fists_up" then
                    print("fists up")
                    set_animation("fists_up")
                    new_speed(walk_speed)
                end
            end
        -- Now we're moving wooo
        else
            if movement then

                if sneaking and t.animation ~= "sneak" then
                    
                    set_animation("sneak")
                    new_speed(sneak_speed)

                elseif not running and not sneaking and t.animation ~= "walk" then

                    set_animation("walk")
                    new_speed(walk_speed)

                elseif running and not sneaking and t.animation ~= "run" then

                    set_animation("run")
                    new_speed(run_speed)

                end

            elseif t.animation ~= "idle" then

                set_animation("idle")
                new_speed(walk_speed)

            end
        end
    end
end)


