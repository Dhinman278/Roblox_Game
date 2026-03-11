local CombatState = {}
local stateByChar = {}

local function get(char)
	if not char then return nil end
	if not stateByChar[char] then
		stateByChar[char] = {
			Combo = 0,
		}
	end
	return stateByChar[char]
end

function CombatState.Get(char)
	return get(char)
end

function CombatState.ResetCombo(char)
	local st = get(char)
	st.Combo = 0
end

return CombatState
