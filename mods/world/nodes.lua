minetest.register_node("world:grass", {
    tiles = {"dz_grass.png"}
})
minetest.register_node("world:stone", {
    tiles = {"dz_stone.png"}
})
minetest.register_node("world:dirt", {
    tiles = {"dz_dirt.png"}
})
minetest.register_node("world:water", {
    tiles = {"dz_water.png"}
})

local pine_tree_collisionbox = {
    -0.2,-0.5,-0.2,
    0.2,7,0.2
}
minetest.register_node("world:pine_tree", {
    paramtype = "light",
    paramtype2 = "degrotate",
    drawtype = "mesh",
    mesh = "dz_pine_tree.obj",
    use_texture_alpha = "clip",
    tiles = {
        "dz_pine_tree_branch.png",
        "dz_pine_tree_stem.png",
    },
    visual_scale = 1.0,
    collision_box = {
        type = "fixed",
        fixed = pine_tree_collisionbox
    },
    selection_box = {
        type = "fixed",
        fixed = pine_tree_collisionbox
    }
})