import Foundation
import CommonCrypto
import Zip

func deleteWalletPassDirectory() throws {
    let fileManager = FileManager.default
    let walletPassDirectoryURL = URL(fileURLWithPath: "wallet_pass")
    if fileManager.fileExists(atPath: walletPassDirectoryURL.path) {
        try fileManager.removeItem(at: walletPassDirectoryURL)
    }
    print("Deleting Wallet Pass directory is complete.")
}

func deleteUnzippedDirectory() throws {
    let fileManager = FileManager.default
    let unzippedDirectoryURL = URL(fileURLWithPath: "Swift_App/unzipped")
    if fileManager.fileExists(atPath: unzippedDirectoryURL.path) {
        try fileManager.removeItem(at: unzippedDirectoryURL)
    }
    print("Deleting Unzipped directory is complete.")
}

func readQRCodeData() throws -> String { 
    let qrCodeData = try String(contentsOfFile: "qr_codes/qr_data.txt", encoding: .utf8)
    print("QR Code data reading is complete.")
    return qrCodeData
}

func loadPassJson() throws -> [String: Any] { 
    let passJsonURL = URL(fileURLWithPath: "pre.pkpass/pass.json") 
    let passJsonData = try Data(contentsOf: passJsonURL) 
    let jsonObject = try JSONSerialization.jsonObject(with: passJsonData, options: []) as! [String: Any]
    print("Loading pass.json is complete.")
    return jsonObject
}

func updatePassJson(_ passJson: inout [String: Any], with qrCodeData: String) { 
    passJson["barcode"] = [ "message": qrCodeData, "format": "PKBarcodeFormatQR", "messageEncoding": "iso-8859-1" ]
    print("Updating pass.json with QR code data is complete.")
}

func writePassJson(_ passJson: [String: Any]) throws { 
    let passJsonURL = URL(fileURLWithPath: "pre.pkpass/pass.json") 
    let updatedPassJsonData = try JSONSerialization.data(withJSONObject: passJson, options: .prettyPrinted) 
    try updatedPassJsonData.write(to: passJsonURL) 
    print("Writing updated pass.json is complete.")
}

func createManifest(for fileURLs: [URL]) throws -> [String: String] { 
    var manifest = [String: String]() 
    for fileURL in fileURLs { 
        if fileURL.lastPathComponent == "manifest.json" || fileURL.lastPathComponent == "signature" { 
            continue 
        } 
        let fileData = try Data(contentsOf: fileURL) 
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH)) 
        fileData.withUnsafeBytes { _ = CC_SHA1($0.baseAddress, CC_LONG(fileData.count), &hash) } 
        let hashString = hash.map { String(format: "%02x", $0) }.joined() 
        manifest[fileURL.lastPathComponent] = hashString 
    } 
    print("Creating manifest is complete.")
    return manifest 
}

func writeManifest(_ manifest: [String: String]) throws { 
    let manifestURL = URL(fileURLWithPath: "pre.pkpass/manifest.json") 
    let manifestData = try JSONSerialization.data(withJSONObject: manifest, options: .prettyPrinted) 
    try manifestData.write(to: manifestURL) 
    print("Writing manifest is complete.")
}

func signManifest() throws { 
    let privateKeyPath = "certificates/key.pem" 
    let certificatePath = "certificates/certificate.pem" 
    let signaturePath = "pre.pkpass/signature" 
    let manifestURL = URL(fileURLWithPath: "pre.pkpass/manifest.json") 
    let opensslCommand = "openssl smime -binary -sign -certfile \(certificatePath) -signer \(certificatePath) -inkey \(privateKeyPath) -in \(manifestURL.path) -out \(signaturePath) -outform DER -nodetach" 
    let process = Process() 
    process.launchPath = "/bin/sh" 
    process.arguments = ["-c", opensslCommand] 
    let pipe = Pipe() 
    process.standardOutput = pipe 
    process.standardError = pipe 
    process.launch() 
    process.waitUntilExit() 
    if process.terminationStatus != 0 { 
        throw NSError(domain: "OpenSSL", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "The OpenSSL command failed. Check your certificate and private key."]) 
    } 
    print("Signing manifest is complete.")
}

func createWalletPassDirectory() throws { 
    let fileManager = FileManager.default 
    let walletPassDirectoryURL = URL(fileURLWithPath: "wallet_pass") 
    if !fileManager.fileExists(atPath: walletPassDirectoryURL.path) { 
        try fileManager.createDirectory(at: walletPassDirectoryURL, withIntermediateDirectories: true) 
    } 
    print("Creating Wallet Pass directory is complete.")
}

func zipPassPackage() throws { 
    let passDirectoryURL = URL(fileURLWithPath: "pre.pkpass") 
    let walletPassDirectoryURL = URL(fileURLWithPath: "wallet_pass") 
    let zipFilePath = walletPassDirectoryURL.appendingPathComponent("pass.pkpass")
    try Zip.zipFiles(paths: [passDirectoryURL], zipFilePath: zipFilePath, password: nil, progress: nil) 
    print("Zipping pass package is complete.")
}

func unzipPassPackage() throws {
    let unzipCommand = "unzip -o wallet_pass/pass.pkpass -d unzipped"
    let process = Process()
    process.launchPath = "/bin/sh"
    process.arguments = ["-c", unzipCommand]
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    process.launch()
    process.waitUntilExit()
    if process.terminationStatus != 0 {
        throw NSError(domain: "Unzip", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "The unzip command failed. Check your zip file and destination directory."])
    }
    let fileManager = FileManager.default
    let currentDirectoryPath = fileManager.currentDirectoryPath
    let unzippedPackagePath = currentDirectoryPath + "/unzipped"
    print("Unzipping pass package is complete. The unzipped package is located at \(unzippedPackagePath).")

    // List the contents of the unzipped directory
    let lsProcess = Process()
    lsProcess.launchPath = "/bin/sh"
    lsProcess.arguments = ["-c", "ls \(unzippedPackagePath)"]
    let lsPipe = Pipe()
    lsProcess.standardOutput = lsPipe
    lsProcess.standardError = lsPipe
    lsProcess.launch()
    lsProcess.waitUntilExit()

    let data = lsPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    print("Contents of the unzipped directory:\n\(output ?? "No output")")
}

func verifyCertificateFile() throws {
    let fileManager = FileManager.default
    let certificatePath = "certificates/certificate.pem"

    // Check if the file exists
    guard fileManager.fileExists(atPath: certificatePath) else {
        throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "The certificate file does not exist."])
    }

    // Check if the file is readable
    guard fileManager.isReadableFile(atPath: certificatePath) else {
        throw NSError(domain: "FileError", code: 2, userInfo: [NSLocalizedDescriptionKey: "The certificate file is not accessible."])
    }

    print("The certificate file exists and is accessible.")
}

func verifyManifestAndSignatureFiles() throws {
    let fileManager = FileManager.default
    let manifestPath = "unzipped/pre.pkpass/manifest.json"
    let signaturePath = "unzipped/pre.pkpass/signature"

    // Check if the manifest.json file exists and is readable
    guard fileManager.fileExists(atPath: manifestPath), fileManager.isReadableFile(atPath: manifestPath) else {
        throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "The manifest.json file does not exist or is not accessible."])
    }

    // Check if the signature file exists and is readable
    guard fileManager.fileExists(atPath: signaturePath), fileManager.isReadableFile(atPath: signaturePath) else {
        throw NSError(domain: "FileError", code: 2, userInfo: [NSLocalizedDescriptionKey: "The signature file does not exist or is not accessible."])
    }

    print("The manifest.json and signature files exist and are accessible.")
}

func verifyUnzippedManifest() throws {
    let certificatePath = "certificates/certificate.pem"
    let manifestPath = "unzipped/pre.pkpass/manifest.json"
    let signaturePath = "unzipped/pre.pkpass/signature"
    let opensslCommand = "openssl smime -verify -in \(signaturePath) -inform DER -content \(manifestPath) -CAfile \(certificatePath)"
    let process = Process()
    process.launchPath = "/bin/sh"
    process.arguments = ["-c", opensslCommand]
    let outPipe = Pipe()
    let errPipe = Pipe()
    process.standardOutput = outPipe
    process.standardError = errPipe
    process.launch()
    process.waitUntilExit()

    let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
    let outPrint = String(data: outData, encoding: .utf8)
    let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
    let errPrint = String(data: errData, encoding: .utf8)
    print("Standard Output: \(outPrint ?? "")")
    print("Standard Error: \(errPrint ?? "")")

    if process.terminationStatus != 0 {
        throw NSError(domain: "OpenSSL", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "The OpenSSL command failed. Check your certificate."])
    }
    print("Verification of unzipped manifest is complete.")
}

func main() throws { 
    try deleteWalletPassDirectory()
    try deleteUnzippedDirectory()
    let qrCodeData = try readQRCodeData() 
    var passJson = try loadPassJson() 
    updatePassJson(&passJson, with: qrCodeData) 
    try writePassJson(passJson) 
    let fileManager = FileManager.default 
    let passDirectoryURL = URL(fileURLWithPath: "pre.pkpass") 
    let fileURLs = try fileManager.contentsOfDirectory(at: passDirectoryURL, includingPropertiesForKeys: nil) 
    let manifest = try createManifest(for: fileURLs) 
    try writeManifest(manifest) 
    try signManifest() 
    try createWalletPassDirectory() 
    try zipPassPackage()
    try unzipPassPackage()
    try verifyCertificateFile()
    try verifyManifestAndSignatureFiles()
    try verifyUnzippedManifest()
    print("Main function execution is complete.")
}

do {
    // Run the main function and catch any errors
    try main()
} catch {
    print("An error occurred: \(error)")
}