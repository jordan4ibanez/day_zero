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
