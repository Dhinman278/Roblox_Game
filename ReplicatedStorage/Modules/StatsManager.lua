local StatsModule = {}
StatsModule.Data = {}

function StatsModule.Initialize(player)
	StatsModule.Data[player] = {
		Level = 1,
		XP = 0,
		Posture = 0,
		Stamina = 100,
    MaxStamina = 100,
		MaxXP = 100,
		Strength = 1,
		Defense = 1,
		Health = 100,
    MaxHealth = 100
	}
end

function StatsModule.Get(player, stat)
	return StatsModule.Data[player][stat]
end

function StatsModule.Set(player, stat, value)
	StatsModule.Data[player][stat] = value
end

function StatsModule.Update(player, stat, value)
	StatsModule.Data[player][stat] += value
end

function StatsModule.Remove(player)
	StatsModule.Data[player] = nil
end


function StatsModule.UpdateRecovery(player, dt, stat)
  StatsManager.Posture = math.max(0, StatsManager.Posture - (5 * dt))
  StatsManager.Health = math.min(StatsManager.Health + (5 * dt), StatsManager.MaxHealth)
  StatsManager.Stamina = math.min(StatsManager.Stamina + (5 * dt), StatsManager.MaxStamina)
  print("Posture down to ".. StatsModule.Get(player, "Posture") )
end


return StatsModule
