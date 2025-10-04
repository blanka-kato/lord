local setmetatable, table_walk, tonumber, table_is_empty, tostring_or_nil, type
    = setmetatable, table.walk, tonumber, table.is_empty, string.or_nil, type

local FieldType = require('base_classes.Meta.FieldType')


--- @class base_classes.Meta.Base
local BaseMeta = {
	key_prefix = nil,
	--- @protected
	--- @type MetaDataRef
	meta = nil,       --- @diagnostic disable-line: assign-type-mismatch
	--- @protected
	--- @type table<string,string> key - name of field, value - field-type (one of base_classes.Meta.FieldType::<CONST>)
	field_type = {},
}

--- @public
--- @generic GenericMeta: base_classes.Meta.Base
--- @param child_class GenericMeta
--- @return GenericMeta
function BaseMeta:extended(child_class)
	assert(type(child_class) == 'table')
	assert(child_class.field_type and type(child_class.field_type) == 'table')
	table.walk(child_class.field_type, function(value, key)
		assert(type(value) == 'string')
		assertf(value:is_one_of(FieldType), 'Unknown type `%s` for field `%s`', value, key)
	end)

	return setmetatable(child_class, { __index = self })
end

--- @public
--- @overload fun(meta:MetaDataRef)
--- @param meta       MetaDataRef
--- @param key_prefix string|nil
--- @generic GenericMeta: base_classes.Meta.Base
--- @return GenericMeta
function BaseMeta:new(meta, key_prefix)
	local class = self

	self = {}
	self.meta       = meta
	self.key_prefix = key_prefix or class.key_prefix or ''

	return setmetatable(self, {
		--- @generic GenericMeta: base_classes.Meta.Base
		--- @param instance GenericMeta
		__index    = function(instance, field)
			local field_value = class[field]
			if field_value ~= nil then
				return field_value
			end

			return instance:get(field)
		end,
		__newindex = class.set,
	})
end

--- @public
--- @param key string
--- @return boolean|nil
function BaseMeta:contains(key)
	return self.meta:contains(key)
end

BaseMeta.has = BaseMeta.contains

--- @param field string
--- @return string
function BaseMeta:get_type(field)
	local field_type = self.field_type[field]
	if not field_type then
		errorlf('Undefined field: `%s`', 4, field or 'nil')
	end

	return field_type
end

--- @protected
--- @param field_type string one of base_classes.Meta.FieldType::<CONST>
--- @param key        string
--- @param default    any
--- @return nil|any
function BaseMeta:get_typified(field_type, key, default)
	key = self.key_prefix .. key

	if field_type == FieldType.BOOLEAN then
		local value = self.meta:get(key)
		if value == nil then  return default  end

		return minetest.is_yes(tonumber(value))
	elseif field_type == FieldType.INTEGER then
		return tonumber(self.meta:get(key) or default)
	elseif field_type == FieldType.STRING then
		return self.meta:get(key) or default
	elseif field_type == FieldType.TABLE then
		return minetest.parse_json(self.meta:get(key) or 'null', default)
	else
		errorf('Something went wrong...')
	end
end

--- @public
--- @param field   string
--- @param default any
--- @return any
function BaseMeta:get(field, default)
	return self:get_typified(self:get_type(field), field, default)
end

--- @protected
--- @param field_type  string one of base_classes.Meta.FieldType::<CONST>
--- @param key   string
--- @param value any
--- @generic GenericMeta: base_classes.Meta.Base
--- @return GenericMeta
function BaseMeta:set_typified(field_type, key, value)
	key = self.key_prefix .. key

	if field_type == FieldType.BOOLEAN then
		self.meta:set_int(key, minetest.is_yes(value) and 1 or 0)
	elseif field_type == FieldType.INTEGER then
		--- @diagnostic disable-next-line: param-type-not-match -- TODO: consider to use `tonumber(value) or 0` instead
		self.meta:set_int(key, tonumber(value))
	elseif field_type == FieldType.STRING then
		--- @diagnostic disable-next-line: param-type-not-match -- TODO: consider to use `tostring_or_nil(value) or ''`
		self.meta:set_string(key, tostring_or_nil(value))
	elseif field_type == FieldType.TABLE then
		if type(value) ~= 'table' then
			errorlf('Type mismatch for meta-field `%s`: `table` expected, got `%s`', 3, key, type(value))
		end
		--- @diagnostic disable-next-line: param-type-not-match -- we checked the type above and that not table.is_empty
		self.meta:set_string(key, table_is_empty(value) and '[]' or minetest.write_json(value))
	else
		errorf('Something went wrong...')
	end

	return self
end

--- @param key_or_pairs string|table<string,any>
--- @param value        any
--- @generic GenericMeta: base_classes.Meta.Base
--- @return GenericMeta
function BaseMeta:set(key_or_pairs, value)
	if type(key_or_pairs) == 'table' then
		table_walk(key_or_pairs, function(val, key)
			self:set_typified(self:get_type(key), key, val)
		end)
	else
		self:set_typified(self:get_type(key_or_pairs), key_or_pairs, value)
	end

	return self
end


return BaseMeta
