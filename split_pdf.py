import PyPDF2

def split_pdf(file_path):
    pdf = PyPDF2.PdfFileReader(file_path)
    for page in range(pdf.getNumPages()):
        pdf_writer = PyPDF2.PdfFileWriter()
        pdf_writer.addPage(pdf.getPage(page))

        output_filename = f"{file_path.split('.pdf')[0]}_page{page + 1}.pdf"

        with open(output_filename, 'wb') as output_pdf:
            pdf_writer.write(output_pdf)

    print(f"Split the pdf into {pdf.getNumPages()} pages.")