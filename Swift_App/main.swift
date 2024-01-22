import Foundation
import CommonCrypto
import Zip

func main() throws {
    // Create a FileManager instance
    let fileManager = FileManager.default

    // Read the QR code data from a file
    let qrCodeData = try String(contentsOfFile: "qr_codes/qr_data.txt", encoding: .utf8)

    // Load the pass.json file
    let passJsonURL = URL(fileURLWithPath: "pass.pkpass/pass.json")
    let passJsonData = try Data(contentsOf: passJsonURL)
    var passJson = try JSONSerialization.jsonObject(with: passJsonData, options: []) as! [String: Any]

    // Update the barcode field in the pass.json file with the QR code data
    passJson["barcode"] = [
        "message": qrCodeData,
        "format": "PKBarcodeFormatQR",
        "messageEncoding": "iso-8859-1"
    ]

    // Write the updated pass.json file back to disk
    let updatedPassJsonData = try JSONSerialization.data(withJSONObject: passJson, options: .prettyPrinted)
    try updatedPassJsonData.write(to: passJsonURL)

    // Get a list of all files in the pass.pkpass directory
    let passDirectoryURL = URL(fileURLWithPath: "pass.pkpass")
    let fileURLs = try fileManager.contentsOfDirectory(at: passDirectoryURL, includingPropertiesForKeys: nil)

    // Create a manifest file
    var manifest = [String: String]()
    for fileURL in fileURLs {
        // Skip the manifest.json and signature files
        if fileURL.lastPathComponent == "manifest.json" || fileURL.lastPathComponent == "signature" {
            continue
        }

        // Compute the SHA1 hash of each file
        let fileData = try Data(contentsOf: fileURL)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA1_DIGEST_LENGTH))
        fileData.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(fileData.count), &hash)
        }
        let hashString = hash.map { String(format: "%02x", $0) }.joined()

        // Add the file name and its hash to the manifest
        manifest[fileURL.lastPathComponent] = hashString
    }

    // Write the manifest file to disk
    let manifestURL = passDirectoryURL.appendingPathComponent("manifest.json")
    let manifestData = try JSONSerialization.data(withJSONObject: manifest, options: .prettyPrinted)
    try manifestData.write(to: manifestURL)

    // Sign the manifest.json file using OpenSSL
    let privateKeyPath = "certificates/key.pem"
    let certificatePath = "certificates/certificate.pem"
    let signaturePath = "pass.pkpass/signature"
    let opensslCommand = "openssl smime -binary -sign -certfile \(certificatePath) -signer \(certificatePath) -inkey \(privateKeyPath) -in \(manifestURL.path) -out \(signaturePath) -outform DER -nodetach"

    // Execute the OpenSSL command
    let process = Process()
    process.launchPath = "/bin/sh"
    process.arguments = ["-c", opensslCommand]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    process.launch()
    process.waitUntilExit()

    // Print the output of the OpenSSL command
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    print("OpenSSL output: \(output ?? "No output")")

    // Zip the pass package into a .pkpass file
    try Zip.zipFiles(paths: [passDirectoryURL], zipFilePath: URL(fileURLWithPath: "wallet_pass/pass.pkpass"), password: nil, progress: nil)

    // Create the wallet_pass directory if it doesn't exist
    let walletPassDirectoryURL = URL(fileURLWithPath: "wallet_pass")
    if !fileManager.fileExists(atPath: walletPassDirectoryURL.path) {
        try fileManager.createDirectory(at: walletPassDirectoryURL, withIntermediateDirectories: true)
    }

    // Zip the pass package again into a .pkpass file in the wallet_pass directory
    let zipFilePath = walletPassDirectoryURL.appendingPathComponent("pass.pkpass")
    try Zip.zipFiles(paths: [passDirectoryURL], zipFilePath: zipFilePath, password: nil, progress: nil)
}

do {
    // Run the main function and catch any errors
    try main()
} catch {
    print("An error occurred: \(error)")
}