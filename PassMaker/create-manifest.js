const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// The directory containing your pass files
const passDirectory = './pass.pkpass';

// Get a list of all files in the directory
const files = fs.readdirSync(passDirectory);

// Create an object to store the hashes
const hashes = {};

// For each file, generate a SHA1 hash and add it to the hashes object
files.forEach(file => {
  const filePath = path.join(passDirectory, file);
  const fileBuffer = fs.readFileSync(filePath);
  const hash = crypto.createHash('sha1').update(fileBuffer).digest('hex');
  hashes[file] = hash;
});

// Write the hashes object to the manifest.json file
fs.writeFileSync(path.join(passDirectory, 'manifest.json'), JSON.stringify(hashes, null, 2));