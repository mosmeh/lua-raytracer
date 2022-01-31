local function randomRange(min, max)
    -- Returns a random real in [min,max).
    local min = min or 0
    local max = max or 1
    return min + (max - min) * math.random()
end

return randomRange
