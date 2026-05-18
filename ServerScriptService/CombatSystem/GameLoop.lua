local ServerStorage = :GetService("ServerStorage")
local ReplicatedStorage = :GetService("ReplicatedStorage")
local Players = :GetService("Players")

local StateManager = require(ServerStorage.Modules.StateManager)
local ClientCast = require(ServerStorage.Modules.ClientCast)
local StatsModule = require(ServerStorage.Modules.StatsModule)
local InputEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("InputEvent")

-- Function to handle player setup
local function onPlayerAdded(player)
	StateManager.Initialize(player)
	StatsModule.Initialize(player)
end

-- Setup connections
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	StateManager.Remove(player)
	StatsModule.Remove(player)
end)

-- Studio Fix: Initialize players who joined before the script ran
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

InputEvent.OnServerEvent:Connect(function(player, action)
	local char = player.Character
	if not char then return end

	local state = StateManager.Get(player)

	-- Safety check: If stunned, they cannot perform any actions
	if not state or state.IsStunned then 
		print(player.Name .. " tried to act but is STUNNED")
		return
  elseif state.IsGaurdBroken then
		print(player.Name .. " tried to act but is GaurdBroken ")     
    return
	end

	if action == "Attack" then
		local lArm = char:WaitForChild("Left Arm", 5)
		local rArm = char:WaitForChild("Right Arm", 5)

		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {char}
		params.FilterType = Enum.RaycastFilterType.Exclude

		local lCaster = ClientCast.new(lArm, params)
		local rCaster = ClientCast.new(rArm, params)

		state.HitList = {} 

		local function onHit(RaycastResult, VictimHumanoid)
			local victimChar = VictimHumanoid.Parent
			if state.HitList[victimChar] then return end
			state.HitList[victimChar] = true

			local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
			local vState = StateManager.Get(victimPlayer or victimChar)

			if vState then
				-- PARRY LOGIC
				if vState.ParryWindow then
					print(player.Name .. " hit a PARRY window!")
          vState.LastHitTime = os.clock()
					-- 1. Increase Attacker Posture
					StatsModule.Update(player, "Posture", 20)
					local currentPosture = StatsModule.Get(player, "Posture")
					print("Attacker Posture: " .. currentPosture)

					-- 2. Check for Posture Break (Stun)
					if currentPosture >= 100 then
						print(player.Name .. " POSTURE BROKEN!")

						-- Apply Stun states
						StateManager.Update(player, "IsGuardBroken", true)
						char:SetAttribute("IsGuardBroken", true)

						-- Reset Posture so they can recover
						

						task.delay(2, function()
							StateManager.Update(player, "IsGaurdBroken", false)
							char:SetAttribute("IsGaurdBroken", false)
							print(player.Name .. " recovered from stun.")
						end)
					end
					return -- Stop attack logic here

				elseif vState.IsBlocking then
					-- BLOCK LOGIC
					print(victimChar.Name .. " blocked the hit.")
          StatsModule.Update(victimChar, "Posture", 20)
					local currentPosture = StatsModule.Get(player, "Posture")
					print("Attacker Posture: " .. currentPosture)

					-- 2. Check for Posture Break (Stun)
					if currentPosture >= 100 then
						print(player.Name .. " POSTURE BROKEN!")

						-- Apply Stun states
						StateManager.Update(player, "IsGaurdBroken", true)
						char:SetAttribute("IsGaurdBroken", true)
						

						task.delay(2, function()
							StateManager.Update(player, "IsGaurdBroken", false)
							char:SetAttribute("IsGaurdBroken", false)
							print(player.Name .. " recovered from stun.")
						end)
					end
					return
				else
					-- CLEAN HIT
					VictimHumanoid:TakeDamage(10)
					print("HIT: 10 DMG to " .. victimChar.Name)
          
						-- Apply Stun states
						StateManager.Update(player, "IsStunned", true)
						char:SetAttribute("IsStunned", true)
						
						task.delay(.5, function()
							StateManager.Update(player, "IsStunned", false)
							char:SetAttribute("IsStunned", false)
							print(player.Name .. " recovered from stun.")
				end
			else
				-- NPC Fallback
				VictimHumanoid:TakeDamage(10)

						-- Apply Stun states
						StateManager.Update(player, "IsStunned", true)
						char:SetAttribute("IsStunned", true)
						

						task.delay(.5, function()
							StateManager.Update(player, "IsStunned", false)
							char:SetAttribute("IsStunned", false)
							print(player.Name .. " recovered from stun.")
			end
		end

		local lConn = lCaster.HumanoidCollided:Connect(onHit)
		local rConn = rCaster.HumanoidCollided:Connect(onHit)

		lCaster:Start()
		rCaster:Start()

		task.wait(0.5) 

		lCaster:Stop()
		rCaster:Stop()
		lConn:Disconnect()
		rConn:Disconnect()

	elseif action == "Parry" then
		print(player.Name .. " parrying...")
		StateManager.Update(player, "ParryWindow", true)
		task.wait(0.2)
		StateManager.Update(player, "ParryWindow", false)
		-- Automatically enter block state after parry window ends
		StateManager.Update(player, "IsBlocking", true)

	elseif action == "BlockEnd" then
		print(player.Name .. " stopped blocking")
		StateManager.Update(player, "IsBlocking", false)
	end
end)