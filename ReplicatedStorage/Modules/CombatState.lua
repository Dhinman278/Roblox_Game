local CombatState = {}
CombatState.Data = {}

function CombatState.Initialize(player)
	CombatState.Data[player] = {
		IsBlocking = false,
		ParryWindow = false,
		IsStunned = false,
		Posture = 100,
		HitList = {}
	}
end

function CombatState.Update(player, key, value)
	if CombatState.Data[player] then
		CombatState.Data[player][key] = value
	end
end

function CombatState.Get(player)
	return CombatState.Data[player]
end

function CombatState.Remove(player)
	CombatState.Data[player] = nil
end

return CombatState