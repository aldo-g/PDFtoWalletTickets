const fs = require('fs');
const { Pass } = require('passkit-generator');

// Read the QR data from the file
const qrData = fs.readFileSync('./qr_codes/qr_data.txt', 'utf8');
console.log('QR Data:', qrData); // Log the QR data
console.log('Model directory:', fs.existsSync('./myPassModel'));
console.log('Certificates.p12 file:', fs.existsSync('./certificates/Certificates.p12'));
console.log('key.pem file:', fs.existsSync('./certificates/key.pem'));
console.log('wwdr.pem file:', fs.existsSync('./certificates/wwdr.pem'));
console.log('Serial number:', 'A1B2C3D4E5');
console.log('Description:', 'Description of the pass');

// Create a new pass
let pass = new Pass({
    model: './myPassModel', // Updated path to the pass model
    certificate: './certificates/Certificates.p12',
    key: './certificates/key.pem',
    wwdr: './certificates/wwdr.pem',
});

console.log('Pass created:', pass); // Log the created pass

// // Add fields to the pass
// pass.primaryFields.add({
//     key: 'event',
//     label: 'Event',
//     value: 'Event Name', // Update this value if necessary
// });
// pass.secondaryFields.add({
//     key: 'location',
//     label: 'Location',
//     value: 'Event Location', // Update this value if necessary
// });
// pass.auxiliaryFields.add({
//     key: 'date',
//     label: 'Date',
//     value: 'Event Date', // Update this value if necessary
// });

// console.log('Fields added to pass:', pass); // Log the pass after adding fields

// Add a barcode to the pass
pass.barcodes.add({
    message: qrData, // Use the QR data as the message
    format: 'PKBarcodeFormatQR',
    messageEncoding: 'iso-8859-1',
});

console.log('Barcode added to pass:', pass); // Log the pass after adding the barcode

// Generate the pass and write it to a file
pass.generate()
    .then(pass => {
        pass.writeFile('./pass.pkpass'); // Updated path to the output file
        console.log('Pass generated and written to file:', pass); // Log the pass after it's generated and written to file
    })
    .catch(err => {
        console.error('Error generating pass:', err); // Log any errors that occur during pass generation
    });