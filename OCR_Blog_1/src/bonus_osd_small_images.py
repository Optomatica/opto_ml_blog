import re
import cv2
import pytesseract

# Read image
img = cv2.imread('data/image.jpg')

# If you run Tesseract OSD on image that contains few characters, 
# it will yield an exception
# osd_output = pytesseract.image_to_osd(img)

# Fix: Tile the image
# First we use the hconcat method to tile the image horizontally
img_tiled_h = cv2.hconcat([img]*5)

# Then we use the vconcat method to tile the image vertically
img_tiled = cv2.vconcat([img_tiled_h]*5)

# Display the image before tiling
cv2.imshow('Image before tiling', img)

# Display the image after tiling
cv2.imshow('Image after tiling', img_tiled)

cv2.waitKey(0)
cv2.destroyAllWindows()

# Get the full OSD output
osd_output = pytesseract.image_to_osd(img_tiled)
print(f'Full OSD output: \n{osd_output}')

# Select the language from the OSD output
text_language = re.search('(?<=Script: )[a-zA-Z]+', osd_output).group(0)
print(f'Language: {text_language}')
