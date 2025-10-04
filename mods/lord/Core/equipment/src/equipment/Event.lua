local pairs
	= pairs


local SUBSCRIBERS_EVENTS_SET_OF_KIND = {
	["set"]    = {},
	["delete"] = {},
	["create"] = {},
	["load"]   = {},
	["change"] = {},
}

--- @alias equipment.Event.callback fun(player:Player,kind:string,event:string,slot:number,item:ItemStack)

--- @class equipment.Event
local Event = {}

--- @private
--- @type table<string, table<string, equipment.Event.callback[]>>
Event.subscribers = {
	["*any*"] = table.copy(SUBSCRIBERS_EVENTS_SET_OF_KIND),
	["*all*"] = {
		["load_all"] = {},
	},
}

--- @internal
--- @param kind string kind(type) of equipment. For ex. "armor"|"clothing"|<your_one>.
function Event.addSubscribersKind(kind)
	if kind == "*any*" or kind == "*all*" then
		-- This function is internal & used only by `Kind.register()`
		-- So we pass `level == 3` for `error()`, it will point to where the `Kind.register()` was called
		error("Names \"*all*\" and \"*any*\" are reserved. You are can't use them for `kind` name.", 3)
	end
	Event.subscribers[kind] = table.copy(SUBSCRIBERS_EVENTS_SET_OF_KIND)
end

--- @param kind     string equipment kind(type)
--- @param event    string
--- @param callback fun(player:Player, kind:string, event:string, slot:number, item:ItemStack)
function Event.subscribe(kind, event, callback)
	table.insert(Event.subscribers[kind][event], callback)
end

--- @private
function Event.notify(player, subscribers_kind, kind, event, slot, item)
	for _, callback in pairs(Event.subscribers[subscribers_kind][event]) do
		callback(player, kind, event, slot, item)
	end
end

--- @overload fun(player:Player,kind:string,event:string)
--- @param player Player
--- @param kind   string
--- @param event  string
--- @param slot   number
--- @param item   ItemStack
function Event.trigger(player, kind, event, slot, item)
	if event == "create" then
		Event.notify(player, kind, kind, event)
		return
	end
	if event == "load" then
		Event.notify(player, kind, kind, event, slot, item)
		Event.notify(player, "*any*", kind, event, slot, item)
		return
	end
	if event == "load_all" then
		Event.notify(player, kind, kind, event)
		return
	end
	Event.notify(player, kind, kind, event, slot, item)
	Event.notify(player, kind, kind, "change", slot, item)  -- TODO use Event.CHANGE constant
	Event.notify(player, "*any*", kind, event, slot, item)
	Event.notify(player, "*any*", kind, "change", slot, item)
end

return {
	addSubscribersKind = Event.addSubscribersKind,
	subscribe          = Event.subscribe,
	trigger            = Event.trigger,
}
