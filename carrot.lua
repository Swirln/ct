-- by carrot
-- dab
print("CT: Loading v1.0.0...")

---------------------------------------------------------------------------------------------------------
--// Declarations
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting") 
local owners = {"s_nowfall", "trashprovider56"} -- s_nowfall included for 2018 testing hhhhhhhh
local admins = {"s_nowfall", "trashprovider56"}
local blacklistedPlayers = {"misawa", "Ruin", "satanist"} -- aka banned
local sePrefix = "//" -- Script Execution Prefix (serverside)
local lsPrefix = ".." -- Local Script Prefix
local lsPlrPrefix = ";;" -- Local Script Player Prefix
local prefixes = {
	":",
	";",
	"?",
	"^",
	"@",
	".",
	"/",
	"$",
	"!"
}
local dayAndNight = false
---------------------------------------------------------------------------------------------------------
--// Functions that should be in lua but aren't
local function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function starts(stringF, start)
   return string.sub(stringF, 1, string.len(start)) == start
end

local function returnIndexOf(tab, el)
	for index, value in pairs(tab) do
		if value == el then
			return index
		end
	end
end

local function push(x)
    return x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x
end
---------------------------------------------------------------------------------------------------------
--// Admin command functions
local function blacklisted(name)
	name = string.lower(name)
	if hasValue(blacklistedPlayers, name) then
		return true
	end
    return false
end

local function isOwner(player)
	for _, owner in pairs(owners) do
		if string.lower(owner) == string.lower(player.Name) then
			return true
		end
	end
	return false
end

local function isAdmin(player)
	for _, admin in pairs(owners) do
		if string.lower(admin) == string.lower(player.Name) then
			return true
		end
	end
	if isOwner(player) then return true end
	return false
end

local function getPlayerByUsername(name)
	local players_ = Players:GetPlayers()
	for _, player in pairs(players_) do
		if string.lower(player.Name) == string.lower(name) then
			return player
		end
	end
	return false
end

local function getPlayerByUserId(userId)
	local players_ = Players:GetPlayers()
	for _, player in pairs(players_) do
		if player.userId == userId then
			return player
		end
	end
	return false
end

local function parseSelection(sender, arguments)
	if #arguments == 0 then
		return {sender} -- assume they're asking for an ff of themselves, e.g: ;ff
	end
	local players_ = Players:GetPlayers()
	local IMPlayers = {}
	local toReturn = {}
	if arguments[1] == "all" then
		return players_
	elseif arguments[1] == "others" then
		local index = returnIndexOf(players_, sender)
		if index then
			table.remove(players_, index)
		end
		return players_
	elseif arguments[1] == "me" then
		return {sender}
	elseif arguments[1] == "random" then
		return {players_[math.random(#players_)]}
	elseif arguments[1] == "admins" then
		for _, player in pairs(players_) do
			if hasValue(admins, player.Name) then
				table.insert(IMPlayers, player)
			end
		end
		return IMPlayers
	elseif arguments[1] == "nonadmins" then
		for _, player in pairs(players_) do
			if not hasValue(admins, player.Name) then
				table.insert(IMPlayers, player)
			end
		end
		return IMPlayers
	else
		-- Loop through players to see if this portion is found there
		for _, argument in pairs(arguments) do
			for _, player in pairs(players_) do
				if string.find(string.lower(player.Name), string.lower(argument)) then
					table.insert(IMPlayers, player)
				end
			end
		end
		return IMPlayers
	end
end

local function die(sender)
	-- familiar ye?
	for _, object in pairs(sender.Character.Head:GetChildren()) do
		if object:IsA("Sound") then
			if object.SoundId == "rbxasset://sounds/uuhhh.wav" then
				object.SoundId = "http://roblox.com/asset?id=333736095"
			end
		end
	end
	-- Kill player
	sender.Character.Humanoid.Health = 0
end

local function message(type, time, parent, arguments)
	if #arguments == 0 then return end
	Spawn(function()
		local message = Instance.new(type)
		message.Parent = parent
		message.Text = table.concat(arguments, " ")
		wait(time)
		message:Destroy()
	end)
end
---------------------------------------------------------------------------------------------------------
--// Commands
local commands = {}

commands.m, commands.msg = push( function(sender, arguments)
	message("Message", 5, workspace, arguments)
end )

commands.h, commands.hint = push( function(sender, arguments)
	message("Hint", 5, workspace, arguments)
end )

commands.admin = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, admin in pairs(selection) do
		admin.Chatted:connect(function(message) parseMessage(message) end)
	end
	message("Hint", 5, workspace, {"Admined player(s) ".. table.concat(selection, ", ") .." as per request of ".. sender.Name})
end

commands.deadmin = function(sender, arguments)
	if not isOwner(sender) then return end
	local selection = parseSelection(sender, arguments)
	for i, _ in pairs(selection) do
		table.remove(admins, i)
	end
	message("Hint", 5, workspace, {"Removed admin for player(s) ".. table.concat(selection, ", ") .." as per request of ".. sender.Name})
end

commands.music = function(sender, arguments)
	if #arguments == 0 then return end
	
	local url = hasValue(arguments, "url")
	local looped = hasValue(arguments, "looped")
	
	local status = Instance.new("Hint")
	status.Parent = workspace
	status.Text = "Stopping all music..."
	for _, object in pairs(workspace:GetChildren()) do
		if object:IsA("Sound") then
			object:Stop()
			object:Destroy()
		end
	end
	
	status.Text = "Playing music..."
	local music = Instance.new("Sound")
	music.Parent = workspace
	music.Name = "CTMusic"
	if url then
		music.SoundId = arguments[1]
	else
		music.SoundId = "http://roblox.com/asset?id=".. arguments[1]
	end
	music.Volume = 1
	music.archivable = false
	repeat
		music:Play()
		wait(2.5)
		music:Stop()
		wait(.5)
		music:Play()
	until music.IsPlaying
	status:Destroy()
end

commands.volume = function(sender, arguments)
	if #arguments == 0 then return end
	if not workspace:FindFirstChild("CTMusic") then return end
	workspace.CTMusic.Volume = arguments[1]
end

commands.pitch = function(sender, arguments)
	if #arguments == 0 then return end
	if not workspace:FindFirstChild("CTMusic") then return end
	workspace.CTMusic.Pitch = arguments[1]
end

commands.stopmusic = function(sender, arguments)
	local status = Instance.new("Hint")
	status.Parent = workspace
	status.Text = "Stopping all music..."
	for _, object in pairs(workspace:GetChildren()) do
		if object:IsA("Sound") then
			object:Stop()
			object:Destroy()
		end
	end
	status:Destroy()
end

commands.time = function(sender, arguments)
	if #arguments == 0 then return end
	Lighting.TimeOfDay = arguments[1]
end

commands.kill = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if not player then return end
		if player.Character then
			player.Character:FindFirstChild("Humanoid").Health = 0
		else
			player:LoadCharacter() -- can be used as a respawn command too
		end
	end
end

commands.ff, commands.forcefield = push( function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if not player then return end
		if player.Character then
			Instance.new("ForceField", player.Character)
		end
	end
end )

commands.unff, noff, removeforcefield = push( function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if not player then return end
		if player.Character then
			for _, object in pairs(player.Character:GetChildren()) do
				if object:IsA("ForceField") then
					object:Destroy()
				end
			end
		end
	end
end )

commands.god, commands.immortalize = push( function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if not player then return end
		if player.Character then
			player.Character:FindFirstChild("Humanoid").MaxHealth = math.huge
		end
	end
end )

commands.ungod, commands.mortalize = push( function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if not player then return end
		if player.Character then
			player.Character:FindFirstChild("Humanoid").MaxHealth = 100
		end
	end
end )

--[[
	commands.nbc = function(sender, arguments)
		local selection = parseSelection(sender, arguments)
		for _, player in pairs(selection) do
			if not player then return end
			player:SetMembershipType(0)
		end
	end

	commands.bc = function(sender, arguments)
		local selection = parseSelection(sender, arguments)
		for _, player in pairs(selection) do
			if not player then return end
			player:SetMembershipType(1)
		end
	end

	commands.tbc = function(sender, arguments)
		local selection = parseSelection(sender, arguments)
		for _, player in pairs(selection) do
			if not player then return end
			player:SetMembershipType(2)
		end
	end

	commands.obc = function(sender, arguments)
		local selection = parseSelection(sender, arguments)
		for _, player in pairs(selection) do
			if not player then return end
			player:SetMembershipType(3)
		end
	end
--]]

commands.kms, commands.fml, commands.reset, commands.energycell, commands.ec, commands.allahuackbar, commands.allahuakbar, commands.heil, commands.hail, commands.cut, commands.cancer, commands.bleach = push( function(sender, arguments)
	die(sender)
end )

commands.rr, commands.russianroulette = push( function(sender, arguments)
	local death = math.random(0, 3)
	if death == 1 then
		die(sender)
	end
end )

commands.test = function(sender, arguments)
	local testMessage = Instance.new("Message")
	testMessage.Parent = workspace
	testMessage.Text = "CT vF1.0.0 : ".. #commands .." commands : Finobe version ".. version()
	wait(5)
	testMessage:Destroy()
end

commands.kick = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		player:Destroy()
	end
end

commands.ban = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		table.insert(blacklistedPlayers, player.Name)
		player:Destroy()
	end
end

commands.freeze = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player and player.Character then
			player.Character.Torso.Anchored = true
		end
	end
end

commands.thaw = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player and player.Character then
			player.Character.Torso.Anchored = false
		end
	end
end

commands.btools = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Backpack then
			local selectTool, deleteTool, copyTool = Instance.new("HopperBin"), Instance.new("HopperBin"), Instance.new("HopperBin")
			selectTool.BinType, deleteTool.BinType, copyTool.BinType = "Grab", "Clone", "Hammer"
			selectTool.Name, deleteTool.Name, copyTool.Name = "Grab", "Clone", "Hammer"
			selectTool.Parent, deleteTool.Parent, copyTool.Parent = push( player.Backpack )
		end
	end
end

commands.ws, commands.walkspeed, commands.speed = push( function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			player.Character.Humanoid.WalkSpeed = arguments[2]
		end
	end
end )

commands.explode = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			local explosion = Instance.new("Explosion")
			explosion.Parent = workspace
			explosion.Position = player.Character.Torso.Position
		end
	end
end

commands.sparkles = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			local sparkles = Instance.new("Sparkles")
			sparkles.SparkleColor = Color3.new(255/255, 102/255, 255/255)
			sparkles.Parent = player.Character.Torso
		end
	end
end

commands.unsparkles = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			for _, object in pairs(player.Character.Torso:GetChildren()) do
				if object:IsA("Sparkles") then
					object:Destroy()
				end
			end
		end
	end
end

commands.smoke = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			local smoke = Instance.new("Smoke")
			smoke.Parent = player.Character.Torso
		end
	end
end

commands.unsmoke = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			for _, object in pairs(player.Character.Torso:GetChildren()) do
				if object:IsA("Smoke") then
					object:Destroy()
				end
			end
		end
	end
end

commands.fire = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			local fire = Instance.new("Fire")
			fire.Parent = player.Character.Torso
		end
	end
end

commands.unfire = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			for _, object in pairs(player.Character.Torso:GetChildren()) do
				if object:IsA("Fire") then
					object:Destroy()
				end
			end
		end
	end
end

commands.holo, commands.hologram = push( function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			for _, object in pairs(player.Character:GetChildren()) do
				if object:IsA("BasePart") then
					object.Transparency = .7
					local box = Instance.new("SelectionBox")
					box.Parent = object
					box.Transparency = .2
					box.Adornee = object
				elseif object:IsA("Hat") then
					for _, object in pairs(object:GetChildren()) do
						if object:IsA("BasePart") then
							object.Transparency = .7
							local box = Instance.new("SelectionBox")
							box.Parent = object
							box.Transparency = .2
							box.Adornee = object
						end
					end
				end
			end
		end
	end
end )

commands.realify = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			for _, object in pairs(player.Character:GetChildren()) do
				if object:IsA("BasePart") then
					for _, object_ in pairs(object:GetChildren()) do
						if object_:IsA("SelectionBox") then
							object_:Destroy()
						end
					end
					object.Transparency = 0
				elseif object:IsA("Hat") then
					for _, object_ in pairs(object:GetChildren()) do
						if object_:IsA("BasePart") then
							for _, object__ in pairs(object_:GetChildren()) do
								if object__:IsA("SelectionBox") then
									object__:Destroy()
								end
							end
							object_.Transparency = 0
						end
					end
				end
			end
		end
	end
end

commands.normal, commands.respawn = push( function(sender, arguments) 
	local selection = parseSelection(arguments)
	for _, player in pairs(selection) do
		if player.Character then
			-- save pos
			local savedPosition = player.Character.Torso.CFrame
			player.Character:Destroy()
			player:LoadCharacter()
			player.Character.Torso.CFrame = savedPosition
		end
	end
end )

commands.name = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character and player.Character:FindFirstChild("Head") then
			for _, object in pairs(player.Character:GetChildren()) do
				if object:FindFirstChild("NameTag") then
					player.Character.Head.Transparency = 0
					object:Destroy()
				end
			end
			local model = Instance.new("Model")
			model.Parent = player.Character
			table.remove(arguments, 1)
			model.Name = table.concat(arguments, " ")
			local clone = player.Character.Head:Clone()
			clone.Parent = model
			local humanoid = Instance.new("Humanoid")
			humanoid.Parent = model
			humanoid.Name = "NameTag"
			humanoid.MaxHealth = 0
			humanoid.Health = 0
			local weld = Instance.new("Weld")
			weld.Parent = clone
			weld.Part0, weld.Part1 = clone, player.Character.Head
			player.Character.Head.Transparency = 1
		end
	end
end

commands.unname = function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character and player.Character:FindFirstChild("Head") then
			for _, object in pairs(player.Character:GetChildren()) do
				if object:FindFirstChild("NameTag") then
					player.Character.Head.Transparency = 0
					object:Destroy()
				end
			end
		end
	end
end

commands.grav, commands.gravity, commands.setgrav, commands.setgravity = push( function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character and player.Character:FindFirstChild("Torso") then

commands.sit = push( function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			player.Character:FindFirstChild("Humanoid").Sit = true
		end
	end
end )

commands.jump = push( function(sender, arguments)
	local selection = parseSelection(sender, arguments)
	for _, player in pairs(selection) do
		if player.Character then
			player.Character:FindFirstChild("Humanoid").Jump = true
		end
	end
end )

--[[ unfinished h
	commands.tpose = function(sender, arguments)
		local selection = parseSelection(sender, arguments)
		local parts = {
			"Left Leg",
			"Right Leg",
			"Right Arm",
			"Left Arm",
			"Torso",
			"Head"
		}
		for _, player in pairs(selection) do
			if player.Character then
				player.Character:FindFirstChild("Humanoid").Jump = true
			end
		end
--]]
---------------------------------------------------------------------------------------------------------
local function parseMessage(player, message)
	if starts(message, sePrefix .. " ") then
		local code = string.sub(message, string.len(sePrefix) + 1)
		print("CT: Executing script '".. code .. "'")
		local success, err = pcall(function() loadstring(code)() end)
		if not success then
			print(err)
		end
		return
	elseif starts(message, lsPrefix .. " ") then
		local code = string.sub(message, string.len(lsPrefix) + 1)
		print("CT: Executing local script for player ".. player.Name .." ('".. code .."')")
		if script:FindFirstChild("LocalScriptBase") then
			local localScript = script.LocalScriptBase:Clone()
			localScript.Parent = player.PlayerGui
			localScript.Code.Value = code
			localScript.Disabled = false
		end
		return
	elseif starts(message, lsPlrPrefix .. " ") then
		local arguments = {}
		for argument in string.gmatch(message, "[^%s]+") do
			table.insert(arguments, argument) -- arguments[2] = code
		end
		local player = parseSelection(arguments) -- player[1] = player, duh
		local code = arguments[2]
		print("CT: Executing local script for player(s) ".. player[1] .." ('".. code .."') as per request of ".. player.Name)
		if script:FindFirstChild("LocalScriptBase") then
			local localScript = script.LocalScriptBase:Clone()
			localScript.Parent = player[1].PlayerGui
			localScript.Code.Value = code
			localScript.Disabled = false
		end
		return
	end
	-- Continue to command parser
	local prefixMatch
	local chosenPrefix
	local debounce = false
	for _, prefix in pairs(prefixes) do
		if debounce == false then
			prefixMatch = starts(message, prefix)
			if prefixMatch then chosenPrefix = prefix debounce = true end
		end
	end
	if prefixMatch then
		message = string.sub(message, string.len(chosenPrefix) + 1)
		local arguments = {}
		for argument in string.gmatch(message, "[^%s]+") do
			table.insert(arguments, argument)
		end
		local commandName = arguments[1]
		table.remove(arguments, 1)
		local commandFunction = commands[commandName]
		if commandFunction ~= nil then
			print("CT: Executing command ".. commandName .." with arguments ".. table.concat(arguments, " "))
			Spawn(function() commandFunction(player, arguments) end)
		end
	end
end

--// Script functions
local function initalize()
	Players.PlayerAdded:connect(function(player)
		if blacklisted(player.Name) then
			player:Destroy()
		end
		player.Chatted:connect(function(message)
			if isAdmin(player) then
				parseMessage(player, message)
			end
		end)
	end)
end

-- // CLEANUP
workspace.ChildAdded:connect(function(object)
	if object:IsA("Tool") or object:IsA("Hat") then
		wait(3)
		if object.Parent == workspace then
			object:Destroy()
		end
	end
end)

-- // DAY NIGHT
if dayAndNight then
	while wait(0.2) do
		Lighting:SetMinutesAfterMidnight(Lighting:GetMinutesAfterMidnight() + 1) 
	end
end

-- Run
print("CT: Attaching events...")
initalize()
print("CT: Running anticheat...")
game:FindFirstChild("Cheeto Dust").Disabled = false

print("CT: Finished loading!")