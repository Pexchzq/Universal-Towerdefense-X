local Types = require(script.Parent.types)
local Engine = require(script.Parent.engine)

local logger = {
	info = function(msg) print(msg) end,
	warn = function(msg) warn(msg) end,
}

-- ตัวอย่าง gameApi แบบ stub: แค่ print ออกมา
local gameApi = {
	unequipAll = function()
		print("[api] unequipAll()")
	end,
	equipUnit = function(guid, slot)
		print(("[api] equipUnit(guid=%s, slot=%d)"):format(guid, slot))
	end,
	summon = function(amount, banner)
		print(("[api] summon(amount=%s, banner=%s)"):format(amount, banner))
		return "OK"
	end,
	claimReward = function(kind, day)
		print(("[api] claimReward(kind=%s, day=%d)"):format(kind, day))
	end,
	wait = function(seconds)
		-- ในเกมจริงจะเป็น task.wait(seconds)
	end,
}

local config = require(script.Parent.example_config)

-- state ตัวอย่าง (inventory/team/currency)
local state = {
	inventory = {
		Types.makeUnit({ id = "FastCart", guid = "u-1", etherealLevel = 0, takedowns = 10, exp = 100 }),
		Types.makeUnit({ id = "FastCart:evolved", guid = "u-2", etherealLevel = 1, takedowns = 5, exp = 50 }),
		Types.makeUnit({ id = "Sasuke", guid = "u-3", etherealLevel = 2, takedowns = 999, exp = 2000, equipped = true }),
		Types.makeUnit({ id = "Bulma", guid = "u-4", etherealLevel = 0, takedowns = 0, exp = 1 }),
	},
}

local engine = Engine.new({ gameApi = gameApi, logger = logger })
engine:runOnce(state, config)

