---@meta

---@alias luacolor integer|string

---@class (exact) client
client = {}

---@return boolean
---@nodiscard
function client.ispaused() end

---@return boolean
---@nodiscard
function client.isseeking() end

---@param x integer
---@param y integer
---@return { x: integer, y: integer }
---@nodiscard
function client.transformPoint(x, y) end

---@class (exact) emu
emu = {}

function emu.frameadvance() end

---@return integer
---@nodiscard
function emu.framecount() end

---@class (exact) event
event = {}

---@param f fun()
---@param name? string
---@return string
function event.onexit(f, name) end

---@param f fun()
---@param name? string
---@return string
function event.onframestart(f, name) end

---@class (exact) LuaCanvas
LuaCanvas = {}

---@param color luacolor
function LuaCanvas.Clear(color) end

---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param fg? luacolor  something by default
---@param bg? luacolor  something by default
function LuaCanvas.DrawBox(x1, y1, x2, y2, fg, bg) end

---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param color? luacolor  black by default
function LuaCanvas.DrawLine(x1, y1, x2, y2, color) end

---@param x1 integer
---@param y1 integer
---@param width integer
---@param height integer
---@param fg? luacolor  something by default
---@param bg? luacolor  something by default
function LuaCanvas.DrawRectangle(x1, y1, width, height, fg, bg) end

function LuaCanvas.Refresh() end

---@param x integer
---@param y integer
function LuaCanvas.SetLocation(x, y) end

---@class (exact) gui
gui = {}

function gui.clearGraphics() end

function gui.cleartext() end

---@param width integer
---@param height integer
---@return LuaCanvas
---@nodiscard
function gui.createcanvas(width, height) end

---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param fg? luacolor  something by default
---@param bg? luacolor  something by default
---@param surfacename? string
function gui.drawBox(x1, y1, x2, y2, fg, bg, surfacename) end

---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@param color? luacolor  black by default
---@param surfacename? string
function gui.drawLine(x1, y1, x2, y2, color, surfacename) end

---@param points integer[][]
---@param offset_x integer
---@param offset_y integer
---@param fg? luacolor  something by default
---@param bg? luacolor  something by default
---@param surfacename? string
function gui.drawPolygon(points, offset_x, offset_y, fg, bg, surfacename) end

---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param fg? luacolor  something by default
---@param bg? luacolor  something by default
---@param surfacename? string
function gui.drawRectangle(x, y, width, height, fg, bg, surfacename) end

---@param x integer
---@param y integer
---@param message string
---@param fg? luacolor  something by default
---@param anchor? "topleft" | "topright" | "bottomleft" | "bottomright"
function gui.text(x, y, message, fg, anchor) end

---@class (exact) input
input = {}

---@return any
---@nodiscard
function input.get() end

---@class (exact) mainmemory
mainmemory = {}

---@param address integer
---@param length integer
---@return integer[]
---@nodiscard
function mainmemory.read_bytes_as_array(address, length) end

---@param address integer
---@return integer
---@nodiscard
function mainmemory.read_u8(address) end

---@param address integer
---@return integer
---@nodiscard
function mainmemory.read_s8(address) end

---@param address integer
---@return integer
---@nodiscard
function mainmemory.read_u16_le(address) end

---@param address integer
---@return integer
---@nodiscard
function mainmemory.read_s16_le(address) end

---@class (exact) memory
memory = {}

---@param address integer
---@param length integer
---@return integer[]
---@nodiscard
function memory.read_bytes_as_array(address, length) end

---@param address integer
---@param domain? string
---@return integer
---@nodiscard
function memory.read_u8(address, domain) end

---@param address integer
---@param domain? string
---@return integer
---@nodiscard
function memory.read_s8(address, domain) end

---@param address integer
---@param domain? string
---@return integer
---@nodiscard
function memory.read_u16_le(address, domain) end

---@param address integer
---@param domain? string
---@return integer
---@nodiscard
function memory.read_u32_le(address, domain) end

---@param address integer
---@param domain? string
---@return integer
---@nodiscard
function memory.read_s16_le(address, domain) end

---@param address integer
---@param value integer
---@param domain? string
function memory.write_u8(address, value, domain) end

---@param address integer
---@param value integer
---@param domain? string
function memory.write_s8(address, value, domain) end

---@param address integer
---@param value integer
---@param domain? string
function memory.write_u16_le(address, value, domain) end

---@param address integer
---@param value integer
---@param domain? string
function memory.write_s16_le(address, value, domain) end
