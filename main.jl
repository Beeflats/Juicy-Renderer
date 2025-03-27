using Images, ImageView
include("geometryOperations.jl")
include("Camera.jl")

# Set up the scene
camera = makeCamera(PointVector(0, 0, 0))
𝕊 = ⋃(Object(Sphere(PointVector(0, 1, 0), 0.1), MATERIAL_gold))
lightsource = PointVector(0, 2, 0)

# Render the scene
render(camera, 𝕊, lightsource)
colorview(RGB, image)