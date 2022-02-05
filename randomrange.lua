local function randomRange(min, max)
    -- Returns a random real in [min,max).
    min = min or 0
    max = max or 1
    return min + (max - min) * math.random()
end

return randomRange
