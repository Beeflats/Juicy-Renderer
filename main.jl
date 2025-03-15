using Images, ImageView

# Initialise image
camera = makeCamera(PointVector(0, 0, 0), î + ĵ + k̂, 1)
sensor = camera.sensor
imageHeight = sensor.imageHeight
imageWidth = sensor.imageWidth
image = zeros(3, imageHeight, imageWidth)

# Render image
for i ∈ 1:imageHeight, j ∈ 1:imageWidth
    ray = Ray(camera.position, unit(sensor.sensorsPositions[i, j] → camera.position))
    pixelColor = [ray.direction.x, ray.direction.y, ray.direction.z]
    image[:, i, j] = pixelColor
end

colorview(RGB, image)