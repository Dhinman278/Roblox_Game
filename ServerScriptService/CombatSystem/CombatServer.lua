local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local hitRemote = Remotes:WaitForChild("FireHitbox")
local dashRemote = Remotes:WaitForChild("DashRemote")
-- movementRemote no longer used (slide removed)

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Shared = require(Modules:WaitForChild("SharedConstants"))
local CombatState = require(Modules:WaitForChild("CombatState"))
local MovementState = require(Modules:WaitForChild("MovementState"))
local RaycastModule = require(Modules:WaitForChild("RaycastModule"))
local Animations = require(Modules:FindFirstChild("AnimationsModule")) or {}

local DAMAGE = Shared.DAMAGE
local RANGE = Shared.RANGE
local COOLDOWN = Shared.COOLDOWN

local lastAttack = {}
local hitDebounce = {}

---------------------------------------------------------------------
-- Utility
---------------------------------------------------------------------

local function humanoidAndRoot(char)
	if not char then return nil, nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return nil, nil end
	return hum, root
end

local function getCharacterFromPart(part)
	if not part then return nil end
	local model = part:FindFirstAncestorOfClass("Model")
	if model and model:FindFirstChildOfClass("Humanoid") then
		return model
	end
	return nil
end

local function canAttack(player, combo)
	local now = tick()
	lastAttack[player] = lastAttack[player] or 0
	if now - lastAttack[player] < (COOLDOWN[combo] or 0.1) then
		return false
	end
	lastAttack[player] = now
	return true
end

local function canHitVictimThisSwing(attackerChar, victimChar)
	hitDebounce[attackerChar] = hitDebounce[attackerChar] or {}
	local now = tick()
	local last = hitDebounce[attackerChar][victimChar] or 0

	if now - last < 0.1 then
		return false
	end

	hitDebounce[attackerChar][victimChar] = now
	return true
end

local function isAirborneEnough(root, minHeight)
	minHeight = minHeight or 2.5
	local origin = root.Position
	local direction = Vector3.new(0, -20, 0)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {root.Parent}

	local result = Workspace:Raycast(origin, direction, params)
	if result then
		local dist = (origin - result.Position).Magnitude
		return dist >= minHeight
	end

	return true
end

---------------------------------------------------------------------
-- Bloodlines/JJS SAFE Ragdoll
---------------------------------------------------------------------

local function bloodlinesRagdoll(character, duration)
	duration = duration or 0.6

	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local ragdollParts = {}

	for _, motor in ipairs(character:GetDescendants()) do
		if motor:IsA("Motor6D") and motor.Name ~= "RootJoint" then
			local part0 = motor.Part0
			local part1 = motor.Part1
			if part0 and part1 then
				local socket = Instance.new("BallSocketConstraint")
				local a0 = Instance.new("Attachment")
				local a1 = Instance.new("Attachment")

				a0.Parent = part0
				a1.Parent = part1

				socket.Attachment0 = a0
				socket.Attachment1 = a1
				socket.Parent = part0

				table.insert(ragdollParts, {
					motor = motor,
					socket = socket,
					a0 = a0,
					a1 = a1
				})

				motor.Transform = CFrame.new()
			end
		end
	end

	hum:ChangeState(Enum.HumanoidStateType.Physics)

	task.delay(duration, function()
		if hum.Parent then
			for _, data in ipairs(ragdollParts) do
				if data.motor then
					data.motor.Transform = CFrame.new()
				end
				if data.socket then data.socket:Destroy() end
				if data.a0 then data.a0:Destroy() end
				if data.a1 then data.a1:Destroy() end
			end

			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end

---------------------------------------------------------------------
-- SphereCast for Downslam (multi-hit)
---------------------------------------------------------------------

local function sphereHitHumanoids(center, radius, ignoreList)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = ignoreList or {}

	local parts = Workspace:GetPartBoundsInRadius(center, radius, params)

	local hitModels = {}
	local unique = {}

	for _, part in ipairs(parts) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and not unique[model] then
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum then
				unique[model] = true
				table.insert(hitModels, model)
			end
		end
	end

	return hitModels
end

---------------------------------------------------------------------
-- Animation + Hit
---------------------------------------------------------------------

local function playM1AnimationAndHit(hum, root, combo, onHit)
	root.AssemblyLinearVelocity = root.CFrame.LookVector * 3

	local animId = Animations["M1_" .. combo]
	if animId and animId ~= "" then
		local anim = Instance.new("Animation")
		anim.AnimationId = animId
		local track = hum:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
	end

	onHit()
end

---------------------------------------------------------------------
-- Combat Logic (uptilt, downslam, normal)
---------------------------------------------------------------------

hitRemote.OnServerEvent:Connect(function(player, controlHeld)
	local char = player.Character
	local hum, root = humanoidAndRoot(char)
	if not hum or not root or hum.Health <= 0 then return end

	local st = CombatState.Get(char)
	st.Combo = st.Combo or 0
	st.Combo += 1
	if st.Combo > 4 then
		st.Combo = 1
	end
	local combo = st.Combo

	if not canAttack(player, combo) then return end

	local function processHit(hitPart)
		local victimChar = getCharacterFromPart(hitPart)
		if not victimChar or victimChar == char then return end

		local vHum, vRoot = humanoidAndRoot(victimChar)
		if not vHum or not vRoot or vHum.Health <= 0 then return end

		if not canHitVictimThisSwing(char, victimChar) then
			return
		end

		local dmg = DAMAGE[combo] or 5

		if combo == 4 then
			vHum:TakeDamage(dmg)

			if vHum.Health > 0 then
				local airborne = isAirborneEnough(root, 2.5)

				if controlHeld then
					-- UPTILT (4th hit + LeftControl)
					bloodlinesRagdoll(victimChar, 0.6)
					vRoot.AssemblyLinearVelocity = Vector3.new(0, 25, 0)

				elseif airborne then
					-- DOWNSLAM (4th hit + airborne)
					local slamCenter = vRoot.Position - Vector3.new(0, 3, 0)
					local victims = sphereHitHumanoids(slamCenter, 9, {char}) -- radius changed from 8 → 9

					for _, model in ipairs(victims) do
						local h, r = humanoidAndRoot(model)
						if h and r and h.Health > 0 then
							bloodlinesRagdoll(model, 0.6)
							r.AssemblyLinearVelocity = Vector3.new(0, -40, 0)
						end
					end

				else
					-- NORMAL 4TH HIT
					vRoot.AssemblyLinearVelocity = root.CFrame.LookVector * 40 + Vector3.new(0, 10, 0)
				end
			end

			CombatState.ResetCombo(char)
			return
		end

		-- HITS 1–3
		vHum:TakeDamage(dmg)
		vRoot.AssemblyLinearVelocity = root.CFrame.LookVector * 10 + Vector3.new(0, 5, 0)
	end

	local function doRaycast()
		local result = RaycastModule.RaycastFromPlayer(player, RANGE[combo] or 7)
		local hitPart = result and result.Instance or nil
		if hitPart then
			processHit(hitPart)
		else
			CombatState.ResetCombo(char)
		end
	end

	playM1AnimationAndHit(hum, root, combo, doRaycast)
end)

---------------------------------------------------------------------
-- Dash only (no slide, no other movement)
---------------------------------------------------------------------

local DASH_SPEED = 70
local DASH_DURATION = 0.25
local DASH_COOLDOWN = 0.35
local IFRAME_DURATION = 0.15
local HITSTUN_DASH_COOLDOWN = 3

dashRemote.OnServerEvent:Connect(function(player, moveDir)
	local char = player.Character
	local hum, root = humanoidAndRoot(char)
	if not hum or not root or hum.Health <= 0 then return end

	local now = tick()

	MovementState.LastHitstunDash = MovementState.LastHitstunDash or {}
	MovementState.LastHitstunDash[char] = MovementState.LastHitstunDash[char] or 0

	local inHitstun = CombatState.IsInHitstun and CombatState.IsInHitstun(char)

	local canNormalDash = MovementState.TryDash(char, DASH_COOLDOWN)
	local canHitstunDash = false

	if inHitstun then
		if now - MovementState.LastHitstunDash[char] >= HITSTUN_DASH_COOLDOWN then
			canHitstunDash = true
		end
	end

	if not canNormalDash and not canHitstunDash then
		return
	end

	if canHitstunDash then
		MovementState.LastHitstunDash[char] = now
	end

	local dir
	if typeof(moveDir) == "Vector3" and moveDir.Magnitude > 0.1 then
		dir = moveDir.Unit
	else
		dir = -root.CFrame.LookVector
	end

	root.AssemblyLinearVelocity = dir * DASH_SPEED + Vector3.new(0, 2, 0)

	if MovementState.SetIFrame then
		MovementState.SetIFrame(char, IFRAME_DURATION)
	end

	local oldWalk = hum.WalkSpeed
	hum.WalkSpeed = 0

	task.delay(DASH_DURATION, function()
		if hum.Parent then
			hum.WalkSpeed = oldWalk
		end
	end)
end)

---------------------------------------------------------------------
-- Cleanup
---------------------------------------------------------------------

Players.PlayerRemoving:Connect(function(plr)
	if plr.Character then
		CombatState.Cleanup(plr.Character)
		MovementState.Cleanup(plr.Character)
	end
end)
