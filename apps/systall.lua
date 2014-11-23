--[[
	Author: CodeX
	Date: 2014-11-23T19:19:00 CET
	Title: systall
	Description:
		This application is to change the systems
		definition.
	Annotation:
		This tool will overwrite and/or delete
		existing files
	Requires: http(s)-api
	Usage: !> systall --help
]]
local args = {...}

--Usage

if(args[1] == "--help") then
	print("Usage:")
	print("systall ls")
	print(" -> Lists available system definitions")
	print("systall get   -> Get current definition name")
	print(" -> Get current definition name")
	print("systall change [option] {defname}")
	print(" -> Installs given defintion")
	print("    options:")
	print("     --kud  keeps user data")
	print("     --bua  backup all")
	print("systall recover {backup-loc}")
	print(" -> Recovers system from backup")
	print("systall update")
	print(" -> Updates current definition")
end


local function apicall(url)
	json = http.get(url)
	if(json) then
		obj = json.parse(json)
		if(obj) then
			return obj
		else
			error("Could not parse API response", 2)
		end
	else
		error("Could not call API", 2)
	end
end

if(args[1] == "ls") then
	repo = http.get("https://api.github.com/repos/InDieTasten/CodeX")
	if(repo) then
		repo = json.parse(repo)
		if(repo) then
			branch = http.get("https://api.github.com/repos/InDieTasten/CodeX/branches/"..repo.default_branch)
			if(branch) then
				branch = json.parse(branch)
				if(branch) then

				end
			end
		end
	end
end