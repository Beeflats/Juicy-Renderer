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
    emissionIntensity
    emissionColor
end

function genericMaterial(color, roughness, metallic) # non-emissive
    return Material(color, roughness, metallic, 0, [1, 1, 1])
end

function plasticMaterial(color)
    return genericMaterial(color, 0.3, 0)
end

function metallicMaterial(color)
    return genericMaterial(color, 0.3, 1)
end

function genericEmissiveMaterial(color, intensity = 1)
    return Material([1, 1, 1], 0.3, 0, intensity, color)
end

MATERIAL_softBeigeLeather = genericMaterial([0.684, 0.586999, 0.452124], 0.5, 0)
MATERIAL_blackRubber = genericMaterial([0.018, 0.018, 0.018], 0.6, 0)
MATERIAL_phenolic = genericMaterial([0.331, 0.130154, 0.020522], 0.8, 1) # coat = 4
MATERIAL_pianoLacquer = genericMaterial([0.002, 0.002, 0.002], 0.01, 0)
MATERIAL_toyPlastic = plasticMaterial([0.755, 0.560625, 0.141185])
MATERIAL_whitePaint = genericMaterial([0.735, 0.735, 0.735], 1, 0)
MATERIAL_whitePorcelain = genericMaterial([0.9, 0.9, 0.9], 0, 0)
MATERIAL_aluminum = metallicMaterial([0.913007, 0.914018, 0.91828])
MATERIAL_coatedMetalPaint = genericMaterial([0.599, 0, 0], 0.48, 1) # coat = 2, sheen = 10
MATERIAL_copper = metallicMaterial([0.910198, 0.624593, 0.570658])
MATERIAL_gold = metallicMaterial([0.93049, 0.753455, 0.392597])
MATERIAL_goldPaint = genericMaterial([0.549, 0.387126, 0.086], 0.65, 1)
MATERIAL_iron = metallicMaterial([0.52742, 0.511844, 0.50087])
MATERIAL_silver = metallicMaterial([0.959, 0.948503, 0.929673])
MATERIAL_platinum = metallicMaterial([0.669607, 0.639872, 0.599869])
MATERIAL_titanium = metallicMaterial([0.609547, 0.58002, 0.549617])
MATERIAL_milkChocolate = genericMaterial([0.126, 0.0466389, 0.003906], 0.4, 0)
MATERIAL_clay = plasticMaterial([0.14, 0.121, 0.106359])
MATERIAL_perfectMirror = genericMaterial([1, 1, 1], 0, 1)
MATERIAL_orangeGlow = genericEmissiveMaterial([1, 0.119, 0], 1)