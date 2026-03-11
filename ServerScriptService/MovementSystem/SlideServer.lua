-- SlideServer.lua
-- Physics-based slide, permadeath-style

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local slideRemote = Remotes:WaitForChild("SlideRemote")

---------------------------------------------------------------------
-- Utility
---------------------------------------------------------------------

local function humanoidAndRoot(char)
	if not char then return nil, nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	return hum, root
end

local function setFriction(char, friction)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CustomPhysicalProperties = PhysicalProperties.new(friction, 0.3, 0.5)
		end
	end
end

local function createVelocity(root, name, vector)
	local existing = root:FindFirstChild(name)
	if existing then existing:Destroy() end

	local attachment = root:FindFirstChild(name.."Attachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = name.."Attachment"
		attachment.Parent = root
	end

	local lv = Instance.new("LinearVelocity")
	lv.Name = name
	lv.Attachment0 = attachment
	lv.MaxForce = 1e6
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.VectorVelocity = vector
	lv.Parent = root

	return lv
end

local function endVelocity(root, name)
	local v = root:FindFirstChild(name)
	if v then v:Destroy() end
end

---------------------------------------------------------------------
-- SLIDE CONFIG
---------------------------------------------------------------------

local SLIDE_BASE_SPEED = 55
local SLIDE_TIME = 0.45
local SLIDE_COOLDOWN = 0.8
local GRAVITY_BOOST = 35

local lastSlide = {}

slideRemote.OnServerEvent:Connect(function(player, moveDir)
	local char = player.Character
	if not char then return end

	local hum, root = humanoidAndRoot(char)
	if not hum or not root or hum.Health <= 0 then return end

	-- Must be moving
	if typeof(moveDir) ~= "Vector3" or moveDir.Magnitude < 0.1 then
		return
	end

	-- Cooldown
	local now = tick()
	lastSlide[player] = lastSlide[player] or 0
	if now - lastSlide[player] < SLIDE_COOLDOWN then
		return
	end
	lastSlide[player] = now

	-----------------------------------------------------------------
	-- Detect slope angle
	-----------------------------------------------------------------
	local ray = Workspace:Raycast(root.Position, Vector3.new(0, -6, 0))
	local slopeBoost = 0

	if ray then
		local steepness = 1 - ray.Normal.Y
		if steepness > 0 then
			slopeBoost = steepness * GRAVITY_BOOST
		end
	end

	-----------------------------------------------------------------
	-- Final slide speed
	-----------------------------------------------------------------
	local finalSpeed = SLIDE_BASE_SPEED + slopeBoost
	local slideVector = moveDir.Unit * finalSpeed

	-----------------------------------------------------------------
	-- Apply slide velocity
	-----------------------------------------------------------------
	local lv = createVelocity(root, "SlideVelocity", slideVector)

	-----------------------------------------------------------------
	-- Reduce friction
	-----------------------------------------------------------------
	setFriction(char, 0.1)

	-----------------------------------------------------------------
	-- End slide
	-----------------------------------------------------------------
	task.delay(SLIDE_TIME, function()
		endVelocity(root, "SlideVelocity")
		setFriction(char, 0.7)
	end)
end)
