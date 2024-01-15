from pdf2image import convert_from_path
from pyzbar.pyzbar import decode
from PIL import Image
from PyPDF2 import PdfReader
import qrcode

# Read the PDF file
with open('pdfs/695372607187-8162482989-ticket_page1.pdf', 'rb') as file:
    reader = PdfReader(file)
    content = reader.pages[0].extract_text()

# Convert PDF page to images
images = convert_from_path('pdfs/695372607187-8162482989-ticket_page1.pdf')

# Find the QR code in the images
for i in range(len(images)):
    decoded_objects = decode(images[i])
    for obj in decoded_objects:
        if obj.type == 'QRCODE':
            qr_data = obj.data.decode('utf-8')
            break

# Write the QR data to a file
with open('qr_codes/qr_data.txt', 'w') as file:
    file.write(qr_data)

# Print the QR data
for i in range(len(images)):
    decoded_objects = decode(images[i])
    for obj in decoded_objects:
        if obj.type == 'QRCODE':
            qr_data = obj.data.decode('utf-8')
            break
