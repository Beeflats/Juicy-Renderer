using Images, ImageView
include("render.jl")

# Camera
lightIntensity = 5
lightColor = [1,1,1]
lightMaterial = genericEmissiveMaterial(lightColor, lightIntensity)
ceilingHeight = HZ = 0.554
leftColor = [0.122, 0.608, 0.145]
rightColor = [0.651, 0.051, 0.051]
roomColor = [0.729, 0.729, 0.729]
floor_z = 0
function roomMaterial(baseColor)
    return Material(baseColor, 1, 0, 0, [0,0,0])
end
ID = STYLE_identity

# Camera
camera = makeCamera(PointVector(0,0,HZ/2), ĵ, 9/9, 500)

# Cornell box
floor = Object(GROUNDPLANE, roomMaterial(roomColor), ID)
ceiling = Object(Plane(PointVector(0,0,HZ), k̂), roomMaterial(roomColor), ID)
backWall = Object(Plane(PointVector(0,2.5HZ,0), ĵ), roomMaterial(roomColor), ID)
leftWall = Object(Plane(PointVector(-HZ/2,0,0), î), roomMaterial(leftColor), ID)
rightWall = Object(Plane(PointVector(HZ/2,0,0), î), roomMaterial(rightColor), ID)

# Light
light1 = Object(Triangle(PointVector(- HZ/4, 1.8HZ - HZ/4, 0.999HZ), PointVector(- HZ/4, 1.8HZ + HZ/4, 0.999HZ), PointVector(+ HZ/4, 1.8HZ - HZ/4, 0.999HZ)), lightMaterial, STYLE_identity)
light2 = Object(Triangle(PointVector(+ HZ/4, 1.8HZ + HZ/4, 0.999HZ), PointVector(- HZ/4, 1.8HZ + HZ/4, 0.999HZ), PointVector(+ HZ/4, 1.8HZ - HZ/4, 0.999HZ)), lightMaterial, STYLE_identity)
light = ⋃(light1, light2)

ball = Object(Sphere(PointVector(-0.17, 2HZ, HZ/6), HZ/6), MATERIAL_perfectMirror, ID)

prismCap_z = HZ/3
corners = [[0.0,1],[0.133,1.2],[0.11,0.8],[0.24,0.98]]
p1 = PointVector(corners[1][1],corners[1][2],0); p2 = PointVector(corners[2][1],corners[2][2],0); p3 = PointVector(corners[3][1],corners[3][2],0) ; p4 = PointVector(corners[4][1],corners[4][2],0);
p5 = PointVector(corners[1][1],corners[1][2],prismCap_z); 
p6 = PointVector(corners[2][1],corners[2][2],prismCap_z); 
p7 = PointVector(corners[3][1],corners[3][2],prismCap_z); 
p8 = PointVector(corners[4][1],corners[4][2],prismCap_z);
prismMat = MATERIAL_perfectMirror
prismStyle = STYLE_identity

prismFace1 = ⋃(Object(Triangle(p1,p3,p7),prismMat, prismStyle), Object(Triangle(p7,p5,p1),prismMat, prismStyle))
prismFace2 = ⋃(Object(Triangle(p2,p1,p5),prismMat, prismStyle), Object(Triangle(p5,p6,p2),prismMat, prismStyle))
prismFace3 = ⋃(Object(Triangle(p2,p4,p8),prismMat, prismStyle), Object(Triangle(p8,p6,p2),prismMat, prismStyle))
prismFace4 = ⋃(Object(Triangle(p3,p4,p8),prismMat, prismStyle), Object(Triangle(p8,p7,p3),prismMat, prismStyle))
prismCap = ⋃(Object(Triangle(p5,p6,p8),prismMat, prismStyle), Object(Triangle(p8,p7,p5),prismMat, prismStyle))
prism = prismFace1 ∪ prismFace2 ∪ prismFace3 ∪ prismFace4 ∪ prismCap

ball1 = Object(Sphere(p1, 0.02), genericMaterial([0,1,0],0,0), ID)
ball2 = Object(Sphere(p2, 0.02), genericMaterial([1,0,0],0,0), ID)
ball3 = Object(Sphere(p3, 0.02), genericMaterial([0,0,1],0,0), ID)
ball4 = Object(Sphere(p4, 0.02), genericMaterial([1,1,0],0,0), ID)
balls = ⋃(ball1,ball2,ball3,ball4)

props = ⋃(ball) ∪ prism #∪ balls

𝕊 = ⋃(floor, ceiling, backWall, leftWall, rightWall) ∪ light ∪ props

lightsource = DirectionVector(1,1,1)

# Render the scene
image = render(camera, 𝕊, lightsource, 5, 3)
colorview(RGB, image)