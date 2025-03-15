struct Sphere
    center::PointVector
    radius
end

function intersects(ray::Ray, sphere::Sphere)
    """
    Computes whether a line and a sphere intersects each other.
    It involves determining the truth value of the following statement:
    ∃t∈ℝ such that ‖C→P(t)‖² = r²,
    where C is the center of the sphere, r is its radius and P(t) is the ray paramerized at time t
    """
    OC = sphere.center → ray.origin
    a = length²(ray.direction)
    b = -2 * (ray.direction ⋅ OC)
    c = length²(OC) - sphere.radius*sphere.radius
    Δ = b*b - 4*a*c
    return Δ ≥ 0
end

function ∩(ray::Ray, sphere::Sphere)
    return intersects(ray, sphere)
end