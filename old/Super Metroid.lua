local xemu = require('cross emu')

-- map of [domain] -> [byte size] -> [signed=true/unsigned=false] -> function(addr)
local _mainread_u8 = mainmemory.read_u8
local _mainread_s8 = mainmemory.read_s8
local _mainread_u16_le = mainmemory.read_u16_le
local _mainread_s16_le = mainmemory.read_s16_le
local _read_u8 = memory.read_u8
local _read_s8 = memory.read_s8
local _read_u16_le = memory.read_u16_le
local _read_s16_le = memory.read_s16_le

---@type table<string, table<1|2, table<boolean, fun(address: integer): integer>>>
local _readers = {
    WRAM = {
        [1] = {
            [false] = _mainread_u8,
            [true] = _mainread_s8,
        },
        [2] = {
            [false] = _mainread_u16_le,
            [true] = _mainread_s16_le,
        },
    },
    APURAM = {
        [1] = {
            [false] = function(addr) return _read_u8(addr, 'APURAM') end,
            [true] = function(addr) return _read_s8(addr, 'APURAM') end,
        },
        [2] = {
            [false] = function(addr) return _read_u16_le(addr, 'APURAM') end,
            [true] = function(addr) return _read_s16_le(addr, 'APURAM') end,
        },
    },
    CARTROM = {
        [1] = {
            [false] = function(addr) return _read_u8(addr, 'CARTROM') end,
            [true] = function(addr) return _read_s8(addr, 'CARTROM') end,
        },
        [2] = {
            [false] = function(addr) return _read_u16_le(addr, 'CARTROM') end,
            [true] = function(addr) return _read_s16_le(addr, 'CARTROM') end,
        },
    },
}

local unsigned = false
local signed = true

---@param address integer pointer to memory
---@param byte_size 1|2 number of bytes to read
---@param is_signed? boolean whether or not to sign extend read values
---@param domain? string memory domain (by default 'WRAM')
---@return fun(integer): integer
local function getReader(address, byte_size, is_signed, domain)
    if domain == nil then
        if address < 0x800000 then
            domain = 'WRAM'
            address = address & 0x1FFFF
        else
            domain = 'CARTROM'
            address = ((address >> 1) & 0x3F8000) + (address & 0x7FFF)
        end
    end

    local reader = _readers[domain]
    reader = reader[byte_size]
    return reader[is_signed or false]
end

---@param address integer pointer to memory
---@param byte_size 1|2 number of bytes to read
---@param is_signed? boolean whether or not to sign extend read values
---@param domain? string memory domain (by default 'WRAM')
---@return fun(): integer
local function makeReader(address, byte_size, is_signed, domain)
    local reader = getReader(address, byte_size, is_signed, domain)
    return function() return reader(address) end
end

---@param address integer pointer to memory
---@param byte_size 1|2 number of bytes to read
---@param is_signed? boolean whether or not to sign extend read values
---@param interval integer If specified, size of array entries, where p is the address within the first array entry Returned reader will have an array index parameter
---@param domain? string memory domain (by default 'WRAM')
---@return fun(i: integer): integer
local function makeArrayReader(address, byte_size, is_signed, interval, domain)
    local reader = getReader(address, byte_size, is_signed, domain)
    return function(i) return reader(address + i * interval) end
end

--[[
local function makeAggregateReader(readers)
    return function(i) return readers[i + 1] end
end
-- ]]

local function makeWriter(p, n, interval)
    -- p: Pointer to WRAM
    -- n: Number of bytes to write
    -- interval: If specified, size of array entries, where p is the address within the first array entry
    --           Returned writer will have an array index parameter

    if n < 1 or n > 2 then
        error(string.format('Trying to make writer with n = %d', n))
    end

    local writers = {
        [1] = xemu.write_u8,
        [2] = xemu.write_u16_le
    }

    local writer = writers[n]
    if interval then
        return function(i, v) return writer(p + i * interval, v) end
    else
        return function(v) return writer(p, v) end
    end
end

local sm                           = {}

-- Button bitmasks --
sm.button_B                        = 0x8000
sm.button_Y                        = 0x4000
sm.button_select                   = 0x2000
sm.button_start                    = 0x1000
sm.button_up                       = 0x800
sm.button_down                     = 0x400
sm.button_left                     = 0x200
sm.button_right                    = 0x100
sm.button_A                        = 0x80
sm.button_X                        = 0x40
sm.button_L                        = 0x20
sm.button_R                        = 0x10

-- WRAM --
sm.getBg1TilemapOptions            = makeReader(0x7E0058, 2)
sm.getBg2TilemapOptions            = makeReader(0x7E0059, 2)

sm.getInput                        = makeReader(0x7E008B, 2)
sm.getChangedInput                 = makeReader(0x7E008F, 2)

sm.getBg1ScrollX                   = makeReader(0x7E00B1, 2)
sm.setBg1ScrollX                   = makeWriter(0x7E00B1, 2)
sm.getBg1ScrollY                   = makeReader(0x7E00B3, 2)
sm.setBg1ScrollY                   = makeWriter(0x7E00B3, 2)
sm.getBg2ScrollX                   = makeReader(0x7E00B5, 2)
sm.setBg2ScrollX                   = makeWriter(0x7E00B5, 2)
sm.getBg2ScrollY                   = makeReader(0x7E00B7, 2)
sm.setBg2ScrollY                   = makeWriter(0x7E00B7, 2)
sm.getBg3ScrollX                   = makeReader(0x7E00B9, 2)
sm.setBg3ScrollX                   = makeWriter(0x7E00B9, 2)
sm.getBg3ScrollY                   = makeReader(0x7E00BB, 2)
sm.setBg3ScrollY                   = makeWriter(0x7E00BB, 2)

sm.getMode7Flag                    = makeReader(0x7E0783, 2)
sm.getDoorDirection                = makeReader(0x7E0791, 2)
sm.getRoomPointer                  = makeReader(0x7E079B, 2)
sm.getAreaIndex                    = makeReader(0x7E079F, 2)
sm.getRoomWidth                    = makeReader(0x7E07A5, 2)
sm.getRoomHeight                   = makeReader(0x7E07A7, 2)
sm.getRoomWidthInScrolls           = makeReader(0x7E07A9, 2)
sm.getRoomHeightInScrolls          = makeReader(0x7E07AB, 2)
sm.getUpScroller                   = makeReader(0x7E07AD, 2)
sm.getDownScroller                 = makeReader(0x7E07AF, 2)
sm.getDoorListPointer              = makeReader(0x7E07B5, 2)

sm.getLayer1XSubposition           = makeReader(0x7E090F, 2)
sm.getLayer1XPosition              = makeReader(0x7E0911, 2, signed)
sm.setLayer1XPosition              = makeWriter(0x7E0911, 2)
sm.getLayer1YSubposition           = makeReader(0x7E0913, 2)
sm.getLayer1YPosition              = makeReader(0x7E0915, 2, signed)
sm.setLayer1YPosition              = makeWriter(0x7E0915, 2)
sm.getLayer2XPosition              = makeReader(0x7E0917, 2, signed)
sm.getLayer2YPosition              = makeReader(0x7E0919, 2, signed)
sm.getLayer2XScroll                = makeReader(0x7E091B, 1)
sm.getLayer2YScroll                = makeReader(0x7E091C, 1)
sm.getBg1ScrollXOffset             = makeReader(0x7E091D, 2, signed)
sm.getBg1ScrollYOffset             = makeReader(0x7E091F, 2, signed)
sm.getBg2ScrollXOffset             = makeReader(0x7E0921, 2, signed)
sm.getBg2ScrollYOffset             = makeReader(0x7E0923, 2, signed)

sm.getDownwardsElevatorDelayTimer  = makeReader(0x7E092F, 2)

sm.getCameraDistanceIndex          = makeReader(0x7E0941, 2)

sm.getGameState                    = makeReader(0x7E0998, 2)
sm.getDoorTransitionFunction       = makeReader(0x7E099C, 2)

sm.getEquippedItems                = makeReader(0x7E09A2, 2)
sm.getCollectedItems               = makeReader(0x7E09A4, 2)
sm.getEquippedBeams                = makeReader(0x7E09A6, 2)
sm.getCollectedBeams               = makeReader(0x7E09A8, 2)

sm.getRunBinding                   = makeReader(0x7E09B6, 2)

sm.getSamusHealth                  = makeReader(0x7E09C2, 2)
sm.getSamusMaxHealth               = makeReader(0x7E09C4, 2)
sm.getSamusMissiles                = makeReader(0x7E09C6, 2)
sm.getSamusMaxMissiles             = makeReader(0x7E09C8, 2)
sm.getSamusSuperMissiles           = makeReader(0x7E09CA, 2)
sm.getSamusMaxSuperMissiles        = makeReader(0x7E09CC, 2)
sm.getSamusPowerBombs              = makeReader(0x7E09CE, 2)
sm.getSamusMaxPowerBombs           = makeReader(0x7E09D0, 2)
sm.getSamusMaxReserveHealth        = makeReader(0x7E09D4, 2)
sm.getSamusReserveHealth           = makeReader(0x7E09D6, 2)

sm.getGameTimeFrames               = makeReader(0x7E09DA, 2)
sm.getGameTimeSeconds              = makeReader(0x7E09DC, 2)
sm.getGameTimeMinutes              = makeReader(0x7E09DE, 2)
sm.getGameTimeHours                = makeReader(0x7E09E0, 2)

sm.getSamusPreviousMovementType    = makeReader(0x7E0A11, 1)
sm.getSamusPose                    = makeReader(0x7E0A1C, 1)
sm.getSamusFacingDirection         = makeReader(0x7E0A1E, 1)
sm.getSamusMovementType            = makeReader(0x7E0A1F, 1)
sm.getKnockbackDirection           = makeReader(0x7E0A52, 2)
sm.getSamusMovementHandler         = makeReader(0x7E0A58, 2)
sm.getSamusPoseInputHandler        = makeReader(0x7E0A60, 2)
sm.getShinesparkTimer              = makeReader(0x7E0A68, 2, signed)
sm.getFrozenTimeFlag               = makeReader(0x7E0A78, 2)
sm.getXrayState                    = makeReader(0x7E0A7A, 2)

sm.getSamusAnimationFrameTimer     = makeReader(0x7E0A94, 2)
sm.getSamusAnimationFrame          = makeReader(0x7E0A96, 2)
sm.getSpecialSamusPaletteType      = makeReader(0x7E0ACC, 2)

sm.getSamusXPosition               = makeReader(0x7E0AF6, 2)
sm.getSamusXPositionSigned         = makeReader(0x7E0AF6, 2, signed)
sm.setSamusXPosition               = makeWriter(0x7E0AF6, 2)
sm.getSamusXSubposition            = makeReader(0x7E0AF8, 2)
sm.getSamusYPosition               = makeReader(0x7E0AFA, 2)
sm.getSamusYPositionSigned         = makeReader(0x7E0AFA, 2, signed)
sm.setSamusYPosition               = makeWriter(0x7E0AFA, 2)
sm.getSamusYSubposition            = makeReader(0x7E0AFC, 2)
sm.getSamusXRadius                 = makeReader(0x7E0AFE, 2)
sm.getSamusYRadius                 = makeReader(0x7E0B00, 2)
sm.getIdealLayer1XPosition         = makeReader(0x7E0B0A, 2)
sm.getIdealLayer1YPosition         = makeReader(0x7E0B0E, 2)
sm.getSamusPreviousXPosition       = makeReader(0x7E0B10, 2)
sm.getSamusPreviousYPosition       = makeReader(0x7E0B14, 2)
sm.getSamusYSubspeed               = makeReader(0x7E0B2C, 2)
sm.getSamusYSpeed                  = makeReader(0x7E0B2E, 2, signed)
sm.getSamusYDirection              = makeReader(0x7E0B36, 2)
sm.getSamusRunningMomentumFlag     = makeReader(0x7E0B3C, 2)
sm.getSpeedBoosterLevel            = makeReader(0x7E0B3F, 2)
sm.getSamusXSpeed                  = makeReader(0x7E0B42, 2)
sm.getSamusXSubspeed               = makeReader(0x7E0B44, 2)
sm.getSamusXMomentum               = makeReader(0x7E0B46, 2)
sm.getSamusXSubmomentum            = makeReader(0x7E0B48, 2)

sm.getCooldownTimer                = makeReader(0x7E0CCC, 2)
sm.getChargeCounter                = makeReader(0x7E0CD0, 2)
sm.getPowerBombXPosition           = makeReader(0x7E0CE2, 2)
sm.getPowerBombYPosition           = makeReader(0x7E0CE4, 2)
sm.getPowerBombRadius              = makeReader(0x7E0CEA, 2)
sm.getPowerBombPreRadius           = makeReader(0x7E0CEC, 2)
sm.getPowerBombFlag                = makeReader(0x7E0CEE, 2)

sm.getXDistanceSamusMoved          = makeReader(0x7E0DA2, 2)
sm.getXSubdistanceSamusMoved       = makeReader(0x7E0DA4, 2)
sm.getYDistanceSamusMoved          = makeReader(0x7E0DA6, 2)
sm.getYSubdistanceSamusMoved       = makeReader(0x7E0DA8, 2)

sm.getBlockIndex                   = makeReader(0x7E0DC4, 2)

sm.getElevatorState                = makeReader(0x7E0E18, 2)

sm.getNEnemies                     = makeReader(0x7E0E4E, 2)

sm.getBossNumber                   = makeReader(0x7E179C, 2)

sm.getEarthquakeType               = makeReader(0x7E183E, 2)
sm.getEarthquakeTimer              = makeReader(0x7E1840, 2)

sm.getInvincibilityTimer           = makeReader(0x7E18A8, 2)
sm.getRecoilTimer                  = makeReader(0x7E18AA, 2)

sm.getHdmaObjectIndex              = makeReader(0x7E18B2, 2)

sm.getFxYPosition                  = makeReader(0x7E195E, 2)
sm.setFxYPosition                  = makeWriter(0x7E195E, 2)
sm.getLavaAcidYPosition            = makeReader(0x7E1962, 2)
sm.setLavaAcidYPosition            = makeWriter(0x7E1962, 2)
sm.getFxTargetYPosition            = makeReader(0x7E197A, 2)

sm.getMessageBoxIndex              = makeReader(0x7E1C1F, 2)

sm.getPlmEnableFlag                = makeReader(0x7E1C23, 2)

-- OAM
sm.getOamXLow                      = makeArrayReader(0x7E0370, 1, unsigned, 4)
sm.setOamXLow                      = makeWriter(0x7E0370, 1, 4)
sm.getOamY                         = makeArrayReader(0x7E0371, 1, unsigned, 4)
sm.setOamY                         = makeWriter(0x7E0371, 1, 4)
sm.getOamProperties                = makeArrayReader(0x7E0372, 2, unsigned, 4)
sm.getOamHigh                      = makeArrayReader(0x7E0570, 1, unsigned, 1)
sm.setOamHigh                      = makeWriter(0x7E0570, 1, 1)

-- Projectiles
sm.getProjectileXPosition          = makeArrayReader(0x7E0B64, 2, unsigned, 2)
sm.getProjectileYPosition          = makeArrayReader(0x7E0B78, 2, unsigned, 2)
sm.getProjectileXRadius            = makeArrayReader(0x7E0BB4, 2, unsigned, 2)
sm.getProjectileYRadius            = makeArrayReader(0x7E0BC8, 2, unsigned, 2)
sm.getProjectileType               = makeArrayReader(0x7E0C18, 2, unsigned, 2)
sm.getProjectileDamage             = makeArrayReader(0x7E0C2C, 2, unsigned, 2)
sm.getBombTimer                    = makeArrayReader(0x7E0C7C, 2, unsigned, 2)

-- Enemies
sm.getEnemyId                      = makeArrayReader(0x7E0F78, 2, unsigned, 0x40)
sm.getEnemyXPosition               = makeArrayReader(0x7E0F7A, 2, unsigned, 0x40)
sm.getEnemyXSubposition            = makeArrayReader(0x7E0F7C, 2, unsigned, 0x40)
sm.getEnemyYPosition               = makeArrayReader(0x7E0F7E, 2, unsigned, 0x40)
sm.getEnemyYSubposition            = makeArrayReader(0x7E0F80, 2, unsigned, 0x40)
sm.getEnemyXRadius                 = makeArrayReader(0x7E0F82, 2, unsigned, 0x40)
sm.getEnemyYRadius                 = makeArrayReader(0x7E0F84, 2, unsigned, 0x40)
sm.getEnemyProperties              = makeArrayReader(0x7E0F86, 2, unsigned, 0x40)
sm.getEnemyExtraProperties         = makeArrayReader(0x7E0F88, 2, unsigned, 0x40)
sm.getEnemyAiHandler               = makeArrayReader(0x7E0F8A, 2, unsigned, 0x40)
sm.getEnemyHealth                  = makeArrayReader(0x7E0F8C, 2, unsigned, 0x40)
sm.getEnemySpritemap               = makeArrayReader(0x7E0F8E, 2, unsigned, 0x40)
sm.getEnemyTimer                   = makeArrayReader(0x7E0F90, 2, unsigned, 0x40)
sm.getEnemyInitialisationParameter = makeArrayReader(0x7E0F92, 2, unsigned, 0x40)
sm.getEnemyInstructionList         = makeArrayReader(0x7E0F92, 2, unsigned, 0x40)
sm.getEnemyInstructionTimer        = makeArrayReader(0x7E0F94, 2, unsigned, 0x40)
sm.getEnemyPaletteIndex            = makeArrayReader(0x7E0F96, 2, unsigned, 0x40)
sm.getEnemyGraphicsIndex           = makeArrayReader(0x7E0F98, 2, unsigned, 0x40)
sm.getEnemyLayer                   = makeArrayReader(0x7E0F9A, 2, unsigned, 0x40)
sm.getEnemyInvincibilityTimer      = makeArrayReader(0x7E0F9C, 2, unsigned, 0x40)
sm.getEnemyFrozenTimer             = makeArrayReader(0x7E0F9E, 2, unsigned, 0x40)
sm.getEnemyPlasmaTimer             = makeArrayReader(0x7E0FA0, 2, unsigned, 0x40)
sm.getEnemyShakeTimer              = makeArrayReader(0x7E0FA2, 2, unsigned, 0x40)
sm.getEnemyFrameCounter            = makeArrayReader(0x7E0FA4, 2, unsigned, 0x40)
sm.getEnemyBank                    = makeArrayReader(0x7E0FA6, 1, unsigned, 0x40)
sm.getEnemyAiVariable0             = makeArrayReader(0x7E0FA8, 2, unsigned, 0x40)
sm.getEnemyAiVariable1             = makeArrayReader(0x7E0FAA, 2, unsigned, 0x40)
sm.getEnemyAiVariable2             = makeArrayReader(0x7E0FAC, 2, unsigned, 0x40)
sm.getEnemyAiVariable3             = makeArrayReader(0x7E0FAE, 2, unsigned, 0x40)
sm.getEnemyAiVariable4             = makeArrayReader(0x7E0FB0, 2, unsigned, 0x40)
sm.getEnemyAiVariable5             = makeArrayReader(0x7E0FB2, 2, unsigned, 0x40)
sm.getEnemyParameter1              = makeArrayReader(0x7E0FB4, 2, unsigned, 0x40)
sm.getEnemyParameter2              = makeArrayReader(0x7E0FB6, 2, unsigned, 0x40)

-- Enemy projectiles
sm.getEnemyProjectileId            = makeArrayReader(0x7E1997, 2, unsigned, 2)
sm.getEnemyProjectileXPosition     = makeArrayReader(0x7E1A4B, 2, unsigned, 2)
sm.getEnemyProjectileYPosition     = makeArrayReader(0x7E1A93, 2, unsigned, 2)
sm.getEnemyProjectileXRadius       = makeArrayReader(0x7E1BB3, 1, unsigned, 2)
sm.getEnemyProjectileYRadius       = makeArrayReader(0x7E1BB4, 1, unsigned, 2)

-- PLMs
sm.getPlmId                        = makeArrayReader(0x7E1C37, 2, unsigned, 2)
sm.getPlmRoomArgument              = makeArrayReader(0x7E1DC7, 2, unsigned, 2)
sm.getPlmInstructionTimer          = makeArrayReader(0x7EDE1C, 2, unsigned, 2)

-- Metatiles
sm.getMetatileTopLeft              = makeArrayReader(0x7EA000, 2, unsigned, 8)
sm.getMetatileTopRight             = makeArrayReader(0x7EA002, 2, unsigned, 8)
sm.getMetatileBottomLeft           = makeArrayReader(0x7EA004, 2, unsigned, 8)
sm.getMetatileBottomRight          = makeArrayReader(0x7EA006, 2, unsigned, 8)

-- Scroll
sm.getScroll                       = makeArrayReader(0x7ECD20, 1, unsigned, 1)

-- Sprite objects
sm.getSpriteObjectInstructionList  = makeArrayReader(0x7EEF78, 2, unsigned, 2)
sm.getSpriteObjectXPosition        = makeArrayReader(0x7EF0F8, 2, unsigned, 2)
sm.getSpriteObjectYPosition        = makeArrayReader(0x7EF1F8, 2, unsigned, 2)

-- Blocks
sm.getLevelDatum                   = makeArrayReader(0x7F0002, 2, unsigned, 2)
sm.getBts                          = makeArrayReader(0x7F6402, 1, unsigned, 1)
sm.getBtsSigned                    = makeArrayReader(0x7F6402, 1, signed, 1)
sm.getBackgroundDatum              = makeArrayReader(0x7F9602, 2, unsigned, 2)


--[[
-- ARAM --
-- CPU IO cache registers
sm.getAram_cpuIo_read                               = makeAramReader(0x0, 1, unsigned, 1)
sm.getAram_cpuIo_write                              = makeAramReader(0x4, 1, unsigned, 1)
sm.getAram_cpuIo_read_prev                          = makeAramReader(0x8, 1, unsigned, 1)

sm.getAram_musicTrackStatus                         = makeAramReader(0xC, 1)

-- Temporaries
sm.getAram_note                                     = makeAramReader(0x10, 2)
sm.getAram_panningBias                              = makeAramReader(0x10, 2)
sm.getAram_dspVoiceVolumeIndex                      = makeAramReader(0x12, 1)
sm.getAram_noteModifiedFlag                         = makeAramReader(0x13, 1)
sm.getAram_misc0                                    = makeAramReader(0x14, 2)
sm.getAram_misc1                                    = makeAramReader(0x16, 2)

sm.getAram_randomNumber                             = makeAramReader(0x18, 2)
sm.getAram_enableSoundEffectVoices                  = makeAramReader(0x1A, 1)
sm.getAram_disableNoteProcessing                    = makeAramReader(0x1B, 1)
sm.getAram_p_return                                 = makeAramReader(0x20, 2)

-- Sound 1
sm.getAram_sound1_instructionListPointerSet         = makeAramReader(0x22, 2)
sm.getAram_sound1_p_charVoiceBitset                 = makeAramReader(0x24, 2)
sm.getAram_sound1_p_charVoiceMask                   = makeAramReader(0x26, 2)
sm.getAram_sound1_p_charVoiceIndex                  = makeAramReader(0x28, 2)

-- Sounds
sm.getAram_sound1_channel0_p_instructionList        = makeAramReader(0x2A, 2)
sm.getAram_sound1_channel1_p_instructionList        = makeAramReader(0x2C, 2)
sm.getAram_sound1_channel2_p_instructionList        = makeAramReader(0x2E, 2)

sm.getAram_trackPointers                            = makeAramReader(0x30, 2, unsigned, 2)
sm.getAram_p_tracker                                = makeAramReader(0x40, 2)
sm.getAram_trackerTimer                             = makeAramReader(0x42, 1)
sm.getAram_soundEffectsClock                        = makeAramReader(0x43, 1)
sm.getAram_trackIndex                               = makeAramReader(0x44, 1)

-- DSP cache
sm.getAram_keyOnFlags                               = makeAramReader(0x45, 1)
sm.getAram_keyOffFlags                              = makeAramReader(0x46, 1)
sm.getAram_musicVoiceBitset                         = makeAramReader(0x47, 1)
sm.getAram_flg                                      = makeAramReader(0x48, 1)
sm.getAram_noiseEnableFlags                         = makeAramReader(0x49, 1)
sm.getAram_echoEnableFlags                          = makeAramReader(0x4A, 1)
sm.getAram_pitchModulationFlags                     = makeAramReader(0x5B, 1)

-- Echo
sm.getAram_echoTimer                                = makeAramReader(0x4C, 1)
sm.getAram_echoDelay                                = makeAramReader(0x4D, 1)
sm.getAram_echoFeedbackVolume                       = makeAramReader(0x4E, 1)

-- Music
sm.getAram_musicTranspose                           = makeAramReader(0x50, 1)
sm.getAram_musicTrackClock                          = makeAramReader(0x51, 1)
sm.getAram_musicTempo                               = makeAramReader(0x52, 2)
sm.getAram_dynamicMusicTempoTimer                   = makeAramReader(0x54, 1)
sm.getAram_targetMusicTempo                         = makeAramReader(0x55, 1)
sm.getAram_musicTempoDelta                          = makeAramReader(0x56, 2)
sm.getAram_musicVolume                              = makeAramReader(0x58, 2)
sm.getAram_dynamicMusicVolumeTimer                  = makeAramReader(0x5A, 1)
sm.getAram_targetMusicVolume                        = makeAramReader(0x5B, 1)
sm.getAram_musicVolumeDelta                         = makeAramReader(0x5C, 2)
sm.getAram_musicVoiceVolumeUpdateBitset             = makeAramReader(0x5E, 1)
sm.getAram_percussionInstrumentsBaseIndex           = makeAramReader(0x5F, 1)

-- Echo
sm.getAram_echoVolumeLeft                           = makeAramReader(0x60, 2)
sm.getAram_echoVolumeRight                          = makeAramReader(0x62, 2)
sm.getAram_echoVolumeLeftDelta                      = makeAramReader(0x64, 2)
sm.getAram_echoVolumeRightDelta                     = makeAramReader(0x66, 2)
sm.getAram_dynamicEchoVolumeTimer                   = makeAramReader(0x68, 1)
sm.getAram_targetEchoVolumeLeft                     = makeAramReader(0x69, 1)
sm.getAram_targetEchoVolumeRight                    = makeAramReader(0x6A, 1)

-- Track
sm.getAram_trackNoteTimers                          = makeAramReader(0x70, 1, unsigned, 2)
sm.getAram_trackNoteRingTimers                      = makeAramReader(0x71, 1, unsigned, 2)
sm.getAram_trackRepeatedSubsectionCounters          = makeAramReader(0x80, 1, unsigned, 2)
sm.getAram_trackDynamicVolumeTimers                 = makeAramReader(0x90, 1, unsigned, 2)
sm.getAram_trackDynamicPanningTimers                = makeAramReader(0x91, 1, unsigned, 2)
sm.getAram_trackPitchSlideTimers                    = makeAramReader(0xA0, 1, unsigned, 2)
sm.getAram_trackPitchSlideDelayTimers               = makeAramReader(0xA1, 1, unsigned, 2)
sm.getAram_trackVibratoDelayTimers                  = makeAramReader(0xB0, 1, unsigned, 2)
sm.getAram_trackVibratoExtents                      = makeAramReader(0xB1, 1, unsigned, 2)
sm.getAram_trackTremoloDelayTimers                  = makeAramReader(0xC0, 1, unsigned, 2)
sm.getAram_trackTremoloExtents                      = makeAramReader(0xC1, 1, unsigned, 2)

-- Sounds
sm.getAram_sound1_channel3_p_instructionList        = makeAramReader(0xD0, 2)
sm.getAram_p_echoBuffer                             = makeAramReader(0xD2, 2)
sm.getAram_sound2_instructionListPointerSet         = makeAramReader(0xD4, 2)
sm.getAram_sound2_p_charVoiceBitset                 = makeAramReader(0xD6, 2)
sm.getAram_sound2_p_charVoiceMask                   = makeAramReader(0xD8, 2)
sm.getAram_sound2_p_charVoiceIndex                  = makeAramReader(0xDA, 2)
sm.getAram_sound2_channel0_p_instructionList        = makeAramReader(0xDC, 2)
sm.getAram_sound2_channel1_p_instructionList        = makeAramReader(0xDE, 2)
sm.getAram_sound3_instructionListPointerSet         = makeAramReader(0xE0, 2)
sm.getAram_sound3_p_charVoiceBitset                 = makeAramReader(0xE2, 2)
sm.getAram_sound3_p_charVoiceMask                   = makeAramReader(0xE4, 2)
sm.getAram_sound3_p_charVoiceIndex                  = makeAramReader(0xE6, 2)
sm.getAram_sound3_channel0_p_instructionList        = makeAramReader(0xE8, 2)
sm.getAram_sound3_channel1_p_instructionList        = makeAramReader(0xEA, 2)

-- Music
sm.getAram_trackDynamicVibratoTimers                = makeAramReader(0x100, 1, unsigned, 2)
sm.getAram_trackNoteLengths                         = makeAramReader(0x200, 1, unsigned, 2)
sm.getAram_trackNoteRingLengths                     = makeAramReader(0x201, 1, unsigned, 2)
sm.getAram_trackNoteVolume                          = makeAramReader(0x210, 1, unsigned, 2)
sm.getAram_trackInstrumentIndices                   = makeAramReader(0x211, 1, unsigned, 2)
sm.getAram_trackInstrumentPitches                   = makeAramReader(0x220, 2, unsigned, 2)
sm.getAram_trackRepeatedSubsectionAddresses         = makeAramReader(0x230, 2, unsigned, 2)
sm.getAram_trackRepeatedSubsectionReturnAddresses   = makeAramReader(0x240, 2, unsigned, 2)
sm.getAram_trackSlideLengths                        = makeAramReader(0x280, 1, unsigned, 2)
sm.getAram_trackSlideDelays                         = makeAramReader(0x281, 1, unsigned, 2)
sm.getAram_trackSlideDirections                     = makeAramReader(0x290, 1, unsigned, 2)
sm.getAram_trackSlideExtents                        = makeAramReader(0x291, 1, unsigned, 2)
sm.getAram_trackVibratoPhases                       = makeAramReader(0x2A0, 1, unsigned, 2)
sm.getAram_trackVibratoRates                        = makeAramReader(0x2A1, 1, unsigned, 2)
sm.getAram_trackVibratoDelays                       = makeAramReader(0x2B0, 1, unsigned, 2)
sm.getAram_trackDynamicVibratoLengths               = makeAramReader(0x2B1, 1, unsigned, 2)
sm.getAram_trackVibratoExtentDeltas                 = makeAramReader(0x2C0, 1, unsigned, 2)
sm.getAram_trackStaticVibratoExtents                = makeAramReader(0x2C1, 1, unsigned, 2)
sm.getAram_trackTremoloPhases                       = makeAramReader(0x2D0, 1, unsigned, 2)
sm.getAram_trackTremoloRates                        = makeAramReader(0x2D1, 1, unsigned, 2)
sm.getAram_trackTremoloDelays                       = makeAramReader(0x2E0, 1, unsigned, 2)
sm.getAram_trackTransposes                          = makeAramReader(0x2F0, 1, unsigned, 2)
sm.getAram_trackVolumes                             = makeAramReader(0x300, 2, unsigned, 2)
sm.getAram_trackVolumeDeltas                        = makeAramReader(0x310, 2, unsigned, 2)
sm.getAram_trackTargetVolumes                       = makeAramReader(0x320, 1, unsigned, 2)
sm.getAram_trackOutputVolumes                       = makeAramReader(0x321, 1, unsigned, 2)
sm.getAram_trackPanningBiases                       = makeAramReader(0x330, 2, unsigned, 2)
sm.getAram_trackPanningBiasDeltas                   = makeAramReader(0x340, 2, unsigned, 2)
sm.getAram_trackTargetPanningBiases                 = makeAramReader(0x350, 1, unsigned, 2)
sm.getAram_trackPhaseInversionOptions               = makeAramReader(0x351, 1, unsigned, 2)
sm.getAram_trackSubnotes                            = makeAramReader(0x360, 1, unsigned, 2)
sm.getAram_trackNotes                               = makeAramReader(0x361, 1, unsigned, 2)
sm.getAram_trackNoteDeltas                          = makeAramReader(0x370, 2, unsigned, 2)
sm.getAram_trackTargetNotes                         = makeAramReader(0x380, 1, unsigned, 2)
sm.getAram_trackSubtransposes                       = makeAramReader(0x381, 1, unsigned, 2)

-- Sound 1
sm.getAram_sound1                                   = makeAramReader(0x392, 1)
sm.getAram_i_sound1                                 = makeAramReader(0x393, 1)
sm.getAram_sound1_i_instructionLists                = makeAramReader(0x394, 1, unsigned, 1)
sm.getAram_sound1_instructionTimers                 = makeAramReader(0x398, 1, unsigned, 1)
sm.getAram_sound1_disableBytes                      = makeAramReader(0x39C, 1, unsigned, 1)
sm.getAram_sound1_i_channel                         = makeAramReader(0x3A0, 1)
sm.getAram_sound1_n_voices                          = makeAramReader(0x3A1, 1)
sm.getAram_sound1_i_voice                           = makeAramReader(0x3A2, 1)
sm.getAram_sound1_remainingEnabledSoundVoices       = makeAramReader(0x3A3, 1)
sm.getAram_sound1_initialisationFlag                = makeAramReader(0x3A4, 1)
sm.getAram_sound1_voiceId                           = makeAramReader(0x3A5, 1)
sm.getAram_sound1_voiceBitsets                      = makeAramReader(0x3A6, 1, unsigned, 1)
sm.getAram_sound1_voiceMasks                        = makeAramReader(0x3AA, 1, unsigned, 1)
sm.getAram_sound1_2i_channel                        = makeAramReader(0x3AE, 1)
sm.getAram_sound1_voiceIndices                      = makeAramReader(0x3AF, 1, unsigned, 1)
sm.getAram_sound1_enabledVoices                     = makeAramReader(0x3B3, 1)
sm.getAram_sound1_dspIndices                        = makeAramReader(0x3B4, 1, unsigned, 1)
sm.getAram_sound1_trackOutputVolumeBackups          = makeAramReader(0x3B8, 1, unsigned, 2)
sm.getAram_sound1_trackPhaseInversionOptionsBackups = makeAramReader(0x3B9, 1, unsigned, 2)
sm.getAram_sound1_releaseFlags                      = makeAramReader(0x3C0, 1, unsigned, 2)
sm.getAram_sound1_releaseTimers                     = makeAramReader(0x3C1, 1, unsigned, 2)
sm.getAram_sound1_repeatCounters                    = makeAramReader(0x3C8, 1, unsigned, 1)
sm.getAram_sound1_repeatPoints                      = makeAramReader(0x3CC, 1, unsigned, 1)
sm.getAram_sound1_adsrSettings                      = makeAramReader(0x3D0, 1, unsigned, 2)
sm.getAram_sound1_updateAdsrSettingsFlags           = makeAramReader(0x3D8, 1, unsigned, 1)
sm.getAram_sound1_notes                             = makeAramReader(0x3DC, 1, unsigned, 7)
sm.getAram_sound1_subnotes                          = makeAramReader(0x3DD, 1, unsigned, 7)
sm.getAram_sound1_subnoteDeltas                     = makeAramReader(0x3DE, 1, unsigned, 7)
sm.getAram_sound1_targetNotes                       = makeAramReader(0x3DF, 1, unsigned, 7)
sm.getAram_sound1_pitchSlideFlags                   = makeAramReader(0x3E0, 1, unsigned, 7)
sm.getAram_sound1_legatoFlags                       = makeAramReader(0x3E1, 1, unsigned, 7)
sm.getAram_sound1_pitchSlideLegatoFlags             = makeAramReader(0x3E2, 1, unsigned, 7)

-- Sound 2
sm.getAram_sound2                                   = makeAramReader(0x3F8, 1)
sm.getAram_i_sound2                                 = makeAramReader(0x3F9, 1)
sm.getAram_sound2_i_instructionLists                = makeAramReader(0x3FA, 1, unsigned, 1)
sm.getAram_sound2_instructionTimers                 = makeAramReader(0x3FC, 1, unsigned, 1)
sm.getAram_sound2_disableBytes                      = makeAramReader(0x3FE, 1, unsigned, 1)

sm.getAram_trackSkipNewNotesFlags                   = makeAramReader(0x400, 1, unsigned, 2)

sm.getAram_sound2_i_channel                         = makeAramReader(0x440, 1)
sm.getAram_sound2_n_voices                          = makeAramReader(0x441, 1)
sm.getAram_sound2_i_voice                           = makeAramReader(0x442, 1)
sm.getAram_sound2_remainingEnabledSoundVoices       = makeAramReader(0x443, 1)
sm.getAram_sound2_initialisationFlag                = makeAramReader(0x444, 1)
sm.getAram_sound2_voiceId                           = makeAramReader(0x445, 1)
sm.getAram_sound2_voiceBitsets                      = makeAramReader(0x446, 1, unsigned, 1)
sm.getAram_sound2_voiceMasks                        = makeAramReader(0x448, 1, unsigned, 1)
sm.getAram_sound2_2i_channel                        = makeAramReader(0x44A, 1)
sm.getAram_sound2_voiceIndices                      = makeAramReader(0x44B, 1, unsigned, 1)
sm.getAram_sound2_enabledVoices                     = makeAramReader(0x44D, 1)
sm.getAram_sound2_dspIndices                        = makeAramReader(0x44E, 1, unsigned, 1)
sm.getAram_sound2_trackOutputVolumeBackups          = makeAramReader(0x450, 1, unsigned, 2)
sm.getAram_sound2_trackPhaseInversionOptionsBackups = makeAramReader(0x451, 1, unsigned, 2)
sm.getAram_sound2_releaseFlags                      = makeAramReader(0x454, 1, unsigned, 2)
sm.getAram_sound2_releaseTimers                     = makeAramReader(0x455, 1, unsigned, 2)
sm.getAram_sound2_repeatCounters                    = makeAramReader(0x458, 1, unsigned, 1)
sm.getAram_sound2_repeatPoints                      = makeAramReader(0x45A, 1, unsigned, 1)
sm.getAram_sound2_adsrSettings                      = makeAramReader(0x45C, 1, unsigned, 2)
sm.getAram_sound2_updateAdsrSettingsFlags           = makeAramReader(0x460, 1, unsigned, 1)
sm.getAram_sound2_notes                             = makeAramReader(0x462, 1, unsigned, 7)
sm.getAram_sound2_subnotes                          = makeAramReader(0x463, 1, unsigned, 7)
sm.getAram_sound2_subnoteDeltas                     = makeAramReader(0x464, 1, unsigned, 7)
sm.getAram_sound2_targetNotes                       = makeAramReader(0x465, 1, unsigned, 7)
sm.getAram_sound2_pitchSlideFlags                   = makeAramReader(0x466, 1, unsigned, 7)
sm.getAram_sound2_legatoFlags                       = makeAramReader(0x467, 1, unsigned, 7)
sm.getAram_sound2_pitchSlideLegatoFlags             = makeAramReader(0x468, 1, unsigned, 7)

-- Sound 3
sm.getAram_sound3                                   = makeAramReader(0x470, 1)
sm.getAram_i_sound3                                 = makeAramReader(0x471, 1)
sm.getAram_sound3_i_instructionLists                = makeAramReader(0x472, 1, unsigned, 1)
sm.getAram_sound3_instructionTimers                 = makeAramReader(0x474, 1, unsigned, 1)
sm.getAram_sound3_disableBytes                      = makeAramReader(0x476, 1, unsigned, 1)
sm.getAram_sound3_i_channel                         = makeAramReader(0x478, 1)
sm.getAram_sound3_n_voices                          = makeAramReader(0x479, 1)
sm.getAram_sound3_i_voice                           = makeAramReader(0x47A, 1)
sm.getAram_sound3_remainingEnabledSoundVoices       = makeAramReader(0x47B, 1)
sm.getAram_sound3_initialisationFlag                = makeAramReader(0x47C, 1)
sm.getAram_sound3_voiceId                           = makeAramReader(0x47D, 1)
sm.getAram_sound3_voiceBitsets                      = makeAramReader(0x47E, 1, unsigned, 1)
sm.getAram_sound3_voiceMasks                        = makeAramReader(0x480, 1, unsigned, 1)
sm.getAram_sound3_2i_channel                        = makeAramReader(0x482, 1)
sm.getAram_sound3_voiceIndices                      = makeAramReader(0x483, 1, unsigned, 1)
sm.getAram_sound3_enabledVoices                     = makeAramReader(0x485, 1)
sm.getAram_sound3_dspIndices                        = makeAramReader(0x486, 1, unsigned, 1)
sm.getAram_sound3_trackOutputVolumeBackups          = makeAramReader(0x488, 1, unsigned, 2)
sm.getAram_sound3_trackPhaseInversionOptionsBackups = makeAramReader(0x489, 1, unsigned, 2)
sm.getAram_sound3_releaseFlags                      = makeAramReader(0x48C, 1, unsigned, 2)
sm.getAram_sound3_releaseTimers                     = makeAramReader(0x48D, 1, unsigned, 2)
sm.getAram_sound3_repeatCounters                    = makeAramReader(0x490, 1, unsigned, 1)
sm.getAram_sound3_repeatPoints                      = makeAramReader(0x492, 1, unsigned, 1)
sm.getAram_sound3_adsrSettings                      = makeAramReader(0x494, 1, unsigned, 2)
sm.getAram_sound3_updateAdsrSettingsFlags           = makeAramReader(0x498, 1, unsigned, 1)
sm.getAram_sound3_notes                             = makeAramReader(0x49A, 1, unsigned, 7)
sm.getAram_sound3_subnotes                          = makeAramReader(0x49B, 1, unsigned, 7)
sm.getAram_sound3_subnoteDeltas                     = makeAramReader(0x49C, 1, unsigned, 7)
sm.getAram_sound3_targetNotes                       = makeAramReader(0x49D, 1, unsigned, 7)
sm.getAram_sound3_pitchSlideFlags                   = makeAramReader(0x49E, 1, unsigned, 7)
sm.getAram_sound3_legatoFlags                       = makeAramReader(0x49F, 1, unsigned, 7)
sm.getAram_sound3_pitchSlideLegatoFlags             = makeAramReader(0x4A0, 1, unsigned, 7)

sm.getAram_disableProcessingCpuIo2                  = makeAramReader(0x4A9, 1)
sm.getAram_i_echoFirFilterSet                       = makeAramReader(0x4B1, 1)
sm.getAram_sound3LowHealthPriority                  = makeAramReader(0x4BA, 1)
sm.getAram_sound_priorities                         = makeAramReader(0x4BB, 1, unsigned, 1)

sm.getAram_echoBuffer                               = makeAramReader(0x500, 1, unsigned, 1)
sm.getAram_noteRingLengthTable                      = makeAramReader(0x5800, 1, unsigned, 1)
sm.getAram_noteVolumeTable                          = makeAramReader(0x5808, 1, unsigned, 1)
sm.getAram_trackerData                              = makeAramReader(0x6C00, 1, unsigned, 1)
sm.getAram_instrumentTable                          = makeAramReader(0x6C00, 1, unsigned, 1)
sm.getAram_sampleTable                              = makeAramReader(0x6D00, 1, unsigned, 1)
sm.getAram_sampleData                               = makeAramReader(0x6E00, 1, unsigned, 1)

-- Wrapper readers
sm.getAram_i_sound                                  = makeAggregateReader({ sm.getAram_i_sound1, sm.getAram_i_sound2, sm
    .getAram_i_sound3 })
sm.getAram_sound_instructionListPointerSet          = makeAggregateReader({ sm.getAram_sound1_instructionListPointerSet,
    sm.getAram_sound2_instructionListPointerSet, sm.getAram_sound3_instructionListPointerSet })
sm.getAram_sound_p_charVoiceBitset                  = makeAggregateReader({ sm.getAram_sound1_p_charVoiceBitset, sm
    .getAram_sound2_p_charVoiceBitset, sm.getAram_sound3_p_charVoiceBitset })
sm.getAram_sound_p_charVoiceMask                    = makeAggregateReader({ sm.getAram_sound1_p_charVoiceMask, sm
    .getAram_sound2_p_charVoiceMask, sm.getAram_sound3_p_charVoiceMask })
sm.getAram_sound_p_charVoiceIndex                   = makeAggregateReader({ sm.getAram_sound1_p_charVoiceIndex, sm
    .getAram_sound2_p_charVoiceIndex, sm.getAram_sound3_p_charVoiceIndex })
sm.getAram_sound                                    = makeAggregateReader({ sm.getAram_sound1, sm.getAram_sound2, sm
    .getAram_sound3 })
sm.getAram_sound_i_instructionLists                 = makeAggregateReader({ sm.getAram_sound1_i_instructionLists, sm
    .getAram_sound2_i_instructionLists, sm.getAram_sound3_i_instructionLists })
sm.getAram_sound_instructionTimers                  = makeAggregateReader({ sm.getAram_sound1_instructionTimers, sm
    .getAram_sound2_instructionTimers, sm.getAram_sound3_instructionTimers })
sm.getAram_sound_disableBytes                       = makeAggregateReader({ sm.getAram_sound1_disableBytes, sm
    .getAram_sound2_disableBytes, sm.getAram_sound3_disableBytes })
sm.getAram_sound_i_channel                          = makeAggregateReader({ sm.getAram_sound1_i_channel, sm
    .getAram_sound2_i_channel, sm.getAram_sound3_i_channel })
sm.getAram_sound_n_voices                           = makeAggregateReader({ sm.getAram_sound1_n_voices, sm
    .getAram_sound2_n_voices, sm.getAram_sound3_n_voices })
sm.getAram_sound_i_voice                            = makeAggregateReader({ sm.getAram_sound1_i_voice, sm
    .getAram_sound2_i_voice, sm.getAram_sound3_i_voice })
sm.getAram_sound_remainingEnabledSoundVoices        = makeAggregateReader({ sm
    .getAram_sound1_remainingEnabledSoundVoices, sm.getAram_sound2_remainingEnabledSoundVoices, sm
    .getAram_sound3_remainingEnabledSoundVoices })
sm.getAram_sound_initialisationFlag                 = makeAggregateReader({ sm.getAram_sound1_initialisationFlag, sm
    .getAram_sound2_initialisationFlag, sm.getAram_sound3_initialisationFlag })
sm.getAram_sound_voiceId                            = makeAggregateReader({ sm.getAram_sound1_voiceId, sm
    .getAram_sound2_voiceId, sm.getAram_sound3_voiceId })
sm.getAram_sound_voiceBitsets                       = makeAggregateReader({ sm.getAram_sound1_voiceBitsets, sm
    .getAram_sound2_voiceBitsets, sm.getAram_sound3_voiceBitsets })
sm.getAram_sound_voiceMasks                         = makeAggregateReader({ sm.getAram_sound1_voiceMasks, sm
    .getAram_sound2_voiceMasks, sm.getAram_sound3_voiceMasks })
sm.getAram_sound_2i_channel                         = makeAggregateReader({ sm.getAram_sound1_2i_channel, sm
    .getAram_sound2_2i_channel, sm.getAram_sound3_2i_channel })
sm.getAram_sound_voiceIndices                       = makeAggregateReader({ sm.getAram_sound1_voiceIndices, sm
    .getAram_sound2_voiceIndices, sm.getAram_sound3_voiceIndices })
sm.getAram_sound_enabledVoices                      = makeAggregateReader({ sm.getAram_sound1_enabledVoices, sm
    .getAram_sound2_enabledVoices, sm.getAram_sound3_enabledVoices })
sm.getAram_sound_dspIndices                         = makeAggregateReader({ sm.getAram_sound1_dspIndices, sm
    .getAram_sound2_dspIndices, sm.getAram_sound3_dspIndices })
sm.getAram_sound_trackOutputVolumeBackups           = makeAggregateReader({ sm.getAram_sound1_trackOutputVolumeBackups,
    sm.getAram_sound2_trackOutputVolumeBackups, sm.getAram_sound3_trackOutputVolumeBackups })
sm.getAram_sound_trackPhaseInversionOptionsBackups  = makeAggregateReader({ sm
    .getAram_sound1_trackPhaseInversionOptionsBackups, sm.getAram_sound2_trackPhaseInversionOptionsBackups, sm
    .getAram_sound3_trackPhaseInversionOptionsBackups })
sm.getAram_sound_releaseFlags                       = makeAggregateReader({ sm.getAram_sound1_releaseFlags, sm
    .getAram_sound2_releaseFlags, sm.getAram_sound3_releaseFlags })
sm.getAram_sound_releaseTimers                      = makeAggregateReader({ sm.getAram_sound1_releaseTimers, sm
    .getAram_sound2_releaseTimers, sm.getAram_sound3_releaseTimers })
sm.getAram_sound_repeatCounters                     = makeAggregateReader({ sm.getAram_sound1_repeatCounters, sm
    .getAram_sound2_repeatCounters, sm.getAram_sound3_repeatCounters })
sm.getAram_sound_repeatPoints                       = makeAggregateReader({ sm.getAram_sound1_repeatPoints, sm
    .getAram_sound2_repeatPoints, sm.getAram_sound3_repeatPoints })
sm.getAram_sound_adsrSettings                       = makeAggregateReader({ sm.getAram_sound1_adsrSettings, sm
    .getAram_sound2_adsrSettings, sm.getAram_sound3_adsrSettings })
sm.getAram_sound_updateAdsrSettingsFlags            = makeAggregateReader({ sm.getAram_sound1_updateAdsrSettingsFlags, sm
    .getAram_sound2_updateAdsrSettingsFlags, sm.getAram_sound3_updateAdsrSettingsFlags })
sm.getAram_sound_notes                              = makeAggregateReader({ sm.getAram_sound1_notes, sm
    .getAram_sound2_notes, sm.getAram_sound3_notes })
sm.getAram_sound_subnotes                           = makeAggregateReader({ sm.getAram_sound1_subnotes, sm
    .getAram_sound2_subnotes, sm.getAram_sound3_subnotes })
sm.getAram_sound_subnoteDeltas                      = makeAggregateReader({ sm.getAram_sound1_subnoteDeltas, sm
    .getAram_sound2_subnoteDeltas, sm.getAram_sound3_subnoteDeltas })
sm.getAram_sound_targetNotes                        = makeAggregateReader({ sm.getAram_sound1_targetNotes, sm
    .getAram_sound2_targetNotes, sm.getAram_sound3_targetNotes })
sm.getAram_sound_pitchSlideFlags                    = makeAggregateReader({ sm.getAram_sound1_pitchSlideFlags, sm
    .getAram_sound2_pitchSlideFlags, sm.getAram_sound3_pitchSlideFlags })
sm.getAram_sound_legatoFlags                        = makeAggregateReader({ sm.getAram_sound1_legatoFlags, sm
    .getAram_sound2_legatoFlags, sm.getAram_sound3_legatoFlags })
sm.getAram_sound_pitchSlideLegatoFlags              = makeAggregateReader({ sm.getAram_sound1_pitchSlideLegatoFlags, sm
    .getAram_sound2_pitchSlideLegatoFlags, sm.getAram_sound3_pitchSlideLegatoFlags })

sm.getAram_sound1_p_instructionList                 = makeAggregateReader({ sm.getAram_sound1_channel0_p_instructionList,
    sm.getAram_sound1_channel1_p_instructionList, sm.getAram_sound1_channel2_p_instructionList, sm
    .getAram_sound1_channel3_p_instructionList })
sm.getAram_sound2_p_instructionList                 = makeAggregateReader({ sm.getAram_sound2_channel0_p_instructionList,
    sm.getAram_sound2_channel1_p_instructionList })
sm.getAram_sound3_p_instructionList                 = makeAggregateReader({ sm.getAram_sound3_channel0_p_instructionList,
    sm.getAram_sound3_channel1_p_instructionList })
sm.getAram_sound_p_instructionList                  = makeAggregateReader({ sm.getAram_sound1_p_instructionList, sm
    .getAram_sound2_p_instructionList, sm.getAram_sound3_p_instructionList })

-- CPU IO cache registers
sm.getAram_cpuIo_read                              = makeAramReader(0x0, 1, false, 1)
sm.getAram_cpuIo_write                             = makeAramReader(0x4, 1, false, 1)
sm.getAram_cpuIo_read_prev                         = makeAramReader(0x8, 1, false, 1)

sm.getAram_musicTrackStatus                        = makeAramReader(0xC, 1)
sm.getAram_zero                                    = makeAramReader(0xD, 2)

-- Temporaries
sm.getAram_note                                    = makeAramReader(0xF, 2)
sm.getAram_panningBias                             = makeAramReader(0xF, 2)
sm.getAram_dspVoiceVolumeIndex                     = makeAramReader(0x11, 1)
sm.getAram_noteModifiedFlag                        = makeAramReader(0x12, 1)
sm.getAram_misc0                                   = makeAramReader(0x13, 2)
sm.getAram_misc1                                   = makeAramReader(0x15, 2)

sm.getAram_randomNumber                            = makeAramReader(0x17, 2)
sm.getAram_enableSoundEffectVoices                 = makeAramReader(0x19, 1)
sm.getAram_disableNoteProcessing                   = makeAramReader(0x1A, 1)
sm.getAram_p_return                                = makeAramReader(0x1B, 2)

-- Sound 1
sm.getAram_sound1_instructionListPointerSet        = makeAramReader(0x1D, 2)
sm.getAram_sound1_p_charVoiceBitset                = makeAramReader(0x1F, 2)
sm.getAram_sound1_p_charVoiceMask                  = makeAramReader(0x21, 2)
sm.getAram_sound1_p_charVoiceIndex                 = makeAramReader(0x23, 2)

-- Sounds
sm.getAram_sound_p_instructionListsLow             = makeAramReader(0x25, 1, false, 1)
sm.getAram_sound_p_instructionListsHigh            = makeAramReader(0x2D, 1, false, 1)

sm.getAram_trackPointers                           = makeAramReader(0x35, 2, false, 2)
sm.getAram_p_tracker                               = makeAramReader(0x45, 2)

-- TODO: this is invalidated up to 0xF0
sm.getAram_trackerTimer                            = makeAramReader(0x47, 1)
sm.getAram_soundEffectsClock                       = makeAramReader(0x48, 1)
sm.getAram_trackIndex                              = makeAramReader(0x49, 1)

-- DSP cache
sm.getAram_keyOnFlags                              = makeAramReader(0x4A, 1)
sm.getAram_keyOffFlags                             = makeAramReader(0x4B, 1)
sm.getAram_musicVoiceBitset                        = makeAramReader(0x4C, 1)
sm.getAram_flg                                     = makeAramReader(0x4D, 1)
sm.getAram_noiseEnableFlags                        = makeAramReader(0x4E, 1)
sm.getAram_echoEnableFlags                         = makeAramReader(0x4F, 1)
sm.getAram_pitchModulationFlags                    = makeAramReader(0x50, 1)

-- Echo
sm.getAram_echoTimer                               = makeAramReader(0x51, 1)
sm.getAram_echoDelay                               = makeAramReader(0x52, 1)
sm.getAram_echoFeedbackVolume                      = makeAramReader(0x53, 1)

-- Music
sm.getAram_musicTranspose                          = makeAramReader(0x54, 1)
sm.getAram_musicTrackClock                         = makeAramReader(0x55, 1)
sm.getAram_musicTempo                              = makeAramReader(0x56, 2)
sm.getAram_dynamicMusicTempoTimer                  = makeAramReader(0x58, 1)
sm.getAram_targetMusicTempo                        = makeAramReader(0x59, 1)
sm.getAram_musicTempoDelta                         = makeAramReader(0x5A, 2)
sm.getAram_musicVolume                             = makeAramReader(0x5C, 2)
sm.getAram_dynamicMusicVolumeTimer                 = makeAramReader(0x5E, 1)
sm.getAram_targetMusicVolume                       = makeAramReader(0x5F, 1)
sm.getAram_musicVolumeDelta                        = makeAramReader(0x60, 2)
sm.getAram_musicVoiceVolumeUpdateBitset            = makeAramReader(0x62, 1)
sm.getAram_percussionInstrumentsBaseIndex          = makeAramReader(0x63, 1)

-- Echo
sm.getAram_echoVolumeLeft                          = makeAramReader(0x64, 2)
sm.getAram_echoVolumeRight                         = makeAramReader(0x66, 2)
sm.getAram_echoVolumeLeftDelta                     = makeAramReader(0x68, 2)
sm.getAram_echoVolumeRightDelta                    = makeAramReader(0x6A, 2)
sm.getAram_dynamicEchoVolumeTimer                  = makeAramReader(0x6C, 1)
sm.getAram_targetEchoVolumeLeft                    = makeAramReader(0x6D, 1)
sm.getAram_targetEchoVolumeRight                   = makeAramReader(0x6E, 1)

-- Track
sm.getAram_trackNoteTimers                         = makeAramReader(0x6F, 1, false, 2)
sm.getAram_trackNoteRingTimers                     = makeAramReader(0x70, 1, false, 2)
sm.getAram_trackRepeatedSubsectionCounters         = makeAramReader(0x7F, 1, false, 2)
sm.getAram_trackDynamicVolumeTimers                = makeAramReader(0x80, 1, false, 2)
sm.getAram_trackDynamicPanningTimers               = makeAramReader(0x8F, 1, false, 2)
sm.getAram_trackPitchSlideTimers                   = makeAramReader(0x90, 1, false, 2)
sm.getAram_trackPitchSlideDelayTimers              = makeAramReader(0x9F, 1, false, 2)
sm.getAram_trackVibratoDelayTimers                 = makeAramReader(0xA0, 1, false, 2)
sm.getAram_trackVibratoExtents                     = makeAramReader(0xAF, 1, false, 2)
sm.getAram_trackTremoloDelayTimers                 = makeAramReader(0xB0, 1, false, 2)
sm.getAram_trackTremoloExtents                     = makeAramReader(0xBF, 1, false, 2)

-- Sounds
sm.getAram_p_echoBuffer                            = makeAramReader(0xCE, 2)
sm.getAram_sound2_instructionListPointerSet        = makeAramReader(0xD0, 2)
sm.getAram_sound2_p_charVoiceBitset                = makeAramReader(0xD2, 2)
sm.getAram_sound2_p_charVoiceMask                  = makeAramReader(0xD4, 2)
sm.getAram_sound2_p_charVoiceIndex                 = makeAramReader(0xD6, 2)
sm.getAram_sound3_instructionListPointerSet        = makeAramReader(0xD8, 2)
sm.getAram_sound3_p_charVoiceBitset                = makeAramReader(0xDA, 2)
sm.getAram_sound3_p_charVoiceMask                  = makeAramReader(0xDC, 2)
sm.getAram_sound3_p_charVoiceIndex                 = makeAramReader(0xDE, 2)

sm.getAram_trackDynamicVibratoTimers               = makeAramReader(0x100, 1, false, 2)

-- Music
sm.getAram_trackNoteLengths                        = makeAramReader(0x200, 1, false, 2)
sm.getAram_trackNoteRingLengths                    = makeAramReader(0x201, 1, false, 2)
sm.getAram_trackNoteVolume                         = makeAramReader(0x210, 1, false, 2)
sm.getAram_trackInstrumentIndices                  = makeAramReader(0x211, 1, false, 2)
sm.getAram_trackInstrumentPitches                  = makeAramReader(0x220, 1, false, 2)
sm.getAram_trackRepeatedSubsectionAddresses        = makeAramReader(0x230, 1, false, 2)
sm.getAram_trackRepeatedSubsectionReturnAddresses  = makeAramReader(0x240, 1, false, 2)
sm.getAram_trackSlideLengths                       = makeAramReader(0x250, 1, false, 2)
sm.getAram_trackSlideDelays                        = makeAramReader(0x251, 1, false, 2)
sm.getAram_trackSlideDirections                    = makeAramReader(0x260, 1, false, 2)
sm.getAram_trackSlideExtents                       = makeAramReader(0x261, 1, false, 2)
sm.getAram_trackVibratoPhases                      = makeAramReader(0x270, 1, false, 2)
sm.getAram_trackVibratoRates                       = makeAramReader(0x271, 1, false, 2)
sm.getAram_trackVibratoDelays                      = makeAramReader(0x280, 1, false, 2)
sm.getAram_trackDynamicVibratoLengths              = makeAramReader(0x281, 1, false, 2)
sm.getAram_trackVibratoExtentDeltas                = makeAramReader(0x290, 1, false, 2)
sm.getAram_trackStaticVibratoExtents               = makeAramReader(0x291, 1, false, 2)
sm.getAram_trackTremoloPhases                      = makeAramReader(0x2A0, 1, false, 2)
sm.getAram_trackTremoloRates                       = makeAramReader(0x2A1, 1, false, 2)
sm.getAram_trackTremoloDelays                      = makeAramReader(0x2B0, 1, false, 2)
sm.getAram_trackTransposes                         = makeAramReader(0x2B1, 1, false, 2)
sm.getAram_trackVolumes                            = makeAramReader(0x2C0, 1, false, 2)
sm.getAram_trackVolumeDeltas                       = makeAramReader(0x2D0, 1, false, 2)
sm.getAram_trackTargetVolumes                      = makeAramReader(0x2E0, 1, false, 2)
sm.getAram_trackOutputVolumes                      = makeAramReader(0x2E1, 1, false, 2)
sm.getAram_trackPanningBiases                      = makeAramReader(0x2F0, 1, false, 2)
sm.getAram_trackPanningBiasDeltas                  = makeAramReader(0x300, 1, false, 2)
sm.getAram_trackTargetPanningBiases                = makeAramReader(0x310, 1, false, 2)
sm.getAram_trackPhaseInversionOptions              = makeAramReader(0x311, 1, false, 2)
sm.getAram_trackSubnotes                           = makeAramReader(0x320, 1, false, 2)
sm.getAram_trackNotes                              = makeAramReader(0x321, 1, false, 2)
sm.getAram_trackNoteDeltas                         = makeAramReader(0x330, 1, false, 2)
sm.getAram_trackTargetNotes                        = makeAramReader(0x340, 1, false, 2)
sm.getAram_trackSubtransposes                      = makeAramReader(0x341, 1, false, 2)
sm.getAram_trackSkipNewNotesFlags                  = makeAramReader(0x350, 1, false, 2)

sm.getAram_i_globalChannel                         = makeAramReader(0x35F, 1)
sm.getAram_i_voice                                 = makeAramReader(0x360, 1)
sm.getAram_i_soundLibrary                          = makeAramReader(0x351, 1)

-- Sound 1
sm.getAram_i_sound1                                = makeAramReader(0x362, 1)
sm.getAram_sound1_i_channel                        = makeAramReader(0x363, 1)
sm.getAram_sound1_n_voices                         = makeAramReader(0x364, 1)
sm.getAram_sound1_i_voice                          = makeAramReader(0x365, 1)
sm.getAram_sound1_remainingEnabledSoundVoices      = makeAramReader(0x366, 1)
sm.getAram_sound1_voiceId                          = makeAramReader(0x367, 1)
sm.getAram_sound1_2i_channel                       = makeAramReader(0x368, 1)

-- Sound 2
sm.getAram_i_sound2                                = makeAramReader(0x369, 1)
sm.getAram_sound2_i_channel                        = makeAramReader(0x36A, 1)
sm.getAram_sound2_n_voices                         = makeAramReader(0x36B, 1)
sm.getAram_sound2_i_voice                          = makeAramReader(0x36C, 1)
sm.getAram_sound2_remainingEnabledSoundVoices      = makeAramReader(0x36D, 1)
sm.getAram_sound2_voiceId                          = makeAramReader(0x36E, 1)
sm.getAram_sound2_2i_channel                       = makeAramReader(0x36F, 1)

-- Sound 3
sm.getAram_i_sound3                                = makeAramReader(0x370, 1)
sm.getAram_sound3_i_channel                        = makeAramReader(0x371, 1)
sm.getAram_sound3_n_voices                         = makeAramReader(0x372, 1)
sm.getAram_sound3_i_voice                          = makeAramReader(0x373, 1)
sm.getAram_sound3_remainingEnabledSoundVoices      = makeAramReader(0x374, 1)
sm.getAram_sound3_voiceId                          = makeAramReader(0x375, 1)
sm.getAram_sound3_2i_channel                       = makeAramReader(0x376, 1)

-- Sounds
sm.getAram_sounds                                  = makeAramReader(0x377, 1, false, 1)
sm.getAram_sound_enabledVoices                     = makeAramReader(0x37A, 1, false, 1)
sm.getAram_sound_priorities                        = makeAramReader(0x37D, 1, false, 1)
sm.getAram_sound_initialisationFlags               = makeAramReader(0x380, 1, false, 1)

-- Sound channels
sm.getAram_sound_i_instructionLists                = makeAramReader(0x383, 1, false, 1)
sm.getAram_sound_instructionTimers                 = makeAramReader(0x38B, 1, false, 1)
sm.getAram_sound_disableBytes                      = makeAramReader(0x393, 1, false, 1)
sm.getAram_sound_voiceBitsets                      = makeAramReader(0x39B, 1, false, 1)
sm.getAram_sound_voiceMasks                        = makeAramReader(0x3A3, 1, false, 1)
sm.getAram_sound_voiceIndices                      = makeAramReader(0x3AB, 1, false, 1)
sm.getAram_sound_dspIndices                        = makeAramReader(0x3B3, 1, false, 1)
sm.getAram_sound_trackOutputVolumeBackups          = makeAramReader(0x3BB, 1, false, 1)
sm.getAram_sound_trackPhaseInversionOptionsBackups = makeAramReader(0x3C3, 1, false, 1)
sm.getAram_sound_releaseFlags                      = makeAramReader(0x3CB, 1, false, 1)
sm.getAram_sound_releaseTimers                     = makeAramReader(0x3D3, 1, false, 1)
sm.getAram_sound_repeatCounters                    = makeAramReader(0x3DB, 1, false, 1)
sm.getAram_sound_repeatPoints                      = makeAramReader(0x3E3, 1, false, 1)
sm.getAram_sound_adsrSettingsLow                   = makeAramReader(0x3EB, 1, false, 1)
sm.getAram_sound_adsrSettingsHigh                  = makeAramReader(0x3F3, 1, false, 1)
sm.getAram_sound_updateAdsrSettingsFlags           = makeAramReader(0x3FB, 1, false, 1)
sm.getAram_sound_notes                             = makeAramReader(0x403, 1, false, 1)
sm.getAram_sound_subnotes                          = makeAramReader(0x40B, 1, false, 1)
sm.getAram_sound_subnoteDeltas                     = makeAramReader(0x413, 1, false, 1)
sm.getAram_sound_targetNotes                       = makeAramReader(0x41B, 1, false, 1)
sm.getAram_sound_pitchSlideFlags                   = makeAramReader(0x423, 1, false, 1)
sm.getAram_sound_legatoFlags                       = makeAramReader(0x42B, 1, false, 1)
sm.getAram_sound_pitchSlideLegatoFlags             = makeAramReader(0x433, 1, false, 1)

sm.getAram_disableProcessingCpuIo2                 = makeAramReader(0x43B, 1)
sm.getAram_i_echoFirFilterSet                      = makeAramReader(0x43C, 1)
sm.getAram_sound3LowHealthPriority                 = makeAramReader(0x43D, 1)

sm.getAram_noteRingLengthTable                     = makeAramReader(0x3855, 1, false, 1)
sm.getAram_noteVolumeTable                         = makeAramReader(0x385D, 1, false, 1)
sm.getAram_instrumentTable                         = makeAramReader(0x386D, 1, false, 1)
sm.getAram_trackerData                             = makeAramReader(0x3957, 1, false, 1)
sm.getAram_sampleTable                             = makeAramReader(0x4A00, 1, false, 1)
sm.getAram_sampleData_echoBuffer                   = makeAramReader(0x4B00, 1, false, 1)
-- ]]

sm.poses = {
    [0x00] = 'Facing forward',
    [0x01] = 'Facing right, normal',
    [0x02] = 'Facing left, normal',
    [0x03] = 'Facing right, aiming up',
    [0x04] = 'Facing left, aiming up',
    [0x05] = 'Facing right, aiming upright',
    [0x06] = 'Facing left, aiming upleft',
    [0x07] = 'Facing right, aiming downright',
    [0x08] = 'Facing left, aiming downleft',
    [0x09] = 'Moving right, not aiming',
    [0x0A] = 'Moving left, not aiming',
    [0x0B] = 'Moving right, gun extended forward (not aiming)',
    [0x0C] = 'Moving left, gun extended forward (not aiming)',
    [0x0D] = 'Moving right, aiming straight up (unused?)',
    [0x0E] = 'Moving left, aiming straight up (unused?)',
    [0x0F] = 'Moving right, aiming upright',
    [0x10] = 'Moving left, aiming upleft',
    [0x11] = 'Moving right, aiming downright',
    [0x12] = 'Moving left, aiming downleft',
    [0x13] = 'Normal jump facing right, gun extended, not aiming or moving',
    [0x14] = 'Normal jump facing left, gun extended, not aiming or moving',
    [0x15] = 'Normal jump facing right, aiming up',
    [0x16] = 'Normal jump facing left, aiming up',
    [0x17] = 'Normal jump facing right, aiming down',
    [0x18] = 'Normal jump facing left, aiming down',
    [0x19] = 'Spin Jump right',
    [0x1A] = 'Spin Jump left',
    [0x1B] = 'Space jump right',
    [0x1C] = 'Space jump left',
    [0x1D] = 'Facing right as morphball, no springball',
    [0x1E] = 'Moving right as a morphball on ground without springball',
    [0x1F] = 'Moving left as a morphball on ground without springball',
    [0x20] = 'Spinjump right. Unused?',
    [0x21] = 'Spinjump right. Unused?',
    [0x22] = 'Spinjump right. Unused?',
    [0x23] = 'Spinjump right. Unused?',
    [0x24] = 'Spinjump right. Unused?',
    [0x25] = 'Starting standing right, turning left',
    [0x26] = 'Starting standing left, turning right',
    [0x27] = 'Crouching, facing right',
    [0x28] = 'Crouching, facing left',
    [0x29] = 'Falling facing right, normal pose',
    [0x2A] = 'Falling facing left, normal pose',
    [0x2B] = 'Falling facing right, aiming up',
    [0x2C] = 'Falling facing left, aiming up',
    [0x2D] = 'Falling facing right, aiming down',
    [0x2E] = 'Falling facing left, aiming down',
    [0x2F] = 'Starting with normal jump facing right, turning left',
    [0x30] = 'Starting with normal jump facing left, turning right',
    [0x31] = 'Midair morphball facing right without springball',
    [0x32] = 'Midair morphball facing left without springball',
    [0x33] = 'Spinjump right. Unused?',
    [0x34] = 'Spinjump right. Unused?',
    [0x35] = 'Crouch transition, facing right',
    [0x36] = 'Crouch transition, facing left',
    [0x37] = 'Morphing into ball, facing right. Ground and mid-air',
    [0x38] = 'Morphing into ball, facing left. Ground and mid-air',
    [0x39] = 'Midair morphing into ball, facing right? May be unused',
    [0x3A] = 'Midair morphing into ball, facing left? May be unused',
    [0x3B] = 'Standing from crouching, facing right',
    [0x3C] = 'Standing from crouching, facing left',
    [0x3D] = 'Demorph while facing right. Mid-air and on ground',
    [0x3E] = 'Demorph while facing left. Mid-air and on ground',
    [0x3F] = 'Some transition with morphball, facing right. Maybe unused',
    [0x40] = 'Some transition with morphball, facing left. Maybe unused',
    [0x41] = 'Staying still with morphball, facing left, no springball',
    [0x42] = 'Spinjump right. Unused?',
    [0x43] = 'Starting from crouching right, turning left',
    [0x44] = 'Starting from crouching left, turning right',
    [0x45] = 'Running, facing right, shooting left. Unused? (Fast moonwalk)',
    [0x46] = 'Running, facing left, shooting right. Unused? (Fast moonwalk)',
    [0x47] = 'Standing, facing right. Unused?',
    [0x48] = 'Standing, facing left. Unused?',
    [0x49] = 'Moonwalk, facing left',
    [0x4A] = 'Moonwalk, facing right',
    [0x4B] = 'Normal jump transition from ground(standing or crouching), facing right',
    [0x4C] = 'Normal jump transition from ground(standing or crouching), facing left',
    [0x4D] = 'Normal jump facing right, gun not extended, not aiming, not moving',
    [0x4E] = 'Normal jump facing left, gun not extended, not aiming, not moving',
    [0x4F] = 'Hurt roll back, moving right/facing left',
    [0x50] = 'Hurt roll back, moving left/facing right',
    [0x51] = 'Normal jump facing right, moving forward (gun extended)',
    [0x52] = 'Normal jump facing left, moving forward (gun extended)',
    [0x53] = 'Hurt, facing right',
    [0x54] = 'Hurt, facing left',
    [0x55] = 'Normal jump transition from ground, facing right and aiming up',
    [0x56] = 'Normal jump transition from ground, facing left and aiming up',
    [0x57] = 'Normal jump transition from ground, facing right and aiming upright',
    [0x58] = 'Normal jump transition from ground, facing left and aiming upleft',
    [0x59] = 'Normal jump transition from ground, facing right and aiming downright',
    [0x5A] = 'Normal jump transition from ground, facing left and aiming downleft',
    [0x5B] = 'Something for grapple (wall jump?), probably unused',
    [0x5C] = 'Something for grapple (wall jump?), probably unused',
    [0x5D] = 'Broken grapple? Facing clockwise, maybe unused',
    [0x5E] = 'Broken grapple? Facing clockwise, maybe unused',
    [0x5F] = 'Broken grapple? Facing clockwise, maybe unused',
    [0x60] = 'Better broken grapple. Facing clockwise, maybe unused',
    [0x61] = 'Nearly normal grapple. Facing clockwise, maybe unused',
    [0x62] = 'Nearly normal grapple. Facing counterclockwise, maybe unused',
    [0x63] = 'Facing left on grapple blocks, ready to jump. Unused?',
    [0x64] = 'Facing right on grapple blocks, ready to jump. Unused?',
    [0x65] = 'Glitchy jump, facing left. Used by unused grapple jump?',
    [0x66] = 'Glitchy jump, facing right. Used by unused grapple jump?',
    [0x67] = 'Facing right, falling, fired a shot',
    [0x68] = 'Facing left, falling, fired a shot',
    [0x69] = 'Normal jump facing right, aiming upright. Moving optional',
    [0x6A] = 'Normal jump facing left, aiming upleft. Moving optional',
    [0x6B] = 'Normal jump facing right, aiming downright. Moving optional',
    [0x6C] = 'Normal jump facing left, aiming downleft. Moving optional',
    [0x6D] = 'Falling facing right, aiming upright',
    [0x6E] = 'Falling facing left, aiming upleft',
    [0x6F] = 'Falling facing right, aiming downright',
    [0x70] = 'Falling facing left, aiming downleft',
    [0x71] = 'Standing to crouching, facing right and aiming upright',
    [0x72] = 'Standing to crouching, facing left and aiming upleft',
    [0x73] = 'Standing to crouching, facing right and aiming downright',
    [0x74] = 'Standing to crouching, facing left and aiming downleft',
    [0x75] = 'Moonwalk, facing left aiming upleft',
    [0x76] = 'Moonwalk, facing right aiming upright',
    [0x77] = 'Moonwalk, facing left aiming downleft',
    [0x78] = 'Moonwalk, facing right aiming downright',
    [0x79] = 'Spring ball on ground, facing right',
    [0x7A] = 'Spring ball on ground, facing left',
    [0x7B] = 'Spring ball on ground, moving right',
    [0x7C] = 'Spring ball on ground, moving left',
    [0x7D] = 'Spring ball falling, facing/moving right',
    [0x7E] = 'Spring ball falling, facing/moving left',
    [0x7F] = 'Spring ball jump in air, facing/moving right',
    [0x80] = 'Spring ball jump in air, facing/moving left',
    [0x81] = 'Screw attack right',
    [0x82] = 'Screw attack left',
    [0x83] = 'Walljump right',
    [0x84] = 'Walljump left',
    [0x85] = 'Crouching, facing right aiming up',
    [0x86] = 'Crouching, facing left aiming up',
    [0x87] = 'Turning from right to left while falling',
    [0x88] = 'Turning from left to right while falling',
    [0x89] = 'Ran into a wall on right (facing right)',
    [0x8A] = 'Ran into a wall on left (facing left)',
    [0x8B] = 'Turning around from right to left while aiming straight up while standing',
    [0x8C] = 'Turning around from left to right while aiming straight up while standing',
    [0x8D] = 'Turn around from right to left while aiming diagonal down while standing',
    [0x8E] = 'Turn around from left to right while aiming diagonal down while standing',
    [0x8F] = 'Turning around from right to left while aiming straight up in midair',
    [0x90] = 'Turning around from left to right while aiming straight up in midair',
    [0x91] = 'Turning around from right to left while aiming down or diagonal down in midair',
    [0x92] = 'Turning around from left to right while aiming down or diagonal down in midair',
    [0x93] = 'Turning around from right to left while aiming straight up while falling',
    [0x94] = 'Turning around from left to right while aiming straight up while falling',
    [0x95] = 'Turning around from right to left while aiming down or diagonal down while falling',
    [0x96] = 'Turning around from left to right while aiming down or diagonal down while falling',
    [0x97] = 'Turning around from right to left while aiming straight up while crouching',
    [0x98] = 'Turning around from left to right while aiming straight up while crouching',
    [0x99] = 'Turning around from right to left while aiming diagonal down while crouching',
    [0x9A] = 'Turning around from left to right while aiming diagonal down while crouching',
    [0x9B] = 'Facing forward, ala Elevator pose... with the Varia and/or Gravity Suit.',
    [0x9C] = 'Turning around from right to left while aiming diagonal up while standing',
    [0x9D] = 'Turning around from left to right while aiming diagonal up while standing',
    [0x9E] = 'Turning around from right to left while aiming diagonal up in midair',
    [0x9F] = 'Turning around from left to right while aiming diagonal up in midair',
    [0xA0] = 'Turning around from right to left while aiming diagonal up while falling',
    [0xA1] = 'Turning around from left to right while aiming diagonal up while falling',
    [0xA2] = 'Turn around from right to left while aiming diagonal up while crouching',
    [0xA3] = 'Turn around from left to right while aiming diagonal up while crouching',
    [0xA4] = 'Landing from normal jump, facing right',
    [0xA5] = 'Landing from normal jump, facing left',
    [0xA6] = 'Landing from spin jump, facing right',
    [0xA7] = 'Landing from spin jump, facing left',
    [0xA8] = 'Just standing, facing right. Unused? (Grapple movement)',
    [0xA9] = 'Just standing, facing left. Unused? (Grapple movement)',
    [0xAA] = 'Just standing, facing right aiming downright. Unused? (Grapple movement)',
    [0xAB] = 'Just standing, facing left aiming downleft. Unused? (Grapple movement)',
    [0xAC] = 'Jumping, facing right, gun extended. Unused? (Grapple movement)',
    [0xAD] = 'Jumping, facing left, gun extended. Unused? (Grapple movement)',
    [0xAE] = 'Jumping, facing right, aiming down. Unused? (Grapple movement)',
    [0xAF] = 'Jumping, facing left, aiming down. Unused? (Grapple movement)',
    [0xB0] = 'Jumping, facing right, aiming downright. Unused? (Grapple movement)',
    [0xB1] = 'Jumping, facing left, aiming downleft. Unused? (Grapple movement)',
    [0xB2] = 'Grapple, facing clockwise',
    [0xB3] = 'Grapple, facing counterclockwise',
    [0xB4] = 'Crouching, facing right. Unused? (Grapple movement)',
    [0xB5] = 'Crouching, facing left. Unused? (Grapple movement)',
    [0xB6] = 'Crouching, facing right, aiming downright. Unused? (Grapple movement)',
    [0xB7] = 'Crouching, facing left, aiming downleft. Unused? (Grapple movement)',
    [0xB8] = 'Grapple, attached to a wall on right, facing left',
    [0xB9] = 'Grapple, attached to a wall on left, facing right',
    [0xBA] = 'Grabbed by Draygon, facing left, not moving',
    [0xBB] = 'Grabbed by Draygon, facing left aiming upleft, not moving',
    [0xBC] = 'Grabbed by Draygon, facing left and firing',
    [0xBD] = 'Grabbed by Draygon, facing left aiming downleft, not moving',
    [0xBE] = 'Grabbed by Draygon, facing left, moving',
    [0xBF] = 'Jump/Turn right to left while moonwalking.',
    [0xC0] = 'Jump/Turn left to right while moonwalking.',
    [0xC1] = 'Jump/Turn right to left while moonwalking and aiming diagonal up.',
    [0xC2] = 'Jump/Turn left to right while moonwalking and aiming diagonal up.',
    [0xC3] = 'Jump/Turn right to left while moonwalking and aiming diagonal down.',
    [0xC4] = 'Jump/Turn left to right while moonwalking and aiming diagonal down.',
    [0xC5] = 'Morph ball, facing right. Unused? (Grabbed by Draygon movement)',
    [0xC6] = 'Morph ball, facing left. Unused? (Grabbed by Draygon movement)',
    [0xC7] = 'Super jump windup, facing right',
    [0xC8] = 'Super jump windup, facing left',
    [0xC9] = 'Horizontal super jump, right',
    [0xCA] = 'Horizontal super jump, left',
    [0xCB] = 'Vertical super jump, facing right',
    [0xCC] = 'Vertical super jump, facing left',
    [0xCD] = 'Diagonal super jump, right',
    [0xCE] = 'Diagonal super jump, left',
    [0xCF] = 'Samus ran right into a wall, is still holding right and is now aiming diagonal up',
    [0xD0] = 'Samus ran left into a wall, is still holding left and is now aiming diagonal up',
    [0xD1] = 'Samus ran right into a wall, is still holding right and is now aiming diagonal down',
    [0xD2] = 'Samus ran left into a wall, is still holding left and is now aiming diagonal down',
    [0xD3] = 'Crystal flash, facing right',
    [0xD4] = 'Crystal flash, facing left',
    [0xD5] = 'X-raying right, standing',
    [0xD6] = 'X-raying left, standing',
    [0xD7] = 'Crystal flash ending, facing right',
    [0xD8] = 'Crystal flash ending, facing left',
    [0xD9] = 'X-raying right, crouching',
    [0xDA] = 'X-raying left, crouching',
    [0xDB] = 'Standing transition to morphball, facing right? Unused?',
    [0xDC] = 'Standing transition to morphball, facing left? Unused?',
    [0xDD] = 'Morphball transition to standing, facing right? Unused?',
    [0xDE] = 'Morphball transition to standing, facing left? Unused?',
    [0xDF] = 'Samus is facing left as a morphball. Unused? (Grabbed by Draygon movement)',
    [0xE0] = 'Landing from normal jump, facing right and aiming up',
    [0xE1] = 'Landing from normal jump, facing left and aiming up',
    [0xE2] = 'Landing from normal jump, facing right and aiming upright',
    [0xE3] = 'Landing from normal jump, facing left and aiming upleft',
    [0xE4] = 'Landing from normal jump, facing right and aiming downright',
    [0xE5] = 'Landing from normal jump, facing left and aiming downleft',
    [0xE6] = 'Landing from normal jump, facing right, firing',
    [0xE7] = 'Landing from normal jump, facing left, firing',
    [0xE8] = 'Samus exhausted(Metroid drain, MB attack), facing right',
    [0xE9] = 'Samus exhausted(Metroid drain, MB attack), facing left',
    [0xEA] = 'Samus exhausted, looking up to watch Metroid attack MB, facing right',
    [0xEB] = 'Samus exhausted, looking up to watch Metroid attack MB, facing left',
    [0xEC] = 'Grabbed by Draygon, facing right. Not moving',
    [0xED] = 'Grabbed by Draygon, facing right aiming upright. Not moving',
    [0xEE] = 'Grabbed by Draygon, facing right and firing.',
    [0xEF] = 'Grabbed by Draygon, facing right aiming downright. Not moving',
    [0xF0] = 'Grabbed by Draygon, facing right. Moving',
    [0xF1] = 'Crouch transition, facing right and aiming up',
    [0xF2] = 'Crouch transition, facing left and aiming up',
    [0xF3] = 'Crouch transition, facing right and aiming upright',
    [0xF4] = 'Crouch transition, facing left and aiming upleft',
    [0xF5] = 'Crouch transition, facing right and aiming downright',
    [0xF6] = 'Crouch transition, facing left and aiming downleft',
    [0xF7] = 'Crouching to standing, facing right and aiming up',
    [0xF8] = 'Crouching to standing, facing left and aiming upleft',
    [0xF9] = 'Crouching to standing, facing right and aiming upright',
    [0xFA] = 'Crouching to standing, facing left and aiming upleft',
    [0xFB] = 'Crouching to standing, facing right and aiming downright',
    [0xFC] = 'Crouching to standing, facing left and aiming downleft',
}

return sm
