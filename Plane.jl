include("Ray.jl")

struct Plane
    """
    A plane Π characterized by a point p and vector N 
    is the set of points
        Π(p, N) = { x ∈ ℝ³ | N ⋅ (p → x) = 0 }.
    """
    point::PointVector
    normal::DirectionVector
end

const XYPLANE = Plane(PointVector(0,0,0), k̂)
const GROUNDPLANE = XYPLANE
const YZPLANE = Plane(PointVector(0,0,0), î)
const ZXPLANE = Plane(PointVector(0,0,0), ĵ)