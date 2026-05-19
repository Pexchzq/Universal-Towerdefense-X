local Types = require(script.Parent.types)
local Rules = require(script.Parent.rules)
local Validate = require(script.Parent.validate)

local Planner = {}
Planner.__index = Planner

-- Action schema (simple table):
-- { type="EQUIP", guid="..." }
-- { type="UNEQUIP_ALL" }
-- { type="SUMMON", amount="TenSummon", banner="Special" }
-- { type="CLAIM_REWARD", kind="WelcomeRewards", day=1 }

function Planner.new(logger)
	return setmetatable({
		_logger = logger,
	}, Planner)
end

local function log(self, level, msg)
	if self._logger and self._logger[level] then
		self._logger[level](msg)
	end
end

-- สร้างแผน “จัดทีม” จาก config.teamSlots = { "FastCart", "Gohan", ... } (ว่างได้)
function Planner:planEquipTeam(state, config)
	local actions = {}

	if config.equip and config.equip.unequipAllFirst then
		table.insert(actions, { type = "UNEQUIP_ALL" })
	end

	local inventory = state.inventory or {}
	local usedGuids = {}

	local slots = (config.equip and config.equip.teamSlots) or {}
	for slotIndex, familyName in ipairs(slots) do
		if familyName and familyName ~= "" then
			local best = Rules.pickBestInFamily(inventory, familyName, { excludeGuids = usedGuids })
			if best then
				usedGuids[best.guid] = true
				table.insert(actions, { type = "EQUIP", slot = slotIndex, guid = best.guid, unitId = best.id })
			else
				log(self, "warn", ("[equip] not found: slot=%d family=%s"):format(slotIndex, familyName))
			end
		end
	end

	return actions
end

-- แผน “สุ่มจนกว่าจะครบ” จาก config.summon.targets = { ["FastCart"]=2, ... }
function Planner:planSummon(state, config)
	local summonCfg = config.summon
	if not summonCfg or not summonCfg.enabled then
		return {}
	end

	local targets = summonCfg.targets or {}
	local counts = {}
	for name, _ in pairs(targets) do
		counts[name] = 0
	end

	local seen = {}
	for _, unit in ipairs(state.inventory or {}) do
		if unit.guid and not seen[unit.guid] then
			seen[unit.guid] = true
			for targetName, _ in pairs(targets) do
				if Types.matchesFamily(unit.id, targetName) then
					counts[targetName] = counts[targetName] + 1
				end
			end
		end
	end

	local allMet = true
	for targetName, required in pairs(targets) do
		if (counts[targetName] or 0) < required then
			allMet = false
			break
		end
	end

	if allMet then
		return {}
	end

	return {
		{
			type = "SUMMON",
			amount = summonCfg.amount or "TenSummon",
			banner = summonCfg.banner or "Special",
			waitAfter = summonCfg.waitAfter or 3.5,
			progress = counts,
		},
	}
end

-- แผน “claim rewards” แบบง่าย
function Planner:planClaimRewards(state, config)
	local rewardsCfg = config.rewards
	if not rewardsCfg or not rewardsCfg.enabled then
		return {}
	end

	local actions = {}
	for _, claim in ipairs(rewardsCfg.claims or {}) do
		table.insert(actions, { type = "CLAIM_REWARD", kind = claim.kind, day = claim.day })
	end
	return actions
end

-- รวมแผนทั้งหมดในรอบเดียว
function Planner:plan(state, config)
	local ok, err = Validate.config(config)
	if not ok then
		log(self, "warn", ("[config] invalid: %s"):format(tostring(err)))
		return {}
	end

	local actions = {}

	for _, a in ipairs(self:planClaimRewards(state, config)) do
		table.insert(actions, a)
	end
	for _, a in ipairs(self:planEquipTeam(state, config)) do
		table.insert(actions, a)
	end
	for _, a in ipairs(self:planSummon(state, config)) do
		table.insert(actions, a)
	end

	return actions
end

return Planner
