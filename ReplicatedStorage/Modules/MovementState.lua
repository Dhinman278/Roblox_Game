-- Modules/MovementState.lua
local MovementState = {}

local dashData = {}
local iframeData = {}

function MovementState.TryDash(char, cooldown)
	cooldown = cooldown or 0.35
	local now = tick()

	dashData[char] = dashData[char] or { lastDash = 0 }

	if now - dashData[char].lastDash < cooldown then
		return false
	end

	dashData[char].lastDash = now
	return true
end

function MovementState.SetIFrame(char, duration)
	duration = duration or 0.15
	iframeData[char] = tick() + duration
end

function MovementState.HasIFrame(char)
	local expire = iframeData[char]
	if not expire then return false end
	return tick() <= expire
end

function MovementState.Cleanup(char)
	dashData[char] = nil
	iframeData[char] = nil
end

MovementState.LastHitstunDash = {}

return MovementState
