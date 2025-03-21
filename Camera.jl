include("geometryOperations.jl")

struct PlaneSensor
    """
    The sensor is a plane whose normal from the center passes through the camera eye
    """
    center::PointVector
    normal::DirectionVector
end

struct DiscretizedPlaneSensor
    continuousSensor::PlaneSensor
    horizontalBasis::DirectionVector
    verticalBasis::DirectionVector
    sensorWidth
    sensorHeight
    imageWidth::Int
    imageHeight::Int
    sensorsPositions::Matrix{PointVector}
end

function discretizePlaneSensor(continuousSensor::PlaneSensor, roll, aspectRatio, sensorWidth, imageWidth)
    sensorCenter = continuousSensor.center
    viewingDirection = continuousSensor.normal
    
    sensorHeight = sensorWidth / aspectRatio
    imageHeight = round(Int, imageWidth / aspectRatio)
    
    if (GROUNDPLANE.normal ∥ viewingDirection) == GROUNDPLANE.normal
        horizontalBasis_default = î
    else
        Π_sensor = Plane(sensorCenter, viewingDirection)
        horizontalBasis_default = unit((Π_sensor ∩ GROUNDPLANE).direction)
    end
    verticalBasis_default = unit(horizontalBasis_default × viewingDirection)

    rollMatrix = transformation_rotateAroundAxis(viewingDirection, roll)

    horizontalBasis = unit(rollMatrix * horizontalBasis_default)
    verticalBasis = unit(rollMatrix * verticalBasis_default)
    

    horizontalDelta = sensorWidth / imageWidth
    verticalDelta = sensorHeight / imageHeight # should be approximately equal to horizontalDelta

    # Make the map of sensor sensorPositions
    sensorsPositions = Array{PointVector}(undef, imageHeight, imageWidth) # Initialise the map with arbitrary positions
    upperLeftSensorPosition = displace(displace(sensorCenter, sensorWidth * horizontalBasis / 2 - horizontalDelta * horizontalBasis / 2), - sensorHeight * verticalBasis / 2 + verticalDelta * verticalBasis / 2)
    for i ∈ 1:imageHeight, j ∈ 1:imageWidth
        displaceRight = - (j-1) * horizontalDelta * horizontalBasis
        displaceDown = (i-1) * verticalDelta * verticalBasis
        sensorPosition = displace(displace(upperLeftSensorPosition, displaceRight), displaceDown)
        sensorsPositions[i,j] = sensorPosition
    end

    return DiscretizedPlaneSensor(continuousSensor, horizontalBasis, verticalBasis, sensorWidth, sensorHeight, imageWidth, imageHeight, sensorsPositions)

end

# Author's note: Sensors need not necessarily be flat nor rectangular as described in DiscretizedPlaneSensor. 
# New classes of sensors can be created to accomodate for different sensor geometries.

struct Camera
    position::PointVector
    viewingDirection::DirectionVector
    focalLength # meters
    sensor::DiscretizedPlaneSensor
end

function makeCamera(position::PointVector,
                    viewingDirection::DirectionVector = ĵ,
                    aspectRatio = 16 / 9, # width-to-height ratio
                    imageWidth::Int = 1920, # Image resolutions are typically 1600×900 (HD+), 1920×1080 (Full HD), 2560×1440 (QHD), 3200×1800, 3840×2160 (4K UHD), 5120×2880 (5K), 7680×4320 (8K UHD)
                    sensorWidth = 0.036, # (meters)
                    focalLength = 0.050, # distance of sensor behind camera (meters); wide-angle ranges 10mm to 35mm, standard lenses are 50mm and telephoto lenses are 70mm to 300mm or more 
                    roll = 0 # anticlockwise rotation (radians); dutch angle
                    ) 
    sensorCenter = displace(position, -focalLength * unit(viewingDirection))
    continuousSensor = PlaneSensor(sensorCenter, viewingDirection)
    sensor = discretizePlaneSensor(continuousSensor, roll, aspectRatio, sensorWidth, imageWidth)
    Camera(position, viewingDirection, focalLength, sensor)
end
