local Event             = require('base_classes.Event')
local Form              = require('base_classes.Form')
local DetachedInventory = require('base_classes.DetachedInventory')
local ObjectState       = require('base_classes.ObjectState')
local HUD               = require('base_classes.HUD')
local Meta              = require('base_classes.Meta')


base_classes = {} -- luacheck: ignore unused global variable base_classes

local function register_api()
	_G.base_classes = {
		--- @type base_classes.Event
		Event             = Event,
		--- @type base_classes.Form
		Form              = Form,
		--- @type base_classes.DetachedInventory
		DetachedInventory = DetachedInventory,
		--- @type base_classes.ObjectState
		ObjectState       = ObjectState,
		--- @type base_classes.HUD
		HUD               = HUD,
		--- @type base_classes.Meta
		Meta              = Meta,
	}
end


return {
	--- @param mod minetest.Mod
	init = function(mod)
		register_api()
	end,
}
