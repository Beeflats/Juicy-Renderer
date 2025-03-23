struct Material
    # Basic
    baseColor
    # Specular
    roughness
    # Reflection
    metallic
    # Transparency
    #transparency
    #transmissionColor
    #atDistance
    #dispersion
    # Sheen
    #sheen
    # Emission
    #emissionIntensity
    #emissionColor
end

function genericPlasticMaterial(color)
    return Material(color, 0.3, 0)
end

function genericMetallicMaterial(color)
    return Material(color, 0.3, 1)
end

MATERIAL_softBeigeLeather = Material([0.684, 0.586999, 0.452124], 0.5, 0)
MATERIAL_blackRubber = Material([0.018, 0.018, 0.018], 0.6, 0)
MATERIAL_phenolic = Material([0.331, 0.130154, 0.020522], 0.8, 1) # coat = 4
MATERIAL_pianoLacquer = Material([0.002, 0.002, 0.002], 0.01, 0)
MATERIAL_toyPlastic = genericPlasticMaterial([0.755, 0.560625, 0.141185])
MATERIAL_whitePaint = Material([0.735, 0.735, 0.735], 1, 0)
MATERIAL_whitePorcelain = Material([0.9, 0.9, 0.9], 0, 0)
MATERIAL_aluminum = genericMetallicMaterial([0.913007, 0.914018, 0.91828])
MATERIAL_coatedMetalPaint = Material([0.599, 0, 0], 0.48, 1) # coat = 2, sheen = 10
MATERIAL_copper = genericMetallicMaterial([0.910198, 0.624593, 0.570658])
MATERIAL_gold = genericMetallicMaterial([0.93049, 0.753455, 0.392597])
MATERIAL_goldPaint = Material([0.549, 0.387126, 0.086], 0.65, 1)
MATERIAL_iron = genericMetallicMaterial([0.52742, 0.511844, 0.50087])
MATERIAL_silver = genericMetallicMaterial([0.959, 0.948503, 0.929673])
MATERIAL_platinum = genericMetallicMaterial([0.669607, 0.639872, 0.599869])
MATERIAL_titanium = genericMetallicMaterial([0.609547, 0.58002, 0.549617])
MATERIAL_milkChocolate = Material([0.126, 0.0466389, 0.003906], 0.4, 0)
MATERIAL_clay = genericPlasticMaterial([0.14, 0.121, 0.106359])
MATERIAL_perfectMirror = Material([1, 1, 1], 0, 1)