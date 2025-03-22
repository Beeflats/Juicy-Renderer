using Images, ImageView
include("geometryOperations.jl")
include("Camera.jl")

# Set up the scene
camera = makeCamera(PointVector(0, 0, 0), î + ĵ + k̂ )
sphere₁ = Sphere(PointVector(1, 1, 1), 0.2) # ball of 20cm radius sitting in front of the camera
sphere₂ = Sphere(PointVector(0.8, 0.9, 1), 0.1) # ball of 10cm radius sitting in front of the camera
𝕊 = sphere₁ ∪ sphere₂

# Initialise image
sensor = camera.sensor
imageHeight = sensor.imageHeight
imageWidth = sensor.imageWidth
image = zeros(3, imageHeight, imageWidth)

# Render image
for i ∈ 1:imageHeight, j ∈ 1:imageWidth
    ray = Ray(camera.position, unit(sensor.sensorsPositions[i, j] → camera.position))
    backgroundColor = [ray.direction.x, ray.direction.y, ray.direction.z]
    pixelColor = backgroundColor
    object, intersectionPoint = ray ∩ 𝕊
    if object == sphere₁ || object == sphere₂
        n = unit(object.center → intersectionPoint)
        pixelColor = 0.5*[n.x+1, n.y+1, n.z+1]
    end
    image[:, i, j] = pixelColor
end

colorview(RGB, image)