""" 
Direction vector structure with operations for 
addition, negation, scalar multiplication, dot product, cross product,
normalizing, vector projections, 
extracting the length, cosines, and parallel and perpendicular components
"""

struct DirectionVector
	x::Float64
	y::Float64
	z::Float64
end

# Addition
Base.:+(v₁::DirectionVector, v₂::DirectionVector) = DirectionVector(v₁.x + v₂.x, v₁.y + v₂.y, v₁.z + v₂.z)
Base.:-(v₁::DirectionVector, v₂::DirectionVector) = DirectionVector(v₁.x - v₂.x, v₁.y - v₂.y, v₁.z - v₂.z)

# Negation
Base.:-(v::DirectionVector) = DirectionVector(-v.x, -v.y, -v.z)

# Scalar Multiplication
Base.:*(c, v::DirectionVector) = DirectionVector(c*v.x, c*v.y, c*v.z)
Base.:*(v::DirectionVector, c) = DirectionVector(c*v.x, c*v.y, c*v.z)
Base.:/(v::DirectionVector, c) = DirectionVector(v.x/c, v.y/c, v.z/c)

# Dot Product
function ⋅(v₁::DirectionVector, v₂::DirectionVector)
	return v₁.x*v₂.x + v₁.y*v₂.y + v₁.z*v₂.z	
end

# Cross Product
function ×(v₁::DirectionVector, v₂::DirectionVector)
	return DirectionVector(
		v₁.y * v₂.z - v₁.z * v₂.y, 
		v₁.z * v₂.x - v₁.x * v₂.z, 
		v₁.x * v₂.y - v₁.y * v₂.x)
end

# Length-squared
function length²(v)
	return v⋅v
end

# Norm
function norm(v::DirectionVector)
	return sqrt(v⋅v)
end

# Normalise
function unit(v) 
	return v/norm(v)
end

# Get cosine
function ∠(v₁::DirectionVector, v₂::DirectionVector)
	return acos(v₁⋅v₂/(norm(v₁)*norm(v₂)))
end

# Vector projection of a onto vector b
function proj(a::DirectionVector, b::DirectionVector)
	return a⋅b / length²(b) * b
end

# Get component of v₁ parallel to v₂
function ∥(v₁::DirectionVector, v₂::DirectionVector)
	return proj(v₁, v₂)
end

# Orthogonal vector projection of vector a on vector b
function oproj(a::DirectionVector, b::DirectionVector)
	return a - proj(a, b)
end

# Get component of v₁ perpendicular to v₂
function ⟂(v₁::DirectionVector, v₂::DirectionVector)
	return oproj(v₁, v₂)
end


""" 
Point structure with operations for 
translation
"""

struct PointVector
	x::Float64
	y::Float64
	z::Float64
end
# Translation
function displace(P::PointVector, v::DirectionVector)
	return PointVector(P.x+v.x, P.y+v.y, P.z+v.z)
end
function displace(v::DirectionVector, P::PointVector)
	return PointVector(P.x+v.x, P.y+v.y, P.z+v.z)
end
# Direction vector pointing from P to Q
function →(P::PointVector, Q::PointVector)
	return DirectionVector(Q.x-P.x, Q.y-P.y, Q.z-P.z)
end
# Normalized direction vector pointing from P to Q
function →ᵘ(P::PointVector, Q::PointVector)
	return unit(→(P,Q))
end