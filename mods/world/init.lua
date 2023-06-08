minetest.set_mapgen_setting("caves", "false", true)
minetest.set_mapgen_setting("dungeons", "false", true)

minetest.register_node("world:grass", {
    tiles = {"dz_grass.png"}
})
minetest.register_node("world:stone", {
    tiles = {"dz_stone.png"}
})
minetest.register_node("world:dirt", {
    tiles = {"dz_dirt.png"}
})


local noise_parameters = {
    offset = 0,
    scale = 1,
    spread = {x = 200, y = 100, z = 200},
    seed = tonumber(minetest.get_mapgen_setting("seed")) or math.random(0,999999999),
    octaves = 5,
    persist = 0.9,
    lacunarity = 1.5,
}


local vm = {}
local emin = {}
local emax = {}
local area = VoxelArea:new({MinEdge = vector.new(0,0,0), MaxEdge = vector.new(0,0,0)})

local data = {}
local grass = minetest.get_content_id("world:grass")
local dirt = minetest.get_content_id("world:dirt")
local stone = minetest.get_content_id("world:stone")

local heightRange = 12

local perlinNoise = PerlinNoise(noise_parameters)

minetest.register_on_generated(function(minp, maxp)

    if maxp.y > 47 or minp.y < -32 then
        return
    end

    vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    vm:get_data(data)
    area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

    for x = minp.x,maxp.x do
        for z = minp.z, maxp.z do
            -- todo: optimize this
            local yHeight = math.floor((perlinNoise:get_2d({x = x, y = z}) * heightRange) + 0.5)
            data[area:index(x,yHeight,z)] = grass
            data[area:index(x,yHeight - 1,z)] = dirt
            data[area:index(x,yHeight - 2,z)] = stone
        end
    end

    vm:set_data(data)
    vm:calc_lighting(nil, nil, false)
    vm:write_to_map()
end)