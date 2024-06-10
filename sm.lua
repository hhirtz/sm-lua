-----------------------------
-- script settings
local GUI_FONT_SIZE = 16
local HUD_COLOR_LO = 0xA0FFFFFF
local HUD_COLOR_HI = 0xFFFFFF00
local HUD_COLUMN_WIDTH = 164
local HUD_COLUMN_0 = 0
local HUD_COLUMN_1 = HUD_COLUMN_0 + (HUD_COLUMN_WIDTH * 1)
local HUD_COLUMN_2 = HUD_COLUMN_0 + (HUD_COLUMN_WIDTH * 2)
local HUD_ROW_HEIGHT = GUI_FONT_SIZE
local HUD_ROW_0 = 72
local HUD_ROW_1 = HUD_ROW_0 + (HUD_ROW_HEIGHT * 1)
local HUD_ROW_2 = HUD_ROW_0 + (HUD_ROW_HEIGHT * 2)
local HUD_ROW_3 = HUD_ROW_0 + (HUD_ROW_HEIGHT * 3)
local HUD_ROW_4 = HUD_ROW_0 + (HUD_ROW_HEIGHT * 4)
local HUD_ROW_5 = HUD_ROW_0 + (HUD_ROW_HEIGHT * 5)
local HUD_ROW_6 = HUD_ROW_0 + (HUD_ROW_HEIGHT * 6)
local HUD_ROW_7 = HUD_ROW_0 + (HUD_ROW_HEIGHT * 7)


-----------------------------
-- databases
local POSE_NAMES = {
    -- ref: https://patrickjohnston.org/ASM/Lists/Super%20Metroid/Pose%20definitions.asm
    -- cat Pose\ definitions.asm | grep " ; " | sed 's/.* ; /[0x/' | sed 's/: /] = "/' | sed 's/.$/",/' | sort | grep -v '"Unused",' | sed 's/ \+- \+/, /g'
    [0x00] = "Facing forward, power suit",
    [0x01] = "Facing right, normal",
    [0x02] = "Facing left, normal",
    [0x03] = "Facing right, aiming up",
    [0x04] = "Facing left, aiming up",
    [0x05] = "Facing right, aiming up-right",
    [0x06] = "Facing left, aiming up-left",
    [0x07] = "Facing right, aiming down-right",
    [0x08] = "Facing left, aiming down-left",
    [0x09] = "Moving right, not aiming",
    [0x0A] = "Moving left, not aiming",
    [0x0B] = "Moving right, gun extended",
    [0x0C] = "Moving left, gun extended",
    [0x0D] = "Moving right, aiming up (unused)",
    [0x0E] = "Moving left, aiming up (unused)",
    [0x0F] = "Moving right, aiming up-right",
    [0x10] = "Moving left, aiming up-left",
    [0x11] = "Moving right, aiming down-right",
    [0x12] = "Moving left, aiming down-left",
    [0x13] = "Facing right, normal jump, not aiming, not moving, gun extended",
    [0x14] = "Facing left, normal jump, not aiming, not moving, gun extended",
    [0x15] = "Facing right, normal jump, aiming up",
    [0x16] = "Facing left, normal jump, aiming up",
    [0x17] = "Facing right, normal jump, aiming down",
    [0x18] = "Facing left, normal jump, aiming down",
    [0x19] = "Facing right, spin jump",
    [0x1A] = "Facing left, spin jump",
    [0x1B] = "Facing right, space jump",
    [0x1C] = "Facing left, space jump",
    [0x1D] = "Facing right, morph ball, no springball, on ground",
    [0x1E] = "Moving right, morph ball, no springball, on ground",
    [0x1F] = "Moving left, morph ball, no springball, on ground",
    [0x25] = "Facing right, turning, standing",
    [0x26] = "Facing left, turning, standing",
    [0x27] = "Facing right, crouching",
    [0x28] = "Facing left, crouching",
    [0x29] = "Facing right, falling",
    [0x2A] = "Facing left, falling",
    [0x2B] = "Facing right, falling, aiming up",
    [0x2C] = "Facing left, falling, aiming up",
    [0x2D] = "Facing right, falling, aiming down",
    [0x2E] = "Facing left, falling, aiming down",
    [0x2F] = "Facing right, turning, jumping",
    [0x30] = "Facing left, turning, jumping",
    [0x31] = "Facing right, morph ball, no springball, in air",
    [0x32] = "Facing left, morph ball, no springball, in air",
    [0x35] = "Facing right, crouching transition",
    [0x36] = "Facing left, crouching transition",
    [0x37] = "Facing right, morphing transition",
    [0x38] = "Facing left, morphing transition",
    [0x3B] = "Facing right, standing transition",
    [0x3C] = "Facing left, standing transition",
    [0x3D] = "Facing right, unmorphing transition",
    [0x3E] = "Facing left, unmorphing transition",
    [0x41] = "Facing left, morph ball, no springball, on ground",
    [0x43] = "Facing right, turning, crouching",
    [0x44] = "Facing left, turning, crouching",
    [0x49] = "Facing left, moonwalk",
    [0x4A] = "Facing right, moonwalk",
    [0x4B] = "Facing right, normal jump transition",
    [0x4C] = "Facing left, normal jump transition",
    [0x4D] = "Facing right, normal jump, not aiming, not moving, gun not extended",
    [0x4E] = "Facing left, normal jump, not aiming, not moving, gun not extended",
    [0x4F] = "Facing left, damage boost",
    [0x50] = "Facing right, damage boost",
    [0x51] = "Facing right, normal jump, not aiming, moving forward",
    [0x52] = "Facing left, normal jump, not aiming, moving forward",
    [0x53] = "Facing right, knockback",
    [0x54] = "Facing left, knockback",
    [0x55] = "Facing right, normal jump transition, aiming up",
    [0x56] = "Facing left, normal jump transition, aiming up",
    [0x57] = "Facing right, normal jump transition, aiming up-right",
    [0x58] = "Facing left, normal jump transition, aiming up-left",
    [0x59] = "Facing right, normal jump transition, aiming down-right",
    [0x5A] = "Facing left, normal jump transition, aiming down-left",
    [0x67] = "Facing right, falling, gun extended",
    [0x68] = "Facing left, falling, gun extended",
    [0x69] = "Facing right, normal jump, aiming up-right",
    [0x6A] = "Facing left, normal jump, aiming up-left",
    [0x6B] = "Facing right, normal jump, aiming down-right",
    [0x6C] = "Facing left, normal jump, aiming down-left",
    [0x6D] = "Facing right, falling, aiming up-right",
    [0x6E] = "Facing left, falling, aiming up-left",
    [0x6F] = "Facing right, falling, aiming down-right",
    [0x70] = "Facing left, falling, aiming down-left",
    [0x71] = "Facing right, crouching, aiming up-right",
    [0x72] = "Facing left, crouching, aiming up-left",
    [0x73] = "Facing right, crouching, aiming down-right",
    [0x74] = "Facing left, crouching, aiming down-left",
    [0x75] = "Facing left, moonwalk, aiming up-left",
    [0x76] = "Facing right, moonwalk, aiming up-right",
    [0x77] = "Facing left, moonwalk, aiming down-left",
    [0x78] = "Facing right, moonwalk, aiming down-right",
    [0x79] = "Facing right, morph ball, spring ball, on ground",
    [0x7A] = "Facing left, morph ball, spring ball, on ground",
    [0x7B] = "Moving right, morph ball, spring ball, on ground",
    [0x7C] = "Moving left, morph ball, spring ball, on ground",
    [0x7D] = "Facing right, morph ball, spring ball, falling",
    [0x7E] = "Facing left, morph ball, spring ball, falling",
    [0x7F] = "Facing right, morph ball, spring ball, in air",
    [0x80] = "Facing left, morph ball, spring ball, in air",
    [0x81] = "Facing right, screw attack",
    [0x82] = "Facing left, screw attack",
    [0x83] = "Facing right, wall jump",
    [0x84] = "Facing left, wall jump",
    [0x85] = "Facing right, crouching, aiming up",
    [0x86] = "Facing left, crouching, aiming up",
    [0x87] = "Facing right, turning, falling",
    [0x88] = "Facing left, turning, falling",
    [0x89] = "Facing right, ran into a wall",
    [0x8A] = "Facing left, ran into a wall",
    [0x8B] = "Facing right, turning, standing, aiming up",
    [0x8C] = "Facing left, turning, standing, aiming up",
    [0x8D] = "Facing right, turning, standing, aiming down-right",
    [0x8E] = "Facing left, turning, standing, aiming down-left",
    [0x8F] = "Facing right, turning, in air, aiming up",
    [0x90] = "Facing left, turning, in air, aiming up",
    [0x91] = "Facing right, turning, in air, aiming down/down-right",
    [0x92] = "Facing left, turning, in air, aiming down/down-left",
    [0x93] = "Facing right, turning, falling, aiming up",
    [0x94] = "Facing left, turning, falling, aiming up",
    [0x95] = "Facing right, turning, falling, aiming down/down-right",
    [0x96] = "Facing left, turning, falling, aiming down/down-left",
    [0x97] = "Facing right, turning, crouching, aiming up",
    [0x98] = "Facing left, turning, crouching, aiming up",
    [0x99] = "Facing right, turning, crouching, aiming down/down-right",
    [0x9A] = "Facing left, turning, crouching, aiming down/down-left",
    [0x9B] = "Facing forward, varia/gravity suit",
    [0x9C] = "Facing right, turning, standing, aiming up-right",
    [0x9D] = "Facing left, turning, standing, aiming up-left",
    [0x9E] = "Facing right, turning, in air, aiming up-right",
    [0x9F] = "Facing left, turning, in air, aiming up-left",
    [0xA0] = "Facing right, turning, falling, aiming up-right",
    [0xA1] = "Facing left, turning, falling, aiming up-left",
    [0xA2] = "Facing right, turning, crouching, aiming up-right",
    [0xA3] = "Facing left, turning, crouching, aiming up-left",
    [0xA4] = "Facing right, landing from normal jump",
    [0xA5] = "Facing left, landing from normal jump",
    [0xA6] = "Facing right, landing from spin jump",
    [0xA7] = "Facing left, landing from spin jump",
    [0xB2] = "Facing clockwise, grapple",
    [0xB3] = "Facing anticlockwise, grapple",
    [0xB8] = "Facing left, grapple wall jump pose",
    [0xB9] = "Facing right, grapple wall jump pose",
    [0xBA] = "Facing left, grabbed by Draygon, not moving, not aiming",
    [0xBB] = "Facing left, grabbed by Draygon, not moving, aiming up-left",
    [0xBC] = "Facing left, grabbed by Draygon, firing",
    [0xBD] = "Facing left, grabbed by Draygon, not moving, aiming down-left",
    [0xBE] = "Facing left, grabbed by Draygon, moving",
    [0xBF] = "Facing right, moonwalking, turn/jump left",
    [0xC0] = "Facing left, moonwalking, turn/jump right",
    [0xC1] = "Facing right, moonwalking, turn/jump left, aiming up-right",
    [0xC2] = "Facing left, moonwalking, turn/jump right, aiming up-left",
    [0xC3] = "Facing right, moonwalking, turn/jump left, aiming down-right",
    [0xC4] = "Facing left, moonwalking, turn/jump right, aiming down-left",
    [0xC7] = "Facing right, vertical shinespark windup",
    [0xC8] = "Facing left, vertical shinespark windup",
    [0xC9] = "Facing right, shinespark, horizontal",
    [0xCA] = "Facing left, shinespark, horizontal",
    [0xCB] = "Facing right, shinespark, vertical",
    [0xCC] = "Facing left, shinespark, vertical",
    [0xCD] = "Facing right, shinespark, diagonal",
    [0xCE] = "Facing left, shinespark, diagonal",
    [0xCF] = "Facing right, ran into a wall, aiming up-right",
    [0xD0] = "Facing left, ran into a wall, aiming up-left",
    [0xD1] = "Facing right, ran into a wall, aiming down-right",
    [0xD2] = "Facing left, ran into a wall, aiming down-left",
    [0xD3] = "Facing right, crystal flash",
    [0xD4] = "Facing left, crystal flash",
    [0xD5] = "Facing right, x-ray, standing",
    [0xD6] = "Facing left, x-ray, standing",
    [0xD7] = "Facing right, crystal flash ending",
    [0xD8] = "Facing left, crystal flash ending",
    [0xD9] = "Facing right, x-ray, crouching",
    [0xDA] = "Facing left, x-ray, crouching",
    [0xE0] = "Facing right, landing from normal jump, aiming up",
    [0xE1] = "Facing left, landing from normal jump, aiming up",
    [0xE2] = "Facing right, landing from normal jump, aiming up-right",
    [0xE3] = "Facing left, landing from normal jump, aiming up-left",
    [0xE4] = "Facing right, landing from normal jump, aiming down-right",
    [0xE5] = "Facing left, landing from normal jump, aiming down-left",
    [0xE6] = "Facing right, landing from normal jump, firing",
    [0xE7] = "Facing left, landing from normal jump, firing",
    [0xE8] = "Facing right, Samus drained, crouching",
    [0xE9] = "Facing left, Samus drained, crouching",
    [0xEA] = "Facing right, Samus drained, standing",
    [0xEB] = "Facing left, Samus drained, standing",
    [0xEC] = "Facing right, grabbed by Draygon, not moving, not aiming",
    [0xED] = "Facing right, grabbed by Draygon, not moving, aiming up-right",
    [0xEE] = "Facing right, grabbed by Draygon, firing",
    [0xEF] = "Facing right, grabbed by Draygon, not moving, aiming down-right",
    [0xF0] = "Facing right, grabbed by Draygon, moving",
    [0xF1] = "Facing right, crouching transition, aiming up",
    [0xF2] = "Facing left, crouching transition, aiming up",
    [0xF3] = "Facing right, crouching transition, aiming up-right",
    [0xF4] = "Facing left, crouching transition, aiming up-left",
    [0xF5] = "Facing right, crouching transition, aiming down-right",
    [0xF6] = "Facing left, crouching transition, aiming down-left",
    [0xF7] = "Facing right, standing transition, aiming up",
    [0xF8] = "Facing left, standing transition, aiming up",
    [0xF9] = "Facing right, standing transition, aiming up-right",
    [0xFA] = "Facing left, standing transition, aiming up-left",
    [0xFB] = "Facing right, standing transition, aiming down-right",
    [0xFC] = "Facing left, standing transition, aiming down-left",
}

local BUTTON_R = 1 << 4
local BUTTON_L = 1 << 5
local BUTTON_X = 1 << 6
local BUTTON_A = 1 << 7
local BUTTON_RIGHT = 1 << 8
local BUTTON_LEFT = 1 << 9
local BUTTON_DOWN = 1 << 10
local BUTTON_UP = 1 << 11
local BUTTON_START = 1 << 12
local BUTTON_SELECT = 1 << 13
local BUTTON_Y = 1 << 14
local BUTTON_B = 1 << 15


-----------------------------
-- memory values
local CHARGE_COUNTER = 0
local DOOR_TRANSITION_FUNC = 0
local OLD_DOOR_TRANSITION_FUNC = 0
local GAME_STATE = 0
local OLD_GAME_STATE = 0
local IFRAMES = 0
local INPUT = 0
local KNOCKBACK = 0
local POWERBOMB_RADIUS = 0
local POWERBOMB_TIMER = 0
local POWERBOMB_X = 0
local POWERBOMB_Y = 0
local SAMUS_X = 0
local OLD_SAMUS_X = 0
local SAMUS_Y = 0
local OLD_SAMUS_Y = 0
local SAMUS_DASH = 0
local SAMUS_DIRECTION_X = 0
local SAMUS_DIRECTION_Y = 0
local SAMUS_POSE = 0
local SAMUS_RADIUS_X = 0
local SAMUS_RADIUS_Y = 0
local SAMUS_SPEED_X = 0
local SAMUS_SPEED_Y = 0
local OLD_SAMUS_SPEED_Y = 0
local SCREEN_X = 0
local SCREEN_Y = 0
local SPARK_TIMER = 0
local SPEED_LEVEL = 0
local WEAPON_COOLDOWN = 0

local PROJECTILES_X = {}
local PROJECTILES_Y = {}
local PROJECTILES_RADIUS_X = {}
local PROJECTILES_RADIUS_Y = {}
local BOMB_TIMERS = {}

local ENEMY_COUNT = 0
local ENEMY_DATA = {}
local ENEMY_PROJECTILE_IDS = {}
local ENEMY_PROJECTILE_XS = {}
local ENEMY_PROJECTILE_YS = {}
local ENEMY_PROJECTILE_RADIUSES = {}


-----------------------------
-- other frame constants
local FRAME_NO = 0
local SEEKED = true


-----------------------------
-- actual code

local function snes2pc(address)
    return ((address >> 1) & 0x3F8000) | (address & 0x7FFF)
end

local function read_enemy_data(res)
    local MAX_ENEMIES = 32
    local bytes = mainmemory.read_bytes_as_array(0x0F78, 0x40 * MAX_ENEMIES)
    for i = 1, MAX_ENEMIES do
        local offset = (i - 1) * 0x40 + 1
        local id = bytes[offset]| (bytes[offset + 1] << 8)
        res[i] = {
            id = id,
            x = bytes[offset + 2]| (bytes[offset + 3] << 8),
            -- skip subx
            y = bytes[offset + 6]| (bytes[offset + 7] << 8),
            -- skip suby
            radius_x = bytes[offset + 10]| (bytes[offset + 11] << 8),
            radius_y = bytes[offset + 12]| (bytes[offset + 13] << 8),
            health = bytes[offset + 20]| (bytes[offset + 21] << 8),
            max_health = memory.read_u16_le(snes2pc(0xA00004 + id), "CARTROM"),
        }
    end
end

local function read_old_memory()
    OLD_DOOR_TRANSITION_FUNC = mainmemory.read_u16_le(0x099C)
    OLD_GAME_STATE = mainmemory.read_u8(0x0998)
    OLD_SAMUS_X = (mainmemory.read_u16_le(0x0AF6) << 16) | mainmemory.read_u16_le(0x0AF8)
    OLD_SAMUS_Y = (mainmemory.read_u16_le(0x0AFA) << 16) | mainmemory.read_u16_le(0x0AFC)
    OLD_SAMUS_SPEED_Y = (mainmemory.read_s16_le(0x0B2E) << 16) | mainmemory.read_u16_le(0x0B2C)
end

local function read_new_memory()
    DOOR_TRANSITION_FUNC = mainmemory.read_u16_le(0x099C)
    CHARGE_COUNTER = mainmemory.read_u16_le(0x0CD0)
    GAME_STATE = mainmemory.read_u8(0x0998)
    IFRAMES = mainmemory.read_u16_le(0x18A8)
    INPUT = mainmemory.read_u16_le(0x008B)
    KNOCKBACK = mainmemory.read_u16_le(0x18AA)
    POWERBOMB_RADIUS = mainmemory.read_u16_le(0x0CEA)
    POWERBOMB_TIMER = mainmemory.read_u16_le(0x0CEE)
    POWERBOMB_X = mainmemory.read_u16_le(0x0CE2)
    POWERBOMB_Y = mainmemory.read_u16_le(0x0CE4)
    SAMUS_DIRECTION_X = mainmemory.read_u8(0X0A1E)
    SAMUS_DIRECTION_Y = mainmemory.read_u8(0X0B36)
    SAMUS_DASH = (mainmemory.read_u16_le(0x0B46) << 16) | mainmemory.read_u16_le(0x0B48)
    SAMUS_POSE = mainmemory.read_u8(0x0A1C)
    SAMUS_RADIUS_X = mainmemory.read_u8(0x0AFE)
    SAMUS_RADIUS_Y = mainmemory.read_u8(0x0B00)
    SAMUS_SPEED_X = (mainmemory.read_s16_le(0x0B42) << 16) | mainmemory.read_u16_le(0x0B44)
    SAMUS_SPEED_Y = (mainmemory.read_s16_le(0x0B2E) << 16) | mainmemory.read_u16_le(0x0B2C)
    SAMUS_X = (mainmemory.read_u16_le(0x0AF6) << 16) | mainmemory.read_u16_le(0x0AF8)
    SAMUS_Y = (mainmemory.read_u16_le(0x0AFA) << 16) | mainmemory.read_u16_le(0x0AFC)
    SCREEN_X = mainmemory.read_u16_le(0x0911)
    SCREEN_Y = mainmemory.read_u16_le(0x0915)
    SPEED_LEVEL = mainmemory.read_u8(0x0B3F)
    SPARK_TIMER = mainmemory.read_u16_le(0x0A68)
    WEAPON_COOLDOWN = mainmemory.read_u16_le(0x0CCC)

    local function read_u16_le_array(res, address, length)
        local bytes = mainmemory.read_bytes_as_array(address, length * 2)
        for i = 1, length do
            res[i] = (bytes[2 * i] << 8) | bytes[2 * i - 1]
        end
    end

    read_u16_le_array(PROJECTILES_X, 0x0B64, 10)
    read_u16_le_array(PROJECTILES_Y, 0x0B78, 10)
    read_u16_le_array(PROJECTILES_RADIUS_X, 0x0BB4, 10)
    read_u16_le_array(PROJECTILES_RADIUS_Y, 0x0BC8, 10)
    read_u16_le_array(BOMB_TIMERS, 0x0C7C, 10)

    ENEMY_COUNT = mainmemory.read_u8(0x0E4E)
    read_enemy_data(ENEMY_DATA)

    read_u16_le_array(ENEMY_PROJECTILE_IDS, 0x1997, 18)
    read_u16_le_array(ENEMY_PROJECTILE_XS, 0x1A4B, 18)
    read_u16_le_array(ENEMY_PROJECTILE_YS, 0x1A93, 18)
    ENEMY_PROJECTILE_RADIUSES = mainmemory.read_bytes_as_array(0x1BB3, 36)
end

local function gameplay()
    -- TODO return false during pause
    return (0x08 <= GAME_STATE and GAME_STATE <= 0x12) or
        GAME_STATE == 0x2A
end

local function valid_level_data()
    return (0x08 <= GAME_STATE and GAME_STATE < 0x0B) or
        (GAME_STATE == 0x0B and DOOR_TRANSITION_FUNC ~= 0xE36E) or
        (GAME_STATE == 0x0C) or
        (GAME_STATE == 0x11) or
        (GAME_STATE == 0x12)
end

local function samus_displacement()
    local samus_dx
    if SAMUS_X < OLD_SAMUS_X then
        samus_dx = OLD_SAMUS_X - SAMUS_X
    else
        samus_dx = SAMUS_X - OLD_SAMUS_X
    end

    local samus_dy
    if SAMUS_Y < OLD_SAMUS_Y then
        samus_dy = OLD_SAMUS_Y - SAMUS_Y
    else
        samus_dy = SAMUS_Y - OLD_SAMUS_Y
    end

    return samus_dx, samus_dy
end

local function draw_samus_hitbox(samus_dx, samus_dy)
    -- hitbox around samus
    local x = (SAMUS_X >> 16) - SCREEN_X
    local y = (SAMUS_Y >> 16) - SCREEN_Y
    local x1 = x - SAMUS_RADIUS_X
    local y1 = y - SAMUS_RADIUS_Y
    local x2 = x + SAMUS_RADIUS_X
    local y2 = y + SAMUS_RADIUS_Y
    gui.drawBox(x1, y1, x2, y2, 0xFFFFFFFF, 0x35FFFFFF)

    -- speed expectation
    local textpos = client.transformPoint(x1, y1)
    local expected_dx = SAMUS_SPEED_X + SAMUS_DASH -- TODO use *0x0B4A
    local dx_ratio = samus_dx / expected_dx * 100
    if dx_ratio == dx_ratio then
        -- dx_ratio is not NaN
        local expected_dx_msg = string.format("dx:%3.0f%%", samus_dx / expected_dx * 100)
        gui.text(textpos.x, textpos.y - 2 * GUI_FONT_SIZE, expected_dx_msg)
    end
    local expected_dy = OLD_SAMUS_SPEED_Y -- TODO this only works for positive values
    local dy_ratio = samus_dy / expected_dy * 100
    if dy_ratio == dy_ratio then
        -- dy_ratio is not NaN
        local expected_dy_msg = string.format("dy:%3.0f%%", samus_dy / expected_dy * 100)
        gui.text(textpos.x, textpos.y - GUI_FONT_SIZE, expected_dy_msg)
    end

    -- walljump lines
    local spinning_right = (SAMUS_POSE == 0x19) or (SAMUS_POSE == 0x81)
    local spinning_left = (SAMUS_POSE == 0x1A) or (SAMUS_POSE == 0x82)
    local pressing_right = (INPUT & BUTTON_RIGHT) ~= 0
    local pressing_left = (INPUT & BUTTON_LEFT) ~= 0
    if (spinning_left and pressing_left) or (spinning_right and pressing_left and pressing_right) then
        gui.drawLine(x2 + 8, y1, x2 + 8, y2)
    elseif spinning_right and pressing_right then
        gui.drawLine(x1 - 8, y1, x1 - 8, y2)
    end
end

local function draw_projectile_hitboxes()
    for i = 1, 10 do
        if PROJECTILES_RADIUS_X[i] ~= 0 or PROJECTILES_RADIUS_Y[i] ~= 0 or BOMB_TIMERS[i] ~= 0 then
            local x = PROJECTILES_X[i] - SCREEN_X
            local y = PROJECTILES_Y[i] - SCREEN_Y
            local x1 = x - PROJECTILES_RADIUS_X[i]
            local y1 = y - PROJECTILES_RADIUS_Y[i]
            local x2 = x + PROJECTILES_RADIUS_X[i]
            local y2 = y + PROJECTILES_RADIUS_Y[i]
            gui.drawBox(x1, y1, x2, y2, 0xFFFFFFFF, 0x35FFFFFF)

            if BOMB_TIMERS[i] ~= 0 then
                local textpos = client.transformPoint(x1, y1)
                gui.text(textpos.x, textpos.y - GUI_FONT_SIZE, BOMB_TIMERS[i])
            end
        end
    end
end

local function draw_powerbomb_hitbox()
    if POWERBOMB_TIMER == 0 then
        return
    end

    local radius_x = POWERBOMB_RADIUS >> 8
    local radius_y = (radius_x * 3) // 4
    local x1 = POWERBOMB_X - radius_x - SCREEN_X
    local y1 = POWERBOMB_Y - radius_y - SCREEN_Y
    local x2 = POWERBOMB_X + radius_x - SCREEN_X
    local y2 = POWERBOMB_Y + radius_y - SCREEN_Y
    gui.drawBox(x1, y1, x2, y2, 0xFF00FFFF, 0x35F00FFF)
end

local function draw_enemy_hitboxes()
    for i = ENEMY_COUNT, 1, -1 do
        if ENEMY_DATA[i].id ~= 0 then
            local x1 = ENEMY_DATA[i].x - ENEMY_DATA[i].radius_x - SCREEN_X
            local y1 = ENEMY_DATA[i].y - ENEMY_DATA[i].radius_y - SCREEN_Y
            local x2 = ENEMY_DATA[i].x + ENEMY_DATA[i].radius_x - SCREEN_X
            local y2 = ENEMY_DATA[i].y + ENEMY_DATA[i].radius_y - SCREEN_Y

            -- TODO extended sprite map
            gui.drawBox(x1, y1, x2, y2, 0xFFFF0000, 0x35FF0000)
            local textpos = client.transformPoint(x1, y1)
            gui.text(textpos.x, textpos.y - GUI_FONT_SIZE,
                string.format("hp: %d/%d", ENEMY_DATA[i].health, ENEMY_DATA[i].max_health))
        end
    end
end

local function draw_enemy_projectile_hitboxes()
    for i = 18, 1, -1 do
        if ENEMY_PROJECTILE_IDS[i] ~= 0 then
            local x1 = ENEMY_PROJECTILE_XS[i] - ENEMY_PROJECTILE_RADIUSES[(i << 1) - 1] - SCREEN_X
            local y1 = ENEMY_PROJECTILE_YS[i] - ENEMY_PROJECTILE_RADIUSES[(i << 1) - 0] - SCREEN_Y
            local x2 = ENEMY_PROJECTILE_XS[i] + ENEMY_PROJECTILE_RADIUSES[(i << 1) - 1] - SCREEN_X
            local y2 = ENEMY_PROJECTILE_YS[i] + ENEMY_PROJECTILE_RADIUSES[(i << 1) - 0] - SCREEN_Y
            gui.drawBox(x1, y1, x2, y2, 0xFFFF8000, 0x35FF8000)
        end
    end
end

local _dlag_seen_transition_start = false
local _dlag_seen_transition_end = false
local _dlag_elevator = 0
local _dlag_sound = 0
local _dlag_scroll = 0
local _dlag_moving_up = 0
local function draw_door_lag()
    if SEEKED then
        _dlag_seen_transition_start = false
        _dlag_seen_transition_end = false
        _dlag_elevator = 0
        _dlag_sound = 0
        _dlag_scroll = 0
        _dlag_moving_up = 0
    end

    if not (0x09 <= GAME_STATE and GAME_STATE <= 0x0B) then
        -- not in a door transition
        return
    end

    if not SEEKED and OLD_GAME_STATE == 0x08 then
        _dlag_seen_transition_start = true
        _dlag_seen_transition_end = false
        _dlag_elevator = 0
        _dlag_sound = 0
        _dlag_scroll = 0
        _dlag_moving_up = 0
    end

    if GAME_STATE == 0x0B then
        if DOOR_TRANSITION_FUNC == 0xE17D and OLD_DOOR_TRANSITION_FUNC == 0xE17D then
            _dlag_elevator = _dlag_elevator + 1
        elseif DOOR_TRANSITION_FUNC == 0xE29E and OLD_DOOR_TRANSITION_FUNC == 0xE29E then
            _dlag_sound = _dlag_sound + 1
        elseif DOOR_TRANSITION_FUNC == 0xE310 and OLD_DOOR_TRANSITION_FUNC == 0xE310 then
            _dlag_scroll = _dlag_scroll + 1
        elseif DOOR_TRANSITION_FUNC == 0xE353 and OLD_DOOR_TRANSITION_FUNC == 0xE353 then
            _dlag_moving_up = _dlag_moving_up + 1
        elseif DOOR_TRANSITION_FUNC == 0xE36E then
            _dlag_seen_transition_end = true
        end
    end

    local sum = _dlag_scroll + _dlag_sound + _dlag_elevator + _dlag_moving_up
    local lag_msg
    if _dlag_seen_transition_start then
        lag_msg = string.format("Door lag:%3d", sum)
    else
        lag_msg = string.format("Door lag >%2d", sum)
    end
    local sep = " ("
    if _dlag_elevator ~= 0 then
        lag_msg = lag_msg .. sep .. string.format("elevator =%2d", _dlag_elevator)
        sep = "; "
    end
    if _dlag_sound ~= 0 then
        lag_msg = lag_msg .. sep .. string.format("sound =%2d", _dlag_sound)
        sep = "; "
    end
    if _dlag_scroll ~= 0 then
        lag_msg = lag_msg .. sep .. string.format("scroll =%2d", _dlag_scroll)
        sep = "; "
    end
    if _dlag_moving_up ~= 0 then
        lag_msg = lag_msg .. sep .. string.format("fix up =%2d", _dlag_moving_up)
        sep = "; "
    end
    if sep == "; " then
        sep = ")"
    else
        sep = ""
    end
    if _dlag_seen_transition_end then
        lag_msg = lag_msg .. sep .. " (done)"
    else
        lag_msg = lag_msg .. sep .. " (in progress)"
    end
    gui.text(0, 0, lag_msg, HUD_COLOR_HI, "bottomleft")
end

local function draw_hud(samus_dx, samus_dy)
    local function draw_samus_x(x, y)
        local text = string.format("x:%7d.%05d", SAMUS_X >> 16, SAMUS_X & 0xFFFF)
        gui.text(x, y, text)
    end

    local function draw_samus_y(x, y)
        local text = string.format("y:%7d.%05d", SAMUS_Y >> 16, SAMUS_Y & 0xFFFF)
        gui.text(x, y, text)
    end

    local function draw_samus_speed_x(x, y)
        local format
        if SAMUS_DIRECTION_X == 4 then
            format = "vx: <%4d.%05d"
        elseif SAMUS_DIRECTION_X == 8 then
            format = "vx: >%4d.%05d"
        else
            format = "vx: ?%4d.%05d"
        end
        local text = string.format(format, SAMUS_SPEED_X // 0x10000, SAMUS_SPEED_X & 0xFFFF)
        local color
        if SAMUS_SPEED_X == 0 then
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_samus_speed_y(x, y)
        local format
        if SAMUS_DIRECTION_Y == 0 then
            format = "vy: -%4d.%05d"
        elseif SAMUS_DIRECTION_Y == 1 then
            format = "vy: ^%4d.%05d"
        elseif SAMUS_DIRECTION_Y == 2 then
            format = "vy: v%4d.%05d"
        else
            format = "vy: ?%4d.%05d"
        end
        local text = string.format(format, SAMUS_SPEED_Y // 0x10000, SAMUS_SPEED_Y & 0xFFFF)
        local color
        if SAMUS_SPEED_Y == 0 then
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_samus_dx(x, y)
        local text
        local color
        if OLD_SAMUS_X < SAMUS_X then
            text = string.format("dx: >%4d.%05d", samus_dx >> 16, samus_dx & 0xFFFF)
        elseif OLD_SAMUS_X > SAMUS_X then
            text = string.format("dx: <%4d.%05d", samus_dx >> 16, samus_dx & 0xFFFF)
        else
            text = string.format("dx:     0.00000")
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_samus_dy(x, y)
        local text
        local color
        if OLD_SAMUS_Y < SAMUS_Y then
            text = string.format("dy: v%4d.%05d", samus_dy >> 16, samus_dy & 0xFFFF)
        elseif OLD_SAMUS_Y > SAMUS_Y then
            text = string.format("dy: ^%4d.%05d", samus_dy >> 16, samus_dy & 0xFFFF)
        else
            text = string.format("dy:     0.00000")
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_samus_dash(x, y)
        local text = string.format("Dash:%4d.%05d", SAMUS_DASH >> 16, SAMUS_DASH & 0xFFFF)
        local color
        if SAMUS_DASH == 0 then
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_samus_pose(x, y)
        local pose_name = POSE_NAMES[SAMUS_POSE] or "???"
        local text = string.format("Pose: $%02X \"%s\"", SAMUS_POSE, pose_name)
        gui.text(x, y, text)
    end

    local function draw_beam_cooldown(x, y)
        local text = string.format("Weapon CD:%5d", WEAPON_COOLDOWN)
        local color
        if WEAPON_COOLDOWN == 0 then
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_charge_counter(x, y)
        local text = string.format("Charge:%8d", CHARGE_COUNTER)
        local color
        if CHARGE_COUNTER == 0 then
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_knockback_iframes(x, y)
        local text
        local color
        if KNOCKBACK ~= 0 then
            text = string.format("Knockback:%5d", KNOCKBACK)
            color = HUD_COLOR_HI
        else
            text = string.format("I. frames:%5d", IFRAMES)
            if IFRAMES == 0 then
                color = HUD_COLOR_LO
            end
        end
        gui.text(x, y, text, color)
    end

    local function draw_speed_level(x, y)
        local text = string.format("Speed lvl:%5d", SPEED_LEVEL)
        local color
        if SPEED_LEVEL == 0 then
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_spark_timer(x, y)
        local text = string.format("Spark CD:%6d", SPARK_TIMER)
        local color
        if SPARK_TIMER == 0 then
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    draw_samus_dx(HUD_COLUMN_0, HUD_ROW_0)
    draw_samus_dy(HUD_COLUMN_0, HUD_ROW_1)
    draw_samus_x(HUD_COLUMN_0, HUD_ROW_2)
    draw_samus_y(HUD_COLUMN_0, HUD_ROW_3)
    draw_samus_speed_x(HUD_COLUMN_0, HUD_ROW_4)
    draw_samus_speed_y(HUD_COLUMN_0, HUD_ROW_5)
    draw_samus_dash(HUD_COLUMN_0, HUD_ROW_6)

    draw_samus_pose(HUD_COLUMN_1, HUD_ROW_0)
    draw_beam_cooldown(HUD_COLUMN_1, HUD_ROW_1)
    draw_charge_counter(HUD_COLUMN_1, HUD_ROW_2)
    draw_knockback_iframes(HUD_COLUMN_1, HUD_ROW_3)
    draw_speed_level(HUD_COLUMN_1, HUD_ROW_4)
    draw_spark_timer(HUD_COLUMN_1, HUD_ROW_5)
end

event.onframestart(read_old_memory)
event.onexit(function()
    gui.clearGraphics()
    gui.cleartext()
end)
while true do
    emu.frameadvance()
    gui.clearGraphics()
    gui.cleartext()
    read_new_memory()

    do
        local new_frame_no = emu.framecount()
        SEEKED = new_frame_no ~= FRAME_NO + 1
        FRAME_NO = new_frame_no
    end

    if gameplay() then
        local samus_dx, samus_dy = samus_displacement()
        draw_samus_hitbox(samus_dx, samus_dy)
        draw_projectile_hitboxes()
        draw_powerbomb_hitbox()
        draw_enemy_hitboxes()
        draw_enemy_projectile_hitboxes()
        draw_hud(samus_dx, samus_dy)
        draw_door_lag()
    end
end
