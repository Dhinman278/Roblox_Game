local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Ensure the module is found before proceeding
local ClanData = require(ServerStorage.Modules:WaitForChild("Clansmodule"))

-- Table to store player clans (In a real game, use DataStore here)
local playerClans = {}

-- Function to roll a random clan based on rarity weights
local function rollClan()
	local totalWeight = 0
	for _, weight in pairs(ClanData.rarity) do
		totalWeight += weight
	end

	local roll = math.random() * totalWeight
	local currentWeight = 0
	local selectedRarity = "Common"

	for rarity, weight in pairs(ClanData.rarity) do
		currentWeight += weight
		if roll <= currentWeight then
			selectedRarity = rarity
			break
		end
	end

	-- Get all clans of the selected rarity
	local clansOfRarity = {}
	for _, clan in pairs(ClanData.clans) do
		if clan.Rarity == selectedRarity then
			table.insert(clansOfRarity, clan)
		end
	end

	-- Pick a random clan from that rarity list
	if #clansOfRarity > 0 then
		return clansOfRarity[math.random(1, #clansOfRarity)]
	end

	return nil
end

-- Function to apply clan stats to a character
local function applyClanStats(character, clan)
	local humanoid = character:WaitForChild("Humanoid", 5) -- Wait to ensure Humanoid exists
	if humanoid and clan.Stats then
		if clan.Stats.Health then
			humanoid.MaxHealth = clan.Stats.Health
			humanoid.Health = clan.Stats.Health
		end
		-- Add stamina or speed logic here
	end
end

-- Main function for character setup
local function onCharacterAdded(player, character)
	-- Assign clan if they don't have one
	if not playerClans[player.UserId] then
		local rolledClan = rollClan()
		if rolledClan then
			playerClans[player.UserId] = rolledClan
		else
			warn("Failed to roll a clan for " .. player.Name)
			return
		end
	end

	local clan = playerClans[player.UserId]
	applyClanStats(character, clan)
	print(player.Name .. " is using clan: " .. clan.Name)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	-- Edge case: if player spawned before this script ran
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end

-- Initialization
Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player) -- Use task.spawn to avoid yielding
end