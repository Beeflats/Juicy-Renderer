using Images, ImageView

# Set up the scene
camera = makeCamera(PointVector(0, 0, 0), î + ĵ + k̂ )
sphere = Sphere(PointVector(1, 1, 1), 0.2) # ball of 10cm radius sitting in front of the camera

# Initialise image
sensor = camera.sensor
imageHeight = sensor.imageHeight
imageWidth = sensor.imageWidth
image = zeros(3, imageHeight, imageWidth)

# Render image
for i ∈ 1:imageHeight, j ∈ 1:imageWidth
    ray = Ray(camera.position, unit(sensor.sensorsPositions[i, j] → camera.position))
    backgroundColor = [ray.direction.x, ray.direction.y, ray.direction.z]
    if ray ∩ sphere
        pixelColor = [1, 0, 0]
    else
        pixelColor = backgroundColor
    end
    image[:, i, j] = pixelColor
end

colorview(RGB, image)