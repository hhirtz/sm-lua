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
    [0x00] = "Facing forward",
    [0x01] = "Facing right, normal",
    [0x02] = "Facing left, normal",
    [0x03] = "Facing right, aiming up",
    [0x04] = "Facing left, aiming up",
    [0x05] = "Facing right, aiming upright",
    [0x06] = "Facing left, aiming upleft",
    [0x07] = "Facing right, aiming downright",
    [0x08] = "Facing left, aiming downleft",
    [0x09] = "Moving right, not aiming",
    [0x0A] = "Moving left, not aiming",
    [0x0B] = "Moving right, gun extended forward (not aiming)",
    [0x0C] = "Moving left, gun extended forward (not aiming)",
    [0x0D] = "Moving right, aiming straight up (unused?)",
    [0x0E] = "Moving left, aiming straight up (unused?)",
    [0x0F] = "Moving right, aiming upright",
    [0x10] = "Moving left, aiming upleft",
    [0x11] = "Moving right, aiming downright",
    [0x12] = "Moving left, aiming downleft",
    [0x13] = "Normal jump facing right, gun extended, not aiming or moving",
    [0x14] = "Normal jump facing left, gun extended, not aiming or moving",
    [0x15] = "Normal jump facing right, aiming up",
    [0x16] = "Normal jump facing left, aiming up",
    [0x17] = "Normal jump facing right, aiming down",
    [0x18] = "Normal jump facing left, aiming down",
    [0x19] = "Spin Jump right",
    [0x1A] = "Spin Jump left",
    [0x1B] = "Space jump right",
    [0x1C] = "Space jump left",
    [0x1D] = "Facing right as morphball, no springball",
    [0x1E] = "Moving right as a morphball on ground without springball",
    [0x1F] = "Moving left as a morphball on ground without springball",
    [0x20] = "Spinjump right. Unused?",
    [0x21] = "Spinjump right. Unused?",
    [0x22] = "Spinjump right. Unused?",
    [0x23] = "Spinjump right. Unused?",
    [0x24] = "Spinjump right. Unused?",
    [0x25] = "Starting standing right, turning left",
    [0x26] = "Starting standing left, turning right",
    [0x27] = "Crouching, facing right",
    [0x28] = "Crouching, facing left",
    [0x29] = "Falling facing right, normal pose",
    [0x2A] = "Falling facing left, normal pose",
    [0x2B] = "Falling facing right, aiming up",
    [0x2C] = "Falling facing left, aiming up",
    [0x2D] = "Falling facing right, aiming down",
    [0x2E] = "Falling facing left, aiming down",
    [0x2F] = "Starting with normal jump facing right, turning left",
    [0x30] = "Starting with normal jump facing left, turning right",
    [0x31] = "Midair morphball facing right without springball",
    [0x32] = "Midair morphball facing left without springball",
    [0x33] = "Spinjump right. Unused?",
    [0x34] = "Spinjump right. Unused?",
    [0x35] = "Crouch transition, facing right",
    [0x36] = "Crouch transition, facing left",
    [0x37] = "Morphing into ball, facing right. Ground and mid-air",
    [0x38] = "Morphing into ball, facing left. Ground and mid-air",
    [0x39] = "Midair morphing into ball, facing right? May be unused",
    [0x3A] = "Midair morphing into ball, facing left? May be unused",
    [0x3B] = "Standing from crouching, facing right",
    [0x3C] = "Standing from crouching, facing left",
    [0x3D] = "Demorph while facing right. Mid-air and on ground",
    [0x3E] = "Demorph while facing left. Mid-air and on ground",
    [0x3F] = "Some transition with morphball, facing right. Maybe unused",
    [0x40] = "Some transition with morphball, facing left. Maybe unused",
    [0x41] = "Staying still with morphball, facing left, no springball",
    [0x42] = "Spinjump right. Unused?",
    [0x43] = "Starting from crouching right, turning left",
    [0x44] = "Starting from crouching left, turning right",
    [0x45] = "Running, facing right, shooting left. Unused? (Fast moonwalk)",
    [0x46] = "Running, facing left, shooting right. Unused? (Fast moonwalk)",
    [0x47] = "Standing, facing right. Unused?",
    [0x48] = "Standing, facing left. Unused?",
    [0x49] = "Moonwalk, facing left",
    [0x4A] = "Moonwalk, facing right",
    [0x4B] = "Normal jump transition from ground(standing or crouching), facing right",
    [0x4C] = "Normal jump transition from ground(standing or crouching), facing left",
    [0x4D] = "Normal jump facing right, gun not extended, not aiming, not moving",
    [0x4E] = "Normal jump facing left, gun not extended, not aiming, not moving",
    [0x4F] = "Hurt roll back, moving right/facing left",
    [0x50] = "Hurt roll back, moving left/facing right",
    [0x51] = "Normal jump facing right, moving forward (gun extended)",
    [0x52] = "Normal jump facing left, moving forward (gun extended)",
    [0x53] = "Hurt, facing right",
    [0x54] = "Hurt, facing left",
    [0x55] = "Normal jump transition from ground, facing right and aiming up",
    [0x56] = "Normal jump transition from ground, facing left and aiming up",
    [0x57] = "Normal jump transition from ground, facing right and aiming upright",
    [0x58] = "Normal jump transition from ground, facing left and aiming upleft",
    [0x59] = "Normal jump transition from ground, facing right and aiming downright",
    [0x5A] = "Normal jump transition from ground, facing left and aiming downleft",
    [0x5B] = "Something for grapple (wall jump?), probably unused",
    [0x5C] = "Something for grapple (wall jump?), probably unused",
    [0x5D] = "Broken grapple? Facing clockwise, maybe unused",
    [0x5E] = "Broken grapple? Facing clockwise, maybe unused",
    [0x5F] = "Broken grapple? Facing clockwise, maybe unused",
    [0x60] = "Better broken grapple. Facing clockwise, maybe unused",
    [0x61] = "Nearly normal grapple. Facing clockwise, maybe unused",
    [0x62] = "Nearly normal grapple. Facing counterclockwise, maybe unused",
    [0x63] = "Facing left on grapple blocks, ready to jump. Unused?",
    [0x64] = "Facing right on grapple blocks, ready to jump. Unused?",
    [0x65] = "Glitchy jump, facing left. Used by unused grapple jump?",
    [0x66] = "Glitchy jump, facing right. Used by unused grapple jump?",
    [0x67] = "Facing right, falling, fired a shot",
    [0x68] = "Facing left, falling, fired a shot",
    [0x69] = "Normal jump facing right, aiming upright. Moving optional",
    [0x6A] = "Normal jump facing left, aiming upleft. Moving optional",
    [0x6B] = "Normal jump facing right, aiming downright. Moving optional",
    [0x6C] = "Normal jump facing left, aiming downleft. Moving optional",
    [0x6D] = "Falling facing right, aiming upright",
    [0x6E] = "Falling facing left, aiming upleft",
    [0x6F] = "Falling facing right, aiming downright",
    [0x70] = "Falling facing left, aiming downleft",
    [0x71] = "Standing to crouching, facing right and aiming upright",
    [0x72] = "Standing to crouching, facing left and aiming upleft",
    [0x73] = "Standing to crouching, facing right and aiming downright",
    [0x74] = "Standing to crouching, facing left and aiming downleft",
    [0x75] = "Moonwalk, facing left aiming upleft",
    [0x76] = "Moonwalk, facing right aiming upright",
    [0x77] = "Moonwalk, facing left aiming downleft",
    [0x78] = "Moonwalk, facing right aiming downright",
    [0x79] = "Spring ball on ground, facing right",
    [0x7A] = "Spring ball on ground, facing left",
    [0x7B] = "Spring ball on ground, moving right",
    [0x7C] = "Spring ball on ground, moving left",
    [0x7D] = "Spring ball falling, facing/moving right",
    [0x7E] = "Spring ball falling, facing/moving left",
    [0x7F] = "Spring ball jump in air, facing/moving right",
    [0x80] = "Spring ball jump in air, facing/moving left",
    [0x81] = "Screw attack right",
    [0x82] = "Screw attack left",
    [0x83] = "Walljump right",
    [0x84] = "Walljump left",
    [0x85] = "Crouching, facing right aiming up",
    [0x86] = "Crouching, facing left aiming up",
    [0x87] = "Turning from right to left while falling",
    [0x88] = "Turning from left to right while falling",
    [0x89] = "Ran into a wall on right (facing right)",
    [0x8A] = "Ran into a wall on left (facing left)",
    [0x8B] = "Turning around from right to left while aiming straight up while standing",
    [0x8C] = "Turning around from left to right while aiming straight up while standing",
    [0x8D] = "Turn around from right to left while aiming diagonal down while standing",
    [0x8E] = "Turn around from left to right while aiming diagonal down while standing",
    [0x8F] = "Turning around from right to left while aiming straight up in midair",
    [0x90] = "Turning around from left to right while aiming straight up in midair",
    [0x91] = "Turning around from right to left while aiming down or diagonal down in midair",
    [0x92] = "Turning around from left to right while aiming down or diagonal down in midair",
    [0x93] = "Turning around from right to left while aiming straight up while falling",
    [0x94] = "Turning around from left to right while aiming straight up while falling",
    [0x95] = "Turning around from right to left while aiming down or diagonal down while falling",
    [0x96] = "Turning around from left to right while aiming down or diagonal down while falling",
    [0x97] = "Turning around from right to left while aiming straight up while crouching",
    [0x98] = "Turning around from left to right while aiming straight up while crouching",
    [0x99] = "Turning around from right to left while aiming diagonal down while crouching",
    [0x9A] = "Turning around from left to right while aiming diagonal down while crouching",
    [0x9B] = "Facing forward, ala Elevator pose... with the Varia and/or Gravity Suit.",
    [0x9C] = "Turning around from right to left while aiming diagonal up while standing",
    [0x9D] = "Turning around from left to right while aiming diagonal up while standing",
    [0x9E] = "Turning around from right to left while aiming diagonal up in midair",
    [0x9F] = "Turning around from left to right while aiming diagonal up in midair",
    [0xA0] = "Turning around from right to left while aiming diagonal up while falling",
    [0xA1] = "Turning around from left to right while aiming diagonal up while falling",
    [0xA2] = "Turn around from right to left while aiming diagonal up while crouching",
    [0xA3] = "Turn around from left to right while aiming diagonal up while crouching",
    [0xA4] = "Landing from normal jump, facing right",
    [0xA5] = "Landing from normal jump, facing left",
    [0xA6] = "Landing from spin jump, facing right",
    [0xA7] = "Landing from spin jump, facing left",
    [0xA8] = "Just standing, facing right. Unused? (Grapple movement)",
    [0xA9] = "Just standing, facing left. Unused? (Grapple movement)",
    [0xAA] = "Just standing, facing right aiming downright. Unused? (Grapple movement)",
    [0xAB] = "Just standing, facing left aiming downleft. Unused? (Grapple movement)",
    [0xAC] = "Jumping, facing right, gun extended. Unused? (Grapple movement)",
    [0xAD] = "Jumping, facing left, gun extended. Unused? (Grapple movement)",
    [0xAE] = "Jumping, facing right, aiming down. Unused? (Grapple movement)",
    [0xAF] = "Jumping, facing left, aiming down. Unused? (Grapple movement)",
    [0xB0] = "Jumping, facing right, aiming downright. Unused? (Grapple movement)",
    [0xB1] = "Jumping, facing left, aiming downleft. Unused? (Grapple movement)",
    [0xB2] = "Grapple, facing clockwise",
    [0xB3] = "Grapple, facing counterclockwise",
    [0xB4] = "Crouching, facing right. Unused? (Grapple movement)",
    [0xB5] = "Crouching, facing left. Unused? (Grapple movement)",
    [0xB6] = "Crouching, facing right, aiming downright. Unused? (Grapple movement)",
    [0xB7] = "Crouching, facing left, aiming downleft. Unused? (Grapple movement)",
    [0xB8] = "Grapple, attached to a wall on right, facing left",
    [0xB9] = "Grapple, attached to a wall on left, facing right",
    [0xBA] = "Grabbed by Draygon, facing left, not moving",
    [0xBB] = "Grabbed by Draygon, facing left aiming upleft, not moving",
    [0xBC] = "Grabbed by Draygon, facing left and firing",
    [0xBD] = "Grabbed by Draygon, facing left aiming downleft, not moving",
    [0xBE] = "Grabbed by Draygon, facing left, moving",
    [0xBF] = "Jump/Turn right to left while moonwalking.",
    [0xC0] = "Jump/Turn left to right while moonwalking.",
    [0xC1] = "Jump/Turn right to left while moonwalking and aiming diagonal up.",
    [0xC2] = "Jump/Turn left to right while moonwalking and aiming diagonal up.",
    [0xC3] = "Jump/Turn right to left while moonwalking and aiming diagonal down.",
    [0xC4] = "Jump/Turn left to right while moonwalking and aiming diagonal down.",
    [0xC5] = "Morph ball, facing right. Unused? (Grabbed by Draygon movement)",
    [0xC6] = "Morph ball, facing left. Unused? (Grabbed by Draygon movement)",
    [0xC7] = "Super jump windup, facing right",
    [0xC8] = "Super jump windup, facing left",
    [0xC9] = "Horizontal super jump, right",
    [0xCA] = "Horizontal super jump, left",
    [0xCB] = "Vertical super jump, facing right",
    [0xCC] = "Vertical super jump, facing left",
    [0xCD] = "Diagonal super jump, right",
    [0xCE] = "Diagonal super jump, left",
    [0xCF] = "Samus ran right into a wall, is still holding right and is now aiming diagonal up",
    [0xD0] = "Samus ran left into a wall, is still holding left and is now aiming diagonal up",
    [0xD1] = "Samus ran right into a wall, is still holding right and is now aiming diagonal down",
    [0xD2] = "Samus ran left into a wall, is still holding left and is now aiming diagonal down",
    [0xD3] = "Crystal flash, facing right",
    [0xD4] = "Crystal flash, facing left",
    [0xD5] = "X-raying right, standing",
    [0xD6] = "X-raying left, standing",
    [0xD7] = "Crystal flash ending, facing right",
    [0xD8] = "Crystal flash ending, facing left",
    [0xD9] = "X-raying right, crouching",
    [0xDA] = "X-raying left, crouching",
    [0xDB] = "Standing transition to morphball, facing right? Unused?",
    [0xDC] = "Standing transition to morphball, facing left? Unused?",
    [0xDD] = "Morphball transition to standing, facing right? Unused?",
    [0xDE] = "Morphball transition to standing, facing left? Unused?",
    [0xDF] = "Samus is facing left as a morphball. Unused? (Grabbed by Draygon movement)",
    [0xE0] = "Landing from normal jump, facing right and aiming up",
    [0xE1] = "Landing from normal jump, facing left and aiming up",
    [0xE2] = "Landing from normal jump, facing right and aiming upright",
    [0xE3] = "Landing from normal jump, facing left and aiming upleft",
    [0xE4] = "Landing from normal jump, facing right and aiming downright",
    [0xE5] = "Landing from normal jump, facing left and aiming downleft",
    [0xE6] = "Landing from normal jump, facing right, firing",
    [0xE7] = "Landing from normal jump, facing left, firing",
    [0xE8] = "Samus exhausted(Metroid drain, MB attack), facing right",
    [0xE9] = "Samus exhausted(Metroid drain, MB attack), facing left",
    [0xEA] = "Samus exhausted, looking up to watch Metroid attack MB, facing right",
    [0xEB] = "Samus exhausted, looking up to watch Metroid attack MB, facing left",
    [0xEC] = "Grabbed by Draygon, facing right. Not moving",
    [0xED] = "Grabbed by Draygon, facing right aiming upright. Not moving",
    [0xEE] = "Grabbed by Draygon, facing right and firing.",
    [0xEF] = "Grabbed by Draygon, facing right aiming downright. Not moving",
    [0xF0] = "Grabbed by Draygon, facing right. Moving",
    [0xF1] = "Crouch transition, facing right and aiming up",
    [0xF2] = "Crouch transition, facing left and aiming up",
    [0xF3] = "Crouch transition, facing right and aiming upright",
    [0xF4] = "Crouch transition, facing left and aiming upleft",
    [0xF5] = "Crouch transition, facing right and aiming downright",
    [0xF6] = "Crouch transition, facing left and aiming downleft",
    [0xF7] = "Crouching to standing, facing right and aiming up",
    [0xF8] = "Crouching to standing, facing left and aiming upleft",
    [0xF9] = "Crouching to standing, facing right and aiming upright",
    [0xFA] = "Crouching to standing, facing left and aiming upleft",
    [0xFB] = "Crouching to standing, facing right and aiming downright",
    [0xFC] = "Crouching to standing, facing left and aiming downleft",
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
local DOOR_TRANSITION_FUNC = 0
local OLD_DOOR_TRANSITION_FUNC = 0

local OLD_GAME_STATE = 0
local GAME_STATE = 0

local OLD_SAMUS_X = 0
local SAMUS_X = 0

local OLD_SAMUS_Y = 0
local SAMUS_Y = 0

local CHARGE_COUNTER = 0
local IFRAMES = 0
local INPUT = 0
local KNOCKBACK = 0
local POWERBOMB_RADIUS = 0
local POWERBOMB_TIMER = 0
local POWERBOMB_X = 0
local POWERBOMB_Y = 0
local SAMUS_DASH = 0
local SAMUS_DIRECTION_X = 0
local SAMUS_DIRECTION_Y = 0
local SAMUS_POSE = 0
local SAMUS_RADIUS_X = 0
local SAMUS_RADIUS_Y = 0
local SAMUS_SPEED_X = 0
local SAMUS_SPEED_Y = 0
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
end

local function read_new_memory()
    DOOR_TRANSITION_FUNC = mainmemory.read_u16_le(0x099C)
    GAME_STATE = mainmemory.read_u8(0x0998)
    SAMUS_X = (mainmemory.read_u16_le(0x0AF6) << 16) | mainmemory.read_u16_le(0x0AF8)
    SAMUS_Y = (mainmemory.read_u16_le(0x0AFA) << 16) | mainmemory.read_u16_le(0x0AFC)

    CHARGE_COUNTER = mainmemory.read_u16_le(0x0CD0)
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
    SAMUS_SPEED_X = (mainmemory.read_s8(0x0B42) * 0x10000) + mainmemory.read_u16_le(0x0B44)
    SAMUS_SPEED_Y = (mainmemory.read_s8(0x0B2E) * 0x10000) + mainmemory.read_u16_le(0x0B2C)
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

local function draw_samus_hitbox(samus_dx)
    local expected_dx = SAMUS_SPEED_X + SAMUS_DASH

    local fg_color
    if samus_dx > expected_dx then
        fg_color = 0xFF00FF00
    elseif samus_dx == expected_dx then
        fg_color = 0xFF80FFFF
    elseif 4 * samus_dx > 3 * expected_dx then
        fg_color = 0xFFFF8000
    elseif 4 * samus_dx > 2 * expected_dx then
        fg_color = 0xFFFF0000
    else
        fg_color = 0xFF800000
    end

    -- hitbox around samus
    local x = (SAMUS_X >> 16) - SCREEN_X
    local y = (SAMUS_Y >> 16) - SCREEN_Y
    local x1 = x - SAMUS_RADIUS_X
    local y1 = y - SAMUS_RADIUS_Y
    local x2 = x + SAMUS_RADIUS_X
    local y2 = y + SAMUS_RADIUS_Y
    local bg_color = 0x350000FF
    gui.drawBox(x1, y1, x2, y2, fg_color, bg_color)

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
            -- TODO show projectile damage?
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
        draw_samus_hitbox(samus_dx)
        draw_projectile_hitboxes()
        draw_powerbomb_hitbox()
        draw_enemy_hitboxes()
        draw_enemy_projectile_hitboxes()
        draw_hud(samus_dx, samus_dy)
        draw_door_lag()
    end
end
