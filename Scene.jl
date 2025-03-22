include("Ray.jl")
include("Vector.jl")

abstract type Geometry end

struct Plane <: Geometry
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

struct Sphere <: Geometry
    """
    A sphere is a surface (not a volume in this scenario)
    characterized by a center C and radius r. It is the set of points
        S(C, r) = { x ∈ ℝ³ | (C → x) ⋅ (C → x) = r² }.
    """
    center::PointVector
    radius
end

# TODO: create more geometries e.g. triangles, quadrilaterals, toruses

#struct Object
#    geometry::Geometry
#    material::Material # TODO: Create material structure
#end

struct Scene
    items::Set{Geometry} # TODO: replace Geometry struct with Object struct
end