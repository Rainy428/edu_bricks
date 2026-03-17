local MODNAME = minetest.get_current_modname()

edu_bricks = rawget(_G, "edu_bricks") or {}
edu_bricks.common = edu_bricks.common or {}

local C = edu_bricks.common

C.cooldowns = C.cooldowns or {}

minetest.register_privilege("edu_teacher", {
    description = "Can edit and pick up protected education nodes",
    give_to_singleplayer = true,
})

C.PROTECTED_NODE_DEF = {
    diggable = false,
    can_dig = function() return false end,
    drop = "",
    on_blast = function() end,
}

C.PICKUP_BUFFER_NODE = MODNAME .. ":pickup_buffer"

if not minetest.registered_nodes[C.PICKUP_BUFFER_NODE] then
    minetest.register_node(C.PICKUP_BUFFER_NODE, {
        description = "Pickup Buffer",
        drawtype = "airlike",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        pointable = true,
        diggable = false,
        buildable_to = false,
        floodable = true,
        groups = {not_in_creative_inventory = 1},
        drop = "",
        on_blast = function() end,
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
        collision_box = {
            type = "fixed",
            fixed = {0, 0, 0, 0, 0, 0},
        },
    })
end

function C.is_player(player)
    return player and player:is_player()
end

function C.get_player_name(player)
    if not C.is_player(player) then return nil end
    return player:get_player_name()
end

function C.get_ctrl(player)
    if not C.is_player(player) then return nil end
    return player:get_player_control()
end

function C.is_teacher_pickup(player)
    local ctrl = C.get_ctrl(player)
    return ctrl and ctrl.sneak and ctrl.aux1 and C.is_teacher(player)
end

function C.is_teacher(player)
    local name = C.get_player_name(player)
    if not name then return false end
    return minetest.check_player_privs(name, {edu_teacher = true})
end

function C.same_pos(a, b)
    if not a or not b then return false end
    return a.x == b.x and a.y == b.y and a.z == b.z
end

function C.same_pointed_node(pos, pointed_thing)
    return pointed_thing
        and pointed_thing.type == "node"
        and pointed_thing.under
        and C.same_pos(pointed_thing.under, pos)
end

function C.cooldown_ok(player, key, us)
    local name = C.get_player_name(player)
    if not name then return false end

    key = tostring(key or "pickup")
    us = tonumber(us) or 300000

    local now = minetest.get_us_time()
    C.cooldowns[key] = C.cooldowns[key] or {}

    local last = C.cooldowns[key][name] or 0
    if now - last < us then
        return false
    end

    C.cooldowns[key][name] = now
    return true
end

function C.add_item(player, pos, itemname)
    if not C.is_player(player) then return false end

    local stack = ItemStack(itemname)
    local inv = player:get_inventory()

    if inv and inv:room_for_item("main", stack) then
        inv:add_item("main", stack)
    else
        minetest.add_item(pos, stack)
    end

    return true
end

function C.pickup_buffered(pos, player, itemname, cd_key, cd_us, delay)
    if not C.is_player(player) then return false end

    if not C.cooldown_ok(player, cd_key or "pickup", cd_us or 300000) then
        return false
    end

    delay = delay or 0.10

    local node = minetest.get_node_or_nil(pos)
    if not node then return false end

    minetest.swap_node(pos, {name = C.PICKUP_BUFFER_NODE})

    minetest.after(delay, function()
        local node_now = minetest.get_node_or_nil(pos)
        if node_now and node_now.name == C.PICKUP_BUFFER_NODE then
            minetest.remove_node(pos)
        end
        C.add_item(player, pos, itemname)
    end)

    return true
end

function C.handle_teacher_pickup_buffered(pos, player, pointed_thing, itemname, cd_key, cd_us, delay)
    if not C.is_player(player) then return false end
    if not C.same_pointed_node(pos, pointed_thing) then return false end
    if not C.is_teacher_pickup(player) then return false end

    return C.pickup_buffered(
        pos,
        player,
        itemname,
        cd_key or "pickup",
        cd_us or 300000,
        delay or 0.15
    )
end

function C.sanitize_multiline_text(s, max_lines)
    s = s or ""
    max_lines = max_lines or 50

    s = s:gsub("[%z\1-\8\11-\31\127]", "")
    s = s:gsub("\r\n", "\n"):gsub("\r", "\n")

    local lines = {}
    for line in (s .. "\n"):gmatch("(.-)\n") do
        lines[#lines + 1] = line
        if #lines >= max_lines then break end
    end

    return table.concat(lines, "\n")
end

function C.make_infotext(prefix, text, empty_text, max_chars)
    text = text or ""
    empty_text = empty_text or "空"
    max_chars = max_chars or 240

    text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
    if text == "" then
        return empty_text
    end

    if #text > max_chars then
        text = text:sub(1, max_chars) .. "…"
    end

    if prefix and prefix ~= "" then
        return prefix .. "\n" .. text
    end
    return text
end