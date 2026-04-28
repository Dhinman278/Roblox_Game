local StatsModule = {}
StatsModule.data = {}

function StatsModule.Initialize(player)
	StatsModule.data[player] = {
		Level = 1,
		XP = 0,
		Posture = 100,
		Stamina = 100,
		MaxXP = 100,
		Strength = 1,
		Defense = 1,
		Health = 100
	}
end

function StatsModule.Get(player, stat)
	return StatsModule.data[player][stat]
end

function StatsModule.Set(player, stat, value)
	StatsModule.data[player][stat] = value
end

function StatsModule.Update(player, stat, value)
	StatsModule.data[player][stat] += value
end
return StatsModule
