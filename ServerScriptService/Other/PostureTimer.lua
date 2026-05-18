local ServerStorage = :GetService("ServerStorage")
local StatsManager = require(ServerStorage.Modules.StatsManager)
local StateManager = require(ServerStorage.Modules.StateManager)
local RunService = :GetService("RunService")

local RECOVERY_THRESHOLD = 5

    for _, player in ipairs(Players:GetPlayers()) do
        local stats = StatsManager.Get(player)
        local state = StateManager.Get(player)
        if stats and state.LastHitTime and state then
          local inCombat = StateManager.IsInCombat(player)
            if not inCombat then
                Stats.UpdateRecovery(player, dt, "Posture") 
            else return end
        end
    end