local S = skinstamp.translator
local F = minetest.formspec_escape
local ui = unified_inventory





ui.register_button('skinstamp', {
  type = 'image',
  image = 'skinstamp_button.png',
  tooltip = 'Skin'
})

ui.register_page("skinstamp", {
  get_formspec = function(player, perplayer_formspec)
    local player_name = player:get_player_name()
    return { 
      formspec = table.concat({
        "list[detached:" .. F(player_name) .. "_skinstamp;skin;1.075,1.65;1,1;]",
      }) 
    }
  end
})





minetest.register_on_joinplayer(function(player)
  local player_name = player:get_player_name()
  local bags_inv = minetest.create_detached_inventory(player_name .. "_skinstamp", {
    allow_put = function(inv, listname, index, stack, player)
      
      if stack:get_name() ~= "skinstamp:skin" then
        return 0 -- ItemStack is not a skin.
      end

      return 1
    end,
    on_put = function(inv, listname, index, stack, player)
      player:get_inventory():set_size(listname .. "contents",
          stack:get_definition().groups.bagslots)
      save_bags_metadata(player, inv)
    end,
    allow_take = function(inv, listname, index, stack, player)
      if player:get_inventory():is_empty(listname .. "contents") then
        return stack:get_count()
      end
      return 0
    end,
    on_take = function(inv, listname, index, stack, player)
      player:get_inventory():set_size(listname .. "contents", 0)
      save_bags_metadata(player, inv)
    end,
    allow_move = function()
      return 0
    end,
  }, player_name)

  load_bags_metadata(player, bags_inv)
end)
