local argparse = require 'argparse'

local randomRange = require 'randomrange'
local Vec3 = require 'vec3'
local Camera = require 'camera'
local Sphere = require 'sphere'

local materials = require 'materials'
local Lambertian = materials.Lambertian
local Metal = materials.Metal
local Dialectric = materials.Dialectric

local function hit(hittableList, r, tMin, tMax)
    local tempRec
    local closestSoFar = tMax

    for i = 1, #hittableList do
        local object = hittableList[i]
        local rec = object:hit(r, tMin, closestSoFar)
        if rec then
            closestSoFar = rec.t
            tempRec = rec
        end
    end

    return tempRec
end

local function rayColor(r, world, depth)
    -- If we've exceeded the ray bounce limit, no more light is gathered.
    if depth <= 0 then
        return Vec3.zero()
    end

    local rec = hit(world, r, 0.001, math.huge)
    if rec then
        local attenuation, scattered = rec.material:scatter(r, rec)
        if attenuation then
            return attenuation * rayColor(scattered, world, depth - 1)
        end
        return Vec3.zero()
    end

    local unitDirection = r.direction:normalize()
    local t = 0.5 * (unitDirection.y + 1)
    return (1 - t) * Vec3.new(1, 1, 1) + t * Vec3.new(0.5, 0.7, 1.0)
end

local function randomScene()
    local world = {}

    local groundMaterial = Lambertian.new(Vec3.new(0.5, 0.5, 0.5))
    table.insert(world, Sphere.new(Vec3.new(0, -1000, 0), 1000, groundMaterial))

    for a = -11, 10 do
        for b = -11, 10 do
            local chooseMat = math.random()
            local center = Vec3.new(a + 0.9 * math.random(), 0.2, b + 0.9 * math.random())

            if (center - Vec3.new(4, 0.2, 0)):length() > 0.9 then
                local sphereMaterial
                if chooseMat < 0.8 then
                    -- diffuse
                    local albedo = Vec3.random() * Vec3.random()
                    sphereMaterial = Lambertian.new(albedo)
                elseif chooseMat < 0.95 then
                    -- metal
                    local albedo = Vec3.random(0.5, 1)
                    local fuzz = randomRange(0, 0.5)
                    sphereMaterial = Metal.new(albedo, fuzz)
                else
                    -- glass
                    sphereMaterial = Dialectric.new(1.5)
                end

                table.insert(world, Sphere.new(center, 0.2, sphereMaterial))
            end
        end
    end

    local material1 = Dialectric.new(1.5)
    table.insert(world, Sphere.new(Vec3.new(0, 1, 0), 1, material1))

    local material2 = Lambertian.new(Vec3.new(0.4, 0.2, 0.1))
    table.insert(world, Sphere.new(Vec3.new(-4, 1, 0), 1, material2))

    local material3 = Metal.new(Vec3.new(0.7, 0.6, 0.5), 0)
    table.insert(world, Sphere.new(Vec3.new(4, 1, 0), 1, material3))

    return world
end

local function clamp(x, min, max)
    if x < min then
        return min
    elseif max < x then
        return max
    end
    return x
end

local function writeColor(file, pixelColor, samplesPerPixel)
    -- Divide the color by the number of samples and gamma-correct for gamma=2.0.
    local scale = 1 / samplesPerPixel
    local r = math.sqrt(pixelColor.x * scale)
    local g = math.sqrt(pixelColor.y * scale)
    local b = math.sqrt(pixelColor.z * scale)

    -- Write the translated [0,255] value of each color component.
    file:write(math.floor(256 * clamp(r, 0, 0.999)), ' ', math.floor(256 * clamp(g, 0, 0.999)), ' ',
        math.floor(256 * clamp(b, 0, 0.999)), '\n')
end

local function main()
    -- Image
    local aspectRatio = 1.5
    local imageWidth = 500
    local imageHeight = math.floor(imageWidth / aspectRatio)
    local samplesPerPixel = 100
    local maxDepth = 50

    -- World
    local world = randomScene()

    -- Camera
    local lookfrom = Vec3.new(13, 2, 3)
    local lookat = Vec3.zero()
    local vup = Vec3.new(0, 1, 0)
    local distToFocus = 10
    local aperture = 0.1
    local cam = Camera.new {
        lookfrom = lookfrom,
        lookat = lookat,
        vup = vup,
        vfov = 20,
        aspectRatio = aspectRatio,
        aperture = aperture,
        focusDist = distToFocus
    }

    local file = io.open('out.ppm', 'w')
    file:write('P3\n', imageWidth, ' ', imageHeight, '\n255\n')

    -- Render
    for j = imageHeight, 1, -1 do
        print('Scanlines remaining:', j)

        for i = 1, imageWidth do
            local pixelColor = Vec3.zero()
            for _ = 1, samplesPerPixel do
                local u = (i - 1 + math.random()) / (imageWidth - 1)
                local v = (j - 1 + math.random()) / (imageHeight - 1)
                local r = cam:getRay(u, v)
                pixelColor = pixelColor + rayColor(r, world, maxDepth)
            end
            writeColor(file, pixelColor, samplesPerPixel)
        end
    end

    print('Done.')
    file:close()
end

main()
