using Images, ImageView
using ProgressMeter
include("Camera.jl")
include("geometryOperations.jl")

function traceRay(ray::Ray, 𝕊::Scene, lightsource::DirectionVector, depth::Int64)
    object, intersectionPoint = ray ∩ 𝕊
    if isnothing(object) || depth < 0
        return [0.8, 0.8, 1]
    end
    
    normal = getNormal(intersectionPoint, object.geometry)

    objectColor = object.material.baseColor
    α = object.material.roughness
    γ = object.material.metallic
    
    # TODO: Interact with light from lightsource
    emittedColor = object.material.emissionColor * object.material.emissionIntensity
    reflectedRay = reflection(ray, normal, intersectionPoint)
    reflectedColor = traceRay(reflectedRay, 𝕊, lightsource, depth - 1) .* objectColor
    scatteredRay = scatter(ray, normal, intersectionPoint)
    diffuseColor = traceRay(scatteredRay, 𝕊, lightsource, depth - 1) .* objectColor

    # Raytraced color
    rayTracedColor = emittedColor + α * diffuseColor + (1 - α) * reflectedColor
    g_θ = object.style.stylizationFunction
    intersectionData = IntersectionData(intersectionPoint, normal, ray, reflectedRay, scatteredRay)
    return g_θ(rayTracedColor, intersectionData)
end

function uniformSample(a,b)
    return (b-a) * rand() + a
end

function render(camera::Camera, 𝕊::Scene, lightsource, numSamples, depth = 2, type = "perspective")
    # Initialize image
    sensor = camera.sensor
    imageHeight = sensor.imageHeight
    imageWidth = sensor.imageWidth
    image = zeros(3, imageHeight, imageWidth)
    pixelHorizontal = sensor.wholeWidth / imageWidth * sensor.horizontalBasis
    pixelVertical = sensor.wholeHeight / imageHeight * sensor.verticalBasis

    # Initialize buffer
    progress = Progress(imageHeight * imageWidth, desc="Processing...")
    
    # Render image
    for i ∈ 1:imageHeight, j ∈ 1:imageWidth
        pixelColor = [0, 0, 0]
        for _ in 1:numSamples
            pixelCenter = sensor.sensorsPositions[i, j]
            horizontalShift = pixelHorizontal * uniformSample(-1, 1)
            verticalShift = pixelVertical * uniformSample(-1, 1)
            shiftedCenter = pixelCenter ⊕ ( horizontalShift + verticalShift )
            if type == "orthogonal"
                ray = Ray(shiftedCenter, camera.viewingDirection)
            else
                ray = Ray(camera.position, shiftedCenter →ᵘ camera.position)
            end
            pixelColor += traceRay(ray, 𝕊, lightsource, depth)
        end
        image[:, i, j] = pixelColor / numSamples
        
        # Buffer
        update!(progress, (j + (i - 1) * imageWidth))
    end
    println("Render complete")
    return image
end