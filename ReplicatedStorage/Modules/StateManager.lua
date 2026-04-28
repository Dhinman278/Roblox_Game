local StateManager = {}
StateManager.Data = {}

function StateManager.Initialize(player)
	StateManager.Data[player] = {
		IsBlocking = false,
		ParryWindow = false,
		IsStunned = false,
		IsSprinting = false,
		canSprint = true,
		isInAir = false,
		W = false,
		A = false,
		S = false,
		D = false,
		HitList = {}
	}
end

function StateManager.Update(player, key, value)
	if StateManager.Data[player] then
		StateManager.Data[player][key] = value
	end
end

function StateManager.Get(player)
	return StateManager.Data[player]
end

function StateManager.Remove(player)
	StateManager.Data[player] = nil
end

return StateManager