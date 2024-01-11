const fs = require('fs');
const { Pass } = require('passkit-generator');

// Read the QR data from the file
const qrData = fs.readFileSync('./qr_codes/qr_data.txt', 'utf8');

// Create a new pass
let pass = new Pass({
    model: './myPassModel', // Updated path to the pass model
    certificate: './certificates/Certificates.p12',
    key: './certificates/key.pem',
    wwdr: './certificates/wwdr.pem',
    overrides: {
        // Keys to be overridden
        serialNumber: 'A1B2C3D4E5',
        description: 'Description of the pass',
    },
});

// Add fields to the pass
pass.primaryFields.add({
    key: 'event',
    label: 'Event',
    value: 'Event Name', // Update this value if necessary
});
pass.secondaryFields.add({
    key: 'location',
    label: 'Location',
    value: 'Event Location', // Update this value if necessary
});
pass.auxiliaryFields.add({
    key: 'date',
    label: 'Date',
    value: 'Event Date', // Update this value if necessary
});

// Add a barcode to the pass
pass.barcodes.add({
    message: qrData, // Use the QR data as the message
    format: 'PKBarcodeFormatQR',
    messageEncoding: 'iso-8859-1',
});

// Generate the pass and write it to a file
pass.generate()
    .then(pass => {
        pass.writeFile('./pass.pkpass'); // Updated path to the output file
    })
    .catch(err => {
        console.error(err);
    });