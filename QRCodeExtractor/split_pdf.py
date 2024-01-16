from PyPDF2 import PdfReader, PdfWriter

# Define a function to split a PDF file into separate pages
def split_pdf(file_path):
    # Create a PdfReader instance with the input file path
    pdf = PdfReader(file_path)
    
    # Loop over the number of pages in the PDF file
    for page in range(len(pdf.pages)):
        # Create a PdfWriter instance
        pdf_writer = PdfWriter()
        
        # Add the current page to the PdfWriter instance
        pdf_writer.add_page(pdf.pages[page])
        
        # Create the output file name by appending the page number to the input file name
        output_filename = f"{file_path.split('.pdf')[0]}_page{page + 1}.pdf"
        
        # Open the output file in write-binary mode and write the PdfWriter contents to it
        with open(output_filename, 'wb') as output_pdf:
            pdf_writer.write(output_pdf)
    
    # Print a message indicating how many pages the PDF file was split into
    print(f"Split the pdf into {len(pdf.pages)} pages.")

# Call the split_pdf function with the path to the PDF file to split
split_pdf('pdfs/695372607187-8162482989-ticket.pdf')