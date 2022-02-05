local Sphere = {}

function Sphere:new(center, radius, material)
    local o = {
        center = center,
        radius = radius,
        material = material
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Sphere:hit(r, tMin, tMax)
    local oc = r.origin - self.center
    local a = r.direction:lengthSquared()
    local halfB = oc:dot(r.direction)
    local c = oc:lengthSquared() - self.radius * self.radius

    local discriminant = halfB * halfB - a * c
    if discriminant < 0 then
        return nil
    end

    -- Find the nearest root that lies in the acceptable range.
    local sqrtd = math.sqrt(discriminant)
    local root = (-halfB - sqrtd) / a
    if root < tMin or tMax < root then
        root = (-halfB + sqrtd) / a
        if root < tMin or tMax < root then
            return nil
        end
    end

    local p = r:at(root)
    local normal = (p - self.center) / self.radius
    local frontFace = r.direction:dot(normal) < 0
    if not frontFace then
        normal = -normal
    end

    return {
        t = root,
        p = p,
        normal = normal,
        frontFace = frontFace,
        material = self.material
    }
end

return Sphere
