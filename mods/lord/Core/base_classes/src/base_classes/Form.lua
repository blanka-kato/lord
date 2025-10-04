local BaseForm = require('base_classes.Form.Base')
local Mixin    = require('base_classes.Form.Mixin')
local Element  = require('base_classes.Form.Element')



--- Facade `Form`: Factory(Generator) for Form Classes & its Elements.
--- This class constructs for you a base form class.
--- Use methods to mix functionality you need and then call `:extended()` method.
---
--- @class base_classes.Form
--- @field personal      fun(self:self): self
--- @field for_node      fun(self:self): self
--- @field with_detached fun(self:self): self
--- @field with_tabs     fun(self:self, tabs:table<string,number>): self
local Form = {
	--- @type table<string,table>
	will_mixed = {},

	--- @type base_classes.Form.Mixin[]|table<string,base_classes.Form.Mixin>
	mixins = {
		personal      = Mixin.Personal,
		for_node      = Mixin.ForNode,
		with_detached = Mixin.WithDetached,
		with_tabs     = Mixin.WithTabs,
	},

	Element = Element,
}
setmetatable(Form, {
	--- @param self  base_classes.Form
	--- @param mixin string
	__index = function(self, mixin)
		if not self.mixins[mixin] then
			errorlf('Undefined mixin `%s`', 3, mixin)
		end

		--- @param _ self
		--- @vararg any all params passed to mix method (`for_node`, `with_tabs`), that will be passed to `'mixin':mix_to()`
		return function(_, ...)
			self.will_mixed[mixin] = { ... }

			return self
		end
	end
})

--- @public
---
--- @generic GenericForm: base_classes.Form.Base
--- @param child_class GenericForm
---
--- @return GenericForm
function Form:extended(child_class)
	local class = BaseForm:extended(child_class or {})

	for name, params in pairs(self.will_mixed) do
		class:mix(self.mixins[name], unpack(params))
	end

	self.will_mixed = {}

	return class
end

--- @public
--- @param mix_method_name string
--- @param mixin           base_classes.Form.Mixin
--- @return self
function Form:register_mixin(mix_method_name, mixin)
	self.mixins[mix_method_name] = mixin

	return self
end


return Form
