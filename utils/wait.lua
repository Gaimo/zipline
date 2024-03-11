wait = function()
    ticks = {}

    return function(time)
        if not ticks[time] then 
            ticks[time] = getTickCount()
        end

        if getTickCount() - ticks[time] >= time then
            ticks[time] = nil
            return true
        else
            return false
        end
    end
end