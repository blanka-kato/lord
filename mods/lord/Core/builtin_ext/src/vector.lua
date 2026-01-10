
--- @return vector
function vector:above()
	return self:offset(0, 1, 0)
end

--- @return vector
function vector:under()
	return self:offset(0, -1, 0)
end

--- @return vector
function vector:at_north()
	return self:offset(0, 0, 1)
end

--- @return vector
function vector:at_south()
	return self:offset(0, 0, -1)
end

--- @return vector
function vector:at_east()
	return self:offset(1, 0, 0)
end

--- @return vector
function vector:at_west()
	return self:offset(-1, 0, 0)
end
