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
function verbose(text)
	print(text)
end
-- ]]

-- [[ INPUTS
local args = {...}
local namespace = options.namespace
if(args[1]) then namespace = args[1] end
-- ]]

-- creating namespace
_G[namespace] = {}

local function first(json)
	if(#json > 0) then
		return string.sub(json, 1, 1)
	else
		error("End of string", 2)
	end
end
local pos = 1
local function removeFirst(json)
	print(pos)
	pos = pos+1
	sleep(0.05)
	if(#json > 1) then
		return string.sub(json, 2, #json)
	elseif(#json == 1) then
		return ""
	else
		error("End of string", 2)
	end
end

local whitespace = {" ","	","\n"}
local function isWhitespace(x) --done tested
	for k,v in pairs(whitespace) do
		if(v == x) then return true end
	end
	return false
end
local function removeWhitespace(json) --done tested
	if(#json == 0) then return json end
	while(isWhitespace(first(json))) do
		json = removeFirst(json)
	end
	return json
end
local function isString(json) --done tested
	e, m = pcall(readString, json)
	return e
end
local function isNumber(json) --done tested
	e, m = pcall(readNumber, json)
	return e
end
local function isObject(json) --done tested
	e, m = pcall(readObject, json)
	return e
end
local function isArray(json) --done tested
	e, m = pcall(readArray, json)
	return e
end
local function isValue(json) --done tested
	e, m = pcall(readValue, json)
	return e
end
local function isTrue(json) --done tested
	e, m = pcall(readTrue, json)
	return e
end
local function isFalse(json) --done tested
	e, m = pcall(readFalse, json)
	return e
end
local function isNull(json) --done tested
	e, m = pcall(readNull, json)
	return e
end
local function readString(json) --done tested
	local out = ""
	json = removeWhitespace(json)
	if(first(json) == "\"") then
		json = removeFirst(json)
		if(first(json) == "\"") then
			json = removeFirst(json)
			return out, json
		else
			while(true) do
				if(first(json) ~= "\\" and first(json) ~= "\"") then --normal chars
					out = out..first(json)
					json = removeFirst(json)
				elseif(first(json) == "\\") then -- control chars
					json = removeFirst(json)
					local n = first(json)
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
						json = removeFirst(json)
						json = removeFirst(json)
						json = removeFirst(json)
						json = removeFirst(json)
						m = "?"
					else
						error("Error reading string: "..tostring(json))
					end
					json = removeFirst(json)
					out = out..m
				elseif(first(json) == "\"") then -- end of string
					json = removeFirst(json)
					return out, json
				else
					error("Erreor reading string: "..tostring(json))
				end
			end
		end
	else
		error("Error reading string: "..tostring(json))
	end
	json = removeWhitespace(json)
end
local digit19 = {
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["8"] = true,
	["9"] = true
}
local digit09 = {
	["0"] = true,
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["8"] = true,
	["9"] = true
}
local e = {
	["e"] = true,
	["E"] = true
}
local sign = {
	["+"] = true,
	["-"] = true
}
local function readNumber(json) --done tested
	--validate
	json = removeWhitespace(json)
	local backup = json
	if(first(json) == "-") then
		json = removeFirst(json)
	end
	if(digit19[first(json)]) then
		json = removeFirst(json)
		while(digit09[first(json)]) do
			json = removeFirst(json)
		end
	elseif(first(json) == "0") then
		json = removeFirst(json)
	else
		error("Error reading number: "..tostring(json))
	end
	if(first(json) == ".") then
		json = removeFirst(json)
		if(digit09[first(json)]) then
			json = removeFirst(json)
			while(digit09[first(json)]) do
				json = removeFirst(json)
			end
		else
			error("Error reading number: "..tostring(json))
		end
	end
	if( e[ first(json) ] ) then
		json = removeFirst(json)
		if( sign[ first(json) ] ) then
			json = removeFirst(json)
		end
		if(digit09[ first(json) ]) then
			json = removeFirst(json)
			while(digit09[ first(json) ]) do
				json = removeFirst(json)
			end
		else
			error("Error reading number: "..tostring(json))
		end
	end
	return tonumber(string.sub(backup, 1, #backup-#json)), json
end
local function readObject(json) --done tested
	local out = {}
	json = removeWhitespace(json)
	if(first(json) == "{") then
		json = removeFirst(json)
		json = removeWhitespace(json)
		if(first(json) == "}") then
			json = removeFirst(json)
			json = removeWhitespace(json)
			return out, json
		elseif(isString(json)) then
			while (true) do
				if(isString(json)) then
					k, json = readString(json)
					json = removeWhitespace(json)
					if(first(json) == ":") then
						json = removeFirst(json)
						json = removeWhitespace(json)
						if(isValue(json)) then
							v, json = readValue(json)
							out[k] = v

							verbose(tostring(k)..": "..tostring(v))

							json = removeWhitespace(json)
							if(first(json) == ",") then
								json = removeFirst(json)
								json = removeWhitespace(json)
							elseif(first(json) == "}") then
								json = removeFirst(json)
								json = removeWhitespace(json)
								return out, json
							else
								error("Error reading object: "..tostring(json))
							end
						else
							error("Error reading object: "..tostring(json))
						end
					else
						error("Error reading object: "..tostring(json))
					end
				else
					error("Error reading object: "..tostring(json))
				end
			end
		else
			error("Error reading object: "..tostring(json))
		end
	else
		error("Error reading object: "..tostring(json))
	end
end
local function readArray(json) --done tested
	local out = {}
	local index = 1
	json = removeWhitespace(json)
	if(first(json) == "[") then
		json = removeFirst(json)
		if(first(json) == "]") then
			json = removeFirst(json)
			return out, json
		end
		while true do
			if(isValue(json)) then
				out[index], json = readValue(json)
				index = index + 1
				json = removeWhitespace(json)
				if(first(json) == ",") then
					json = removeFirst(json)
				elseif(first(json) == "]") then
					json = removeFirst(json)
					return out, json
				else
					error("Error reading array: "..tostring(json))
				end
			else
				error("Error reading array: "..tostring(json))
			end
		end
		json = removeFirst(json)
		return out, json
	else
		error("Error reading array: "..tostring(json))
	end
end
local function readValue(json) --done tested
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
		error("Error reading value: "..tostring(json))
	end
end
local function readTrue(json) --done tested
	json = removeWhitespace(json)
	if(string.sub(json, 1, 4) == "true") then
		json = string.sub(json, 5, #json)
		json = removeWhitespace(json)
		return true, json
	else
		error("Error reading true: "..tostring(json))
	end
end
local function readFalse(json) --done tested
	json = removeWhitespace(json)
	if(string.sub(json, 1, 5) == "false") then
		json = string.sub(json, 6, #json)
		json = removeWhitespace(json)
		return true, json
	else
		error("Error reading false: "..tostring(json))
	end
end
local function readNull(json) --done tested
	json = removeWhitespace(json)
	if(string.sub(json, 1, 4) == "null") then
		json = string.sub(json, 5, #json)
		json = removeWhitespace(json)
		return nil, json
	else
		error("Error reading null: "..tostring(json))
	end
end


_G[namespace].parse = function(json)
	tmp, _ = readValue(json)
	return tmp
end