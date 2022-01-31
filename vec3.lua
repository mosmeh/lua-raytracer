local randomRange = require 'randomrange'

local Vec3 = {}

function Vec3:new(x, y, z)
    local o = {
        x = x,
        y = y,
        z = z
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Vec3:zero()
    return Vec3:new(0, 0, 0)
end

function Vec3:random(min, max)
    return Vec3:new(randomRange(min, max), randomRange(min, max), randomRange(min, max))
end

local function randomInUnitSphere()
    while true do
        local p = Vec3:random(-1, 1)
        if p:lengthSquared() < 1 then
            return p
        end
    end
end

function Vec3:randomUnitVector()
    return randomInUnitSphere():normalize()
end

function Vec3:randomInUnitDisk()
    while true do
        local p = Vec3:new(randomRange(-1, 1), randomRange(-1, 1), 0)
        if p:lengthSquared() < 1 then
            return p
        end
    end
end

function Vec3.__add(a, b)
    if type(a) == 'number' then
        return Vec3:new(a + b.x, a + b.y, a + b.z)
    elseif type(b) == 'number' then
        return Vec3:new(a.x + b, a.y + b, a.z + b)
    else
        return Vec3:new(a.x + b.x, a.y + b.y, a.z + b.z)
    end
end

function Vec3.__sub(a, b)
    if type(a) == 'number' then
        return Vec3:new(a - b.x, a - b.y, a - b.z)
    elseif type(b) == 'number' then
        return Vec3:new(a.x - b, a.y - b, a.z - b)
    else
        return Vec3:new(a.x - b.x, a.y - b.y, a.z - b.z)
    end
end

function Vec3.__mul(a, b)
    if type(a) == 'number' then
        return Vec3:new(a * b.x, a * b.y, a * b.z)
    elseif type(b) == 'number' then
        return Vec3:new(a.x * b, a.y * b, a.z * b)
    else
        return Vec3:new(a.x * b.x, a.y * b.y, a.z * b.z)
    end
end

function Vec3.__div(a, b)
    if type(a) == 'number' then
        return Vec3:new(a / b.x, a / b.y, a / b.z)
    elseif type(b) == 'number' then
        return Vec3:new(a.x / b, a.y / b, a.z / b)
    else
        return Vec3:new(a.x / b.x, a.y / b.y, a.z / b.z)
    end
end

function Vec3:__unm()
    return Vec3:new(-self.x, -self.y, -self.z)
end

function Vec3:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z
end

function Vec3:cross(other)
    return Vec3:new(self.y * other.z - self.z * other.y, self.z * other.x - self.x * other.z,
        self.x * other.y - self.y * other.x)
end

function Vec3:length()
    return math.sqrt(self:lengthSquared())
end

function Vec3:lengthSquared()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function Vec3:normalize()
    return self / self:length()
end

function Vec3:nearZero()
    -- Return true if the vector is close to zero in all dimensions.

    local s = 1e-8
    return (math.abs(self.x) < s) and (math.abs(self.y) < s) and (math.abs(self.z) < s)
end

return Vec3
