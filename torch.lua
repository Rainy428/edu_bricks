local MODNAME = minetest.get_current_modname()
local C = edu_bricks.common

local function get_wood_sounds()
    if default and default.node_sound_wood_defaults then
        return default.node_sound_wood_defaults()
    end
    return nil
end

local function edu_torch_on_flood(pos, oldnode, newnode)
    minetest.add_item(pos, ItemStack(MODNAME .. ":torch 1"))
    return false
end

local function edu_torch_pickup(pos, node, player, pointed_thing)
    C.handle_teacher_pickup_buffered(
        pos,
        player,
        pointed_thing,
        MODNAME .. ":torch",
        "torch_pickup",
        350000,
        0.10
    )
end

minetest.register_node(MODNAME .. ":torch", {
    description = "Edu Torch (Protected)",
    drawtype = "mesh",
    mesh = "torch_floor.obj",
    inventory_image = "default_torch_on_floor.png",
    wield_image = "default_torch_on_floor.png",
    tiles = {{
        name = "default_torch_on_floor_animated.png",
        animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
    }},
    use_texture_alpha = "clip",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    liquids_pointable = false,
    light_source = 12,

    groups = {unbreakable = 1, attached_node = 1, torch = 1},
    diggable = C.PROTECTED_NODE_DEF.diggable,
    can_dig = C.PROTECTED_NODE_DEF.can_dig,
    drop = C.PROTECTED_NODE_DEF.drop,
    on_blast = C.PROTECTED_NODE_DEF.on_blast,

    selection_box = {
        type = "wallmounted",
        wall_bottom = {-1/8, -1/2, -1/8, 1/8, 2/16, 1/8},
    },

    sounds = get_wood_sounds(),

    on_place = function(itemstack, placer, pointed_thing)
        local under = pointed_thing.under
        local node = minetest.get_node(under)
        local def = minetest.registered_nodes[node.name]

        if def and def.on_rightclick and
            not (placer and placer:is_player() and placer:get_player_control().sneak) then
            return def.on_rightclick(under, node, placer, itemstack, pointed_thing) or itemstack
        end

        local above = pointed_thing.above
        local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
        local fakestack = ItemStack(itemstack)

        if wdir == 0 then
            fakestack:set_name(MODNAME .. ":torch_ceiling")
        elseif wdir == 1 then
            fakestack:set_name(MODNAME .. ":torch")
        else
            fakestack:set_name(MODNAME .. ":torch_wall")
        end

        itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)
        itemstack:set_name(MODNAME .. ":torch")
        return itemstack
    end,

    on_punch = edu_torch_pickup,
    floodable = true,
    on_flood = edu_torch_on_flood,
    on_rotate = false,
})

minetest.register_node(MODNAME .. ":torch_wall", {
    drawtype = "mesh",
    mesh = "torch_wall.obj",
    tiles = {{
        name = "default_torch_on_floor_animated.png",
        animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
    }},
    use_texture_alpha = "clip",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    light_source = 12,

    groups = {unbreakable = 1, not_in_creative_inventory = 1, attached_node = 1, torch = 1},
    diggable = C.PROTECTED_NODE_DEF.diggable,
    can_dig = C.PROTECTED_NODE_DEF.can_dig,
    drop = C.PROTECTED_NODE_DEF.drop,
    on_blast = C.PROTECTED_NODE_DEF.on_blast,

    selection_box = {
        type = "wallmounted",
        wall_side = {-1/2, -1/2, -1/8, -1/8, 1/8, 1/8},
    },

    sounds = get_wood_sounds(),
    on_punch = edu_torch_pickup,

    floodable = true,
    on_flood = edu_torch_on_flood,
    on_rotate = false,
})

minetest.register_node(MODNAME .. ":torch_ceiling", {
    drawtype = "mesh",
    mesh = "torch_ceiling.obj",
    tiles = {{
        name = "default_torch_on_floor_animated.png",
        animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
    }},
    use_texture_alpha = "clip",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    light_source = 12,

    groups = {unbreakable = 1, not_in_creative_inventory = 1, attached_node = 1, torch = 1},
    diggable = C.PROTECTED_NODE_DEF.diggable,
    can_dig = C.PROTECTED_NODE_DEF.can_dig,
    drop = C.PROTECTED_NODE_DEF.drop,
    on_blast = C.PROTECTED_NODE_DEF.on_blast,

    selection_box = {
        type = "wallmounted",
        wall_top = {-1/8, -1/16, -5/16, 1/8, 1/2, 1/8},
    },

    sounds = get_wood_sounds(),
    on_punch = edu_torch_pickup,

    floodable = true,
    on_flood = edu_torch_on_flood,
    on_rotate = false,
})