struct Style
    stylizationFunction
end

struct IntersectionData
    intersectionPoint::PointVector
    normal::DirectionVector
    incidentRay::Ray
    reflectedRay::Ray
    scatteredRay::Ray
end

# Addition
function Base.:+(θ₁::Style, θ₂::Style)
    g_θ₁ = θ₁.stylizationFunction
    g_θ₂ = θ₂.stylizationFunction
    function g_θ₁plusθ₂(color, intersectionData::IntersectionData)
        return g_θ₁(color, intersectionData) + g_θ₂(color, intersectionData)
    end
    θ₁plusθ₂ = Style(g_θ₁plusθ₂)
    return θ₁plusθ₂
end

# Subtraction
function Base.:-(θ₁::Style, θ₂::Style)
    g_θ₁ = θ₁.stylizationFunction
    g_θ₂ = θ₂.stylizationFunction
    function g_θ₁minusθ₂(color, intersectionData::IntersectionData)
        return g_θ₁(color, intersectionData) - g_θ₂(color, intersectionData)
    end
    θ₁minusθ₂ = Style(g_θ₁minusθ₂)
    return θ₁minusθ₂
end

# Negation
function Base.:-(θ)
    g_θ = θ.stylizationFunction
    function g_negθ(color, intersectionData::IntersectionData)
        return -g_θ(color, intersectionData)
    end
    negθ = Style(g_negθ)
    return negθ
end

# Composition
function Base.:∘(θ₁::Style, θ₂::Style)
    g_θ₁ = θ₁.stylizationFunction
    g_θ₂ = θ₂.stylizationFunction
    function g_θ₁composeθ₂(color, intersectionData::IntersectionData)
        return g_θ₁(g_θ₂(color, intersectionData), intersectionData)
    end
    θ₁composeθ₂ = Style(g_θ₁composeθ₂)
    return θ₁composeθ₂
end

# Element-wise multiplication
function Base.:*(θ₁::Style, θ₂::Style)
    g_θ₁ = θ₁.stylizationFunction
    g_θ₂ = θ₂.stylizationFunction
    function g_θ₁timesθ₂(color, intersectionData::IntersectionData)
        return g_θ₁(color, intersectionData) .* g_θ₂(color, intersectionData)
    end
    θ₁timesθ₂ = Style(g_θ₁timesθ₂)
    return θ₁timesθ₂
end

# Scalar multiplication
function Base.:*(c, θ::Style)
    g_θ = θ.stylizationFunction
    function g_cθ(color, intersectionData::IntersectionData)
        return c * g_θ(color, intersectionData)
    end
    cθ = Style(g_cθ)
    return cθ
end

# Stylizations
function g_identity(color, intersectionData::IntersectionData)
    return color
end
STYLE_identity = Style(g_identity)

function g_invert(color, intersectionData::IntersectionData)
    return [1, 1, 1] - color
end
STYLE_invert = Style(g_invert)

function g_normalMap(color, intersectionData::IntersectionData)
    normal = intersectionData.normal
    extractedColor = [normal.x, normal.y, normal.z]
    return extractedColor
end
STYLE_normalMap = Style(g_normalMap)

function g_depthMap(color, intersectionData::IntersectionData)
    distance = norm(intersectionData.incidentRay.origin → intersectionData.intersectionPoint)
    return [1, 1, 1] * distance
end
STYLE_depthMap = Style(g_depthMap)

function make_g_fill(fill_color)
    function g_fill(color, intersectionData::IntersectionData)
        return fill_color
    end
    return g_fill
end
STYLE_fill(fill_color) = Style(make_g_fill(fill_color))

function make_g_edgeLines(tolerance, edgeColor)
    function g_edgeLines(color, intersectionData::IntersectionData)
        θᵢ = ∠(intersectionData.normal, intersectionData.incidentRay.direction) # incidentAngle
        if π/2 - tolerance ≤ θᵢ ≤ π/2 + tolerance
            return edgeColor
        else
            return color
        end
    end
    return g_edgeLines
end
STYLE_edgeLines(tolerance = 0.1, edgeColor = [0, 0, 0]) = Style(make_g_edgeLines(tolerance, edgeColor))

function make_g_hueShift(k_cool, k_warm)
    function g_hueShift(color, intersectionData::IntersectionData)
        θᵢ = ∠(intersectionData.normal, intersectionData.incidentRay.direction) # incidentAngle
        cosθᵢ = cos(θᵢ)
        return (1+cosθᵢ)/2 * k_cool + (1-(1+cosθᵢ)/2) * k_warm
    end
    return g_hueShift
end
STYLE_hueShift(k_cool, k_warm) = Style(make_g_hueShift(k_cool, k_warm))


""" 
List of stylizations

**Technical Illustration**
Amy Gooch, Bruce Gooch, Peter Shirley, and Elaine Cohen. 1998. 
A Non-Photorealistic Lighting Model for Automatic Technical Illustration. 
In Proceedings of the 25th Annual Conference on Computer Graphics and Interactive Techniques (SIGGRAPH’98). Association for Computing Machinery, New York, NY, USA, 447–452. 
https://doi.org/10.1145/280814.280950

**eXtended Toon Shading**
Pascal Barla, Joëlle Thollot, and Lee Markosian. 2006. 
X-Toon: An Extended Toon Shader. 
In Proceedings of the 4th International Symposium on Non-Photorealistic Animation and Rendering (Annecy, France) (NPAR ’06). Association for Computing Machinery, New York, NY, USA, 127–132. 
https://doi.org/10.1145/1124728.1124749

**Feature line**
Rex West. 2021. 
Physically-Based Feature Line Rendering. 
ACM Trans. Graph. 40, 6, Article 246 (dec 2021), 11 pages. 
https://doi.org/10.1145/3478513.3480550

**Cross-hatching**
Oliver Deussen, Jörg Hamel, Andreas Raab, Stefan Schlechtweg, and Thomas Strothotte. 1999. 
An Illustration Technique Using Hardware-Based Intersections and Skeletons.
In Proceedings of the 1999 Conference on Graphics Interface ’99 (Kingston, Ontario, Canada). Morgan Kaufmann Publishers Inc., San Francisco, CA, USA, 175–182.

**Half-tone printing**
P. Hall. 1999. 
Nonphotorealistic Rendering by Q-mapping. 
Computer Graphics Forum (1999). 
https://doi.org/10.1111/1467-8659.00300





"""
 