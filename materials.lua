local Vec3 = require 'vec3'
local Ray = require 'ray'

local Lambertian = {}

function Lambertian:new(albedo)
    local o = {
        albedo = albedo
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Lambertian:scatter(rIn, rec)
    local scatterDirection = rec.normal + Vec3:randomUnitVector()

    -- Catch degenerate scatter direction
    if scatterDirection:nearZero() then
        scatterDirection = rec.normal
    end

    local scattered = Ray:new(rec.p, scatterDirection)
    return self.albedo, scattered
end

local Metal = {}

function Metal:new(albedo, fuzz)
    local o = {
        albedo = albedo,
        fuzz = fuzz
    }
    if o.fuzz > 1 then
        o.fuzz = 1
    end
    setmetatable(o, self)
    self.__index = self
    return o
end

local function reflect(v, n)
    return v - 2 * v:dot(n) * n
end

function Metal:scatter(rIn, rec)
    local reflected = reflect(rIn.direction:normalize(), rec.normal)
    local scattered = Ray:new(rec.p, reflected + self.fuzz * Vec3:randomUnitVector())
    if scattered.direction:dot(rec.normal) > 0 then
        return self.albedo, scattered
    else
        return nil
    end
end

local Dialectric = {}

function Dialectric:new(ir)
    local o = {
        ir = ir -- Index of Refraction
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

local function refract(uv, n, etaiOverEtat)
    local cosTheta = math.min((-uv):dot(n), 1)
    local rOutPerp = etaiOverEtat * (uv + cosTheta * n)
    local rOutParallel = -math.sqrt(math.abs(1 - rOutPerp:lengthSquared())) * n
    return rOutPerp + rOutParallel
end

local function reflectance(cosine, refIdx)
    -- Use Schlick's approximation for reflectance.
    local r0 = (1 - refIdx) / (1 + refIdx)
    r0 = r0 * r0
    return r0 + (1 - r0) * math.pow(1 - cosine, 5)
end

function Dialectric:scatter(rIn, rec)
    local attenuation = Vec3:new(1, 1, 1)

    local refractionRatio
    if rec.frontFace then
        refractionRatio = 1 / self.ir
    else
        refractionRatio = self.ir
    end

    local unitDirection = rIn.direction:normalize()
    local cosTheta = math.min((-unitDirection):dot(rec.normal), 1)
    local sinTheta = math.sqrt(1 - cosTheta * cosTheta)

    local cannotRefract = refractionRatio * sinTheta > 1
    local direction
    if cannotRefract or reflectance(cosTheta, refractionRatio) > math.random() then
        direction = reflect(unitDirection, rec.normal)
    else
        direction = refract(unitDirection, rec.normal, refractionRatio)
    end

    local scattered = Ray:new(rec.p, direction)

    return attenuation, scattered
end

return {
    Lambertian = Lambertian,
    Metal = Metal,
    Dialectric = Dialectric
}
