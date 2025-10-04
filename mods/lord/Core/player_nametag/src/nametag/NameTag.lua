local setmetatable, pairs
	= setmetatable, pairs

local Segment = require("nametag.NameTag.Segment")


--- @type nametag.Segments
local segments_definitions

--- Local in memory storage
--- @type nametag.NameTag[]|table<string,nametag.NameTag>
local storage = {}

--- @class nametag.NameTag
local NameTag = {
	--- @type Player
	player   = nil, --- @diagnostic disable-line: assign-type-mismatch
	--- @type table<string, nametag.NameTag.Segment>
	segments = {}
}


--- @param player Player player object, for which we get the `NameTag` instance.
function NameTag:new(player)
	self = setmetatable({}, { __index = self })

	self.player = player
	self.segments = {}

	for name, definition in pairs(segments_definitions.list()) do
		self.segments[name] = Segment:new(definition, self)
	end

	return self
end

--- @param name string technical name of nametag segment.
--- @return nametag.NameTag.Segment
function NameTag:segment(name)
	return self.segments[name]
end

--- Returns built nametag ready for display.
--- Concatenates built segments; Applies colors and templates (string.format()) for them.
--- @return string
function NameTag:build()
	local text = self.player:get_player_name()
	for _, segment in pairs(self.segments) do
		text = text .. " " .. segment:build()
	end

	return text
end

function NameTag:refresh()

end

function NameTag:force_refresh()
	self.player:set_nametag_attributes({ text = self:build() })
end


return {
	--- @param segments nametag.Segments
	set_segments = function(segments)
		segments_definitions = segments
	end,
	--- @param player Player
	--- @return nametag.NameTag
	for_player = function(player)
		local player_name = player:get_player_name()
		if not storage[player_name] then
			storage[player_name] = NameTag:new(player)
		else
			-- refresh pointer to player, as it could have to gone
			storage[player_name].player = player
		end

		return storage[player_name]
	end
}
