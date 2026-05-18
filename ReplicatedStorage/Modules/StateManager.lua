local StateManager = {}
StateManager.Data = {}

function StateManager.Initialize(player)
	StateManager.Data[player] = {
		IsBlocking = false,
		ParryWindow = false,
		IsStunned = false,
    IsGuardBroken = false,
    LastHitTime = 0,
    InCombatTime = 20,
		HitList = {}
	}
end

function StateManager.Update(player, key, value)
	if StateManager.Data[player] then
		StateManager.Data[player][key] = value

    if key == "HitList" or key == "IsGuardBroken" or key == "IsStunned" then
      StateManager.Data[player].LastHitTime = os.clock()
    end 
	end
end


function StateManager.IsInCombat(player)
 local data = StateManager.Data[player]
 if not data or not data.LastHitTime then return false end

 return (os.clock() - data.LastHitTIme) < StateManager.Data[player].InCombatTime
end

function StateManager.Get(player)
	return StateManager.Data[player]
end

function StateManager.Remove(player)
	StateManager.Data[player] = nil
end



return StateManager