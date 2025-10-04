
--- @class base_classes.Form.Mixin.WithDetached: base_classes.Form.Mixin
local WithDetached = {
	--- @protected
	--- @generic GenericDetachedInventory: base_classes.DetachedInventory
	--- @type GenericDetachedInventory
	inventory = nil,
	--- @static
	--- @private
	--- @generic GenericDetachedInventory: base_classes.DetachedInventory
	--- @type GenericDetachedInventory
	Inventory_class = false,
}

--- @static
--- @param class           base_classes.Form.Base|base_classes.Form.Mixin.WithDetached
--- @param Inventory_class base_classes.DetachedInventory
function WithDetached.mix_to(class, Inventory_class)
	class.Inventory_class = Inventory_class

	--- @param self base_classes.Form.Mixin.WithDetached
	--- @param player Player
	class.on_instance(function(self, player)
		self.inventory = self.Inventory_class:new(player)
	end)
end


return WithDetached
