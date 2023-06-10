minetest.register_entity("items:gun", {
    initial_properties = {
        visual = "mesh",
        mesh = "machine_gun.obj",
        textures = {"dz_dirt.png"},
        visual_size = vector.new(0.1,0.1,0.1)
    }
})

minetest.register_chatcommand("gib",{
    func = function(name)
        local player = minetest.get_player_by_name(name)
        local gunny = minetest.add_entity(player:get_pos(), "items:gun")
        
        local player_model = get_player_model(name)
        gunny:set_attach(player_model, "hand.R", vector.new(0.1,0.3,0.24), vector.new(15,-90,0))
    end
})