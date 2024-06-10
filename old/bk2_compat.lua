-- make lsnes scripts compatible with bizhawk
--
-- usage: at the begining of the script, add
-- require('bk2_compat').ible()
--
-- ref: https://repo.or.cz/lsnes.git/blob_plain/80867950f33abf6b214604f53dcabb939a968c77:/lua.pdf
-- ref: https://tasvideos.org/Bizhawk/LuaFunctions

if memory.read_u16_le == nil then
    -- do nothing on lsnes
    return
end

if ... == nil then
    -- do nothing as a standalone script
    return
end

local repaint_early_requested = false

local function bit_compat()
    -- use "load" because this code triggers syntax errors on lsnes
    load([[
        bit.bnot = function(a, ...)
            for _, x in ipairs({...}) do
                a = a | x
            end
            return ~a
        end
        bit.none = bit.bnot

        bit.bor = function(a, ...)
            for _, x in ipairs({...}) do
                a = a | x
            end
            return a
        end
        bit.any = bit.bor

        bit.band = function(a, ...)
            for _, x in ipairs({...}) do
                a = a & x
            end
            return a
        end
        bit.all = bit.band

        bit.bxor = function(a, ...)
            for _, x in ipairs({...}) do
                a = a ~ x
            end
            return a
        end
        bit.parity = bit.xor

        bit.lrotate = function(x, nplaces, nbits)
            nplaces = nplaces or 1
            nbits = nbits or 48
            return bit.rol(x, nplaces) & ((1 << nbits) - 1)
            --return ((x << nplaces) & ((1 << nbits) - 1)) | (x >> (nbits - nplaces))
        end

        bit.rrotate = function(x, nplaces, nbits)
            nplaces = nplaces or 1
            nbits = nbits or 48
            return bit.ror(x, nplaces) & ((1 << nbits) - 1)
            --return ((x << (nbits - nplaces)) & ((1 << nbits) - 1)) | (x >> nplaces)
        end

        bit.lshift = function(x, nplaces, nbits)
            nplaces = nplaces or 1
            nbits = nbits or 48
            return (x << nplaces) & ((1 << nbits) - 1)
        end

        bit.lrshift = function(x, nplaces, nbits)
            nplaces = nplaces or 1
            nbits = nbits or 48
            return (x >> nplaces) & ((1 << nbits) - 1)
        end

        local _old_arshift = bit.arshift
        bit.arshift = function(x, nplaces, nbits)
            nplaces = nplaces or 1
            nbits = nbits or 48
            return _old_arshift(x, nplaces) & ((1 << nbits) - 1)
        end

        bit.extract = function(base, ...)
            local res = 0
            for _, x in ipairs({...}) do
                res = res << 1
                if x == true then
                    res = res | 1
                elseif x == false then
                    -- do nothing
                else
                    res = res | ((base >> x) & 1)
                end
            end
            return res
        end

        bit.value = function(...)
            local res = 0
            for _, x in ipairs({...}) do
                if x ~= nil then
                    res = res | (1 << x)
                end
            end
            return res
        end

        bit.test = function(a, bit)
            return (a & (1 << bit)) ~= 0
        end

        bit.testn = function(a, bit)
            return (a & (1 << bit)) == 0
        end

        bit.test_any = function(a, b)
            return (a & b) ~= 0
        end

        bit.test_all = function(a, b)
            return (a & b) == b
        end

        bit.popcount = function(a)
            local count = 0
            while a ~= 0 do
                count = count + (a & 1)
                a = a >> 1
            end
            return count
        end

        bit.clshift = function(a, b, nplaces, nbits)
            nplaces = nplaces or 1
            nbits = nbits or 48
            local a2 = ((a << nplaces) & ((1 << nbits) - 1)) | ((b >> (nbits - nplaces)) & ((1 << nbits) - 1))
            local b2 = ((b << nplaces) & ((1 << nbits) - 1))
            return a2, b2
        end

        bit.crshift = function(a, b, nplaces, nbits)
            nplaces = nplaces or 1
            nbits = nbits or 48
            local a2 = ((a >> nplaces) & ((1 << nbits) - 1))
            local b2 = ((b >> nplaces) & ((1 << nbits) - 1)) | ((a & ((1 << nplaces) - 1)) << (nbits - nplaces))
            return a2, b2
        end

        -- TODO bit.flagdecode
        -- TODO bit.rflagdecode
        -- TODO bit.swap{,s}{,h,d,q}word
        -- TODO bit.compose
        -- TODO bit.binary_ld_*
        -- TODO bit.binary_st_*
        -- TODO bit.quotent
        -- TODO bit.multidiv

        bit.mul32 = function(a, b)
            res = (a & 0xFFFFFFFF) * (b & 0xFFFFFFFF)
            return res & 0xFFFFFFFF, res >> 32
        end
    ]])()
end

local function font_compat()
    gui.font = {}
    gui.font.load = function(...) end
end

local function gui_compat()
    load([[
        fix_color = function(c)
            if c == nil then
                return nil
            end
            if c == -1 then
                return 0
            end
            local a = (c >> 24) & 0xFF
            a = 0xFF - a
            return (a << 24) | (c & 0xFFFFFF)
        end
    ]], 'fix_color', 't', _ENV)()
    gui.screenshot = function(path)
        client.screenshot(path)
    end
    gui.line = function(x1, y1, x2, y2, color)
        color = fix_color(color) or 0xFFFFFFFF
        gui.drawLine(x1, y1, x2, y2)
    end
    gui.circle = function(x, y, r, thickness, outline_color, fill_color)
        x = x - r
        y = y - r
        width = r * 2
        height = r * 2
        outline_color = fix_color(outline_color) or 0xFFFFFFFF
        fill_color = fix_color(fill_color) or -1
        gui.drawEllipse(x, y, width, height, outline_color, fill_color)
    end
    gui.resolution = function()
        return client.screenwidth, client.screenheight
    end
    -- TODO gui.left_gap
    -- TODO gui.top_gap
    -- TODO gui.right_gap
    -- TODO gui.bottom_gap
    gui.repaint = function()
        repaint_early = true
    end
    gui.subframe_update = function(enabled)
        -- subframe updates are always enabled
    end
    load([[
        gui.color = function(r, g, b, a)
            r = r & 0xFF
            g = g & 0xFF
            b = b & 0xFF
            a = (a or 0) & 0xFF
            return (a << 24) | (r << 16) | (g << 8) | b
        end
    ]])()
    -- TODO gui.status
    gui.crosshair = function(x, y, size, color)
        color = fix_color(color) or 0xFFFFFFFF
        gui.drawLine(x - size/2, y, x + size/2, y, color)
        gui.drawLine(x, y - size/2, x, y + size/2, color)
    end
    gui.pixel = function(x, y, color)
        color = fix_color(color) or 0xFFFFFFFF
        gui.drawPixel(x, y, color)
    end
    gui.rectangle = function(x, y, w, h, thickness, outline_color, fill_color)
        outline_color = fix_color(outline_color) or 0xFFFFFFFF
        fill_color = fix_color(fill_color) or -1
        gui.drawRectangle(x, y, w, h, outline_color, fill_color)
    end
    gui.box = function(x, y, w, h, thickness, hilight_color, shadow_color, fill_color)
        hilight_color = fix_color(hilight_color) or 0xFFFFFFFF
        fill_color = fix_color(fill_color) or -1
        gui.drawRectangle(x, y, w, h, hilight_color, fill_color)
    end
    gui.text = function(x, y, text, fgcolor, bgcolor)
        fgcolor = fix_color(fgcolor) or 0xFFFFFFFF
        bgcolor = fix_color(bgcolor) or -1
        gui.drawText(x, y, text, fgcolor, bgcolor, nil)
    end
    gui.textH = gui.text
    gui.textV = gui.text
    gui.textHV = gui.text
    -- TODO gui.bitmap_draw
    -- TODO gui.palette_new
    -- TODO gui.palette_set
    -- TODO gui.bitmap_new
    -- TODO gui.bitmap_pset
    -- TODO gui.bitmap_size
    -- TODO gui.bitmap_blit
    -- TODO gui.bitmap_load
    -- TODO gui.rainbow
end

local function memory_compat()
    local fix_domain = function(domain)
        if domain == 'BUS' then
            domain = 'System Bus'
        end
        return domain
    end
    memory.readbyte = function(domain, address)
        domain = fix_domain(domain)
        return memory.read_u8(address, domain)
    end
    memory.readword = function(domain, address)
        domain = fix_domain(domain)
        return memory.read_u16_le(address, domain)
    end
    memory.readsword = function(domain, address)
        domain = fix_domain(domain)
        return memory.read_s16_le(address, domain)
    end
end

local function shallow_copy(t)
    local u = {}
    for k, v in pairs(t) do
        u[k] = v
    end
    return u
end

--local function loop(vanilla_env, compat_env)
--    local on_paint = compat_env.on_paint or function() end
--    local on_video = compat_env.on_video or function() end
--
--    while true do
--        local doing_a_repaint = repaint_early_requested
--        repaint_early_requested = false
--
--        _ENV = compat_env
--        on_paint()
--        if not doing_a_repaint then
--            on_video()
--        end
--        _ENV = vanilla_env
--
--        if repaint_early_requested then
--            emu.yield()
--        else
--            emu.frameadvance()
--        end
--        print("looped once, chiao")
--        return
--    end
--end

local function ible()
    local vanilla_env = shallow_copy(_ENV)
    local compat_env = _ENV

    bit_compat()
    font_compat()
    gui_compat()
    -- TODO hostmemory_compat()
    memory_compat()

    local on_exit_id = ''
    on_exit_id = event.onexit(function(...)
        local unregistered_correctly = event.unregisterbyid(on_exit_id)
        assert(unregistered_correctly, 'race condition')

        _ENV = vanilla_env

        if compat_env.on_video or compat_env.on_paint then
            event.onframeend(function()
                --debug.sethook(function()
                --    local info = debug.getinfo(2, 'lSn')
                --    print('info:', info)
                --    print('---')
                --end, 'l')

                _ENV = compat_env
                if on_video then
                    on_video()
                end
                if on_paint then
                    on_paint()
                end
                _ENV = vanilla_env

                --debug.sethook()
            end)
        end

        print('bk2_compat: script has been loaded')
    end)
end

return { ible = ible }
