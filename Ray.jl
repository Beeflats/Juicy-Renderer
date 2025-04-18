include("Vector.jl")

""" 
Ray structure 
"""

struct Ray
    origin::PointVector
    direction::DirectionVector
end

function at(ray::Ray, t)
    return displace(ray.origin, t * ray.direction)
end

function reflection(ray::Ray, normal::DirectionVector, pointOfIntersection::PointVector)
    """
    An incident ray striking a surface at a point of intersection 
    reflects off of it following the law of reflection. The output is the reflected ray.
    """
    d_incident = ray.direction
    d_reflected = (d_incident ⟂ normal) - (d_incident ∥ normal)
    return Ray(pointOfIntersection, d_reflected)
end

function refraction(ray::Ray, normal::DirectionVector, pointOfIntersection::PointVector, IOR_incident, IOR_refracted)
    """
    An incident ray striking a surface at a point of intersection
    refracts through it while obeying Snell's law:
        n₁*(d₁⟂n) = n₂*(d₂⟂n),
        where dᵢ is the ray's direction, nᵢ is the index of refraction, norm(d₁) = norm(d₂), and n is a vector normal to the surface
    The output is the refracted ray.
    """
    # The following three assumptions were made to derive the following algorithm:
    # - The refracted ray is on the same plane as the incident ray i.e. d_refracted = c₁ * (d_incident ∥ normal) + c₂ * (d_incident ⟂ normal) where c₁ and c₂ depend on the index of refraction
    # - We must obey Snell's law
    # - The refracted ray's arrow has the same length as the incident ray's arrow i.e. norm(d_incident) = norm(d_refracted)
    c₁ = IOR_incident / IOR_refracted
    d_incident = ray.direction 
    ddxnn = (d_incident ⋅ d_incident) * (normal ⋅ normal)
    dnxdn = (d_incident ⋅ normal) * (d_incident ⋅ normal) # equal to cos²(θ₁) where θ₁ is the angle of incidence 
    c₂c₂ = ddxnn/dnxdn * (1 - c₁*c₁) + c₁*c₁
    if c₂c₂ ≥ 0
        c₂ = √(c₂c₂) # equal to cos(θ₂)/cos(θ₁) where θ₂ is the angle of refraction
    else # total internal reflection
        # c₂ = √(c₂c₂+0im)
        # Question: what if we left c₂ = √(c₂c₂) as an imaginary number? How might a 'complex' refracted ray be related to total internal reflection?
        # It may be related to evanescent waves https://en.wikipedia.org/wiki/Evanescent_field
        c₁ = 1
        c₂ = -1
    end
    d_refracted = c₁ * (d_incident ⟂ normal) +  c₂ * (d_incident ∥ normal)
    return Ray(pointOfIntersection, d_refracted)
end

function uniformSampleSphere()
    """
    Samples a random unit vector (sphere) in 3D space
    """
    return unit(DirectionVector(randn(), randn(), randn()))
end

function scatter(ray::Ray, normal::DirectionVector, pointOfIntersection::PointVector)
    """
    Scattered reflection of a ray by uniform sampling of a unit vector from a hemisphere
    """
    d_incident = ray.direction
    orientedNormal = -(d_incident ∥ normal)
    randomDirection = uniformSampleSphere()
    scatteredDirection = randomDirection * sign(orientedNormal ⋅ randomDirection) # orient the random unit vector to be acute with the oriented normal
    # TODO: It is very unlikely that randomDirection is exactly perpendicular to the normal vector but resampling is necessarily if it is.
    return Ray(pointOfIntersection, scatteredDirection)
end