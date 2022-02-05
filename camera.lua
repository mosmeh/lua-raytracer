local Vec3 = require 'vec3'
local Ray = require 'ray'

local Camera = {}
Camera.__index = Camera

function Camera.new(options)
    options = options or {}
    local lookfrom = options.lookfrom or Vec3.zero()
    local lookat = options.lookat or Vec3.new(0, 0, -1)
    local vup = options.vup or Vec3.new(0, 1, 0)
    local vfov = options.vfov or 90 -- vertical field-of-view in degrees
    local aspectRatio = options.aspectRatio or (16 / 9)
    local aperture = options.aperture or 0
    local focusDist = options.focusDist or 1

    local theta = math.rad(vfov)
    local h = math.tan(theta / 2)
    local viewportHeight = 2 * h
    local viewportWidth = aspectRatio * viewportHeight

    local w = (lookfrom - lookat):normalize()
    local u = vup:cross(w)
    local v = w:cross(u)

    local origin = lookfrom
    local horizontal = focusDist * viewportWidth * u
    local vertical = focusDist * viewportHeight * v
    local lowerLeftCorner = origin - horizontal / 2 - vertical / 2 - focusDist * w

    local o = {
        origin = origin,
        lowerLeftCorner = lowerLeftCorner,
        horizontal = horizontal,
        vertical = vertical,
        u = u,
        v = v,
        w = w,
        lensRadius = aperture / 2
    }
    setmetatable(o, Camera)
    return o
end

function Camera:getRay(s, t)
    local rd = self.lensRadius * Vec3.randomInUnitDisk()
    local offset = self.u * rd.x + self.v * rd.y

    return Ray.new(self.origin + offset,
        self.lowerLeftCorner + s * self.horizontal + t * self.vertical - self.origin - offset)
end

return Camera
