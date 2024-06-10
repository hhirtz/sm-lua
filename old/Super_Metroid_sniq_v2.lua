---------------------
--sniq--
local FRAMES_SOUND_QUEUE = 0x0000;
local GAME_MODE_LAST = 0x0000;
local NMIREQ_LAST = 0x0000
local FRAMETIMER_LAST = 0x0000
local DOORTRANSFLAG_LAST = 0x0000
local DOORINSTRUCTION_LAST = 0x0000
local FRAMES_SCREENSCROLLY = 0x0000
local FRAMES_SCREENSCROLLX = 0x0000
local FRAMES_DOORLAG = 0x0000
local SCREENX_LAST = 0x0000
local SCREENY_LAST = 0x0000
-- Make Samus' hitbox change color based on environmental friction
local SAMUS_X_LAST = 0x00000000;
local SAMUS_X_THIS = 0x00000000;
local SAMUS_Y_LAST = 0x00000000;
local SAMUS_Y_THIS = 0x00000000;
local ACTUAL_X_DISTANCE = 0x00000000;
local EXPECTED_X_DISTANCE = 0x00000000;
local SAMUS_HITBOX_COLOR = 0xFFFF0000;
local SAMUS_WJCHECK_COLOR = 0xFF970F;
local SAMUS_WJREADY_COLOR = 0x0E4F07;
local WATER_COLOR = 0x2020E0;
local HOTLIQUID_COLOR = 0xA0A000;

function event.onframestart()

	SAMUS_X_LAST = (0x10000 * mainmemory.read_u16_le(0x0AF6)) + mainmemory.read_u16_le(0x0AF8)
	SAMUS_Y_LAST = (0x10000 * mainmemory.read_u16_le(0x0AFA)) + mainmemory.read_u16_le(0x0AFC)

	GAME_MODE_LAST = mainmemory.read_u8(0x0998)

	NMIREQ_LAST = mainmemory.read_u8(0x05B4)
	FRAMETIMER_LAST = mainmemory.read_u16_le(0x05B6)
	DOORTRANSFLAG_LAST = mainmemory.read_u8(0x0795)
	DOORINSTRUCTION_LAST = mainmemory.read_u16_le(0x099C)
	SCREENX_LAST = mainmemory.read_u16_le(0x0911)
	SCREENY_LAST = mainmemory.read_u16_le(0x0915)

end

function MovementPredictor()
	SAMUS_X_LAST = SAMUS_X_THIS
	SAMUS_X_THIS = (0x10000 * mainmemory.read_u16_le(0x0AF6)) + mainmemory.read_u16_le(0x0AF8)
	SAMUS_Y_LAST = SAMUS_Y_THIS
	SAMUS_Y_THIS = (0x10000 * mainmemory.read_u16_le(0x0AFA)) + mainmemory.read_u16_le(0x0AFC)

	if (SAMUS_X_THIS < SAMUS_X_LAST)
	then
		ACTUAL_X_DISTANCE = (SAMUS_X_LAST - SAMUS_X_THIS)
	else
		ACTUAL_X_DISTANCE = (SAMUS_X_THIS - SAMUS_X_LAST)
	end
	EXPECTED_X_DISTANCE = (0x10000 * (mainmemory.read_u16_le(0x0B42) + mainmemory.read_u16_le(0x0B46))) + (mainmemory.read_u16_le(0x0B44) + mainmemory.read_u16_le(0x0B48))

	if (SAMUS_Y_THIS < SAMUS_Y_LAST)
	then
		ACTUAL_Y_DISTANCE = (SAMUS_Y_LAST - SAMUS_Y_THIS)
	else
		ACTUAL_Y_DISTANCE = (SAMUS_Y_THIS - SAMUS_Y_LAST)
	end
		EXPECTED_Y_DISTANCE = (0x10000 * (mainmemory.read_u16_le(0x0B2E) )) + (mainmemory.read_u16_le(0x0B2C))

	if (ACTUAL_X_DISTANCE > EXPECTED_X_DISTANCE) -- arm pumping
	then
		SAMUS_HITBOX_COLOR = 0xFF00FF00;
	elseif (ACTUAL_X_DISTANCE == EXPECTED_X_DISTANCE)
	then
		SAMUS_HITBOX_COLOR = 0xFF80FFFF
	elseif ((4 * ACTUAL_X_DISTANCE) > (3 * EXPECTED_X_DISTANCE))
	then
		SAMUS_HITBOX_COLOR = 0xFFFF8000;
	elseif ((4 * ACTUAL_X_DISTANCE) > (2 * EXPECTED_X_DISTANCE))
	then
		SAMUS_HITBOX_COLOR = 0xFFFF0000
	else
		SAMUS_HITBOX_COLOR = 0xFF800000
	end
end

function MovementX()
	if (SAMUS_X_LAST > SAMUS_X_THIS)
	then
		gui.text(20, 200, string.format("X:<-: %3d.%05d", (ACTUAL_X_DISTANCE >> 0x10), (ACTUAL_X_DISTANCE & 0xFFFF)), 0xFFFFCC33);
	elseif (SAMUS_X_LAST < SAMUS_X_THIS)
	then
		gui.text(20, 200, string.format("X:->: %3d.%05d", (ACTUAL_X_DISTANCE >> 0x10), (ACTUAL_X_DISTANCE & 0xFFFF)), 0xFFFFCC33);
	end
end
function MovementY()
	if (SAMUS_Y_LAST > SAMUS_Y_THIS)
	then
		gui.text(20, 220, string.format("Y: ^: %3d.%05d", (ACTUAL_Y_DISTANCE >> 0x10), (ACTUAL_Y_DISTANCE & 0xFFFF)), 0xFFFFCC33);

	elseif (SAMUS_Y_LAST < SAMUS_Y_THIS)
	then
		gui.text(20, 220, string.format("Y: v: %3d.%05d", (ACTUAL_Y_DISTANCE >> 0x10), (ACTUAL_Y_DISTANCE & 0xFFFF)), 0xFFFFCC33);
	end
end


function DoorHelper1()

--local NMIREQ_THIS = memory.readbyte ('WRAM', 0x05B4)
local GAME_MODE_THIS = mainmemory.read_u8(0x0998)
	if (GAME_MODE_THIS == 0x0B)
    then
		local soundq1 = mainmemory.read_u8(0x0643)
		local soundq2 = mainmemory.read_u8(0x0644)
		local soundq3 = mainmemory.read_u8(0x0645)

		local soundq1next = mainmemory.read_u8(0x0646)
		local soundq2next = mainmemory.read_u8(0x0647)
		local soundq3next = mainmemory.read_u8(0x0648)

		if (soundq1 ~= soundq1next or soundq2 ~= soundq2next or soundq3 ~= soundq3next)
		then
			--if NMIREQ_THIS == 0x01
			--then
				FRAMES_SOUND_QUEUE = FRAMES_SOUND_QUEUE + 1
			--end
		end

		if (FRAMES_SOUND_QUEUE ~= 0)
		then
			gui.text(20, 280, "Sound frames lost: " .. FRAMES_SOUND_QUEUE)
		end
	end

	if (GAME_MODE_LAST == 0x0A or GAME_MODE_THIS == 0x08)
	then
		FRAMES_SOUND_QUEUE = 0
	end
end
function DoorHelper2()

local doordir = mainmemory.read_u8(0x0791)
local DOORTRANSFLAG_THIS = mainmemory.read_u8(0x0795)
local DOORINSTRUCTION_THIS = mainmemory.read_u16_le(0x099C)
local GAME_MODE_THIS = mainmemory.read_u8(0x0998)

	if (GAME_MODE_THIS == 0x0B)
	then
		if (DOORINSTRUCTION_THIS == 0xE310)
		then
			if (doordir == 0x00 or 0x01 or 0x04 or 0x05)
			then
				local screeny = mainmemory.read_u16_le(0x0915)
				if (screeny ~= SCREENY_LAST)
				then
					FRAMES_SCREENSCROLLY = FRAMES_SCREENSCROLLY + 1
				end
			end

			if (doordir == 0x02 or 0x03 or 0x06 or 0x07)
			then
				local screenx = mainmemory.read_u16_le(0x0911)
				if (screenx ~= SCREENX_LAST)
				then
					FRAMES_SCREENSCROLLX = FRAMES_SCREENSCROLLX + 1
				end
			end
		end

		if (FRAMES_SCREENSCROLLY ~= 0)
		then
			gui.text(20, 300, "Screen frames lost: " .. FRAMES_SCREENSCROLLY);
		end

		if (FRAMES_SCREENSCROLLX ~= 0)
		then
			gui.text(20, 300, "Screen frames lost: " .. FRAMES_SCREENSCROLLX);
		end

		if (DOORTRANSFLAG_LAST == 0x01 and DOORTRANSFLAG_THIS == 0x00)
		then
			FRAMES_SCREENSCROLLY = 0
			FRAMES_SCREENSCROLLX = 0
		end
	end
	if (GAME_MODE_THIS == 0x08)
	then
		FRAMES_SCREENSCROLLY = 0
		FRAMES_SCREENSCROLLX = 0
	end
end
function DoorHelper3()

local GAME_MODE_THIS = mainmemory.read_u8(0x0998)
local DOORINSTRUCTION_THIS = mainmemory.read_u16_le(0x099C)
local DOORTRANSFLAG_THIS = mainmemory.read_u8(0x0795)
local FRAMETIMER_THIS = mainmemory.read_u16_le(0x05B6)
local NMIREQ_THIS = mainmemory.read_u8(0x05B4)
local elevflag = mainmemory.read_u8(0x0E18)

	if (DOORINSTRUCTION_THIS == 0xE17D or DOORINSTRUCTION_THIS == 0xE29E)
	then
		if (elevflag == 0x00)
		then
			if (FRAMETIMER_THIS == FRAMETIMER_LAST)
			then
				FRAMES_DOORLAG = FRAMES_DOORLAG + 1
			end
		end
	end

	if (FRAMES_DOORLAG ~= 0)
	then
		if (GAME_MODE_THIS == 0x09 or GAME_MODE_THIS == 0x0B)
		then
			gui.text(20, 320, "Lag frames lost: " .. FRAMES_DOORLAG )
		end
	end

	if (DOORTRANSFLAG_LAST == 0x01 and DOORTRANSFLAG_THIS == 0x00)
	then
		FRAMES_DOORLAG = 0
	end

	if GAME_MODE_THIS == 0x08
	then
		FRAMES_DOORLAG = 0
	end
end

--[[
	local radiusX, radiusY = memory.read_s16_le(0x7E0AFE), memory.read_s16_le(0x7E0B00)
	local topleft = {128 - radiusX, 112 - radiusY}
	local bottomright = {128 + radiusX, 112 + radiusY}
	gui.drawBox(topleft[1]*2,topleft[2]*2, (bottomright[1]-topleft[1])*2,(bottomright[2]-topleft[2])*2, 1, SAMUS_HITBOX_COLOR, -1)
	-- draw Samus' hitbox
]]--
---------------------
--sniq--




--Author Pasky13

--Player
local px = 0x000AF6
local py = 0x000AFA
local plife = 0x0009C2
--Camera
local camx = 0x000911
local camy = 0x000915
--Text scaler
local xs
local ys
local function Samus()
	local x = mainmemory.read_u16_le(px) - mainmemory.read_u16_le(camx)
	local y = mainmemory.read_u16_le(py) - mainmemory.read_u16_le(camy)
	local xrad = mainmemory.read_u8(0x0AFE)
	local yrad = mainmemory.read_u8(0x0B00)

	gui.drawBox(x + (xrad * -1), y + (yrad * -1), x+xrad,y+yrad,SAMUS_HITBOX_COLOR,0x350000FF)

end

local function EnemyBoxes()
	local x = 0
	local y = 0
	local xrad = 0
	local yrad = 0
	local oend = 20
	local base = 0xF7A

	for i = 0, oend, 1 do
		if i > 0 then
			base = 0xF7A + (i * 0x40)
		else
			base = 0xF7A
		end

		x = mainmemory.read_u16_le(base) - mainmemory.read_u16_le(camx)
		y = mainmemory.read_u16_le(base+ 4) - mainmemory.read_u16_le(camy)
		xrad = mainmemory.read_u8(0x0F82 + (i * 0x40))
		yrad = mainmemory.read_u8(0x0F84 + (i * 0x40))
		hp = mainmemory.read_u16_le(base + 0x12)

		gui.drawBox(x + (xrad * -1),y + (yrad * -1),x+xrad,y+yrad,0xFFFF0000,0x35FF0000)
		gui.text((x-5) * xs,(y-5) * ys,"HP: " .. hp)
	end
end

local function powerbomb()
	local x = mainmemory.read_u16_le(0xCE2) - mainmemory.read_u16_le(camx)
	local y = mainmemory.read_u16_le(0xCE4) - mainmemory.read_u16_le(camy)
	local xrad
	local yrad

	xrad = (memory.readbyte(0xCEB) & 0xFF)
	yrad = ((xrad / 2) + xrad) / 2
	gui.drawBox(x + (xrad * -1), y + (yrad * -1),x+xrad,y+yrad,0xFF00FFFF,0x35F00FFF)
end

local function Projectiles()
	local x
	local y
	local xrad
	local yrad
	local oend = 8
	local projxbase = 0xB64
	local projybase = 0xB78
	local projxrbase = 0xBB4
	local projyrbase = 0xBC8

	for i = 0, oend, 1 do


		x = mainmemory.read_u16_le(projxbase + (i*2)) - mainmemory.read_u16_le(camx)
		y = mainmemory.read_u16_le(projybase + (i*2)) - mainmemory.read_u16_le(camy)

		xrad = mainmemory.read_u8(projxrbase + (i * 2))
		yrad = mainmemory.read_u8(projyrbase + (i * 2))

		gui.drawBox(x + (xrad * -1), y + (yrad * -1), x+xrad,y+yrad,0xFFFFFFFF,0x35FFFFFF)
	end

	if (mainmemory.read_u16_le(0xCEB) & 0xFF) > 0 then
		powerbomb()
	end
end

local function scaler()
	xs = client.screenwidth() / 256
	ys = client.screenwidth() / 224
end

while true do
	MovementPredictor()
	MovementX()
	MovementY()
	DoorHelper1()
	--DoorHelper2()
	DoorHelper3()
	scaler()
	Samus()
	EnemyBoxes()
	Projectiles()
	emu.frameadvance()
end
