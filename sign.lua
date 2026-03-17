local MODNAME = minetest.get_current_modname()
local C = edu_bricks.common

local SIGN_NODE = MODNAME .. ":sign"
local SIGN_FORMSPEC_PREFIX = MODNAME .. ":sign_edit:"
local SIGN_READ_PREFIX     = MODNAME .. ":sign_read:"

local function formspec_edit(text)
    text = text or ""
    return "formspec_version[4]" ..
        "size[12,8]" ..
        "label[0.5,0.4;看板メッセージ（改行OK / 保存で反映）]" ..
        "textarea[0.5,1.0;11.0,5.6;msg;;" .. minetest.formspec_escape(text) .. "]" ..
        "button[8.6,6.9;3.0,0.9;save;保存]" ..
        "button_exit[0.5,6.9;3.0,0.9;cancel;閉じる]"
end

local function formspec_read(text)
    text = text or ""
    return "formspec_version[4]" ..
        "size[12,8]" ..
        "label[0.5,0.4;看板メッセージ]" ..
        "textarea[0.5,1.0;11.0,5.6;_;;" .. minetest.formspec_escape(text) .. "]" ..
        "button_exit[8.6,6.9;3.0,0.9;ok;OK]"
end

minetest.register_node(SIGN_NODE, {
    description = "Edu Sign (Protected)",
    drawtype = "nodebox",
    tiles = {"default_sign_wall_wood.png"},
    inventory_image = "default_sign_wood.png",
    wield_image = "default_sign_wood.png",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    is_ground_content = false,
    walkable = false,
    use_texture_alpha = "opaque",

    node_box = {
        type = "wallmounted",
        wall_top    = {-0.4375, 0.4375, -0.3125, 0.4375, 0.5, 0.3125},
        wall_bottom = {-0.4375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125},
        wall_side   = {-0.5, -0.3125, -0.4375, -0.4375, 0.3125, 0.4375},
    },

    legacy_wallmounted = true,
    sounds = (default and default.node_sound_wood_defaults)
        and default.node_sound_wood_defaults()
        or nil,

    groups = {unbreakable = 1, attached_node = 1},
    diggable = C.PROTECTED_NODE_DEF.diggable,
    can_dig = C.PROTECTED_NODE_DEF.can_dig,
    drop = C.PROTECTED_NODE_DEF.drop,
    on_blast = C.PROTECTED_NODE_DEF.on_blast,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("text", "")
        meta:set_string("infotext", "看板（空）")
    end,

    on_punch = function(pos, node, player, pointed_thing)
        if not C.is_player(player) then return end
        if not C.same_pointed_node(pos, pointed_thing) then return end

        local name = player:get_player_name()
        local ctrl = C.get_ctrl(player)

        if not ctrl or not ctrl.aux1 then
            local text = minetest.get_meta(pos):get_string("text") or ""
            minetest.show_formspec(
                name,
                SIGN_READ_PREFIX .. minetest.pos_to_string(pos),
                formspec_read(text)
            )
            return
        end

        if ctrl.sneak and ctrl.aux1 then
            C.handle_teacher_pickup_buffered(
                pos,
                player,
                pointed_thing,
                SIGN_NODE,
                "sign_pickup",
                350000,
                0.10
            )
            return
        end

        if ctrl.aux1 then
            if not C.is_teacher(player) then
                minetest.chat_send_player(name, "編集権限がない。")
                return
            end

            if not C.cooldown_ok(player, "sign_edit", 200000) then
                return
            end

            local text = minetest.get_meta(pos):get_string("text") or ""
            minetest.show_formspec(
                name,
                SIGN_FORMSPEC_PREFIX .. minetest.pos_to_string(pos),
                formspec_edit(text)
            )
        end
    end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if not player or not formname or not fields then return false end

    if formname:sub(1, #SIGN_FORMSPEC_PREFIX) ~= SIGN_FORMSPEC_PREFIX then
        return false
    end

    local pos_str = formname:sub(#SIGN_FORMSPEC_PREFIX + 1)
    local pos = minetest.string_to_pos(pos_str)
    if not pos then return true end
    if not fields.save then return true end

    local node = minetest.get_node_or_nil(pos)
    if not node or node.name ~= SIGN_NODE then
        return true
    end

    if not C.is_teacher(player) then
        return true
    end

    local text = fields.msg or ""
    if #text > 512 then
        minetest.chat_send_player(player:get_player_name(), "Text too long（最大512文字）")
        return true
    end

    text = C.sanitize_multiline_text(text, 50)

    local meta = minetest.get_meta(pos)
    meta:set_string("text", text)
    meta:set_string("infotext", C.make_infotext("看板:", text, "看板（空）", 240))

    minetest.chat_send_player(player:get_player_name(), "看板を保存した。")
    return true
end)