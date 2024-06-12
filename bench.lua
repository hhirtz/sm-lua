-- Benchmark utility
--
-- Measure the time spent in a portion of a script, in milliseconds.
--
-- build:
-- you need to build the "bench.c" file into "libbench.so", all in the same
-- folder:
--
--     cc -O2 -shared helper.c -o libhelper.so
--
--
-- usage:
--     local bench_hitbox = require("bench").new()
--     while true do
--         bench_hitbox.start_timing()
--         my_hitbox_drawing_function()
--         bench_hitbox.end_timing()
--         bench_hitbox.print(300) -- print every 300 frames, to avoid console lag
--         emu.frameadvance()
--     end

local clock_ns = package.loadlib("./libbench.so", "clock_ns")

local function new(name)
    local b = {
        name = name or "Bench",
        count = 0,
        mean = 0.0,
        mean2 = 0.0,
        min = 1 / 0,
        max = -1 / 0,
    }

    function b.push(value)
        if value < b.min then
            b.min = value
        end
        if b.max < value then
            b.max = value
        end
        -- Ref: https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Welford's_online_algorithm
        b.count = b.count + 1
        local delta = value - b.mean
        b.mean = b.mean + delta / b.count
        local delta2 = value - b.mean
        b.mean2 = b.mean2 + delta * delta2
    end

    function b.start_timing()
        b.t_start = clock_ns()
    end

    function b.end_timing()
        local t_end = clock_ns()
        local msec = (t_end - b.t_start) / 1000000
        b.push(msec)
    end

    function b.print(modulo)
        if modulo and b.count % modulo ~= 0 then
            return
        end
        local variance = 0.0
        if b.count > 1 then
            variance = b.mean2 / (b.count - 1)
        end
        print(
            string.format("%s (msec): count=%d, range=[%f;%f], mean=%f, var=%f",
                b.name, b.count, b.min, b.max, b.mean, variance)
        )
    end

    return b
end

return { new = new }
