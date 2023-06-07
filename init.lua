-- vim: ts=4 sw=4 et
local modname = minetest.get_current_modname()

local function get_target_name(pos, listname, index)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local tar_stack = inv:get_stack(listname, index)
    local tar_name = tar_stack:get_name()
    return tar_name
end

bookshelf_def = table.copy(minetest.registered_nodes["default:bookshelf"])

bookshelf_def.description = "Library Bookshelf"

bookshelf_def.allow_metadata_inventory_put = 
function(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end

    local tar_name = get_target_name(pos, listname, index)
    minetest.chat_send_player(player:get_player_name(), "put " .. stack:get_name() ..  " to spot which already contains: " .. tar_name)

    if stack:get_name() == "default:book_written" 
        or stack:get_name() == "keys:skeleton_key" and tar_name == "default:book_written"
    then
        return stack:get_count()
    end

    return 0
end

bookshelf_def.allow_metadata_inventory_move = 
function(pos, from_list, from_index, to_list, to_index, count, player)
    minetest.chat_send_player(player:get_player_name(), "move")
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    else
        return count
    end
end

bookshelf_def.allow_metadata_inventory_take =
function(pos, listname, index, stack, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local tar_stack = inv:get_stack(listname, index)
    local tar_name = tar_stack:get_name()

    minetest.chat_send_player(player:get_player_name(), "take stack name: " .. stack:get_name() .. " (target stack: )" .. tar_stack:get_name())

    local count = stack:get_count()
    if stack:get_name() == "default:book_written" then
        --if minetest.is_protected(pos, player:get_player_name()) then
            return -1
        --[[else
            return count
        end--]]
    else
        if minetest.is_protected(pos, player:get_player_name()) then
            return 0
        else
            return count
        end
    end
end

local nodename = modname..":shelf"

local old_on_put = bookshelf_def.on_metadata_inventory_put
bookshelf_def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
    minetest.chat_send_player(player:get_player_name(), "putted: " .. stack:get_name())
    old_on_put(pos, listname, index, stack, player)
end

minetest.register_node(nodename, bookshelf_def)

minetest.register_craft({
    output = nodename,
    recipe = { {"default:bookshelf", "default:mese_crystal"}, },
})
