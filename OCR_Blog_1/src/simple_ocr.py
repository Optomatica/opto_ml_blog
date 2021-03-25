'''Simple OCR with Tesseract'''

import pytesseract
import cv2

# Read image
img = cv2.imread('data/image.jpg')

# Show image
cv2.imshow('Image', img)
cv2.waitKey(0)
cv2.destroyAllWindows()

# Run Tesseract
text = pytesseract.image_to_string(img, config='--oem=3 --psm=6')
print(f'I found the following text in the image: {text}')

