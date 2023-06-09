local terrain_noise_parameters = {
    offset = 0,
    scale = 1,
    spread = {x = 200, y = 100, z = 200},
    seed = tonumber(minetest.get_mapgen_setting("seed")) or math.random(0,999999999),
    octaves = 3,
    persist = 0.25,
    lacunarity = 1.5,
}

local tree_noise_parameters = {
    offset = 0,
    scale = 1,
    spread = {x = 2, y = 2, z = 2},
    seed = tonumber(minetest.get_mapgen_setting("seed")) -50000,
    octaves = 8,
    persist = 0.5,
    lacunarity = 3.5,
    flags = "noeased"
}

-- Don't change these
local minY = -32
local maxY = 47

-- You can change these
local heightRange = 20
local baseHeight = 2
local waterHeight = -17

-- Don't change these
assert(baseHeight + heightRange <= maxY)
assert(baseHeight - heightRange >= minY)
assert(waterHeight - 1 > minY)
assert(waterHeight + 1 < maxY)

-- These are just optimizations
local terrain_perlin_noise = PerlinNoise(terrain_noise_parameters)
local tree_perlin_noise = PerlinNoise(tree_noise_parameters)

local vm = {}
local emin = {}
local emax = {}
local area = VoxelArea:new({MinEdge = vector.new(0,0,0), MaxEdge = vector.new(0,0,0)})

local data = {}

local grass = minetest.get_content_id("world:grass")
local dirt = minetest.get_content_id("world:dirt")
local stone = minetest.get_content_id("world:stone")
local water = minetest.get_content_id("world:water")
local pine_tree = minetest.get_content_id("world:pine_tree")

-- The map is actually 2d
minetest.register_on_generated(function(minp, maxp)

    if maxp.y > 47 or minp.y < -32 then
        return
    end

    vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    vm:get_data(data)
    area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

    print("new map chunk")

    for x = minp.x,maxp.x do
        for z = minp.z, maxp.z do
            local yHeight = math.floor((terrain_perlin_noise:get_2d({x = x, y = z}) * heightRange) + 0.5)

            if (yHeight <= waterHeight) then -- Generate water
                -- Generates water with dirt under so swimming can be simulated
                data[area:index(x,waterHeight,z)] = water
                data[area:index(x,waterHeight - 1,z)] = dirt

            else
                -- Generate land
                data[area:index(x,yHeight,z)] = grass
                data[area:index(x,yHeight - 1,z)] = dirt
                data[area:index(x,yHeight - 2,z)] = stone

                -- Generate trees
                local tree_noise = tree_perlin_noise:get_2d({x = x, y = z})
                -- print("tree_noise:",tree_noise)
                if (math.abs(tree_noise) > 1.3) then
                    data[area:index(x,yHeight + 1,z)] = pine_tree
                end
            end
        end
    end

    vm:set_data(data)
    vm:calc_lighting(nil, nil, false)
    vm:write_to_map()
end)