using Images, ImageView

# Initialise image
imageWidth = 256
imageHeight = 256
image = zeros(3, imageHeight, imageWidth)

# Render image
for i ∈ 1:imageHeight, j ∈ 1:imageWidth
    pixelColor = [(i-1)/imageHeight, (j-1)/imageWidth, 0]
    image[:, i, j] = pixelColor
end

colorview(RGB, image)