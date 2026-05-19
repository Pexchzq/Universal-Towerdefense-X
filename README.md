# Universal TD – Decision Engine (Rebuild)

โปรเจกต์นี้คือ “แกนตัดสินใจ” (decision engine) สำหรับระบบออโต้/มาโครในเกมแนว Tower Defense โดย **แยก logic การตัดสินใจออกจากการยิงฟังก์ชันของเกม** เพื่อให้ทำต่อได้ง่ายและไม่ผูกกับ Remote/Service ใดๆ

> สถานะ: รีบิลด์ใหม่จากไฟล์สคริปต์เก่าในโฟลเดอร์นี้ (`*.txt`) ให้เป็นโครงสร้างโมดูลที่อ่านง่าย, ทดสอบ/ต่อยอดได้

## เป้าหมาย

- ทำให้ “การตัดสินใจว่าจะทำอะไร” เป็นโค้ดที่อ่าน/แก้ได้ง่าย เช่น
  - มีตัวละคร/ยูนิตนี้หรือยัง?
  - เลเวล/ดาว/เงื่อนไขครบหรือยัง?
  - ควรใส่ทีมตัวไหนดีที่สุดตามกติกา (ดาว > คิล > EXP > ร่าง)?
  - ต้องสุ่มกาชาต่อไหมจนกว่าจะครบเป้าหมาย?
- ให้ชั้น “การกระทำ” (เช่นการกดปุ่ม/เรียก API ของเกม) อยู่ด้านนอก ผ่าน interface ที่สลับ implementation ได้

## โครงสร้างไฟล์ใหม่

- `src/types.lua` – โครงสร้างข้อมูลและ helper กลาง
- `src/rules.lua` – กติกาการคัดเลือก/จัดอันดับ (sorting/scoring)
- `src/planner.lua` – วางแผนงานระดับสูงจาก state + config (สร้าง “รายการคำสั่ง”)
- `src/engine.lua` – ตัวรัน planner + executor (ต้องฉีด `gameApi` มาเอง)
- `src/example_config.lua` – ตัวอย่างคอนฟิก
- `src/example_main.lua` – ตัวอย่างการผูก `gameApi` แบบ stub (ไม่ผูกกับเกมจริง)

## แนวคิดหลัก (แยก 3 ชั้น)

1) **State**: สภาพปัจจุบันของผู้เล่น/เกม (inventory, team, currency, flags)
2) **Decision/Rules**: กติกา “เลือก/ไม่เลือก” และ “เลือกตัวไหน”
3) **Actions**: รายการสิ่งที่จะทำ (Equip, Summon, Place, Upgrade, ClaimReward ฯลฯ)

ในรีบิลด์นี้ “engine” จะสร้าง action list จาก state+config แล้วเรียก executor (`gameApi`) เพื่อทำจริง

## การใช้งาน (ตัวอย่าง)

ดูตัวอย่างที่ `src/example_main.lua`:

- เตรียม `state` (inventory/team/currency)
- ตั้ง `config` (เป้าหมายทีม, เป้าหมายสุ่ม, blacklist, ฯลฯ)
- สร้าง `engine = Engine.new({ gameApi = ..., logger = ... })`
- เรียก `engine:runOnce(state, config)` หรือ `engine:runLoop(getStateFn, config, opts)`

## ขอบเขตและข้อควรรู้

- โค้ดใน `src/` **ไม่ทำการยิง Remote / ไม่ดึงข้อมูลจาก memory / ไม่พึ่ง Knit** โดยตรง
- การเชื่อมต่อกับเกมจริงให้ทำในชั้น `gameApi` (อยู่นอกแกน decision engine)
- ถ้าคุณจะทำต่อให้ “เล่นกับเกมจริง”:
  - ทำ adapter `gameApi` ที่มีฟังก์ชันตามที่ `src/engine.lua` เรียก
  - ทำตัวดึง state (inventory/team/currency) จากแหล่งข้อมูลที่ถูกต้องของโปรเจกต์คุณ

## TODO ต่อ (สำหรับ AI/คนทำงานต่อ)

- เพิ่ม planner สำหรับ “Map/Macro” (เช่น Place/Upgrade แบบเป็นลิสต์ตามด่าน)
- เพิ่มระบบ condition-based flow:
  - ถ้าเงินไม่พอ ให้รอ/ข้าม/เปลี่ยนลำดับ
  - ถ้า unit ไม่พบ ให้ fallback slot อื่น
- เพิ่ม validator ฝั่ง config (ตรวจชื่อซ้ำ/คีย์ผิด)
- เพิ่ม test harness (ถ้า repo ต้องการ)

## Mapping จากไฟล์เก่า → โมดูลใหม่

- `equip.txt` → logic “เลือกตัวที่ดีที่สุดในตระกูล + ไม่หยิบซ้ำ” อยู่ที่ `src/rules.lua` และ `src/planner.lua`
- `summon.txt` → logic “นับ progress แล้วตัดสินใจสุ่มต่อไหม” อยู่ที่ `src/planner.lua` (`planSummon`)
- `Login rewards.txt` → action แบบทั่วไปอยู่ที่ `src/planner.lua` (`planClaimRewards`)
- `Setting.txt` / `code.txt` / `fuse&stat.txt` / `Etherealize.txt` / `Tutorial.txt` / `gamemode.txt`
  - ยังไม่ได้ย้ายเข้ามาแบบเต็มรูปแบบ (ต้องทำเป็น planner/action เพิ่มเติมตาม scope ที่ต้องการ)
