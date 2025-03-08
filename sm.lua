-- Super Metroid TAS script
-- for bizhawk 2.9/2.10

-----------------------------
-- script settings

-- padding in pixels, to show tiles and entities outside the game display
-- this impacts performance. must be positive
local PADDING_X = 64
local PADDING_Y = 64

-- whether to center on samus's hitbox instead of aligning hitboxes on the game
-- screen.
--
-- nil = auto (only when samus is offscreen)
-- false = align hitboxes on game screen
-- true = center on samus' hitbox
local FORCE_CENTER_SAMUS = nil

-- Color of block BTS values (or nil to not print BTS)
--                0xAARRGGBB or nil
local BTS_COLOR = 0xFFAAAAFF

-- expected size of bizhawk's font in pixels
local GUI_FONT_SIZE = 16

-- hud settings      0xAARRGGBB
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
local HUD_ROW_8 = HUD_ROW_0 + (HUD_ROW_HEIGHT * 8)

-- tile hitbox colors  0xAARRGGBB
local TILE_COLOR_AIR = 0x00000000
local TILE_COLOR_DOOR = 0xFF8080FF
local TILE_COLOR_DOORCAP = 0xFFFF8000
local TILE_COLOR_ERROR = 0xFFFF0000
local TILE_COLOR_SLOPE = 0xA0FFFFFF
local TILE_COLOR_SOLID = 0xA0FFFFFF
local TILE_COLOR_SPECIAL = 0xFF0000FF
local TILE_COLOR_SPIKE = 0xC08080FF


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

local ITEM_VARIA = 1 << 0
local ITEM_SPRING = 1 << 1
local ITEM_MORPH = 1 << 2
local ITEM_SCREW = 1 << 3
local ITEM_GRAVITY = 1 << 5
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
local ENEMY_DROP_CHANCES = nil
local FX_POSITION = 0
local GAME_STATE = 0
local OLD_GAME_STATE = 0
local GRAPPLE_ANGLE = 0
local GRAPPLE_FUNC = 0
local GRAPPLE_SPEED = 0
local IFRAMES = 0
local INITIAL_Y_SPEED = {}
local INPUT = 0
local INPUT_HANDLER = 0
local ITEMS_EQUIPPED = 0
local KNOCKBACK = 0
local LAVA_POSITION = 0
local MUSIC_TIMER = 0
local POWERBOMB_RADIUS = 0
local POWERBOMB_TIMER = 0
local POWERBOMB_X = 0
local POWERBOMB_Y = 0
local RANDOM = 0
local ROOM_PTR = 0
local ROOM_WIDTH = 0
local SAMUS_DASH = 0
local SAMUS_DIRECTION_X = 0
local SAMUS_DIRECTION_Y = 0
local SAMUS_HEALTH = 0
local SAMUS_HEALTH_BOMB = 0
local SAMUS_HEALTH_MAX = 0
local SAMUS_HEALTH_RESERVE = 0
local SAMUS_HEALTH_RESERVE_MAX = 0
local SAMUS_MISSILES = 0
local SAMUS_MISSILES_MAX = 0
local SAMUS_POSE = 0
local SAMUS_POWERBOMBS = 0
local SAMUS_POWERBOMBS_MAX = 0
local SAMUS_RADIUS_X = 0
local SAMUS_RADIUS_Y = 0
local SAMUS_SPEED_CAP_Y = nil
local SAMUS_SPEED_X = 0
local SAMUS_SPEED_Y = 0
local OLD_SAMUS_SPEED_Y = 0
local SAMUS_SUPERS = 0
local SAMUS_SUPERS_MAX = 0
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
local PROJECTILES_VX = {}
local PROJECTILES_VY = {}
local BOMB_TIMERS = {}

local ENEMY_COUNT = 0
local ENEMY_DATA = {}
local ENEMY_PROJECTILE_ENEMIES = {}
local ENEMY_PROJECTILE_IDS = {}
local ENEMY_PROJECTILE_INSTRS = {}
local ENEMY_PROJECTILE_INSTR_TIMERS = {}
local ENEMY_PROJECTILE_XS = {}
local ENEMY_PROJECTILE_YS = {}
local ENEMY_PROJECTILE_RADIUSES = {}
local ENEMY_PROJECTILE_TIMERS = {}


-----------------------------
-- SM arcade
local ARCADE_POINTS = 0
local ARCADE_TIMER = 0

-----------------------------
-- other frame constants
local CENTER_SAMUS = nil
local OFFSET_X = 0
local OFFSET_Y = 0
local SAMUS_DX = 0
local SAMUS_DY = 0

local FRAME_NO = 0
local SEEKED = true


-----------------------------
-- actual code

-- like print but prints numbers in hex
local function print_hex(...)
    local args = { ... }
    for i = 1, #args do
        local n = args[i]
        if type(n) == "number" then
            if n < 0x100 then
                args[i] = string.format("%02Xh", n)
            elseif n < 0x10000 then
                args[i] = string.format("%04Xh", n)
            elseif n < 0x1000000 then
                args[i] = string.format("%06Xh", n)
            else
                args[i] = string.format("%Xh", n)
            end
        end
    end
    print(table.unpack(args))
end

local function client_transformPoint(x, y)
    return client.transformPoint(x - PADDING_X, y - PADDING_Y + 8)
end

local function u8_to_s8(n)
    return (n & 0x7F) - (n & 0x80)
end

-- fixes memory.read_bytes_as_array to make it read the correct data when
-- address+length overflows the bank.
local function read_bytes_as_array(address, length)
    local _rbaa = memory.read_bytes_as_array

    local bank_local = address & 0xFFFF
    if bank_local + length <= 0xFFFF then
        return _rbaa(address, length)
    end

    local a1_length = 0x10000 - bank_local
    local a1 = _rbaa(address, a1_length)

    local a2_length = length - a1_length
    local a2 = _rbaa(address & 0xFF0000, a2_length)

    for i = 1, #a2 do
        a1[#a1 + 1] = a2[i]
    end

    return a1
end

local function read_u16_le_array(res, address, length)
    local bytes = read_bytes_as_array(address, length * 2)
    for i = 1, length do
        res[i] = (bytes[2 * i] << 8) | bytes[2 * i - 1]
    end
end

local function read_s16_le_array(res, address, length)
    local bytes = read_bytes_as_array(address, length * 2)
    for i = 1, length do
        local n = (bytes[2 * i] << 8) | bytes[2 * i - 1]
        res[i] = (n & 0x7FFF) - (n & 0x8000)
    end
end

local function read_bi_u16_le(address)
    local u32 = memory.read_u32_le(address)
    return u32 & 0xFFFF, u32 >> 16
end

local function read_u32_le_inv(address)
    local u32 = memory.read_u32_le(address)
    return ((u32 & 0xFFFF) << 16) | (u32 >> 16)
end

local function table_u16_le(t, i)
    return (t[i]) | (t[i + 1] << 8)
end

local _ENEMY_HEADERS = {}
local function get_enemy_header(enemy_id)
    local header = _ENEMY_HEADERS[enemy_id]

    if not header then
        local bytes = read_bytes_as_array(0xA00000 | enemy_id, 0x40)
        local drop_chances = table_u16_le(bytes, 0x3B)
        header = {
            max_health = table_u16_le(bytes, 0x05),
            bank = bytes[0x0D],
            drop_chances = drop_chances ~= 0 and (drop_chances - 0xF1F3) or nil,
        }
        _ENEMY_HEADERS[enemy_id] = header
    end

    return header
end

local _ENEMY_SPRITEMAP_HITBOXES = {}
local function get_enemy_spritemap_hitboxes(ptr)
    local hitbox = _ENEMY_SPRITEMAP_HITBOXES[ptr]

    if not hitbox then
        hitbox = {}

        local n = memory.read_u8(ptr)
        local p = ptr + 2

        for _ = 1, n do
            hitbox[#hitbox + 1] = {
                left = memory.read_s16_le(p),
                top = memory.read_s16_le(p + 2),
                right = memory.read_s16_le(p + 4),
                bottom = memory.read_s16_le(p + 6),
            }
            p = p + 12
        end

        _ENEMY_SPRITEMAP_HITBOXES[ptr] = hitbox
    end

    return hitbox
end

local _ENEMY_SPRITEMAPS = {}
local function get_enemy_spritemap(bank, address)
    bank = bank << 16
    local ptr = bank | address

    local spritemap = _ENEMY_SPRITEMAPS[ptr]

    if not spritemap then
        spritemap = {}

        local n = memory.read_u8(ptr)
        local p = ptr + 2

        for _ = 1, n do
            local x = memory.read_s16_le(p)
            local y = memory.read_s16_le(p + 2)
            local hitbox_ptr = memory.read_u16_le(p + 6)

            if hitbox_ptr ~= 0 then
                local hitboxes = get_enemy_spritemap_hitboxes(bank | hitbox_ptr)
                spritemap[#spritemap + 1] = { x = x, y = y, hitboxes = hitboxes }
            end

            p = p + 8
        end

        _ENEMY_SPRITEMAPS[ptr] = spritemap
    end

    return spritemap
end

local function read_enemy_data(res)
    --local MAX_ENEMIES = 32
    local MAX_ENEMIES = ENEMY_COUNT
    local bytes = mainmemory.read_bytes_as_array(0x0F78, MAX_ENEMIES << 6)
    for i = 1, MAX_ENEMIES do
        local offset = (i - 1) * 0x40 + 1
        local id = table_u16_le(bytes, offset)
        local header = get_enemy_header(id)
        local props_ext = table_u16_le(bytes, offset + 16)
        local spritemap
        if props_ext & 0x04 ~= 0 then
            spritemap = get_enemy_spritemap(header.bank, table_u16_le(bytes, offset + 22))
        end
        res[i] = {
            header = header,
            id = id,
            x = table_u16_le(bytes, offset + 2),
            -- skip subx
            y = table_u16_le(bytes, offset + 6),
            -- skip suby
            radius_x = table_u16_le(bytes, offset + 10),
            radius_y = table_u16_le(bytes, offset + 12),
            props = table_u16_le(bytes, offset + 14),
            props_ext = props_ext,
            ai = table_u16_le(bytes, offset + 18),
            health = table_u16_le(bytes, offset + 20),
            spritemap = spritemap,
            ilist_ptr = table_u16_le(bytes, offset + 26),
            ilist_timer = table_u16_le(bytes, offset + 28),
            hurt_timer = table_u16_le(bytes, offset + 36),
            iframes = table_u16_le(bytes, offset + 40),
            ai1 = table_u16_le(bytes, offset + 48),
            ai2 = table_u16_le(bytes, offset + 50),
            ai3 = table_u16_le(bytes, offset + 52),
            ai4 = table_u16_le(bytes, offset + 54),
            ai5 = table_u16_le(bytes, offset + 56),
            ai6 = table_u16_le(bytes, offset + 58),
        }
    end
end

local function read_old_memory()
    OLD_DOOR_TRANSITION_FUNC = mainmemory.read_u16_le(0x099C)
    OLD_GAME_STATE = mainmemory.read_u8(0x0998)
    OLD_SAMUS_X = read_u32_le_inv(0x7E0AF6)
    OLD_SAMUS_Y = read_u32_le_inv(0x7E0AFA)
    OLD_SAMUS_SPEED_Y = (mainmemory.read_s16_le(0x0B2E) << 16) | mainmemory.read_u16_le(0x0B2C)
end

local function read_new_memory()
    CHARGE_COUNTER = mainmemory.read_u16_le(0x0CD0)
    DOOR_TRANSITION_FUNC = mainmemory.read_u16_le(0x099C)
    ENEMY_DROP_CHANCES = ENEMY_DROP_CHANCES or memory.read_bytes_as_array(0xB4F1F4, 708)
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
    INPUT_HANDLER = mainmemory.read_u16_le(0x0A60)
    ITEMS_EQUIPPED = mainmemory.read_u16_le(0x09A2)
    KNOCKBACK = mainmemory.read_u16_le(0x18AA)
    LAVA_POSITION = mainmemory.read_s32_le(0x1960)
    MUSIC_TIMER = mainmemory.read_u16_le(0x063F)
    POWERBOMB_RADIUS = mainmemory.read_u16_le(0x0CEA)
    POWERBOMB_TIMER = mainmemory.read_u16_le(0x0CEE)
    POWERBOMB_X, POWERBOMB_Y = read_bi_u16_le(0x7E0CE2)
    RANDOM = mainmemory.read_u16_le(0x05E5)
    ROOM_PTR = mainmemory.read_u16_le(0x079B)
    ROOM_WIDTH = mainmemory.read_u8(0x07A5)
    SAMUS_DIRECTION_X = mainmemory.read_u8(0x0A1E)
    SAMUS_DIRECTION_Y = mainmemory.read_u8(0x0B36)
    SAMUS_HEALTH, SAMUS_HEALTH_MAX = read_bi_u16_le(0x7E09C2)
    SAMUS_HEALTH_BOMB = mainmemory.read_u16_le(0x0E1A)
    SAMUS_HEALTH_RESERVE_MAX, SAMUS_HEALTH_RESERVE = read_bi_u16_le(0x7E09D4)
    SAMUS_DASH = read_u32_le_inv(0x7E0B42)
    SAMUS_MISSILES, SAMUS_MISSILES_MAX = read_bi_u16_le(0x7E09C6)
    SAMUS_POSE = mainmemory.read_u8(0x0A1C)
    SAMUS_POWERBOMBS, SAMUS_POWERBOMBS_MAX = read_bi_u16_le(0x7E09CE)
    SAMUS_RADIUS_X, SAMUS_RADIUS_Y = read_bi_u16_le(0x7E0AFE)
    SAMUS_SPEED_CAP_Y = SAMUS_SPEED_CAP_Y or memory.read_u16_le(0x909110)
    SAMUS_SPEED_X = read_u32_le_inv(0x7E0B46)
    SAMUS_SPEED_Y = (mainmemory.read_s16_le(0x0B2E) << 16) | mainmemory.read_u16_le(0x0B2C)
    SAMUS_SUPERS, SAMUS_SUPERS_MAX = read_bi_u16_le(0x7E08CA)
    SAMUS_X = read_u32_le_inv(0x7E0AF6)
    SAMUS_Y = read_u32_le_inv(0x7E0AFA)
    SAMUS_Y_ACCEL_AIR = SAMUS_Y_ACCEL_AIR or (memory.read_u16_le(0x909EA7) << 16) | memory.read_u16_le(0x909EA1)
    SAMUS_Y_ACCEL_LAVA = SAMUS_Y_ACCEL_LAVA or (memory.read_u16_le(0x909EAB) << 16) | memory.read_u16_le(0x909EA5)
    SAMUS_Y_ACCEL_WATER = SAMUS_Y_ACCEL_WATER or (memory.read_u16_le(0x909EA9) << 16) | memory.read_u16_le(0x909EA3)
    SCREEN_X = mainmemory.read_u16_le(0x0911)
    SCREEN_Y = mainmemory.read_u16_le(0x0915)
    SPEED_LEVEL = mainmemory.read_u16_le(0x0B3F)
    SPARK_TIMER = mainmemory.read_u16_le(0x0A68)
    WEAPON_COOLDOWN = mainmemory.read_u16_le(0x0CCC)

    read_u16_le_array(PROJECTILES_X, 0x7E0B64, 10)
    read_u16_le_array(PROJECTILES_Y, 0x7E0B78, 10)
    read_u16_le_array(PROJECTILES_RADIUS_X, 0x7E0BB4, 10)
    read_u16_le_array(PROJECTILES_RADIUS_Y, 0x7E0BC8, 10)
    read_s16_le_array(PROJECTILES_VX, 0x7E0BDC, 10)
    read_s16_le_array(PROJECTILES_VY, 0x7E0BF0, 10)
    read_u16_le_array(BOMB_TIMERS, 0x7E0C7C, 10)

    ENEMY_COUNT = mainmemory.read_u8(0x0E4E)
    read_enemy_data(ENEMY_DATA)

    read_u16_le_array(ENEMY_PROJECTILE_ENEMIES, 0x7EF3C8, 18)
    read_u16_le_array(ENEMY_PROJECTILE_IDS, 0x7E1997, 18)
    read_u16_le_array(ENEMY_PROJECTILE_INSTRS, 0x7E1B47, 18)
    read_u16_le_array(ENEMY_PROJECTILE_INSTR_TIMERS, 0x7E1B8F, 18)
    read_u16_le_array(ENEMY_PROJECTILE_XS, 0x7E1A4B, 18)
    read_u16_le_array(ENEMY_PROJECTILE_YS, 0x7E1A93, 18)
    ENEMY_PROJECTILE_RADIUSES = mainmemory.read_bytes_as_array(0x1BB3, 36)
    read_u16_le_array(ENEMY_PROJECTILE_TIMERS, 0x7E19DF, 18)

    ARCADE_POINTS = memory.read_u16_le(0x7FFFA0)
    ARCADE_TIMER = memory.read_u16_le(0x7FFFEA)

    CENTER_SAMUS = FORCE_CENTER_SAMUS
    if CENTER_SAMUS == nil then
        if GAME_STATE == 0x08 then
            local samus_x_px = SAMUS_X >> 16
            local samus_y_px = SAMUS_Y >> 16
            CENTER_SAMUS = (samus_x_px < SCREEN_X) or (SCREEN_X + 256 < samus_x_px) or
                (samus_y_px < SCREEN_Y) or (SCREEN_Y + 224 < samus_y_px)
        else
            -- don't center on room transitions
            CENTER_SAMUS = false
        end
    end

    if CENTER_SAMUS then
        OFFSET_X = (SAMUS_X >> 16) - 128 - PADDING_X
        OFFSET_Y = (SAMUS_Y >> 16) - 112 - PADDING_Y
    else
        OFFSET_X = SCREEN_X - PADDING_X
        OFFSET_Y = SCREEN_Y - PADDING_Y
    end
    SAMUS_DX = math.abs(SAMUS_X - OLD_SAMUS_X)
    SAMUS_DY = math.abs(SAMUS_Y - OLD_SAMUS_Y)
end

local function update_frame_no()
    local new_frame_no = emu.framecount()
    SEEKED = new_frame_no ~= FRAME_NO + 1
    FRAME_NO = new_frame_no
end

local function enable_draw()
    return (0x08 <= GAME_STATE and GAME_STATE <= 0x14) or -- gameplay, room transitions, pause menu and start of death animation
        GAME_STATE == 0x2A or                             -- demo
        GAME_STATE == 0x1B                                -- reserves auto refill
end

local function next_random(prev)
    -- ref: 80:8111
    local next = ((prev * 5) & 0xFFFF) + 0x100
    return (next + 0x11 + (next >> 16)) & 0xFFFF
end

-- 0=air, 1=water, 2=lava/acid
local function liquid_physics(bottom_y, fx_position, lava_position)
    if ITEMS_EQUIPPED & ITEM_GRAVITY ~= 0 then
        return 0
    end

    bottom_y = bottom_y and (bottom_y >> 16) or (SAMUS_Y >> 16) + SAMUS_RADIUS_Y
    fx_position = fx_position or FX_POSITION
    lava_position = lava_position or LAVA_POSITION

    if fx_position >= 0 and bottom_y > (fx_position >> 16) then
        return 1
    elseif lava_position >= 0 and bottom_y > (lava_position >> 16) then
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

-- returns average vertical speed during space jumps or wall jumps
-- initial = initial jump speed
-- held = number of frames where the jump button is held
-- released = number of frames where the jump button isn't pressed
local function avg_jump_speed(initial, held, released)
    return math.floor((2 * initial * held - 7168 * (held * held + released * released)) / 2 / (held + released))
end

local function max_avg_jump_speed(initial, released)
    local max_held = initial // 7168
    local imax = 0
    local max = 0
    for held = 1, max_held do
        local speed = avg_jump_speed(initial, held, released)
        if max < speed then
            imax = held
            max = speed
        end
    end
    return imax, max
end

local function draw_background()
    if CENTER_SAMUS then
        gui.drawRectangle(PADDING_X, PADDING_Y, 256, 224, 0xA0000000, 0xA0000000)
    end
end

local function draw_samus_hitbox()
    -- hitbox around samus
    local x = (SAMUS_X >> 16) - OFFSET_X
    local y = (SAMUS_Y >> 16) - OFFSET_Y
    local x1 = x - SAMUS_RADIUS_X
    local y1 = y - SAMUS_RADIUS_Y
    local x2 = x + SAMUS_RADIUS_X
    local y2 = y + SAMUS_RADIUS_Y
    local fg = 0xFFFFFFFF
    local bg = 0x35FFFFFF
    if INPUT_HANDLER ~= 0xE913 then
        fg = 0xFF803535
        bg = 0x35803535
    end
    gui.drawBox(x1, y1, x2, y2, fg, bg)

    -- walljump lines
    -- TODO some cases of walljump check are not shown
    local spinning_right = (SAMUS_POSE == 0x19) or (SAMUS_POSE == 0x1B) or (SAMUS_POSE == 0x81)
    local spinning_left = (SAMUS_POSE == 0x1A) or (SAMUS_POSE == 0x1C) or (SAMUS_POSE == 0x82)
    local pressing_right = (INPUT & BUTTON_RIGHT) ~= 0
    local pressing_left = (INPUT & BUTTON_LEFT) ~= 0
    if (spinning_left and pressing_left) or (spinning_right and pressing_left and pressing_right) then
        gui.drawLine(x2 + 8, y1, x2 + 8, y2)
    elseif spinning_right and pressing_right then
        gui.drawLine(x1 - 8, y1, x1 - 8, y2)
    end
end

local function draw_speed_percent()
    if GRAPPLE_FUNC == 0xC79D or INPUT_HANDLER ~= 0xE913 then
        -- swinging with grapple or game doesnt accept inputs
        return
    end

    local x = (SAMUS_X >> 16) - OFFSET_X - SAMUS_RADIUS_X
    local y = (SAMUS_Y >> 16) - OFFSET_Y - SAMUS_RADIUS_Y
    local textpos = client_transformPoint(x, y)
    local expected_dx = SAMUS_SPEED_X + SAMUS_DASH -- TODO use *$0B4A and *$0A6C
    local dx_ratio = SAMUS_DX / expected_dx * 100
    if dx_ratio == dx_ratio and dx_ratio ~= 100.0 then
        -- dx_ratio is not NaN
        local expected_dx_msg = string.format("dx:%3.0f%%", SAMUS_DX / expected_dx * 100)
        local color = SAMUS_DX < expected_dx and HUD_COLOR_HI or HUD_COLOR_LO
        gui.text(textpos.x, textpos.y - 2 * GUI_FONT_SIZE, expected_dx_msg, color)
    end
    local expected_dy = math.abs(OLD_SAMUS_SPEED_Y)
    local dy_ratio = SAMUS_DY / expected_dy * 100
    if dy_ratio == dy_ratio and dy_ratio ~= 100.0 then
        -- dy_ratio is not NaN
        local expected_dy_msg = string.format("dy:%3.0f%%", SAMUS_DY / expected_dy * 100)
        local color = SAMUS_DY < expected_dy and HUD_COLOR_HI or HUD_COLOR_LO
        gui.text(textpos.x, textpos.y - GUI_FONT_SIZE, expected_dy_msg, color)
    end
end

local function draw_projectile_hitboxes()
    for i = 1, 10 do
        if PROJECTILES_RADIUS_X[i] ~= 0 or PROJECTILES_RADIUS_Y[i] ~= 0 or BOMB_TIMERS[i] ~= 0 then
            local x = PROJECTILES_X[i] - OFFSET_X
            local y = PROJECTILES_Y[i] - OFFSET_Y
            local vx = PROJECTILES_VX[i]
            local vy = PROJECTILES_VY[i]

            local x1 = x - PROJECTILES_RADIUS_X[i]
            local y1 = y - PROJECTILES_RADIUS_Y[i]
            local x2 = x + PROJECTILES_RADIUS_X[i]
            local y2 = y + PROJECTILES_RADIUS_Y[i]
            gui.drawBox(x1, y1, x2, y2, 0xFFFFFFFF, 0x35FFFFFF)

            if vx ~= 0 or vy ~= 0 then
                local textpos = client_transformPoint(x1, y1)
                local text = string.format("v: %.2f;%.2f", vx / 0x100, vy / 0x100)
                gui.text(textpos.x, textpos.y - GUI_FONT_SIZE, text)
            elseif BOMB_TIMERS[i] ~= 0 then
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
    local x1 = POWERBOMB_X - radius_x - OFFSET_X
    local y1 = POWERBOMB_Y - radius_y - OFFSET_Y
    gui.drawRectangle(x1, y1, radius_x << 1, radius_y << 1, 0xFF00FFFF, 0x35F00FFF)
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
        return ((a_lo * y + a_hi * y_lo) & 0xFFFFFF) + a_hi * y_hi
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

local DROP_NAMES = {
    "sl nrgy",
    "bg nrgy",
    "missile",
    "nothing",
    "super",
    "powrbmb",
}
local function predict_enemy_drop(drop_chances_idx, random)
    -- ref: 86:F106

    local small_energy = ENEMY_DROP_CHANCES[drop_chances_idx]
    local big_energy = ENEMY_DROP_CHANCES[drop_chances_idx + 1]
    local missile = ENEMY_DROP_CHANCES[drop_chances_idx + 2]
    local nothing = ENEMY_DROP_CHANCES[drop_chances_idx + 3]
    local super = ENEMY_DROP_CHANCES[drop_chances_idx + 4]
    local powerbomb = ENEMY_DROP_CHANCES[drop_chances_idx + 5]

    random = random or RANDOM
    repeat
        random = next_random(random)
    until random & 0xFF ~= 0
    random = random & 0xFF

    local health_bomb = (SAMUS_HEALTH + SAMUS_HEALTH_RESERVE < 30) or
        (SAMUS_HEALTH + SAMUS_HEALTH_RESERVE < 50 and SAMUS_HEALTH_BOMB)

    local enabled_drops = 0
    local pooled_minors_chance = 0
    local pooled_majors_complement = 0xFF
    if health_bomb then
        enabled_drops = 0x03
        pooled_minors_chance = small_energy + big_energy
    else
        enabled_drops = 0x08
        pooled_minors_chance = nothing
        if SAMUS_HEALTH ~= SAMUS_HEALTH_MAX or SAMUS_HEALTH_RESERVE ~= SAMUS_HEALTH_RESERVE_MAX then
            enabled_drops = enabled_drops | 0x03
            pooled_minors_chance = pooled_minors_chance + small_energy + big_energy
        end
        if SAMUS_MISSILES ~= SAMUS_MISSILES_MAX then
            enabled_drops = enabled_drops | 0x04
            pooled_minors_chance = pooled_minors_chance + missile
        end
        if SAMUS_SUPERS ~= SAMUS_SUPERS_MAX then
            enabled_drops = enabled_drops | 0x10
            pooled_majors_complement = pooled_majors_complement - super
        end
        if SAMUS_POWERBOMBS ~= SAMUS_POWERBOMBS_MAX then
            enabled_drops = enabled_drops | 0x20
            pooled_majors_complement = pooled_majors_complement - powerbomb
        end
    end

    local drop_chance_acc = 0
    if pooled_minors_chance ~= 0 then
        for i = 0, 3 do
            if enabled_drops & (1 << i) ~= 0 then
                drop_chance_acc = drop_chance_acc +
                    (ENEMY_DROP_CHANCES[drop_chances_idx + i] * pooled_majors_complement) // pooled_minors_chance
                if drop_chance_acc >= random then
                    return i
                end
            end
        end
    end
    for i = 4, 5 do
        if enabled_drops & (1 << i) ~= 0 then
            drop_chance_acc = drop_chance_acc + ENEMY_DROP_CHANCES[drop_chances_idx + i]
            if drop_chance_acc >= random then
                return i
            end
        end
    end
    return 3
end

local function time_until_steam_hits(enemy)
    local instr = memory.read_u16_le(0xA60000 | enemy.ilist_ptr)
    if instr == 0xF11D then
        return enemy.ai4
    elseif instr == 0xF127 then
        return enemy.ai4
    elseif instr == 0xF135 then
        return enemy.ilist_timer
    else
        return 0
    end
end

local function draw_enemy_hitboxes()
    for i = ENEMY_COUNT, 1, -1 do
        local enemy = ENEMY_DATA[i]
        if enemy.id ~= 0 then
            local ex = enemy.x - OFFSET_X
            local ey = enemy.y - OFFSET_Y

            local x = enemy.x - enemy.radius_x - OFFSET_X
            local y = enemy.y - enemy.radius_y - OFFSET_Y

            gui.drawRectangle(x, y, enemy.radius_x << 1, enemy.radius_y << 1, 0xFFFF0000, 0x35FF0000)

            if enemy.id ~= 0xE2BF and enemy.spritemap and enemy.ai ~= 4 then
                -- enemy not frozen, draw extended spritemap
                -- TODO make it work with kraid (E2BF)
                for is = 1, #enemy.spritemap do
                    local spritemap = enemy.spritemap[is]
                    local sx = ex + spritemap.x
                    local sy = ey + spritemap.y
                    for ih = 1, #spritemap.hitboxes do
                        local hitbox = spritemap.hitboxes[ih]
                        gui.drawBox(
                            sx + hitbox.left,
                            sy + hitbox.top,
                            sx + hitbox.right,
                            sy + hitbox.bottom,
                            0xFFFF0000,
                            0x35FF0000)
                    end
                end
            end

            local textpos = client_transformPoint(x + 1, y + 1)
            local text
            if enemy.iframes ~= 0 then
                text = string.format("hp: %d/%d\ninv: %d",
                    enemy.health, enemy.header.max_health, enemy.iframes)
            else
                text = string.format("hp: %d/%d",
                    enemy.health, enemy.header.max_health)
            end

            if enemy.id == 0xE1FF then
                local n = time_until_steam_hits(enemy)
                text = string.format("%s\nhits in %df", text, n)
            end

            gui.text(textpos.x, textpos.y, text)
        end
    end
end

local _ILIST_STARTS = {
    -- addresses where instruction lists start. must be sorted
    0xECAB,
    0xECC5,
    0xED4B,
    0xED69,
    0xED8D,
    0xEDA3,
    0xEDB9,
    0xEDDD,
    0xEDEB,
    0xEDFF,
}
local _ILIST_NOK_STARTS = {
    -- instruction lists between _ILIST_STARTS[1] and
    -- _ILIST_STARTS[#_ILIST_STARTS] that aren't ok to
    -- run because they would loop infinitely
    [0xED8D] = true,
    [0xEDA3] = true,
    [0xEDB9] = true,
    [0xEDDD] = true,
    [0xEDEB] = true,
}
local _INSTRUCTION_ARG_COUNTS = {
    -- number of arguments eaten by instructions
    [0x81C6] = 1,
    [0x81D5] = 1,
    [0xECE3] = 1,
    [0xED17] = 1,
}
local _INSTRUCTION_RNG_CALLS = {
    -- number of RNG calls instructions do
    [0xECE3] = 1,
    [0xED17] = 1,
}
local _ILISTS = {}
local _ILIST_MAX_LENGTH = 76 -- in bytes
-- run an instruction list until the "delete" (0x8154) instruction is reached
-- ptr = projectile instruction pointer
-- projectile_timer = projectile timer (not the instruction timer)
-- returns X,Y
-- X = number of frames until instruction list ends (minus current instruction timer value)
-- Y = number of RNG calls triggered in the process
local function run_instruction_list(ptr, projectile_timer)
    -- ref: 86:8125

    local function get_instr_list_begin_ptr(current_ptr)
        for i = #_ILIST_STARTS, 1, -1 do
            local begin_ptr = _ILIST_STARTS[i]
            if begin_ptr <= current_ptr then
                return begin_ptr
            end
        end
        return nil
    end

    local function get_instr_list(begin_ptr)
        local ilist = _ILISTS[begin_ptr]
        if not ilist then
            ilist = {}

            -- all instruction lists span fewer than 76 bytes
            read_u16_le_array(ilist, 0x860000 | begin_ptr, _ILIST_MAX_LENGTH >> 1)

            _ILISTS[begin_ptr] = ilist
        end
        return ilist
    end

    local begin_ptr = get_instr_list_begin_ptr(ptr)
    if not begin_ptr or ptr - begin_ptr >= _ILIST_MAX_LENGTH or _ILIST_NOK_STARTS[begin_ptr] then
        -- unknown instruction list, or it's infinite
        return nil, nil
    end

    local ilist = get_instr_list(begin_ptr)
    local local_ptr = ((ptr - begin_ptr) >> 1) + 1
    local frames = 0
    local rng_calls = 0
    local exe_counter = 0
    repeat
        exe_counter = exe_counter + 1
        if exe_counter >= 100 then
            print(string.format("Instuction %04X started at %04X is looping infinitely.", begin_ptr, ptr))
            return nil, nil
        end

        local instruction = ilist[local_ptr]

        if instruction & 0x8000 == 0 then
            -- spritemap timer & pointer
            frames = frames + instruction
            local_ptr = local_ptr + 2
        elseif instruction == 0x81D5 then
            -- projectile timer init
            projectile_timer = ilist[local_ptr + 1]
            local_ptr = local_ptr + 2
        elseif instruction == 0x81C6 then
            -- projectile timer nil test
            projectile_timer = projectile_timer - 1
            if projectile_timer == 0 then
                local_ptr = local_ptr + 2
            else
                local jump_ptr = ilist[local_ptr + 1]
                local_ptr = ((jump_ptr - begin_ptr) >> 1) + 1
            end
        else
            -- pointer to code
            local_ptr = local_ptr + (_INSTRUCTION_ARG_COUNTS[instruction] or 0) + 1
            rng_calls = rng_calls + (_INSTRUCTION_RNG_CALLS[instruction] or 0)
        end
    until instruction == 0x8154

    return frames, rng_calls
end

local function draw_enemy_projectile_hitboxes()
    for i = 18, 1, -1 do
        local id = ENEMY_PROJECTILE_IDS[i]
        if id ~= 0 then
            local radius_i = i << 1
            local radius_x = ENEMY_PROJECTILE_RADIUSES[radius_i - 1]
            local radius_y = ENEMY_PROJECTILE_RADIUSES[radius_i]
            local x1 = ENEMY_PROJECTILE_XS[i] - radius_x - OFFSET_X
            local y1 = ENEMY_PROJECTILE_YS[i] - radius_y - OFFSET_Y
            gui.drawRectangle(x1, y1, radius_x << 1, radius_y << 1, 0xFFFF8000, 0x35FF8000)

            if id == 0xF345 then
                -- death animation
                local instruction = ENEMY_PROJECTILE_INSTRS[i]
                local timer = ENEMY_PROJECTILE_TIMERS[i]
                local cooldown, rng_calls = run_instruction_list(instruction, timer)
                if cooldown and rng_calls then
                    -- death animation that hasn't become a pickup yet
                    cooldown = cooldown + ENEMY_PROJECTILE_INSTR_TIMERS[i]

                    -- TODO take into account other RNG interference

                    local enemy_id = ENEMY_PROJECTILE_ENEMIES[i]
                    local enemy_header = get_enemy_header(enemy_id)
                    local drop_chances = enemy_header.drop_chances
                    if drop_chances then
                        local random = RANDOM
                        for _ = 1, cooldown + rng_calls do
                            random = next_random(random)
                        end
                        local drop = DROP_NAMES[predict_enemy_drop(drop_chances, random) + 1]

                        local textpos = client_transformPoint(x1 + 1, y1 + 1)
                        gui.text(textpos.x, textpos.y,
                            string.format("%s in %df\nrng: %04X", drop, cooldown, random))
                    end
                end
            end
        end
    end
end

local function draw_phantoon_helpers()
    if ROOM_PTR ~= 0xCD13 or ENEMY_COUNT < 3 then
        -- not in phantoon's room, or phantoon's dead
        return
    end

    -- ref: A7:****
    -- pick first pattern: D596
    -- pick next pattern: D076

    local ai = ENEMY_DATA[1].ai
    --local ilist_ptr = ENEMY_DATA[1].ilist_ptr
    local ilist_timer = ENEMY_DATA[1].ilist_timer
    local hurt_timer = ENEMY_DATA[1].hurt_timer
    --local p_speed_lo = ENEMY_DATA[1].ai2
    --local p_speed_hi = ENEMY_DATA[1].ai3
    local fn_timer = ENEMY_DATA[1].ai5
    local fn_ptr = ENEMY_DATA[1].ai6
    local eye_open_timer = ENEMY_DATA[2].ai1
    local swooping_triggered = ENEMY_DATA[3].ai1
    local round_damage = ENEMY_DATA[3].ai2

    local is_tangible = (ENEMY_DATA[1].props & 0x0400) == 0

    local function draw_super_window(x, y)
        if is_tangible and ai & 0x0002 == 0 then
            gui.text(x, y, "CAN SUPER", HUD_COLOR_HI)
            return
        end
    end

    local function draw_stun_timer(x, y)
        local color
        local text
        if ai & 0x0002 ~= 0 then
            text = string.format("Stun Timer:%4d", hurt_timer - 8)
        else
            text = "Stun Timer: ---"
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_tangible(x, y)
        if eye_open_timer > 0 then
            gui.text(x, y, string.format("Eye CD:%8d", eye_open_timer))
            return
        end
        if not is_tangible then
            -- TODO show invincibility CD
            if swooping_triggered then
                gui.text(x, y, "Eye CD: opening")
            else
                gui.text(x, y, "Eye CD:       0", HUD_COLOR_HI)
            end
            return
        end
        gui.text(x, y, string.format("Close CD:%6d", fn_timer))
    end

    local function draw_round_damage(x, y)
        local color
        if not is_tangible then
            color = HUD_COLOR_LO
        end
        local text = string.format("Round dmg:%5d", round_damage)
        gui.text(x, y, text, color)
    end

    local function draw_fn_ptr(x, y)
        local text = string.format("Fn Timer: %04Xh", fn_ptr)
        gui.text(x, y, text)
    end

    draw_tangible(HUD_COLUMN_0, HUD_ROW_7)
    draw_round_damage(HUD_COLUMN_0, HUD_ROW_8)

    draw_stun_timer(HUD_COLUMN_1, HUD_ROW_7)
    draw_fn_ptr(HUD_COLUMN_1, HUD_ROW_8)
end

local _RIDLEY_STATES = {
    [0xA354] = "Start, speed reset",
    [0xA35B] = "Start, 1st frame",
    [0xA377] = "Start, wait",
    [0xA389] = "Start, eyes appear",
    [0xA3DF] = "Start, body appears",
    [0xA455] = "Start, roar",
    [0xA478] = "Start, raise acid",
    [0xB2F3] = "Start, misc setup",
    [0xB321] = "Change AI",
    [0xB3EC] = "Move to center, 1st frame",
    [0xB3F8] = "Move to center",
    [0xB5C4] = "Pre-pogo, 1st frame",
    [0xB5E5] = "Pre-pogo, spinjump check, 1st frame",
    [0xB613] = "Pre-pogo, spinjump check",
    [0xB6A7] = "Pogo, fly and turn to position",
    [0xB6DD] = "Pogo, extend tail",
    [0xB70E] = "Pogo, going down",
    [0xB7B9] = "Pogo, going up",
    [0xBAB7] = "Lunge/pwrbmb check/death check",
    [0xBBC4] = "Hold Samus, move to target",
    [0xBBF1] = "Drop Samus",
    [0xBC2E] = "Drop Samus, cry",
    [0xBD4E] = "Evade powerbomb",
    [0xC551] = "Death, move to spot",
    [0xC538] = "Death, move to 80;148",
    [0xC588] = "Death, explosion",
    [0xC5A8] = "Death, disable ridley",
    [0xC5C8] = "Death, wait 20 frames",
    [0xC5DA] = "Death, spawn drops after wait",
    [0xC600] = "Dead",
}
local function draw_ridley_helpers()
    if ROOM_PTR ~= 0xB32E or ENEMY_COUNT < 1 then
        -- not in ridley's room, or ridley's dead
        return
    end

    -- ref: A6:****

    local fn_ptr = ENEMY_DATA[1].ai1

    local function draw_fn_ptr(x, y)
        local state = _RIDLEY_STATES[fn_ptr] or "???"
        local text = string.format("State: %04Xh \"%s\"", fn_ptr, state)
        gui.text(x, y, text)
    end

    draw_fn_ptr(HUD_COLUMN_2, HUD_ROW_5)
end

-- Build and cache slope polygons
-- polygon from slope S is stored at SLOPES[4 * S + 2 * flip_y + flip_x + 1]
local SLOPES = {}
local function build_slopes()
    local slope_data = memory.read_bytes_as_array(0x948B2B, 0x20 << 4)

    local function reduce_polygon(ps)
        local i = 3
        while i <= #ps do
            local left_x = ps[i - 2][1]
            local left_y = ps[i - 2][2]
            local mid_x = ps[i - 1][1]
            local mid_y = ps[i - 1][2]
            local right_x = ps[i][1]
            local right_y = ps[i][2]

            local off_line = (right_x - left_x) * mid_y - (right_x - mid_x) * left_y - (mid_x - left_x) * right_y

            if off_line == 0 then
                table.remove(ps, i - 1)
            else
                i = i + 1
            end
        end
        return ps
    end

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

        return reduce_polygon(points)
    end

    for i = 0, 0x1F do
        SLOPES[#SLOPES + 1] = build_slope(i, false, false)
        SLOPES[#SLOPES + 1] = build_slope(i, true, false)
        SLOPES[#SLOPES + 1] = build_slope(i, false, true)
        SLOPES[#SLOPES + 1] = build_slope(i, true, true)
    end
end

local _BLOCK_SYMBOLS = {
    false, -- 0x00: air
    false, -- 0x01: slope
    "!",   -- 0x02: spike air
    " ",   -- 0x03: special air
    "X",   -- 0x04: shootable air
    "_",   -- 0x05: horizontal extension
    "?",   -- 0x06: unused air
    "O",   -- 0x07: bombable air
    false, -- 0x08: solid block
    " ",   -- 0x09: door block
    "!",   -- 0x0A: spike block
    " ",   -- 0x0B: special block
    "x",   -- 0x0C: shootable block
    "|",   -- 0x0D: vertical extension
    "g",   -- 0x0E: grapple block
    "o",   -- 0x0F: bombable block
}
local SIMPLE_OUTLINES = {
    TILE_COLOR_AIR,     -- 0x00: air
    false,
    TILE_COLOR_SPIKE,   -- 0x02: spike air
    TILE_COLOR_SPECIAL, -- 0x03: special air
    TILE_COLOR_SPECIAL, -- 0x04: shootable air
    false,
    TILE_COLOR_AIR,     -- 0x06: unused air
    TILE_COLOR_SPECIAL, -- 0x07: bombable air
    TILE_COLOR_SOLID,   -- 0x08: solid block
    TILE_COLOR_DOOR,    -- 0x09: door block
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
        local bts = (line_bts and u8_to_s8(line_bts[line_index])) or
            memory.read_s8(0x7F6402 + global_index)
        if bts == 0 then
            -- Infinite recursion, game would probably freeze if this block reacts to anything
            return TILE_COLOR_ERROR
        end
        local extension_index = global_index + bts
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
        local bts = (line_bts and u8_to_s8(line_bts[line_index])) or
            memory.read_s8(0x7F6402 + global_index)
        if bts == 0 then
            -- Infinite recursion, game would probably freeze if this block reacts to anything
            return TILE_COLOR_ERROR
        end
        local extension_index = global_index + bts * ROOM_WIDTH
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
        (0x12 <= GAME_STATE and GAME_STATE <= 0x14) or
        GAME_STATE == 0x1B
    if not valid_level_data then
        return
    end

    if #SLOPES == 0 then
        build_slopes()
    end

    local drawPolygon = gui.drawPolygon
    local drawRectangle = gui.drawRectangle
    local type = type

    local line_length = 17 + (PADDING_X >> 3)

    for y = 0, 14 + (PADDING_Y >> 3) do
        local pos_y = (y << 4) - (OFFSET_Y % 16)

        local draw_line = function(offset_x, length)
            -- block index offset for the current line
            -- ref: 94:95F5
            -- the game computes the block index using 8-bit multiplication, thus
            -- the "& 0xFF". ROOM_WIDTH is already read as a u8.
            local index_offset = ((OFFSET_Y // 16 + y) & 0xFF) * ROOM_WIDTH + (offset_x & 0xFFF)

            -- data accesses wrap accross bank boundaries
            local line_data = read_bytes_as_array(0x7F0000 | ((0x0002 + (index_offset << 1)) & 0xFFFF), length << 1)
            local line_bts = read_bytes_as_array(0x7F0000 | ((0x6402 + index_offset) & 0xFFFF), length)

            for x = 0, length - 1 do
                local pos_x = (x + offset_x) * 16 - OFFSET_X
                local line_index = x + 1
                local block_type = line_data[line_index << 1] >> 4
                local block = SIMPLE_OUTLINES[block_type + 1] or
                    COMPLEX_OUTLINES[block_type](index_offset + x, line_index, line_bts, 224)
                if type(block) == "number" then
                    if block ~= 0 then
                        drawRectangle(pos_x, pos_y, 15, 15, block)
                    end
                else -- type(block) == "table"
                    drawPolygon(block, pos_x, pos_y, TILE_COLOR_SLOPE)
                end

                if BTS_COLOR then
                    local symbol = _BLOCK_SYMBOLS[block_type + 1]
                    if symbol then
                        local textpos = client_transformPoint(pos_x + 1, pos_y + 1)
                        local text = string.format("%s%02X", symbol, line_bts[line_index])
                        gui.text(textpos.x, textpos.y, text, BTS_COLOR)
                    end
                end
            end
        end

        -- if OFFSET_X is negative, part of the line is out of bounds and the
        -- whole line is not stored in contiguous memory addresses.
        if OFFSET_X >= 0 then
            draw_line(OFFSET_X // 16, line_length)
        else
            local oob_length = math.ceil(-OFFSET_X / 16)
            draw_line(OFFSET_X // 16, oob_length)
            draw_line(0, line_length - oob_length)
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

    if SAMUS_DIRECTION_Y == 1 then
        -- TODO make it work when going upwards
        return
    end

    -- TODO read unmorph_length from memory (for PAL, where unmorph is 4 frames)
    -- TODO pixel offset from level data
    -- TODO handle horizontal movement: 90:8EA9

    -- Up press lag: samus falls at full speed for one frame
    local y = SAMUS_Y + math.abs(SAMUS_SPEED_Y)

    -- crouching/unmorphing pose radius (ref: 91:B629)
    y = y + 0x100000

    --local unmorph_length = 4 -- for PAL
    local unmorph_length = 6
    local lp = liquid_physics()
    local accel_y = SAMUS_Y_ACCEL_AIR
    if lp == 1 then
        unmorph_length = 12
        accel_y = SAMUS_Y_ACCEL_WATER
    elseif lp == 2 then
        unmorph_length = 12
        accel_y = SAMUS_Y_ACCEL_LAVA
    end
    local in_air = lp == 0
    local fx_position = FX_POSITION
    local lava_position = LAVA_POSITION
    local speed_y = (SAMUS_SPEED_Y < 0) and 0x10000 or (SAMUS_SPEED_Y + accel_y)
    while unmorph_length > 0 do
        -- TODO 90:A16C  94:86FE
        y = y + speed_y
        if SAMUS_SPEED_Y >= 0 and speed_y >> 16 ~= SAMUS_SPEED_CAP_Y then
            speed_y = speed_y + accel_y
        end
        unmorph_length = unmorph_length - 1
        if in_air then
            -- TODO update fx & lava position accross time
            lp = liquid_physics(y, fx_position, lava_position)
            if lp == 1 then
                in_air = false
                unmorph_length = unmorph_length << 1
                accel_y = SAMUS_Y_ACCEL_WATER
            elseif lp == 2 then
                in_air = false
                unmorph_length = unmorph_length << 1
                accel_y = SAMUS_Y_ACCEL_LAVA
            end
        end
    end

    local y_hi = (y >> 16)

    local y_line = y_hi - OFFSET_Y
    gui.drawLine(0, y_line, 256 + 2 * PADDING_X, y_line, 0xFFFFFFFF)
    local textpos = client_transformPoint(0, y_line - 1)
    gui.text(0, textpos.y - GUI_FONT_SIZE, string.format("unmorph at: %d", y_hi))
end

local _dlag_seen_transition_start = false
local _dlag_seen_transition_end = false
local _dlag_sound = 0
local _dlag_fade_out = -39 -- fade out should last 40 frames
local _dlag_scroll = 0
local function draw_door_lag()
    if SEEKED then
        _dlag_seen_transition_start = false
        _dlag_seen_transition_end = false
        _dlag_sound = 0
        _dlag_fade_out = -39
        _dlag_scroll = 0
    end

    if not (0x09 <= GAME_STATE and GAME_STATE <= 0x0B) then
        -- not in a door transition
        return
    end

    if not SEEKED and OLD_GAME_STATE == 0x08 then
        _dlag_seen_transition_start = true
        _dlag_seen_transition_end = false
        _dlag_sound = 0
        _dlag_fade_out = -39
        _dlag_scroll = 0
    end

    if DOOR_TRANSITION_FUNC == OLD_DOOR_TRANSITION_FUNC then
        if DOOR_TRANSITION_FUNC == 0xE29E then
            _dlag_sound = _dlag_sound + 1
        elseif DOOR_TRANSITION_FUNC == 0xE2DB then
            _dlag_fade_out = _dlag_fade_out + 1
        elseif DOOR_TRANSITION_FUNC == 0xE310 or DOOR_TRANSITION_FUNC == 0xE353 then
            _dlag_scroll = _dlag_scroll + 1
        end
    end
    if DOOR_TRANSITION_FUNC == 0xE36E then
        _dlag_seen_transition_end = true
    end

    local op = _dlag_seen_transition_start and "=" or ">"
    local done = _dlag_seen_transition_end and "(done)" or "(in progress)"

    local breakdown = {}
    if _dlag_sound ~= 0 then
        breakdown[#breakdown + 1] = string.format("sound%s%d", op, _dlag_sound)
    end
    if _dlag_fade_out > 0 then
        breakdown[#breakdown + 1] = string.format("process%s%d", op, _dlag_fade_out)
    end
    if _dlag_scroll ~= 0 then
        breakdown[#breakdown + 1] = string.format("scroll%s%d", op, _dlag_scroll)
    end
    if _dlag_seen_transition_end and _dlag_fade_out < 0 then
        breakdown[#breakdown + 1] = string.format("fade out%s%d", op, _dlag_fade_out)
    end

    local lag_msg
    if #breakdown == 0 then
        lag_msg = string.format("Door lag%s 0 %s", op, done)
    else
        local sum = _dlag_scroll + _dlag_sound
        if _dlag_fade_out > 0 or _dlag_seen_transition_end then
            sum = sum + _dlag_fade_out
        end
        local brkdwn = table.concat(breakdown, ", ")
        lag_msg = string.format("Door lag%s%2d (%s) %s", op, sum, brkdwn, done)
    end

    gui.text(0, 0, lag_msg, HUD_COLOR_HI, "bottomleft")
end

local function mark_door_transitions_as_lag()
    -- make it work even when read_new_memory hasn't been called
    local game_state = mainmemory.read_u8(0x0998)
    if OLD_GAME_STATE == 0x0B or game_state == 0x0B then
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

    local function draw_screen_x(x, y)
        local text = string.format("sx:%12d", SCREEN_X)
        gui.text(x, y, text)
    end

    local function draw_screen_y(x, y)
        local text = string.format("sy:%12d", SCREEN_Y)
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
        local text = string.format("Pose: %02Xh \"%s\"", SAMUS_POSE, pose_name)
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
        local text = string.format("Speed lvl:%04Xh", SPEED_LEVEL)
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
        local color
        if jump_speed then
            text = string.format("Jump:%4d.%05d", jump_speed >> 16, jump_speed & 0xFFFF)
        else
            text = "Jump:   -.-----"
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_fanfare_timer(x, y)
        local fanfare_timer = 0
        if SAMUS_POSE == 0x00 or SAMUS_POSE == 0x9B then
            fanfare_timer = MUSIC_TIMER
        end
        local text = string.format("Fanfare:%7d", fanfare_timer)
        local color
        if fanfare_timer == 0 then
            color = HUD_COLOR_LO
        end
        gui.text(x, y, text, color)
    end

    local function draw_game_state(x, y)
        local text = string.format("Game state: %02Xh", GAME_STATE)
        gui.text(x, y, text)
    end

    local function draw_arcade_points(x, y)
        local text = string.format("Points:%8d", ARCADE_POINTS)
        gui.text(x, y, text)
    end

    local function draw_arcade_timer(x, y)
        local text = string.format("Timer:%6d:%02d", ARCADE_TIMER >> 8, ARCADE_TIMER & 0xFF)
        gui.text(x, y, text)
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
    draw_game_state(HUD_COLUMN_1, HUD_ROW_6)

    draw_jump_speed(HUD_COLUMN_2, HUD_ROW_1)
    draw_fanfare_timer(HUD_COLUMN_2, HUD_ROW_2)
    draw_screen_x(HUD_COLUMN_2, HUD_ROW_3)
    draw_screen_y(HUD_COLUMN_2, HUD_ROW_4)
    --draw_arcade_points(HUD_COLUMN_2, HUD_ROW_5)
    --draw_arcade_timer(HUD_COLUMN_2, HUD_ROW_6)
end

event.onframestart(read_old_memory)
event.onexit(function()
    gui.clearGraphics()
    gui.cleartext()
    client.SetGameExtraPadding(0, 0, 0, 0)
end)
client.SetGameExtraPadding(PADDING_X, PADDING_Y - 8, PADDING_X, PADDING_Y)
update_frame_no()
mark_door_transitions_as_lag()
while true do
    read_new_memory()

    if enable_draw() then
        draw_background()
        draw_blocks()
        draw_samus_hitbox()
        draw_speed_percent()
        draw_slopekiller_line()
        draw_projectile_hitboxes()
        draw_powerbomb_hitbox()
        draw_grapple_throw_speed()
        draw_enemy_hitboxes()
        draw_enemy_projectile_hitboxes()
        draw_phantoon_helpers()
        draw_ridley_helpers()
        draw_hud()
        draw_door_lag()
    end

    repeat
        -- don't run when seeking

        -- double call to isseeking to avoid false positives
        -- when loading a savestate in tastudio.
        local was_seeking = client.isseeking() or client.isturbo()

        emu.frameadvance()
        gui.clearGraphics()
        gui.cleartext()

        update_frame_no()
        mark_door_transitions_as_lag()
    until not (was_seeking and (client.isseeking() or client.isturbo()))
end
