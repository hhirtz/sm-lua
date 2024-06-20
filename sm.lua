-----------------------------
-- Super Metroid TAS script for Bizhawk 2.9
--
-- Features:
--  - Hitbox around samus, enemies, projectiles and blocks, with extra padding
--  - RAM watches
--  - Armpump and slope speed interference detection
--  - Grapple swing speed prediction
--  - Door lag
--  - mark door transitions as lag in tastudio
--  - slopekiller prediction
--  - jump speed prediction
--
-- How to use:
--
-- TODO usage notes...
--
-- Dev notes:
--  - lua perf: https://www.lua.org/gems/sample.pdf

-----------------------------
-- script settings

-- padding in pixels, to show tiles and entities outside the game display
-- this impacts performance
local PADDING_X = 0
local PADDING_Y = 0

-- size of the font in pixels
local GUI_FONT_SIZE = 16

-- hud settings
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

-- tile hitbox colors
local TILE_COLOR_DOORCAP = 0xFFFF8000
local TILE_COLOR_ERROR = 0xFFFF0000
local TILE_COLOR_SLOPE = 0xA0FFFFFF
local TILE_COLOR_SOLID = 0xA0FFFFFF
local TILE_COLOR_SPECIAL = 0xFF0000FF


-----------------------------
-- databases
local POSE_NAMES = {
    -- ref: https://patrickjohnston.org/ASM/Lists/Super%20Metroid/Pose%20definitions.asm
    -- cat Pose\ definitions.asm | grep " ; " | sed 's/.* ; /[0x/' | sed 's/: /] = "/' | sed 's/.$/",/' | sort | grep -v '"Unused",' | sed 's/ \+- \+/, /g'
    -- TODO this is a hash table because we use this notation, make it an array?
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

local ITEM_VARIA = 1 << 1
local ITEM_SPRING = 1 << 2
local ITEM_MORPH = 1 << 3
local ITEM_SCREW = 1 << 4
local ITEM_GRAVITY = 1 << 6
local ITEM_HIJUMP = 1 << 8
local ITEM_SPACE = 1 << 9
local ITEM_BOMBS = 1 << 12
local ITEM_SPEED = 1 << 13
local ITEM_GRAPPLE = 1 << 14
local ITEM_XRAY = 1 << 15


-----------------------------
-- memory values
local CHARGE_COUNTER = 0
local DOOR_TRANSITION_FUNC = 0
local OLD_DOOR_TRANSITION_FUNC = 0
local FX_POSITION = 0
local GAME_STATE = 0
local OLD_GAME_STATE = 0
local GRAPPLE_ANGLE = 0
local GRAPPLE_FUNC = 0
local GRAPPLE_SPEED = 0
local IFRAMES = 0
local INITIAL_Y_SPEED = {}
local INPUT = 0
local ITEMS_EQUIPPED = 0
local KNOCKBACK = 0
local LAVA_POSITION = 0
local LIQUID_PHYSICS = 0
local POWERBOMB_RADIUS = 0
local POWERBOMB_TIMER = 0
local POWERBOMB_X = 0
local POWERBOMB_Y = 0
local ROOM_WIDTH = 0
local SAMUS_DASH = 0
local SAMUS_DIRECTION_X = 0
local SAMUS_DIRECTION_Y = 0
local SAMUS_POSE = 0
local SAMUS_RADIUS_X = 0
local SAMUS_RADIUS_Y = 0
local SAMUS_SPEED_CAP_Y = nil
local SAMUS_SPEED_X = 0
local SAMUS_SPEED_Y = 0
local OLD_SAMUS_SPEED_Y = 0
local SAMUS_X = 0
local OLD_SAMUS_X = 0
local SAMUS_Y = 0
local OLD_SAMUS_Y = 0
local SAMUS_Y_ACCEL_AIR = nil
local SAMUS_Y_ACCEL_LAVA = nil
local SAMUS_Y_ACCEL_WATER = nil
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
local OFFSET_X = 0
local OFFSET_Y = 0
local SAMUS_DX = 0
local SAMUS_DY = 0

local FRAME_NO = 0
local SEEKED = true


-----------------------------
-- actual code

local function client_transformPoint(x, y)
    return client.transformPoint(x - PADDING_X, y - PADDING_Y)
end

local function u8_to_s8(n)
    return (n & 0x7F) - (n & 0x80)
end

local function read_enemy_data(res)
    --local MAX_ENEMIES = 32
    local MAX_ENEMIES = ENEMY_COUNT
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
            max_health = memory.read_u16_le(0xA00004 + id),
            iframes = bytes[offset + 40]|(bytes[offset + 41] << 8),
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

local function read_u16_le_array(res, address, length)
    local bytes = memory.read_bytes_as_array(address, length * 2)
    for i = 1, length do
        res[i] = (bytes[2 * i] << 8) | bytes[2 * i - 1]
    end
end

local function read_new_memory()
    CHARGE_COUNTER = mainmemory.read_u16_le(0x0CD0)
    DOOR_TRANSITION_FUNC = mainmemory.read_u16_le(0x099C)
    FX_POSITION = mainmemory.read_s32_le(0x195C)
    GAME_STATE = mainmemory.read_u8(0x0998)
    GRAPPLE_ANGLE = mainmemory.read_u16_le(0x0CFA)
    GRAPPLE_FUNC = mainmemory.read_u16_le(0x0D32)
    GRAPPLE_SPEED = mainmemory.read_s16_le(0x0D26)
    IFRAMES = mainmemory.read_u16_le(0x18A8)
    if #INITIAL_Y_SPEED == 0 then
        read_u16_le_array(INITIAL_Y_SPEED, 0x909EB9, 36)
    end
    INPUT = mainmemory.read_u16_le(0x008B)
    ITEMS_EQUIPPED = mainmemory.read_u16_le(0x09A2)
    KNOCKBACK = mainmemory.read_u16_le(0x18AA)
    LAVA_POSITION = mainmemory.read_s32_le(0x1962)
    LIQUID_PHYSICS = mainmemory.read_u16_le(0x0AD2)
    POWERBOMB_RADIUS = mainmemory.read_u16_le(0x0CEA)
    POWERBOMB_TIMER = mainmemory.read_u16_le(0x0CEE)
    POWERBOMB_X = mainmemory.read_u16_le(0x0CE2)
    POWERBOMB_Y = mainmemory.read_u16_le(0x0CE4)
    ROOM_WIDTH = mainmemory.read_u16_le(0x07A5)
    SAMUS_DIRECTION_X = mainmemory.read_u8(0x0A1E)
    SAMUS_DIRECTION_Y = mainmemory.read_u8(0x0B36)
    SAMUS_DASH = (mainmemory.read_s16_le(0x0B42) << 16) | mainmemory.read_u16_le(0x0B44)
    SAMUS_POSE = mainmemory.read_u8(0x0A1C)
    SAMUS_RADIUS_X = mainmemory.read_u8(0x0AFE)
    SAMUS_RADIUS_Y = mainmemory.read_u8(0x0B00)
    SAMUS_SPEED_CAP_Y = SAMUS_SPEED_CAP_Y or memory.read_u16_le(0x909110)
    SAMUS_SPEED_X = (mainmemory.read_u16_le(0x0B46) << 16) | mainmemory.read_u16_le(0x0B48)
    SAMUS_SPEED_Y = (mainmemory.read_s16_le(0x0B2E) << 16) | mainmemory.read_u16_le(0x0B2C)
    SAMUS_X = (mainmemory.read_u16_le(0x0AF6) << 16) | mainmemory.read_u16_le(0x0AF8)
    SAMUS_Y = (mainmemory.read_u16_le(0x0AFA) << 16) | mainmemory.read_u16_le(0x0AFC)
    SAMUS_Y_ACCEL_AIR = SAMUS_Y_ACCEL_AIR or (memory.read_u16_le(0x909EA7) << 16) | memory.read_u16_le(0x909EA1)
    SAMUS_Y_ACCEL_LAVA = SAMUS_Y_ACCEL_LAVA or (memory.read_u16_le(0x909EAB) << 16) | memory.read_u16_le(0x909EA5)
    SAMUS_Y_ACCEL_WATER = SAMUS_Y_ACCEL_WATER or (memory.read_u16_le(0x909EA9) << 16) | memory.read_u16_le(0x909EA3)
    SCREEN_X = mainmemory.read_u16_le(0x0911)
    SCREEN_Y = mainmemory.read_u16_le(0x0915)
    SPEED_LEVEL = mainmemory.read_u8(0x0B3F)
    SPARK_TIMER = mainmemory.read_u16_le(0x0A68)
    WEAPON_COOLDOWN = mainmemory.read_u16_le(0x0CCC)

    read_u16_le_array(PROJECTILES_X, 0x7E0B64, 10)
    read_u16_le_array(PROJECTILES_Y, 0x7E0B78, 10)
    read_u16_le_array(PROJECTILES_RADIUS_X, 0x7E0BB4, 10)
    read_u16_le_array(PROJECTILES_RADIUS_Y, 0x7E0BC8, 10)
    read_u16_le_array(BOMB_TIMERS, 0x7E0C7C, 10)

    ENEMY_COUNT = mainmemory.read_u8(0x0E4E)
    read_enemy_data(ENEMY_DATA)

    read_u16_le_array(ENEMY_PROJECTILE_IDS, 0x7E1997, 18)
    read_u16_le_array(ENEMY_PROJECTILE_XS, 0x7E1A4B, 18)
    read_u16_le_array(ENEMY_PROJECTILE_YS, 0x7E1A93, 18)
    ENEMY_PROJECTILE_RADIUSES = mainmemory.read_bytes_as_array(0x1BB3, 36)

    OFFSET_X = SCREEN_X - PADDING_X
    OFFSET_Y = SCREEN_Y - PADDING_Y
    SAMUS_DX = math.abs(SAMUS_X - OLD_SAMUS_X)
    SAMUS_DY = math.abs(SAMUS_Y - OLD_SAMUS_Y)
end

local function gameplay()
    -- TODO return false during pause
    return (0x08 <= GAME_STATE and GAME_STATE <= 0x12) or
        GAME_STATE == 0x2A
end

-- 0=air, 1=water, 2=lava/acid
local function liquid_physics(bottom_y)
    bottom_y = bottom_y or (SAMUS_Y >> 16) + SAMUS_RADIUS_Y
    if ITEMS_EQUIPPED & ITEM_GRAVITY then
        return 0
    end
    if FX_POSITION >= 0 and bottom_y < (FX_POSITION >> 16) then
        return 1
    elseif LAVA_POSITION >= 0 and bottom_y < (LAVA_POSITION >> 16) then
        return 2
    else
        return 0
    end
end

local function predict_jump_speed()
    if 0x12 < SAMUS_POSE then
        return nil
    end

    local speed_ptr = 1 + liquid_physics()
    if ITEMS_EQUIPPED & ITEM_HIJUMP ~= 0 then
        speed_ptr = speed_ptr + 6
    end
    local subspeed_ptr = speed_ptr + 3

    local speed = INITIAL_Y_SPEED[speed_ptr]
    local subspeed = INITIAL_Y_SPEED[subspeed_ptr]

    if ITEMS_EQUIPPED & ITEM_SPEED ~= 0 then
        speed = speed + (SAMUS_DASH >> 17)
        subspeed = (subspeed + (SAMUS_DASH & 0xFFFF)) & 0xFFFF
    end

    return (speed << 16) | subspeed
end

local function draw_samus_hitbox()
    -- hitbox around samus
    local x = (SAMUS_X >> 16) - OFFSET_X
    local y = (SAMUS_Y >> 16) - OFFSET_Y
    local x1 = x - SAMUS_RADIUS_X
    local y1 = y - SAMUS_RADIUS_Y
    local x2 = x + SAMUS_RADIUS_X
    local y2 = y + SAMUS_RADIUS_Y
    gui.drawBox(x1, y1, x2, y2, 0xFFFFFFFF, 0x35FFFFFF)

    -- walljump lines
    -- TODO some cases of walljump check are not shown
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

local function draw_speed_percent()
    if GRAPPLE_FUNC == 0xC79D then
        -- swinging with grapple
        return
    end

    local x = (SAMUS_X >> 16) - OFFSET_X - SAMUS_RADIUS_X
    local y = (SAMUS_Y >> 16) - OFFSET_Y - SAMUS_RADIUS_Y
    local textpos = client_transformPoint(x, y)
    local expected_dx = SAMUS_SPEED_X + SAMUS_DASH -- TODO use *$0B4A and *$0A6C
    local dx_ratio = SAMUS_DX / expected_dx * 100
    if dx_ratio == dx_ratio then
        -- dx_ratio is not NaN
        local expected_dx_msg = string.format("dx:%3.0f%%", SAMUS_DX / expected_dx * 100)
        gui.text(textpos.x, textpos.y - 2 * GUI_FONT_SIZE, expected_dx_msg)
    end
    local expected_dy = math.abs(OLD_SAMUS_SPEED_Y)
    local dy_ratio = SAMUS_DY / expected_dy * 100
    if dy_ratio == dy_ratio then
        -- dy_ratio is not NaN
        local expected_dy_msg = string.format("dy:%3.0f%%", SAMUS_DY / expected_dy * 100)
        gui.text(textpos.x, textpos.y - GUI_FONT_SIZE, expected_dy_msg)
    end
end

local function draw_projectile_hitboxes()
    for i = 1, 10 do
        if PROJECTILES_RADIUS_X[i] ~= 0 or PROJECTILES_RADIUS_Y[i] ~= 0 or BOMB_TIMERS[i] ~= 0 then
            local x = PROJECTILES_X[i] - OFFSET_X
            local y = PROJECTILES_Y[i] - OFFSET_Y
            local x1 = x - PROJECTILES_RADIUS_X[i]
            local y1 = y - PROJECTILES_RADIUS_Y[i]
            local x2 = x + PROJECTILES_RADIUS_X[i]
            local y2 = y + PROJECTILES_RADIUS_Y[i]
            gui.drawBox(x1, y1, x2, y2, 0xFFFFFFFF, 0x35FFFFFF)

            if BOMB_TIMERS[i] ~= 0 then
                local textpos = client_transformPoint(x1, y1)
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
    local x = POWERBOMB_X - radius_x - OFFSET_X
    local y = POWERBOMB_Y - radius_y - OFFSET_Y
    gui.drawRectangle(x, y, radius_x << 1, radius_y << 1, 0xFF00FFFF, 0x35F00FFF)
end

local function draw_grapple_throw_speed()
    if GRAPPLE_FUNC ~= 0xC79D then
        -- not swinging
        return
    end

    local function u16_mul(a, y)
        -- ref: 80:82D6
        local a_lo = a & 0x00FF
        local a_hi = a & 0xFF00
        local y_lo = y & 0x00FF
        local y_hi = y & 0xFF00
        return ((a_lo * y_lo + a_hi * y_lo + a_lo * y_hi) & 0xFFFFFF) + a_hi * y_hi
    end

    -- ref: 9B:CA65

    local rot_speed = math.abs(GRAPPLE_SPEED) << 1

    local sin_angle = memory.read_s16_le(0xA0B443 + ((GRAPPLE_ANGLE >> 8) << 1))
    local speed_y = u16_mul(rot_speed, math.abs(sin_angle))
    local going_up = (sin_angle >= 0) ~= (GRAPPLE_SPEED >= 0)

    local h12 = ((GRAPPLE_ANGLE >> 8) - 0x40 + 3 * (rot_speed >> 9)) & 0xFF
    local sin_h12 = memory.read_s16_le(0xA0B443 + (h12 << 1))
    local speed_x = u16_mul(rot_speed, math.abs(sin_h12))
    local going_left = SAMUS_DIRECTION_X == 4

    local textpos = client_transformPoint(
        (SAMUS_X >> 16) - OFFSET_X - SAMUS_RADIUS_X,
        (SAMUS_Y >> 16) - OFFSET_Y - SAMUS_RADIUS_Y)

    local horiz_dir = (going_left and "<") or ">"
    local vert_dir = (going_up and "^") or "v"
    local text = string.format("%s%3d.%05d\n%s%3d.%05d",
        horiz_dir, speed_x >> 16, speed_x & 0xFFFF,
        vert_dir, speed_y >> 16, speed_y & 0xFFFF)
    gui.text(textpos.x, textpos.y - 2 * GUI_FONT_SIZE, text)
end

local function draw_enemy_hitboxes()
    for i = ENEMY_COUNT, 1, -1 do
        local enemy = ENEMY_DATA[i]
        if enemy.id ~= 0 then
            local x = enemy.x - enemy.radius_x - OFFSET_X
            local y = enemy.y - enemy.radius_y - OFFSET_Y

            -- TODO extended sprite map
            gui.drawRectangle(x, y, enemy.radius_x << 1, enemy.radius_y << 1, 0xFFFF0000, 0x35FF0000)
            local textpos = client_transformPoint(x + 1, y + 1)
            local text
            if enemy.iframes ~= 0 then
                text = string.format("hp: %d/%d\ninv %d",
                    enemy.health, enemy.max_health, enemy.iframes)
            else
                text = string.format("hp: %d/%d", enemy.health, enemy.max_health)
            end
            gui.text(textpos.x, textpos.y, text)
        end
    end
end

local function draw_enemy_projectile_hitboxes()
    for i = 18, 1, -1 do
        if ENEMY_PROJECTILE_IDS[i] ~= 0 then
            local radius_i = i << 1
            local radius_x = ENEMY_PROJECTILE_RADIUSES[radius_i - 1]
            local radius_y = ENEMY_PROJECTILE_RADIUSES[radius_i]
            local x = ENEMY_PROJECTILE_XS[i] - radius_x - OFFSET_X
            local y = ENEMY_PROJECTILE_YS[i] - radius_y - OFFSET_Y
            gui.drawRectangle(x, y, radius_x << 1, radius_y << 1, 0xFFFF8000, 0x35FF8000)
        end
    end
end

-- Build and cache slope polygons
-- polygon from slope S is stored at SLOPES[4 * S + 2 * flip_y + flip_x + 1]
local SLOPES = {}
local function build_slopes()
    local slope_data = memory.read_bytes_as_array(0x948B2B, 0x20 << 4)

    local ys = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    local function build_slope(slope_index, flip_x, flip_y)
        for x = 0, 15 do
            local i = x
            if flip_x then
                i = 15 - x
            end
            local y = slope_data[(slope_index << 4) + i + 1]
            if flip_y and y < 16 then
                y = 15 - y
            end
            ys[x + 1] = y
        end

        local x_min
        for x = 1, 16 do
            if ys[x] < 16 then
                x_min = x - 1
                break
            end
        end
        if x_min == nil then
            return {}
        end

        local x_max
        for x = 16, 1, -1 do
            if ys[x] < 16 then
                x_max = x - 1
                break
            end
        end

        local y_base = 15
        if flip_y then
            y_base = 0
        end

        local points = {
            { x_max, y_base },
            { x_min, y_base },
            { x_min, ys[x_min + 1] },
        }

        for x = x_min + 1, x_max do
            if ys[x] < 0x10 and ys[x + 1] < 0x10 then
                points[#points + 1] = { x, ys[x] }
                if ys[x] ~= ys[x + 1] then
                    points[#points + 1] = { x, ys[x + 1] }
                end
            end
        end

        return points
    end

    for i = 0, 0x1F do
        SLOPES[#SLOPES + 1] = build_slope(i, false, false)
        SLOPES[#SLOPES + 1] = build_slope(i, true, false)
        SLOPES[#SLOPES + 1] = build_slope(i, false, true)
        SLOPES[#SLOPES + 1] = build_slope(i, true, true)
    end
end

local SIMPLE_OUTLINES = {
    0x00000000,         -- 0x00: air
    false,
    0x00000000,         -- 0x02: spike air
    TILE_COLOR_SPECIAL, -- 0x03: special air
    0x00000000,         -- 0x04: shootable air
    false,
    0x00000000,         -- 0x06: unused air
    0x00000000,         -- 0x07: bombable air
    TILE_COLOR_SOLID,   -- 0x08: solid block
    TILE_COLOR_SPECIAL, -- 0x09: door block
    TILE_COLOR_SPECIAL, -- 0x0A: spike block
    TILE_COLOR_SPECIAL, -- 0x0B: special block
    false,
    false,
    TILE_COLOR_SPECIAL, -- 0x0E: grapple block
    TILE_COLOR_SPECIAL, -- 0x0F: bombable block
}
local COMPLEX_OUTLINES
COMPLEX_OUTLINES = {
    -- slope
    [0x01] = function(global_index, line_index, line_bts, _)
        local bts = (line_bts and line_bts[line_index]) or
            memory.read_u8(0x7F6402 + global_index)
        local slope_index = ((bts & 0x1F) << 2) | ((bts & 0xC0) >> 6)
        return SLOPES[slope_index + 1]
    end,

    -- horizontal extension
    [0x05] = function(global_index, line_index, line_bts, stack_limit)
        if stack_limit == 0 then
            return TILE_COLOR_ERROR
        end
        local bts = (line_bts and line_bts[line_index]) or
            memory.read_u8(0x7F6402 + global_index)
        if bts == 0 then
            -- Infinite recursion, game would probably freeze if this block reacts to anything
            return TILE_COLOR_ERROR
        end
        local extension_index = global_index + u8_to_s8(bts)
        local block_type = memory.read_u8(0x7F0003 + (extension_index << 1)) >> 4
        return SIMPLE_OUTLINES[block_type + 1] or
            COMPLEX_OUTLINES[block_type](extension_index, 0, nil, stack_limit - 1)
    end,

    -- shootable block
    [0x0C] = function(global_index, line_index, line_bts, _)
        local bts = (line_bts and line_bts[line_index]) or
            memory.read_u8(0x7F6402 + global_index)
        if 0x40 <= bts and bts <= 0x43 then
            return TILE_COLOR_DOORCAP
        else
            return TILE_COLOR_SPECIAL
        end
    end,

    -- vertical extension
    [0x0D] = function(global_index, line_index, line_bts, stack_limit)
        if stack_limit == 0 then
            return TILE_COLOR_ERROR
        end
        local bts = (line_bts and line_bts[line_index]) or
            memory.read_u8(0x7F6402 + global_index)
        if bts == 0 then
            -- Infinite recursion, game would probably freeze if this block reacts to anything
            return TILE_COLOR_ERROR
        end
        local extension_index = global_index + u8_to_s8(bts) * ROOM_WIDTH
        local block_type = memory.read_u8(0x7F0003 + (extension_index << 1)) >> 4
        return SIMPLE_OUTLINES[block_type + 1] or
            COMPLEX_OUTLINES[block_type](extension_index, 0, nil, stack_limit - 1)
    end,
}

local function draw_blocks()
    local valid_level_data =
        (0x08 <= GAME_STATE and GAME_STATE < 0x0B) or
        (GAME_STATE == 0x0B and (DOOR_TRANSITION_FUNC < 0xE2F7 or 0xE36E < DOOR_TRANSITION_FUNC)) or
        (GAME_STATE == 0x0C) or
        (GAME_STATE == 0x11) or
        (GAME_STATE == 0x12)
    if not valid_level_data then
        return
    end

    if #SLOPES == 0 then
        build_slopes()
    end

    local read_bytes_as_array = memory.read_bytes_as_array
    local drawPolygon = gui.drawPolygon
    local drawRectangle = gui.drawRectangle
    local type = type

    local line_length = 17 + (PADDING_X >> 3)
    local block_x_offset = OFFSET_X & 0x0F
    local block_y_offset = OFFSET_Y & 0x0F
    local screen_offset = (OFFSET_Y // 16) * ROOM_WIDTH + (OFFSET_X // 16)
    for y = 0, 14 + (PADDING_Y >> 3) do
        local block_y = (y << 4) - block_y_offset
        local index_offset = screen_offset + y * ROOM_WIDTH
        local line_data = read_bytes_as_array(0x7F0002 + (index_offset << 1), line_length << 1)
        local line_bts = read_bytes_as_array(0x7F6402 + index_offset, line_length)
        for x = 0, 16 + (PADDING_X >> 3) do
            local block_x = (x << 4) - block_x_offset
            local line_index = x + 1
            local block_type = line_data[line_index << 1] >> 4
            local block = SIMPLE_OUTLINES[block_type + 1] or
                COMPLEX_OUTLINES[block_type](index_offset + x, line_index, line_bts, 224)
            if type(block) == "number" then
                if block ~= 0 then
                    drawRectangle(block_x, block_y, 15, 15, block)
                end
            else -- type(block) == "table"
                drawPolygon(block, block_x, block_y, TILE_COLOR_SLOPE)
            end
        end
    end
end

local function draw_slopekiller_line()
    if SAMUS_POSE ~= 0x31 and
        SAMUS_POSE ~= 0x32 and
        (SAMUS_POSE < 0x7D or 0x80 < SAMUS_POSE)
    then
        -- not morphed or on ground
        return
    end

    -- TODO mixed air/water physics
    -- TODO pixel offset from level data
    -- TODO handle horizontal movement: 90:8EA9

    -- Up press lag: samus falls at full speed for one frame
    local y = SAMUS_Y + math.abs(SAMUS_SPEED_Y)

    local unmorph_length = 6 -- TODO don't hardcode it
    local accel_y = SAMUS_Y_ACCEL_AIR
    if LIQUID_PHYSICS == 1 then
        unmorph_length = 12
        accel_y = SAMUS_Y_ACCEL_WATER
    elseif LIQUID_PHYSICS == 2 then
        unmorph_length = 12
        accel_y = SAMUS_Y_ACCEL_LAVA
    end
    local speed_y = (SAMUS_SPEED_Y < 0) and 0x10000 or SAMUS_SPEED_Y
    while unmorph_length > 0 do
        -- TODO 90:A16C  94:86FE
        y = y + speed_y
        if SAMUS_SPEED_Y >= 0 and speed_y >> 16 ~= SAMUS_SPEED_CAP_Y then
            speed_y = speed_y + accel_y
        end
        unmorph_length = unmorph_length - 1
    end
    y = y + 0x100000 -- crouching pose radius (ref: 91:B629)

    local y_hi = (y >> 16)

    local y_line = y_hi - OFFSET_Y
    gui.drawLine(0, y_line, 256, y_line, 0xFFFFFFFF)
    local textpos = client_transformPoint(0, y_line - 1)
    gui.text(0, textpos.y - GUI_FONT_SIZE, string.format("%d", y_hi))
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
        lag_msg = string.format("Door lag=%2d", sum)
    else
        lag_msg = string.format("Door lag>%2d", sum)
    end
    local breakdown = {}
    if _dlag_elevator ~= 0 then
        breakdown[#breakdown + 1] = string.format("elevator=%d", _dlag_elevator)
    end
    if _dlag_sound ~= 0 then
        breakdown[#breakdown + 1] = string.format("sound=%d", _dlag_sound)
    end
    if _dlag_scroll ~= 0 then
        breakdown[#breakdown + 1] = string.format("scroll=%d", _dlag_scroll)
    end
    if _dlag_moving_up ~= 0 then
        breakdown[#breakdown + 1] = string.format("moving_up=%d", _dlag_moving_up)
    end
    if #breakdown ~= 0 then
        lag_msg = lag_msg .. " (" .. table.concat(breakdown, ", ") .. ")"
    end
    if _dlag_seen_transition_end then
        lag_msg = lag_msg .. " (done)"
    else
        lag_msg = lag_msg .. " (in progress)"
    end
    gui.text(0, 0, lag_msg, HUD_COLOR_HI, "bottomleft")
end

local function mark_door_transitions_as_lag()
    -- TODO this is called before GAME_STATE is initialized
    if OLD_GAME_STATE == 0x0B or GAME_STATE == 0x0B then
        tastudio.setlag(FRAME_NO, true)
    end
end

local function draw_hud()
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
        if SAMUS_DIRECTION_X == 0 then
            format = "vx: |%4d.%05d"
        elseif SAMUS_DIRECTION_X == 4 then
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
            text = string.format("dx: >%4d.%05d", SAMUS_DX >> 16, SAMUS_DX & 0xFFFF)
        elseif OLD_SAMUS_X > SAMUS_X then
            text = string.format("dx: <%4d.%05d", SAMUS_DX >> 16, SAMUS_DX & 0xFFFF)
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
            text = string.format("dy: v%4d.%05d", SAMUS_DY >> 16, SAMUS_DY & 0xFFFF)
        elseif OLD_SAMUS_Y > SAMUS_Y then
            text = string.format("dy: ^%4d.%05d", SAMUS_DY >> 16, SAMUS_DY & 0xFFFF)
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

    local function draw_jump_speed(x, y)
        local jump_speed = predict_jump_speed()
        local text
        if jump_speed then
            text = string.format("Jump:%4d.%05d", jump_speed >> 16, jump_speed & 0xFFFF)
        else
            text = "Jump:   -.-----"
        end
        local color
        if not jump_speed then
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

    draw_jump_speed(HUD_COLUMN_2, HUD_ROW_1)
end

event.onframestart(read_old_memory)
event.onexit(function()
    gui.clearGraphics()
    gui.cleartext()
    client.SetGameExtraPadding(0, 0, 0, 0)
end)
client.SetGameExtraPadding(PADDING_X, PADDING_Y, PADDING_X, PADDING_Y)
while true do
    read_new_memory()

    do
        local new_frame_no = emu.framecount()
        SEEKED = new_frame_no ~= FRAME_NO + 1
        FRAME_NO = new_frame_no
    end

    if gameplay() then
        draw_blocks()
        draw_samus_hitbox()
        draw_speed_percent()
        draw_slopekiller_line()
        draw_projectile_hitboxes()
        draw_powerbomb_hitbox()
        draw_grapple_throw_speed()
        draw_enemy_hitboxes()
        draw_enemy_projectile_hitboxes()
        draw_hud()
        draw_door_lag()
    end

    repeat
        -- don't run when seeking

        mark_door_transitions_as_lag()

        -- double call to isseeking to avoid false positives
        -- when loading a savestate in tastudio.
        local was_seeking = client.isseeking()

        emu.frameadvance()
        gui.clearGraphics()
        gui.cleartext()
    until not (was_seeking and client.isseeking())
end
