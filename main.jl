using Images, ImageView
include("render.jl")

# Set up the scene
camera = makeCamera(PointVector(0,0,0), ĵ, 16/9, 500)

light = Object(Sphere(PointVector(0,0.6,0.27), 0.2), genericEmissiveMaterial([1,1,0.8],2), STYLE_identity)
floor = Object(Plane(PointVector(0,0,-0.1), k̂), MATERIAL_whitePaint, STYLE_depthMap)
ceiling = Object(Plane(PointVector(0,0,0.1), k̂), MATERIAL_whitePaint, STYLE_normalMap)
leftwall = Object(Plane(PointVector(-0.14,0,0), î), Material([0,0.9,0],0.98,0.1,0,[0,0,0]), STYLE_identity)
rightwall = Object(Plane(PointVector(0.14,0,0), î), Material([0.9,0,0],0.98,0.1,0,[0,0,0]), STYLE_depthMap)
backwall = Object(Plane(PointVector(0,0.9,0), ĵ), MATERIAL_whitePaint, STYLE_depthMap)
frontwall = Object(Plane(PointVector(0,-0.1,0), ĵ), genericEmissiveMaterial([1,1,0.8], 0.5), STYLE_identity)

STYLE_MonochromeEdge = STYLE_edgeLines(0.2, [0,0,0]) ∘ STYLE_fill([1,1,1])

ball1 = Object(Sphere(PointVector(0,0.6,-0.1+0.02), 0.02), MATERIAL_toyPlastic, STYLE_MonochromeEdge)
ball2 = Object(Sphere(PointVector(-0.07,0.5,-0.1+0.03), 0.03), MATERIAL_coatedMetalPaint, STYLE_identity)
ball3 = Object(Sphere(PointVector(0.08,0.6,-0.1+0.04), 0.04), MATERIAL_aluminum, STYLE_invert)

𝕊 = ⋃(light, floor, ceiling, leftwall, rightwall, frontwall, backwall, ball1, ball2 ,ball3)

lightsource = DirectionVector(1,1,1)

# Render the scene
image = render(camera, 𝕊, lightsource, 1, 2)
colorview(RGB, image)