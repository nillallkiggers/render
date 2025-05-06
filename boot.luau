--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.
repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

if identifyexecutor and ({identifyexecutor()})[1] == 'Argon' then
	getgenv().setthreadidentity = nil
end

local vape
--local executor: string = identifyexecutor();
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/'..readfile('rendervape/profiles/commit.txt')..'/'..select(1, path:gsub('rendervape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				loadstring(readfile('rendervape/boot.luau'), 'boot')()
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			--[[if identifyexecutor == nil or ({identifyexecutor()})[1] ~= 'Swift' then 
				queue_on_teleport(teleportScript);
			end;]]
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('rendervape/profiles/gui.txt') then
	writefile('rendervape/profiles/gui.txt', 'new');
end;

local gui = readfile('rendervape/profiles/gui.txt') :: string;

if not isfolder('rendervape/assets/'..gui) then
	makefolder('rendervape/assets/'..gui);
end

vape = loadstring(downloadFile('rendervape/guis/'..gui..'.lua'), 'gui')();
shared.vape = vape;

if not shared.VapeIndependent then
	loadstring(downloadFile('rendervape/games/vape/universal.lua'), 'vape/universal')();
	loadstring(downloadFile('rendervape/games/universal.lua'), 'universal')();
	if isfile('rendervape/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('rendervape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...); 
	end;
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end