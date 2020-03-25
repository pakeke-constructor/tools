

local wrap = coroutine.wrap
local yield = coroutine.yield
local clock = os.clock

return function()

    return wrap(function(tabl, func, max_time)
        assert(tabl," Expected table, got nil.")

        max_time = max_time or 0.01

        local start
        local delta = 0

        while true do
            for i=1,#tabl do
                if delta > max_time then
                    delta = 0
                    yield()
                end
                start = clock()
                func(tabl[i])
                delta = delta + (clock() - start)
            end
        end
    end)
end
