const fs = require('fs');
const crypto = require('crypto');
const child_process = require('child_process');
const archiver = require('archiver');

// Read the pass.json file
const passJson = fs.readFileSync('./pass.pkpass/pass.json', 'utf8');

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