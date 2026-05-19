local Validate = {}

local function isArray(t)
	if type(t) ~= "table" then
		return false
	end
	local n = 0
	for k, _ in pairs(t) do
		if type(k) ~= "number" then
			return false
		end
		n += 1
	end
	return true
end

function Validate.config(config)
	if type(config) ~= "table" then
		return false, "config must be a table"
	end

	if config.equip and config.equip.teamSlots ~= nil then
		if not isArray(config.equip.teamSlots) then
			return false, "config.equip.teamSlots must be an array"
		end
	end

	if config.summon and config.summon.targets ~= nil then
		if type(config.summon.targets) ~= "table" then
			return false, "config.summon.targets must be a table"
		end
		for name, required in pairs(config.summon.targets) do
			if type(name) ~= "string" or name == "" then
				return false, "config.summon.targets keys must be non-empty strings"
			end
			if type(required) ~= "number" or required < 1 then
				return false, ("config.summon.targets[%s] must be >= 1"):format(name)
			end
		end
	end

	if config.rewards and config.rewards.claims ~= nil then
		if not isArray(config.rewards.claims) then
			return false, "config.rewards.claims must be an array"
		end
	end

	return true
end

return Validate

