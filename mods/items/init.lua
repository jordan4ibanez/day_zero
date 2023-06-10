minetest.register_entity("items:gun", {
    initial_properties = {
        visual = "mesh",
        mesh = "machine_gun.obj",
        textures = {"dz_dirt.png"}
    }
})

minetest.register_chatcommand("gib",{
    func = function(name)
        minetest.add_entity(minetest.get_player_by_name(name):get_pos(), "items:gun")
    end
})