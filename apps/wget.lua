--[[
	Author: CodeX
	Date: 2014-11-22T11:42:00 CET
	Title: wget
	Description:
		This tool is to easily download files over the
		http(s)-api of standard CC
	Annotation:
		This tool will overwrite existing files
	Requires: http(s)-api
	Usage: !> wget {url} {filename}
]]

args = {...}

local url = args[1]
local filename = args[2]

if(not http) then
	print("http(s)-api disabled or moved")
	shell.exit()
end

local response = http.get(url)
if(response) then
	print("Response code: ", response.getResponseCode())
	local fileHandle = fs.open(filename, "w")
	if(fileHandle) then
		fileHandle.write(response.readAll())
		fileHandle.close()
	else
		print("Could not open file: ", filename)
	end
else
	print("Could not connect to page: ", url)
end