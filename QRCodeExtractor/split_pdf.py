from PyPDF2 import PdfReader, PdfWriter

def split_pdf(file_path):
    pdf = PdfReader(file_path)
    for page in range(len(pdf.pages)):
        pdf_writer = PdfWriter()
        pdf_writer.add_page(pdf.pages[page])

        output_filename = f"{file_path.split('.pdf')[0]}_page{page + 1}.pdf"

        with open(output_filename, 'wb') as output_pdf:
            pdf_writer.write(output_pdf)

    print(f"Split the pdf into {len(pdf.pages)} pages.")

split_pdf('pdfs/695372607187-8162482989-ticket.pdf')