const fs = require('fs');
const path = require('path');

const sourceDir = '/app/shared';
const targetDir = '/app/qr_codes';

// Read the contents of the source directory
fs.readdir(sourceDir, (err, files) => {
    if (err) {
        return console.log('Unable to scan directory: ' + err);
    }

    // Loop through all the files in the directory
    files.forEach((file) => {
        // Construct full file paths
        const sourceFile = path.join(sourceDir, file);
        const targetFile = path.join(targetDir, file);

        // Copy the file
        fs.copyFile(sourceFile, targetFile, (err) => {
            if (err) throw err;
            console.log(`Copied ${file} to ${targetDir}`);

            // Delete the original file
            fs.unlink(sourceFile, (err) => {
                if (err) throw err;
                console.log(`Deleted original ${file}`);
            });
        });
    });
});