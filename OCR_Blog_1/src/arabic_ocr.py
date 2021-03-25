import cv2
import pytesseract

img = cv2.imread('data/image3.png')
text = pytesseract.image_to_string(img, lang='ara', config='--oem=3 --psm=6')
print(f'I found the following text in the image: {text}')
