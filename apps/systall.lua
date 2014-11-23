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
	Requires:
		- http.get
		- json.parse
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
	if(http) then
		if(json) then
			js = http.get(url)
			if(json) then
				obj = json.parse(js)
				if(obj) then
					return obj
				else
					error("Could not parse API response", 3)
				end
			else
				error("Could not call API", 3)
			end
		else
			error("json parser not found", 3)
		end
	else
		error("http api not found", 3)
	end
end

if(args[1] == "ls") then
	repo = apicall("https://api.github.com/repos/InDieTasten/CodeX")
	branch = apicall("https://api.github.com/repos/InDieTasten/CodeX/branches/"..repo.default_branch)
	tree = apicall(branch.commit.tree.url)
	for k, elem in pairs(tree.tree) do
		if(elem.path == "install-definitions") then
			tree = apicall(elem.url)
			for k, elem in pairs(tree.tree) do
				name = elem.path
				print(string.sub(name, 1, #name-5))
			end
			break
		end
	end
end