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

function findRotation(x1,y1,x2,y2)
    local t = -math.deg(math.atan2(x2-x1,y2-y1))
    if t < 0 then t = t + 360 end;
    return t;
end