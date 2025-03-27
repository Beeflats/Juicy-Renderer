using Images, ImageView
include("Camera.jl")
include("geometryOperations.jl")

function traceRay(ray::Ray, 𝕊::Scene, lightsource::PointVector)
    object, intersectionPoint = ray ∩ 𝕊
    if isnothing(object)
        return [0.2, 0.2, 0.4]
    elseif typeof(object.geometry) == Sphere
        normal = object.geometry.center → intersectionPoint
        reflectedRay = reflection(ray, normal, intersectionPoint)
        return object.material.baseColor * max(reflectedRay.direction ⋅ (ray.origin →ᵘ lightsource), 0)
        #object.material.roughness
        #object.material.metallic
    end
end

function render(camera::Camera, 𝕊::Scene, lightsource)
    # Initialise image
    sensor = camera.sensor
    imageHeight = sensor.imageHeight
    imageWidth = sensor.imageWidth
    image = zeros(3, imageHeight, imageWidth)

    # Render image
    for i ∈ 1:imageHeight, j ∈ 1:imageWidth
        ray = Ray(camera.position, sensor.sensorsPositions[i, j] →ᵘ camera.position)
        pixelColor = traceRay(ray, 𝕊, lightsource)
        image[:, i, j] = pixelColor
    end

    colorview(RGB, image)
end

camera = makeCamera(PointVector(0, 0, 0))
𝕊 = ⋃(Object(Sphere(PointVector(0, 1, 0), 0.1), MATERIAL_gold))
lightsource = PointVector(0, 2, 0)

render(camera, 𝕊, lightsource)