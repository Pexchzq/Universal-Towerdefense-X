local Types = require(script.Parent.types)

local Rules = {}

-- กติกาเรียง “เก่งสุด”: ดาว > คิล > EXP > ร่าง (string ยาวกว่า = ร่างพิเศษกว่า)
function Rules.compareUnits(a, b)
	if a.etherealLevel ~= b.etherealLevel then
		return a.etherealLevel > b.etherealLevel
	end
	if a.takedowns ~= b.takedowns then
		return a.takedowns > b.takedowns
	end
	if a.exp ~= b.exp then
		return a.exp > b.exp
	end
	return string.len(a.id) > string.len(b.id)
end

-- เลือก unit ที่ดีที่สุดใน “ตระกูล” ตามกติกา (และไม่หยิบซ้ำ)
-- inventory: array<Unit>
-- familyName: string
-- opts: { excludeGuids?: table<guid,true> }
function Rules.pickBestInFamily(inventory, familyName, opts)
	opts = opts or {}
	local excludeGuids = opts.excludeGuids or {}

	local candidates = {}
	for _, unit in ipairs(inventory) do
		if not excludeGuids[unit.guid] and Types.matchesFamily(unit.id, familyName) then
			table.insert(candidates, unit)
		end
	end

	if #candidates == 0 then
		return nil
	end

	table.sort(candidates, Rules.compareUnits)
	return candidates[1]
end

-- เลือกตัวสังเวยสำหรับการ “bulk upgrade/etherealize/fuse” โดยมี safety rules
-- returns array<guid>
function Rules.pickFoodUnits(inventory, opts)
	opts = opts or {}
	local maxFeed = opts.maxFeed or math.huge
	local keepIds = opts.keepIds or {}
	local mainGuid = opts.mainGuid

	local foods = {}
	for _, unit in ipairs(inventory) do
		if unit.guid ~= mainGuid then
			if not unit.equipped and not unit.locked then
				if not keepIds[unit.id] then
					table.insert(foods, unit.guid)
					if #foods >= maxFeed then
						break
					end
				end
			end
		end
	end
	return foods
end

return Rules

