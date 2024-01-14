const fs = require('fs');
const crypto = require('crypto');
const child_process = require('child_process');
const archiver = require('archiver');
const path = require('path');

// Read the QR code data from the file
const qrCodeData = fs.readFileSync(path.join(__dirname, 'qr_codes', 'qr_data.txt'), 'utf8');

// Read the pass.json file
const passJsonPath = path.join(__dirname, 'pass.pkpass', 'pass.json');
let passJsonData = fs.readFileSync(passJsonPath, 'utf8');

// Parse the pass.json file
let passJson = JSON.parse(passJsonData);

// Add the barcode object to the pass.json file
passJson.barcode = {
    message: qrCodeData,
    format: "PKBarcodeFormatQR",
    messageEncoding: "iso-8859-1"
};

// Write the updated pass.json file back to disk
fs.writeFileSync(passJsonPath, JSON.stringify(passJson, null, 4));

// Generate the manifest.json file
const manifest = {};
fs.readdirSync('./pass.pkpass').forEach(file => {
  const filePath = `./pass.pkpass/${file}`;
  const fileBuffer = fs.readFileSync(filePath);
  const hash = crypto.createHash('sha1').update(fileBuffer).digest('hex');
  manifest[file] = hash;
});
fs.writeFileSync('./pass.pkpass/manifest.json', JSON.stringify(manifest));

// Sign the manifest.json file
child_process.execSync('openssl smime -binary -sign -certfile certificates/wwdr.pem -signer certificates/certificate.pem -inkey certificates/key.pem -in ./pass.pkpass/manifest.json -out ./pass.pkpass/signature -outform DER -passin pass:Hello123');

// Zip the pass package
const output = fs.createWriteStream('./wallet_pass/pass.pkpass');
const archive = archiver('zip');
archive.pipe(output);
archive.directory('./pass.pkpass/', false);
archive.finalize();