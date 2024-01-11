const { Pass } = require('passkit-generator');

// Create a new pass
let pass = new Pass({
    model: 'path/to/your/model',
    certificate: 'path/to/your/certificate.pem',
    key: 'path/to/your/key.pem',
    wwdr: 'path/to/your/wwdr.pem',
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
    value: 'Event Name',
});
pass.secondaryFields.add({
    key: 'location',
    label: 'Location',
    value: 'Event Location',
});
pass.auxiliaryFields.add({
    key: 'date',
    label: 'Date',
    value: 'Event Date',
});

// Add a barcode to the pass
pass.barcodes.add({
    message: 'Your message here',
    format: 'PKBarcodeFormatQR',
    messageEncoding: 'iso-8859-1',
});

// Generate the pass and write it to a file
pass.generate()
    .then(pass => {
        pass.writeFile('path/to/your/pass.pkpass');
    })
    .catch(err => {
        console.error(err);
    });