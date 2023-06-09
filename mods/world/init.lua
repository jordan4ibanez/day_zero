minetest.set_mapgen_setting("caves", "false", true)
minetest.set_mapgen_setting("dungeons", "false", true)

local dir = minetest.get_modpath("world")

dofile(dir .. "/nodes.lua")
dofile(dir .. "/terrain_generation.lua")