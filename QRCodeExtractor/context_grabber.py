import openai
import PyPDF2
# used to extract text from PDF files and understand context. 
# Open the PDF file
with open('event.pdf', 'rb') as file:
    reader = PyPDF2.PdfFileReader(file)
    text = ""
    for page in range(reader.numPages):
        text += reader.getPage(page).extractText()

# Initialize OpenAI API
openai.api_key = 'your-api-key'

# Define the prompt
prompt = f"{text}\n\nWhat is the name of the event?\nWhat is the name of the attendee?\nWhat is the date of the event?\nWhat is the location of the event?\nWhat is the seat or ticket number?"

# Call the OpenAI API
response = openai.Completion.create(
  engine="text-davinci-002",
  prompt=prompt,
  temperature=0.5,
  max_tokens=100
)

print(response.choices[0].text.strip())