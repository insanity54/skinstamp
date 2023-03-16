
local S = skinstamp.translator


minetest.register_craftitem("skinstamp:skin", {
  description = S("Skin"),
  inventory_image = "skinstamp_skin.png",
  stack_max = 1,
  groups = { 
    snappy = 2, 
    choppy = 2, 
    oddly_breakable_by_hand = 3, 
    not_in_creative_inventory=1
  },
})
