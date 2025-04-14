using Images, ImageView
include("Camera.jl")
include("geometryOperations.jl")

function traceRay(ray::Ray, 𝕊::Scene, lightsource::PointVector, depth::Int64 = 6)
    object, intersectionPoint = ray ∩ 𝕊
    if isnothing(object) || depth < 0
        return [0,0,0]#[0.8, 0.8, 1]
    end
    
    normal = getNormal(intersectionPoint, object.geometry)
    #return [normal.x, normal.y, normal.z] 

    objectColor = object.material.baseColor
    α = object.material.roughness
    γ = object.material.metallic
    
    emittedColor = object.material.emissionColor * object.material.emissionIntensity
    reflectedRay = reflection(ray, normal, intersectionPoint)
    reflectedColor = traceRay(reflectedRay, 𝕊, lightsource::PointVector, depth - 1) .* objectColor
    scatteredRay = scatter(ray, normal, intersectionPoint)
    diffuseColor = traceRay(scatteredRay, 𝕊, lightsource::PointVector, depth - 1) .* objectColor

    # Raytraced color
    rayTracedColor = emittedColor + α * diffuseColor + (1 - α) * reflectedColor
    return rayTracedColor
end

function uniformSample(a,b)
    return (b-a) * rand() + a
end

function render(camera::Camera, 𝕊::Scene, lightsource, numSamples, depth = 2, type = "perspective")
    # Initialise image
    sensor = camera.sensor
    imageHeight = sensor.imageHeight
    imageWidth = sensor.imageWidth
    image = zeros(3, imageHeight, imageWidth)
    pixelHorizontal = sensor.wholeWidth / imageWidth * sensor.horizontalBasis
    pixelVertical = sensor.wholeHeight / imageHeight * sensor.verticalBasis

    # Render image
    for i ∈ 1:imageHeight, j ∈ 1:imageWidth
        pixelColor = [0, 0, 0]
        for _ in 1:numSamples
            pixelCenter = sensor.sensorsPositions[i, j]
            horizontalShift = pixelHorizontal * uniformSample(-1, 1)
            verticalShift = pixelVertical * uniformSample(-1, 1)
            shiftedCenter = displace(pixelCenter, horizontalShift + verticalShift)
            if type == "orthogonal"
                ray = Ray(shiftedCenter, camera.viewingDirection)
            else
                ray = Ray(camera.position, shiftedCenter →ᵘ camera.position)
            end
            pixelColor += traceRay(ray, 𝕊, depth)
        end
        image[:, i, j] = pixelColor / numSamples 

        # Buffer
        #if j + i * imageHeight % 500 == 1
        #    println((j + i * imageHeight)/(imageHeight*imageWidth) * 100)
        #end
    end

    println("render complete")
    return image
end