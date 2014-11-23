--[[
	Author: CodeX
	Date: 2014-11-21T21:00:00 CET
	Title: if.driver
	Description: -- too lazy
	Annotation:
		- When loading, this driver will create or overwrite
		a namespace given in the first argument
	Requires: ifm.driver
	Loading: !> if.driver {if0} {back}  [ifm-name] [iDuplex] [oDuplex]
]]

-- [[ OPTIONS
local options = {
	["ifm"] = "ifm", -- namespace of loaded ifm.driver
	["iDuplex"] = 0, -- namespace of loaded ifm.driver
	["oDuplex"] = 1, -- namespace of loaded ifm.driver
}
-- ]]

-- [[ INPUTS
args = {...}
if(#args < 2) then
	error(2, "IF.driver could not load as too many arguments are being passed")
end
local name    = args[1]
local port    = args[2]
local ifm     = options.ifm
local iDuplex = options.iDuplex
local oDuplex = options.oDuplex

if(args[3]) then ifm = args[3] end
if(args[4]) then iDuplex = args[4] end
if(args[5]) then oDuplex = args[5] end
-- ]]

local MACmap = {
	["front"]  = 1,
	["back"]   = 2,
	["right"]  = 3,
	["left"]   = 4,
	["top"]    = 5,
	["bottom"] = 6,
}

--create namespace
_G[name] = {}

_G[name]["__TYPE"] = "if"

--local helper functions
local function hash(payload)
	--generate checksum
	return 0
end

--restore point
local pullE = os.pullEvent
local pullEraw = os.pullEventRaw

local packetSuccess = 0
local packetFailure = 0
local packetDistance = 0

_G[name].getMAC = function()
	return 6 * os.getComputerID() + MACmap[port]
end

_G[name].makeFrame = function(destination, source, payload)
	return {destination, source, payload, hash(payload)}
end


local listener = function(e)
	if(e[1] == "modem_message") then								-- check whether network activity
		if(e[2] == args[1]) then									-- check for correct InterFace
			if(e[3] == 0 and e[4] == 1) then						-- check for correct link usage
				frame = textutils.unserialize(e[5])
				if(type(frame) == "table") then						-- check for frame
					if(frame[1] == getMAC()) then					-- check for me
						if(frame[4] == hash(frame[3])) then			-- check validation of message digest
							packetSuccess = packetSuccess + 1
							packetFailure = packetDistance + e[6]
							os.queueEvent("packet", frame[2], frame[5])
						else
							packetFailure = packetFailure + 1
						end
					else
						packetFailure = packetFailure + 1
					end
				else
					packetFailure = packetFailure + 1
				end
			else
				packetFailure = packetFailure + 1
			end
			return true
		end
	end
end

_G[name].lift = function()
	if(type(_G[ifm]) == "table") then
		_G[ifm].liftListener(name, listener)
	else
		error(2, "No ifm.driver installed")
	end
end
_G[name].drop = function()
	if(type(_G[ifm]) == "table") then
		_G[ifm].dropListener(name, listener)
	else
		error(2, "No ifm.driver installed")
	end
end
_G[name].send = function(destination, payload)
	makeFrame()
end
_G[name].sendFrameRaw = function(frame)
	makeFrame()
end