--- @enum http.Method
local HTTPMethod = {
	GET    = "GET",
	POST   = "POST",
	PUT    = "PUT",
	DELETE = "DELETE",
}

--- @class http.Request: HTTPRequest

--- @class http.Request.Result: HTTPRequestResult

--- @class http.Request.Options: HTTPRequest
--- @field protected url? string|nil
--- @field protected method? string|nil


--- @alias http.Client.callback fun(result:http.Request.Result):void


--- **Usage:**
--- ```lua
---	http.Client:new("https://example.com/api/v1/", { timeout = 3 })
---		:on_success(function(result)
---			-- do success stuff
---		end)
---		:on_error(function(result)
---			-- do error stuff
---		end)
---		:post({
---			field1 = 'value1',
---			field2 = 'value2',
---		})
--- ```
---
--- @class http.Client
local Client = {
	--- @static
	--- @private
	--- @type HTTPApiTable
	mt_http_api  = nil, --- @diagnostic disable-line: assign-type-mismatch
	--- @static
	--- @private
	--- @type boolean
	debug        = false,
	--- @type string
	base_url     = nil, --- @diagnostic disable-line: assign-type-mismatch
	--- @type http.Request.Options
	base_options = {},
	--- @type http.Client.callback
	on_success   = nil, --- @diagnostic disable-line: assign-type-mismatch
	--- @type http.Client.callback
	on_error     = nil, --- @diagnostic disable-line: assign-type-mismatch
}

--- @param base_url     string
--- @param base_options http.Request.Options
---
--- @return http.Client
function Client:new(base_url, base_options)
	self = setmetatable({}, { __index = self })

	self.base_url     = base_url
	self.base_options = base_options

	return self
end

--- @param callback http.Client.callback
--- @return http.Client
function Client:on_success(callback)
	--- @diagnostic disable-next-line: assign-type-mismatch override `on_success` of instance & restore in `request()`
	self.on_success = callback

	return self
end

--- @param callback http.Client.callback
--- @return http.Client
function Client:on_error(callback)
	--- @diagnostic disable-next-line: assign-type-mismatch override `on_error` of instance & restore it in `request()`
	self.on_error = callback

	return self
end

--- @return http.Client.callback
function Client:getAsyncCallback()
	--- @type http.Client.callback|nil
	local on_success = self.on_success
	--- @type http.Client.callback|nil
	local on_error   = self.on_error

	--- @type http.Client.callback
	local callback = function(result)
		if self.debug then print(dump(result)) end
		if result.succeeded and result.code < 300 then
			if on_success then on_success(result) end
		else
			if on_error then on_error(result) end
		end
	end

	return callback
end

--- @param request  http.Request
--- @param callback http.Client.callback
function Client:rawRequest(request, callback)
	if self.debug then print(dump(request)) end
	self.mt_http_api.fetch(request, callback)
end

--- @param method  http.Method          one of HTTPMethod::<CONST>'ants
--- @param url     string               url postfix (appends to base_url)
--- @param options http.Request.Options additional request params
function Client:request(method, url, options)
	--- @type http.Request
	local request = table.merge(
		self.base_options,
		table.overwrite(
			{ url = self.base_url .. url, method = method, },
			options or {}
		)
	)

	self:rawRequest(request, self:getAsyncCallback())

	self.on_success = nil
	self.on_error = nil
end

--- @param url      string               url postfix (appends to base_url)
--- @param options? http.Request.Options additional request params
function Client:get(url, options)
	self:request(HTTPMethod.GET, url, options or {})
end

--- @param url      string               url postfix (appends to base_url)
--- @param data?    table                post data fields
--- @param options? http.Request.Options additional request params
function Client:post(url, data, options)
	self:request(HTTPMethod.POST, url, table.merge({ data = data, }, options or {}))
end

--- @param url      string               url postfix (appends to base_url)
--- @param data?    table                post data fields
--- @param options? http.Request.Options additional request params
function Client:put(url, data, options)
	self:request(HTTPMethod.PUT, url, table.merge({ data = data, }, options or {}))
end

--- @param url      string               url postfix (appends to base_url)
--- @param data?    table                post data fields
--- @param options? http.Request.Options additional request params
function Client:delete(url, data, options)
	self:request(HTTPMethod.DELETE, url, table.merge({ data = data, }, options or {}))
end


return {
	--- @param http_api HTTPApiTable
	--- @return http.Client
	init = function(http_api, debug)
		Client.mt_http_api = http_api
		Client.debug       = debug

		return Client
	end
}
