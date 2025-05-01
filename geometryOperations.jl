include("Scene.jl")

∅ = nothing
∞ = Inf

function ∈(p::PointVector, r::Ray)
    ε = 0.0001 # tolerance
    OP = r.origin → p
    if OP == ZEROVECTOR
        return false
    elseif abs(∠(OP, ray.direction) - 1) < ε # (O ≡ P) or (|cos(θ)| ≈ 1)
        return true
    else
        return false
    end
end

function ∈(p::PointVector, S::Sphere)
    ε = 0.0001 # tolerance
    if abs(length²(S.center→p) - S.radius * S.radius) < ε # ‖C→P‖² ≈ r²
        return true
    else
        return false
    end
end

function ∈(p::PointVector, Π::Plane)
    ε = 0.0001 # tolerance
    q = Π.point; n = Π.normal
    QP = q → p
    if QP == ZEROVECTOR
        return true
    elseif abs( ∠(QP, n) - π/2 ) < ε # (Q ≡ P) or (QP ∠ n ≈ π/2)
        return true
    else
        return false
    end
end

function ∈(p::PointVector, P::Paraboloid)
    ε = 0.0001 # tolerance
    f = P.focus
    C = P.foot
    r = P.discRadius
    # we want to verify length²(C → q) ≤ r² 
    return abs(length²(f → p) - length²((C → p) ∥ unit(C → f))) < ε && length²(C → p) - length²(f → p) ≤ r*r
end

function ⊂(p::PointVector, r::Ray)
    return ∈(p, r)
end

function ⊂(p::PointVector, S::Sphere)
    return ∈(p, S)
end

function ⊂(p::PointVector, Π::Plane)
    return ∈(p, Π)
end

function ⊂(r::Ray, Π::Plane)
    ε = 0.0001 # tolerance
    if r.origin ∈ Π && abs( ∠(r.direction, Π.normal) - π/2) < ε
        return true
    else
        return false
    end
end

function ∩(r::Ray, Π::Plane)
    """
    Let O be the origin of the ray, and let d be its direction vector.
    Let P be the point characterising the plane, and n be its normal vector.
    Let θ = n∠(P→O) and let ϕ = n∠d
    """
    if r ⊂ Π # ray is contained on the plane
        return r.origin # TODO: this may cause a bug
    else
        O = r.origin
        OP = O → Π.point
        n = Π.normal
        d = r.direction
        t = (n ⋅ OP) / (n ⋅ d)
        if t > 0
            return at(r, t) # equivalent to displace(O, norm(OP) * cos(θ) / cos(ϕ) * unit(d))
        else # if the ray is pointing away from the plane
            return ∅
        end
    end
end

function ∩(Π::Plane, r::Ray)
    return ∩(r, Π)
end

function ∩(ray::Ray, S::Sphere)
    """
    Let O be the origin of the ray, and let d be its direction vector.
    Let C be the center of the sphere, and r be its radius.
    Let ray₂ be any ray with origin O and tangent to the sphere.
    Let ϕ = ray₂.direction ∠ (O → C), and let θ = (O → C) ∠ d; both angles lie between 0 and π
    This function gives the earliest point of intersection between a ray and a sphere. 
    """
    d = ray.direction
    OC = ray.origin → S.center
    r = S.radius
    Δ = (OC ⋅ d)^2 - length²(d) * (length²(OC) - r^2) # the determinant is Δ = norm(OC)²*norm(d)² * (cos²(θ) - cos²(ϕ))
    if Δ < 0 # if the ray's direction is not contained the cone whose vertex is O and tangent to S; along the lines of "if θ > ϕ"
        return ∅
    else
        t₁ = ( OC ⋅ d - √(Δ) ) / length²(d) # norm(OC)/norm(d) * (cos(θ) - √[cos²(θ) - cos²(ϕ)])
        t₂ = ( OC ⋅ d - √(Δ) ) / length²(d) # norm(OC)/norm(d) * (cos(θ) + √[cos²(θ) - cos²(ϕ)])
        # note that t₁ == t₂ when θ == ϕ meaning only one solution exists if the ray is tangent to the sphere
        if t₁ ≤ 0 && t₂ ≤ 0
            return ∅
        else
            t = t₁ > 0 ? t₁ : t₂ # set t to be the smaller non-negative value between t₁ and t₂
            return at(ray, t) # equivalent to displace(O, norm(OC)*(cos(θ) ± √[cos²(θ) - cos²(ϕ)]) * unit(d))
        end        
    end
end

function ∩(S::Sphere, ray::Ray)
    return ∩(ray, S)
end

function ∩(ray::Ray, P::Paraboloid)
    o = ray.origin
    d = ray.direction
    f = P.focus
    C = P.foot
    n̂ = unit(C → f)

    a = (d ⋅ d)^2 - (d ⋅ n̂)^2
    b = ((f → o) ⋅ d) - ((C → o) ⋅ n̂) * (d ⋅ n̂)
    c = length²(f → o) - ((C → o) ⋅ n̂)^2
    Δ = b^2 - a*c

    if Δ < 0
        return ∅
    else
        sqrtΔ = √(Δ)
        t₁ = (-b - sqrtΔ) / a
        t₂ = (-b + sqrtΔ) / a
        if t₁ ≥ 0 && at(ray, t₁) ∈ P
            t = t₁
        elseif t₂ ≥ 0 && at(ray, t₂) ∈ P
            t = t₂
        else
            return ∅
        end
    end
    return at(ray, t)
end

function ∩(P::Paraboloid, ray::Ray)
    return ∩(ray, P)
end

function ∩(ray::Ray, T::Triangle)
    """
    Let o be the origin of the ray and d be its direction
    let v₁, v₂, v₃ be vectors connecting the origin of the ray to the vertices of the triangle.
    The point x = displace(o, λ₁v₁ + λ₂v₂ + λ₃v₃ ) is in the triangle 
        if λ₁+λ₂+λ₃ = 1 and λ₁,λ₂,λ₃∈[0,1]
    To determine when the ray intersects with the triangle, we need to solve for t
        λ₁v₁ + λ₂v₂ + λ₃v₃ = td
    such that displace(o, td) is in the triangle.
    """
    o = ray.origin
    Λ = RREF(o → T.p₁, o → T.p₂, o → T.p₃, ray.direction)
    if Λ == nothing # TODO: How to deal with a ray whose intersection with the ray is a line segment rather than a single point? 
        return ∅
    elseif all(x -> x ≥ 0, Λ) # all the coefficients of o→pᵢ must be non-negative for the ray to intersect the triangle
        t = 1/sum(Λ)
    else
        return ∅
    end
    return at(ray, t)
end

function ∩(T::Triangle, ray::Ray)
    return ∩(ray, T)
end

function ∩(Π₁::Plane, Π₂::Plane)
    """
    The intersection of two planes is a line (bidirectional ray).
    The origin of the ray is the point on the line that minimises 
     the total distance to both  input points characterising the planes.
    Beware the operation is NON-COMMUTATIVE!! The direction of the
     ray obeys the right-hand rule of the cross product between the 
     normal vectors of the input planes.
    """
    n₁ = unit(Π₁.normal)
    n₂ = unit(Π₂.normal)
    d = Π₁.normal × Π₂.normal # direction of intersecting line
    if length²(d) == 0
        return ∅
    else
        p₁ = Π₁.point
        p₂ = Π₂.point
        m = p₁ ⊕ ((p₁→p₂)/2) # midpoint of p₁ and p₂
        n̄ = (n₁ + n₂) / 2 # a vector that bisects n₁ and n₂
        c = -(p₁→m)⋅n₁ / (n₁⋅n̄) # equivalent to -norm(p₁→p₂) * tan((n₁∠n₂) / 2) / norm(n̄)
        p = m ⊕ (c*n̄)
        return Ray(p, d)
    end
end

function ⋃(args::Vararg{Object})
    return Scene(Set(args))
end

function ∪(object₁::Object, object₂::Object)
    return Scene(Set([object₁, object₂]))
end

function ∪(object::Object, scene::Scene)
    return Scene(union(scene.items, Set([object])))
end

function ∪(scene::Scene, object::Object)
    return ∪(object::Object, scene::Scene)
end

function ∪(scene₁::Scene, scene₂::Scene)
    return Scene(union(scene₁.items, scene₂.items))
end

function ∩(ray::Ray, scene::Scene)
    """
    Let 𝕊 be Scene.items and let r(t) = at(ray, t)
    Let t_hit = min_t({t ∈ ℝ³ | ∃ s ∈ 𝕊: r(t) ∈ s})
    Returns r(t_hit) and return any s ∈ 𝕊 satisfying r(t_hit) ∈ s
    """
    closestObject = ∅
    closestIntersectionPoint = ∅
    distanceToClosestIntersection = ∞
    for object in scene.items
        intersectionPoint = ray ∩ object.geometry
        if intersectionPoint ≠ ∅
            distanceFromOrigin = norm( ray.origin → intersectionPoint )
            if distanceFromOrigin < distanceToClosestIntersection
                closestObject = object
                closestIntersectionPoint = intersectionPoint
                distanceToClosestIntersection = distanceFromOrigin
            end
        end
    end
    # TODO: rewrite the `for` loop to read with more mathematical notation (set comprehension)
    return closestObject, closestIntersectionPoint
end