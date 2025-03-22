include("Scene.jl")

∅ = nothing

function ∈(p::PointVector, r::Ray)
    ε = 0.0001 # tolerance
    OP = r.origin → p
    if OP == ZEROVECTOR || abs(∠(OP, ray.direction) - 1) < ε # (O ≡ P) or (|cos(θ)| ≈ 1)
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
    if QP == ZEROVECTOR || abs( ∠(QP, n) - π/2 ) < ε # (Q ≡ P) or (QP ∠ n ≈ π/2)
        return true
    else
        return false
    end
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
        return r
    else
        O = r.origin
        OP = O → Π.point
        n = Π.normal
        d = r.direction
        t = (n ⋅ OP) / (n ⋅ d)
        if t ≥ 0
            return at(r, t) # equivalent to displace(O, norm(OP) * cos(θ) / cos(ϕ) * unit(d))
        else # if the ray is pointing away from the plane
            return nothing
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
        return nothing
    else
        t₁ = ( OC ⋅ d - √(Δ) ) / length²(d) # norm(OC)/norm(d) * (cos(θ) - √[cos²(θ) - cos²(ϕ)])
        t₂ = ( OC ⋅ d - √(Δ) ) / length²(d) # norm(OC)/norm(d) * (cos(θ) + √[cos²(θ) - cos²(ϕ)])
        # note that t₁ == t₂ when θ == ϕ meaning only one solution exists if the ray is tangent to the sphere
        if t₁ < 0 && t₂ < 0
            return nothing
        else
            t = t₁ > 0 ? t₁ : t₂ # set t to be the smaller non-negative value between t₁ and t₂
            return at(ray, t) # equivalent to displace(O, norm(OC)*(cos(θ) ± √[cos²(θ) - cos²(ϕ)]) * unit(d))
        end        
    end
end

function ∩(S::Sphere, ray::Ray)
    return ∩(ray, S)
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

function ∪(scene₁::Scene, scene₂::Scene)
    return Scene(union(scene₁.items, scene₂.items))
end

function ∪(scene::Scene, object::Geometry)
    return union(scene.items, object)
end

function ∪(object₁::Geometry, object₂::Geometry)
    return Scene(Set([object₁, object₂]))    
end

function ∩(ray::Ray, scene::Scene)
    """
    Let 𝕊 be Scene.items and let r(t) = at(ray, t)
    Let t_hit = min_t({t ∈ ℝ³ | ∃ s ∈ 𝕊: r(t) ∈ s})
    Returns r(t_hit) and return any s ∈ 𝕊 satisfying r(t_hit) ∈ s
    """
    closestObject = ∅
    closestIntersectionPoint = ∅
    distanceToClosestIntersection = Inf
    for object in scene.items
        intersectionPoint = ray ∩ object
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