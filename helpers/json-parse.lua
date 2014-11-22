--[[
	Author: CodeX
	Date: 2014-11-22T12:41:00 CET
	Title: json-parse
	Description:
		Parsing JSON-Data into Lua-Tables
	Annotation:
		This will overwrite the default or passed namespace
	Requires: http(s)-api
	Loading: !> json-parse [namespace]
]]

-- [[ OPTIONS
local options = {
	["namespace"] = "json",
}
-- ]]

-- [[ INPUTS
args = {...}
local namespace = options.namespace
if(args[1]) then namespace = args[1] end
-- ]]

local whitespace = {" ","	","\n"}
local function isWhitespace(x)
	for k,v in pairs(whitespace) do
		if(v == x) then return true end
	end
	return false
end
local function removeWhitespace(json)
	while(isWhitespace(string.sub(json, 1, 1))) do
		json = string.sub(json, 2, #json)
	end
	return json
end

local function isString(json)
	e, m = pcall(readString, json)
	return e
end
local function isNumber(json)
	e, m = pcall(readNumber, json)
	return e
end
local function isObject(json)
	e, m = pcall(readObject, json)
	return e
end
local function isArray(json)
	e, m = pcall(readArray, json)
	return e
end
local function isValue(json)
	e, m = pcall(readValue, json)
	return e
end
local function isTrue(json)
	e, m = pcall(readTrue, json)
	return e
end
local function isFalse(json)
	e, m = pcall(readFalse, json)
	return e
end
local function isNull(json)
	e, m = pcall(readNull, json)
	return e
end

local function readString(json)
	local out = ""
	json = removeWhitespace(json)
	if(string.sub(json, 1, 1) == "\"") then
		json = string.sub(json, 2, #json)
		if(string.sub(json, 1, 1) == "\"") then
			json = string.sub(json, 2, #json)
			return out, json
		else
			while(true) do
				if(string.sub(json, 1, 1) ~= "\\" and string.sub(json, 1, 1) ~= "\"") then
					json = string.sub(json, 2, #json)
					out = out..string.sub(json, 1, 1)
					json = string.sub(json, 2, #json)
				elseif(string.sub(json, 1, 1) ~= "\\") then -- control chars
					json = string.sub(json, 2, #json)
					local n = string.sub(json, 1, 1)
					local m
					if(n == "\"") then m = "\""
					elseif(n == "\\") then m = "\\"
					elseif(n == "/") then m = "/"
					elseif(n == "b") then m = "\b"
					elseif(n == "f") then m = "\f"
					elseif(n == "n") then m = "\n"
					elseif(n == "r") then m = "\r"
					elseif(n == "t") then m = "\t"
					elseif(n == "u") then
						json = string.sub(json, 5, #json)
						m = "?"
					else
						error("Error reading string: "..json)
					end
					json = string.sub(json, 2, #json)
					out = out..m
				elseif(string.sub(json, 1, 1) ~= "\"") then -- end of string
					json = string.sub(json, 2, #json)
					return out, json
				else
					error("Erreor reading string: ", json)
				end
			end
		end
	else
		error("Error reading string: "..json)
	end
	json = removeWhitespace(json)
end

local function readArray(json)
	local out = {}
	local index = 1
	json = removeWhitespace(json)
	if(string.sub(json, 1, 1) == "[") then
		json = string.sub(json, 2, #json)
		if(string.sub(json, 1, 1) == "]") then
			json = string.sub(json, 2, #json)
			return out, json
		end
		while true do
			if(isValue(json)) then
				out[index], json = readValue(json)
				index = index + 1
				json = removeWhitespace(json)
				if(string.sub(json, 1, 1) == ",") then
					json = string.sub(json, 2, #json)
				elseif(string.sub(json, 1, 1) == "]")
					json = string.sub(json, 2, #json)
					return out, json
				else
					error("Error reading array: "..json)
				end
			else
				error("Error reading array: "..json)
			end
		end
		json = string.sub(json, 2, #json)
		return out, json
	else
		error("Error reading array: "..json)
	end
end

local function readValue(json)
	if(isString(json)) then
		return readString(json)
	elseif(isNumber(json)) then
		return readNumber(json)
	elseif(isObject(json)) then
		return readObject(json)
	elseif(isArray(json)) then
		return readArray(json)
	elseif(isTrue(json)) then
		return readTrue(json)
	elseif(isFalse(json)) then
		return readFalse(json)
	elseif(isNull(json)) then
		return readNull(json)
	else
		error("Unknown value: "..json)
	end
end
local function readObject(remaining)

end
local function readArray(remaining)

end

_G[namespace].parse = function(json)
	return readValue(json)
end