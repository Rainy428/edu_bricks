local MODNAME = minetest.get_current_modname()
local C = edu_bricks.common

minetest.register_node(MODNAME .. ":stage_brick", {
    description = "Edu Stage Brick (Protected)",
    tiles = {"default_brick.png^[colorize:#003366:60"},
    is_ground_content = false,

    groups = {unbreakable = 1},

    diggable = C.PROTECTED_NODE_DEF.diggable,
    can_dig = C.PROTECTED_NODE_DEF.can_dig,
    drop = C.PROTECTED_NODE_DEF.drop,
    on_blast = C.PROTECTED_NODE_DEF.on_blast,

    on_punch = function(pos, node, player, pointed_thing)
        C.handle_teacher_pickup_buffered(
            pos,
            player,
            pointed_thing,
            MODNAME .. ":stage_brick",
            "brick_pickup",
            350000,
            0.10
        )
    end,
})