

local S = skinstamp.translator


function skinstamp.get_formspec(pos)
    local spos = pos.x .. "," .. pos.y .. "," .. pos.z
    local formspec =
        "size[8,9]" ..
        "image[1.5,2.2;1,1;skinstamp_merge_arrow.png]"..
        "label[0,0;"..S("Skin Press").."]"..        
        "button[4,3.3;4,1;create_skin;"..S("Create skin").."]" ..
        "list[nodemeta:" .. spos .. ";main;1,1;2,1;0]" ..
        "list[nodemeta:" .. spos .. ";main;1.5,3.3;1,1;2]" ..
        "list[current_player;main;0,4.85;8,1;]" ..
        "list[current_player;main;0,6.08;8,3;8]" ..
        "listring[nodemeta:" .. spos .. ";main]" ..
        "listring[current_player;main]"
    return formspec
end




minetest.register_node("skinstamp:press", {
    description = S("Skin Press"),
    is_ground_content = false,
    groups = { choppy = 2, oddly_breakable_by_hand = 2},
    tiles = {
        {
            name = "skinstamp_guide.png",
            backface_culling = true,
            scale = 2
        }
    },
    use_texture_alpha = "clip",
    drawtype = "nodebox",
    paramtype = "light",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    action = function (pos, node)
        
    end,
    on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
        local cn = clicker:get_player_name()
        minetest.show_formspec(cn, "skinstamp:press_" .. minetest.pos_to_string(pos), skinstamp.get_formspec(pos))
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", S("Skin Press"))
        local inv = meta:get_inventory()
        inv:set_size("main", 3)
    end
})


function get_painting_grid (itemstack)
    local meta = itemstack:get_meta()
    print(dump(meta))
    local sgrid = meta:get_string("grid"); if not sgrid then return nil end
    print(dump(sgrid))
    local grid = minetest.deserialize(painting.decompress(sgrid)); if not grid then return nil end
    return grid
end

function combine_grids (grid1, grid2)
    local combined_grids = {}

    -- Fill the combined table with the values from the two original tables
    for i = 1, #grid1 do
        combined_grids[i] = grid1[i]
    end

    for i = 1, #grid2 do
        combined_grids[i+#grid1] = grid2[i]
    end

    return combined_grids
    -- -- Print the combined table to verify that it represents an 8x4 image
    -- for i = 1, #combine_grids do
    --     for j = 1, #combine_grids[i] do
    --         io.write(combine_grids[i][j] .. " ")
    --     end
    --     io.write("\n")
    -- end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if string.sub(formname, 0, 15) ~= "skinstamp:press" then
        return
    end

    local player_name = player:get_player_name()
    local spos = string.sub(formname, 17)
    local pos = minetest.string_to_pos(spos)
    local meta = minetest.get_meta(pos) ; if not meta then return end
    local press_inv = meta:get_inventory() ; if not press_inv then return end

    if fields["create_skin"] ~= nil then

        -- get painting data
        local l_item = press_inv:get_stack('main', 1)
        local r_item = press_inv:get_stack('main', 2)

        if l_item:get_name() ~= 'painting:paintedcanvas' or r_item:get_name() ~= 'painting:paintedcanvas' then
            minetest.chat_send_player(player_name, "Both items must be a paintedcanvas!")
            return true
        end

        local l_painting_grid = get_painting_grid(l_item)
        local r_painting_grid = get_painting_grid(r_item)

        print(dump(l_painting_grid))
        print(dump(r_painting_grid))

        if l_painting_grid == nil or r_painting_grid == nil then
            minetest.chat_send_player(player_name, "Invalid painting")
            return true
        end


        -- create an empty 64x32 grid
        local combined_grid = combine_grids(l_painting_grid, r_painting_grid)

        print(dump(combined_grid))

        -- --put picture data back into inventory item
        -- local picture = ItemStack("painting:paintedcanvas")
        -- local meta = picture:get_meta()
        -- meta:set_int("resolution", oldmetadata.fields["resolution"] or 16)
        -- meta:set_string("version", oldmetadata.fields["version"])
        -- meta:set_string("grid", oldmetadata.fields["grid"])
        -- local inv = digger:get_inventory()
        -- if inv:room_for_item("main", picture) then
        --     inv:add_item("main", picture)

        local skin = ItemStack("skinstamp:skin")

        if not press_inv:room_for_item("main", "skinstamp:skin") then
            minetest.chat_send_player(player_name, "The output slot must be empty")
            return
        end


        press_inv:add_item("main", skin)
        minetest.log("action", player:get_player_name().." created a skin at "..spos)
        return true

    end


end)