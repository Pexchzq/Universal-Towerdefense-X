local Planner = require(script.Parent.planner)

local Engine = {}
Engine.__index = Engine

-- gameApi: implementation ที่ “ทำจริง” (ยิงฟังก์ชันเกม, กดปุ่ม, ฯลฯ)
-- ต้องมีเมธอดตาม action ที่ใช้:
-- - unequipAll()
-- - equipUnit(guid, slot)
-- - summon(amount, banner) -> any response
-- - claimReward(kind, day)
-- - wait(seconds)
function Engine.new(opts)
	opts = opts or {}
	return setmetatable({
		_gameApi = opts.gameApi,
		_logger = opts.logger,
		_planner = Planner.new(opts.logger),
	}, Engine)
end

local function log(logger, level, msg)
	if logger and logger[level] then
		logger[level](msg)
	end
end

function Engine:execute(actions)
	local api = self._gameApi
	assert(api, "Engine requires gameApi")

	for _, action in ipairs(actions) do
		if action.type == "UNEQUIP_ALL" then
			api.unequipAll()
		elseif action.type == "EQUIP" then
			api.equipUnit(action.guid, action.slot)
		elseif action.type == "SUMMON" then
			local resp = api.summon(action.amount, action.banner)
			log(self._logger, "info", ("[summon] resp=%s"):format(tostring(resp)))
			if action.waitAfter and api.wait then
				api.wait(action.waitAfter)
			end
		elseif action.type == "CLAIM_REWARD" then
			api.claimReward(action.kind, action.day)
		else
			log(self._logger, "warn", ("unknown action: %s"):format(tostring(action.type)))
		end
	end
end

function Engine:runOnce(state, config)
	local actions = self._planner:plan(state, config)
	self:execute(actions)
	return actions
end

-- runLoop(getStateFn): ให้คนผูกฝั่งนอก engine ส่ง state ปัจจุบันมา
function Engine:runLoop(getStateFn, config, opts)
	opts = opts or {}
	local interval = opts.interval or 2.0
	local maxIters = opts.maxIters or 1000000

	for _ = 1, maxIters do
		local state = getStateFn()
		self:runOnce(state, config)
		if self._gameApi.wait then
			self._gameApi.wait(interval)
		end
	end
end

return Engine

