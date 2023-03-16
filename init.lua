
minetest.log("action", "skinstamp mod loading...")

skinstamp = {}
skinstamp.translator = default.get_translator
skinstamp.modpath = minetest.get_modpath(minetest.get_current_modname())


dofile(skinstamp.modpath.."/press.lua")
dofile(skinstamp.modpath.."/skin.lua")
dofile(skinstamp.modpath.."/ui.lua")