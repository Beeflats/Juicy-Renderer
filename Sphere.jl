include("Ray.jl")

struct Sphere
    """
    A sphere is a surface (not a volume in this scenario)
    characterized by a center C and radius r. It is the set of points
        S(C, r) = { x ∈ ℝ³ | (C → x) ⋅ (C → x) = r² }.
    """
    center::PointVector
    radius
end