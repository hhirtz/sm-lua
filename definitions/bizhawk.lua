---@meta

---@class mainmemory
mainmemory = {}

---@param address integer
---@return integer
function mainmemory.read_u8(address) end

---@param address integer
---@return integer
function mainmemory.read_s8(address) end

---@param address integer
---@return integer
function mainmemory.read_u16_le(address) end

---@param address integer
---@return integer
function mainmemory.read_s16_le(address) end

---@class memory
memory = {}

---@param address integer
---@param domain? string
---@return integer
function memory.read_u8(address, domain) end

---@param address integer
---@param domain? string
---@return integer
function memory.read_s8(address, domain) end

---@param address integer
---@param domain? string
---@return integer
function memory.read_u16_le(address, domain) end

---@param address integer
---@param domain? string
---@return integer
function memory.read_s16_le(address, domain) end
