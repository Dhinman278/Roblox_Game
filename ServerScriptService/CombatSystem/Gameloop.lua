local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateManager = require(ServerStorage.Modules.StateManager)
local ClientCast = require(ServerStorage.Modules.ClientCast)
local InputEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("InputEvent")

-- Setup for new players
game.Players.PlayerAdded:Connect(StateManager.Initialize)
game.Players.PlayerRemoving:Connect(StateManager.Remove)

InputEvent.OnServerEvent:Connect(function(player, action)
	local char = player.Character
	local state = StateManager.Get(player)

	-- Safety check for the attacker's state
	if not state or state.IsStunned then return end

	if action == "Attack" then
		-- 1. Setup both arms (Supporting R6 names)
		local lArm = char:WaitForChild("Left Arm", 5)
		local rArm = char:WaitForChild("Right Arm", 5)

		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {char}
		params.FilterType = Enum.RaycastFilterType.Exclude

		-- 2. Create Casters for both arms
		local lCaster = ClientCast.new(lArm, params)
		local rCaster = ClientCast.new(rArm, params)

		state.HitList = {} -- Reset hitlist for this specific swing

		local function onHit(RaycastResult, VictimHumanoid)
			local victimChar = VictimHumanoid.Parent

			-- Prevent hitting the same character twice in one swing
			if state.HitList[victimChar] then return end
			state.HitList[victimChar] = true

			-- 3. THE FIX: Check for player first, fallback to the Rig model itself
			local victimPlayer = game.Players:GetPlayerFromCharacter(victimChar)
			local vState = StateManager.Get(victimPlayer or victimChar)

			if vState then
				-- This logic now handles BOTH Players and initialized Testing Rigs
				if vState.ParryWindow then
					print("ATTACKER STUNNED: " .. player.Name .. " hit the parry window of " .. victimChar.Name)
					StateManager.Update(player, "IsStunned", true)
					char:SetAttribute("IsStunned", true)
					task.delay(2, function() StateManager.Update(player, "IsStunned", false) char:SetAttribute("IsStunned", false) end)
					return -- Don't deal damage if they parried
				elseif vState.IsBlocking then
					-- Handle blocking (Damage is mitigated, Posture is reduced)
					vState.Posture = vState.Posture - 20
					print(victimChar.Name .. " BLOCKED. Posture remaining: " .. vState.Posture)

					-- Optional: You can still deal a tiny bit of "chip damage" here if you want
					-- VictimHumanoid:TakeDamage(2) 

				else
					-- Target has a state but is not blocking or parrying (Open for hit)
					VictimHumanoid:TakeDamage(10)
					print("HIT: Dealt 10 damage to " .. victimChar.Name)
				end
			else
				-- 4. FALLBACK: For Rigs/NPCs that were never initialized in StateManager
				VictimHumanoid:TakeDamage(10)
				print("HIT: Dealt damage to uninitialized target: " .. victimChar.Name)
			end
		end

		-- Connect both arms to the hit logic
		local lConn = lCaster.HumanoidCollided:Connect(onHit)
		local rConn = rCaster.HumanoidCollided:Connect(onHit)

		lCaster:Start()
		rCaster:Start()

		task.wait(0.5) -- Duration of your attack animation

		-- 5. Proper Cleanup
		lCaster:Stop()
		rCaster:Stop()
		lConn:Disconnect()
		rConn:Disconnect()

	elseif action == "Parry" then
		print(player.Name .. " is attempting a parry")
		StateManager.Update(player, "ParryWindow", true)
		task.wait(0.2)
		StateManager.Update(player, "ParryWindow", false)
		-- Transition to blocking state if they hold the button
		StateManager.Update(player, "IsBlocking", true)
		
	

	elseif action == "BlockEnd" then
		print(player.Name .. " stopped blocking")
		StateManager.Update(player, "IsBlocking", false)
	end
end)