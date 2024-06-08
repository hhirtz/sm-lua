-- Patch some functions for cross-emu compatibility
local xemu = {}

-- Converts from SNES address model to flat address model (for ROM access)
local function snes2pc(p)
    return ((p >> 1) & 0x3F8000) + (p & 0x7FFF)
end

local function makeMemoryReader(f)
    return function(p)
        if p < 0x800000 then
            return f(p & 0x1FFFF, "WRAM")
        else
            return f(snes2pc(p), "CARTROM")
        end
    end
end

local function makeMemoryWriter(f)
    return function(p, v)
        if p < 0x800000 then
            return f(p & 0x1FFFF, v, "WRAM")
        else
            print(string.format('Error: trying to write to ROM address %X', p))
        end
    end
end

local function makeAramReader(f)
    return function(p)
        return f(p, "APURAM")
    end
end

xemu.read_u8          = makeMemoryReader(memory.read_u8)
xemu.read_u16_le      = makeMemoryReader(memory.read_u16_le)
xemu.read_s8          = makeMemoryReader(memory.read_s8)
xemu.read_s16_le      = makeMemoryReader(memory.read_s16_le)
xemu.write_u8         = makeMemoryWriter(memory.write_u8)
xemu.write_u16_le     = makeMemoryWriter(memory.write_u16_le)

xemu.read_aram_u8     = makeAramReader(memory.read_u8)
xemu.read_aram_u16_le = makeAramReader(memory.read_u16_le)
xemu.read_aram_s8     = makeAramReader(memory.read_s8)
xemu.read_aram_s16_le = makeAramReader(memory.read_s16_le)

return xemu
