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