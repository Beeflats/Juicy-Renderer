struct Plane
    """
    A plane is characterised by a point p and vector N.
    The parametric equation for a plane is given by
    (p→x)⋅N = 0, where x = (x,y,z)
    """
    point::PointVector
    normal::DirectionVector
end

const XYPLANE = Plane(PointVector(0,0,0), k̂) # Ground plane
const GROUNDPLANE = XYPLANE
const YZPLANE = Plane(PointVector(0,0,0), î)
const ZXPLANE = Plane(PointVector(0,0,0), ĵ)

function intersection(Π₁::Plane, Π₂::Plane)
    """
    The intersection of two planes is a line (bidirectional ray).
    The origin of the ray is the point on the line that minimises 
     the total distance to both  input points characterising the planes.
    Note that the operation is non-commutative! The direction of the
     ray obeys the right-hand rule of the cross product between the 
     normal vectors of the input planes.
    """
    n₁ = unit(Π₁.normal)
    n₂ = unit(Π₂.normal)
    d = Π₁.normal × Π₂.normal # direction of intersecting line
    if length²(d) == 0
        return nothing
    else
        p₁ = Π₁.point
        p₂ = Π₂.point
        m = displace(p₁, (p₁→p₂)/2) # midpoint of p₁ and p₂
        n̄ = (n₁ + n₂) / 2 # a vector that bisects n₁ and n₂
        c = -(p₁→m)⋅n₁ / (n₁⋅n̄) # equivalent to -norm(p₁→p₂) * tan((n₁∠n₂) / 2) / norm(n̄)
        p = displace(m, c*n̄)
        return Ray(p, d)
    end
end

function ∩(Π₁::Plane, Π₂::Plane)
    # Note: operation is not commutative!
    return intersection(Π₁, Π₂)
end