--[[
	Author: CodeX
	Date: 2014-11-21T22:38:00 CET
	Title: ifm.driver
	Description:
		This driver is for managing multiple interfaces at the
		same priority level and enabling dynamic lifting and dropping
		of interfaces in dynamic order
	Annotation:
		- This overwrites the standard os.pullEvent and replaces it with
		one working the same way, but capturing all events rendering
		them in the listeners
		- Also adds namespace: 'ifm'
	Requires: none
	Loading: !> ifm.driver
]]

-- [[ OPTIONS
local namespace = "ifm" -- namespace the ifm.driver is allocated to
-- ]]


local defaultHandle
local defaultHandleRaw

local listeners = {}

_G[namespace] = {}

_G[namespace].liftListener = function(name, listener)
	listeners[name] = listener
end
_G[namespace].dropListener = function(name)
	listeners[name] = nil
end

local ifmHandle = function(...)
	list = {...}
	while(true) do
		e = {defaultHandle()}
		for k,v in pairs(listeners) do
			if(v(e)) then break end
		end
		for k,v in pairs(list) do
			if(v == e[1]) then
				return e
			end
		end
	end
end
local ifmHandleRaw = function(...)
	list = {...}
	while(true) do
		e = {defaultHandleRaw()}
		for k,v in pairs(listeners) do
			if(v(e)) then break end
		end
		for k,v in pairs(list) do
			if(v == e[1]) then
				return e
			end
		end
	end
end

_G[namespace].manage = function()
	defaultHandle = os.pullEvent
	defaultHandleRaw = os.pullEventRaw
	os.pullEvent = ifmHandle
	os.pullEventRaw = ifmHandleRaw
end
_G[namespace].unmanage = function()
	os.pullEvent = defaultHandle
	os.pullEventRaw = defaultHandleRaw
	defaultHandle = nil
	defaultHandleRaw = nil
end
