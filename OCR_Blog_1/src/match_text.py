import cv2
import pytesseract

img = cv2.imread('data/image.jpg')
text = pytesseract.image_to_string(img, config='--oem=3 --psm=6')
print(f'Text: {text}')

keyword = 'Tesseract'

if keyword in text:
    print(f'I found the keyword `{keyword}`!')
else:
    print(f'I did not find the keyword `{keyword}`!')
