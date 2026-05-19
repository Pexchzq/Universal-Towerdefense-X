local Types = {}

-- Unit snapshot ที่ decision engine ใช้ (ไม่ผูกกับโครงสร้างภายในเกม)
-- id: string เช่น "Sasuke" หรือ "Sasuke:evolved"
-- guid: string ตัวระบุเอกลักษณ์ใน inventory (อาจเป็น UUID)
-- etherealLevel: number (ดาว)
-- takedowns: number (คิล)
-- exp: number
-- equipped: boolean
-- locked: boolean
function Types.makeUnit(fields)
	return {
		id = fields.id,
		guid = fields.guid,
		etherealLevel = fields.etherealLevel or 0,
		takedowns = fields.takedowns or 0,
		exp = fields.exp or 0,
		equipped = fields.equipped == true,
		locked = fields.locked == true,
	}
end

-- เป้าหมายแบบ “ชื่อหน้า” รองรับ "Name" หรือ "Name:*"
function Types.matchesFamily(unitId, familyName)
	if unitId == familyName then
		return true
	end
	return string.sub(unitId, 1, #familyName + 1) == (familyName .. ":")
end

return Types

