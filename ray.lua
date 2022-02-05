local Ray = {}

function Ray:new(origin, direction)
    local o = {
        origin = origin,
        direction = direction
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Ray:at(t)
    return self.origin + t * self.direction
end

return Ray
