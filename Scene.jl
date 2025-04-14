include("Ray.jl")
include("Vector.jl")
include("Material.jl")

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

struct Paraboloid <: Geometry
    """
    A paraboloid has a focus f and a foot C. It is the set of points
        P(f, C) = { x ∈ ℝ³ | (f → x) ⋅ (f → x) = ((C → x) ⋅ N)² }
        where N = unit(C → f)
    """
    focus::PointVector
    foot::PointVector
    discRadius
end

# TODO: create more geometries e.g. triangles, quadrilaterals, toruses

function getNormal(p::PointVector, S::Sphere)
    return S.center →ᵘ p
end

function getNormal(p::PointVector, Π::Plane)
    return unit(Π.normal)
end

function getNormal(p::PointVector, P::Paraboloid)
    pf = p →ᵘ P.focus
    n̂ = P.foot →ᵘ P.focus
    return unit(pf + n̂)
end

struct Object
    geometry::Geometry
    material::Material # TODO: Create material structure
end

struct Scene
    items::Set{Object} # TODO: replace Geometry struct with Object struct
end