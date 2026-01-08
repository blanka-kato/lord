local type, math_floor, math_random, math_is_among, vector_sort, v,          id
    = type, math.floor, math.random, math.is_among, vector.sort, vector.new, core.get_content_id


local id_air = id('air')

--- @param data integer[]
function VoxelArea:set_data(data)
	self.data = data
end

--- @param data_param2 integer[]
function VoxelArea:set_data_param2(data_param2)
	self.data_param2 = data_param2
end

--- @param data_light integer[]
function VoxelArea:set_data_light(data_light)
	self.data_light = data_light
end

--- Iterate over positions in area.
--- Use `data[i]` to set/get node at position.
--- Usage:
--- ```lua
--- vox_area:foreach(function(i, data, data_param2, data_light)
---    data[i] = id('default:stone') -- id('default:stone') <==> core.get_content_id('default:stone')
--- end)
--- ```
--- Note: use preloaded ids for better performance.
---
--- @overload fun(callback: fun(i:integer, data:integer[], data_param2:integer[], data_light:integer[])):self
--- @param from Position
--- @param to   Position
--- @param callback fun(i:integer, data:integer[], data_param2:integer[], data_light:integer[])
--- @return self
function VoxelArea:foreach(from, to, callback)
	if type(from) == 'function' then
		callback = from
		from     = self.MinEdge
		to       = self.MaxEdge
	end

	local data = self.data
	for i in self:iterp(from, to) do
		callback(i, data)
	end

	return self
end

--- Sets the node at the specified position to the given node ID.
--- Preloaded node IDs are recommended for better performance; use `core.get_content_id(name)` to preload.
--- @param position Position
--- @param node_id  integer
---
--- @return self
function VoxelArea:set_node_at(position, node_id, param2, light)
	local i = self:indexp(position)
	self.data[i] = node_id
	if param2 then self.data_param2[i] = param2 end
	if light  then self.data_light [i] = light  end

	return self
end

--- Sets all nodes in the specified area to the given node ID or random IDs.
--- @param node_id integer|integer[] if is array of integers, than area part wil be filled with random nodes from it.
--- @param from?   Position
--- @param to?     Position
---
--- @return self
function VoxelArea:fill_with(node_id, from, to)
	from = from or self.MinEdge
	to   = to   or self.MaxEdge
	local data = self.data

	local is_random = type(node_id) == 'table'
	if is_random then
		local nodes_count = #node_id
		for i in self:iterp(from, to) do
			data[i] = node_id[math_random(nodes_count)]
		end
	else
		for i in self:iterp(from, to) do
			data[i] = node_id
		end
	end

	return self
end

--- Places a pile of nodes randomly within the specified area in cuboid [from, to].
--- Nodes are only placed above non-air nodes, with a 50% chance at each valid position.
--- Note: Preloaded node IDs are recommended for better performance; use `core.get_content_id(name)` to preload.
--- Cubaoid [from, to] is inclusive and will be sorted automatically.
---
--- @param node_id   integer|integer[] if is array, random nodes will be placed.
--- @param from?     Position          position from which to start placing pile.
--- @param to?       Position          position to which to place pile.
--- @param peak?     Position          peak position of the pile.
--- @param fillness? number            fillness of the pile, 0..1 (default is 0.75).
--- @param param2?   integer|integer[] if is array, random param2 will be set.
---
--- @return self
function VoxelArea:place_pile(node_id, from, to, peak, fillness, param2)
	from     = from     or self.MinEdge
	to       = to       or self.MaxEdge
	fillness = fillness or 0.75
	from, to = vector_sort(from, to)

	peak = peak or v(
		math_floor((from.x + to.x) / 2),
		to.y,
		math_floor((from.z + to.z) / 2)
	)
	local height = to.y - from.y + 1
	-- Deltas from peak to sides of base of pile (pyramid)
	local peak_from_dx = peak.x - from.x
	local peak_from_dz = peak.z - from.z
	local peak_to_dx   = to.x - peak.x
	local peak_to_dz   = to.z - peak.z

	local data = self.data

	local is_random        = type(node_id) == 'table'
	local is_random_param2 = type(param2) == 'table'
	local nodes_count      = is_random and #node_id or 0
	local param2_count     = is_random_param2 and #param2 or 0

	self:foreach(from, to, function(i)

		local pos = self:position(i)

		-- place above, only if below is not air
		local below_i = self:indexp(v(pos) - v(0, 1, 0))
		local is_below_inside = self:containsi(below_i)
		if not (
			not is_below_inside
			or (is_below_inside and data[below_i] ~= id_air)
		) then
			return
		end

		local layer = pos.y - from.y -- 0..height-1

		local layer_from_dx = from.x + peak_from_dx * layer / height
		local layer_to_dx   = to.x   - peak_to_dx   * layer / height
		local layer_from_dz = from.z + peak_from_dz * layer / height
		local layer_to_dz   = to.z   - peak_to_dz   * layer / height

		if
			math_is_among(pos.x, layer_from_dx, layer_to_dx) and
			math_is_among(pos.z, layer_from_dz, layer_to_dz) and
			math_random() <= fillness
		then
			data[i] = is_random
				and node_id[math_random(nodes_count)]
				or  node_id--[[@as integer]]
			if param2 then
				self.data_param2[i] = is_random_param2
					and param2[math_random(param2_count)]
					or  param2--[[@as integer]]
			end
		end
	end)

	return self
end
