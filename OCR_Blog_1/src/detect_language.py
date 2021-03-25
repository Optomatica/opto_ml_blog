import cv2
import pytesseract
import re

# Read image
img = cv2.imread('data/image2.png')

# Run Tesseract OSD
osd_output = pytesseract.image_to_osd(img)
print(f'Full OSD output: \n{osd_output}')

# Select the language from the OSD output
text_language = re.search('(?<=Script: )[a-zA-Z]+', osd_output).group(0)
print(f'Language: {text_language}')
