-- Pi is equal to 180 degrees so half Pi is 90 degrees, tree needs to fall 90 degrees
local HALF_PI = math.pi / 2.0

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
-- Pine tree starts off standing up node
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
    },

    on_punch = function(pos, node)
        minetest.sound_play({name = "dz_tree_fell", pos = pos,  max_hear_distance = 128})
        minetest.add_entity(pos, "world:pine_tree_falling")
        minetest.remove_node(pos)
    end
})

-- Pine tree falling over entity animation
minetest.register_entity("world:pine_tree_falling", {
    initial_properties = {
        visual = "mesh",
        mesh = "dz_pine_tree.obj",
        textures = {
            "dz_pine_tree_branch.png",
            "dz_pine_tree_stem.png",
        }
    },
    backface_culling = false,
    visual_size = {x = 10, y = 10, z = 10},
    rotation = 0,
    on_step = function(self, dtime)

        self.rotation = self.rotation + (dtime / 3.0)
        self.object:set_rotation({x = self.rotation, y = 0, z = 0})

        if self.rotation >= HALF_PI then
            local pos = self.object:get_pos()
            self.object:remove()
            minetest.set_node(pos, {name = "world:pine_tree_fallen"})
        end
    end
})

local pine_tree_fallen_collisionbox = {
    -0.2,-0.2,-7,
    0.2,0.2,0.5
}
-- Pine tree becomes fallen node
minetest.register_node("world:pine_tree_fallen", {
    paramtype = "light",
    paramtype2 = "degrotate",
    drawtype = "mesh",
    mesh = "dz_pine_tree_fallen.obj",
    use_texture_alpha = "clip",
    tiles = {
        "dz_pine_tree_branch.png",
        "dz_pine_tree_stem.png",
    },
    visual_scale = 1.0,
    collision_box = {
        type = "fixed",
        fixed = pine_tree_fallen_collisionbox
    },
    selection_box = {
        type = "fixed",
        fixed = pine_tree_fallen_collisionbox
    }
})