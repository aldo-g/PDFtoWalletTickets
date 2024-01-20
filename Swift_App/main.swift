import Foundation
import CommonCrypto
import Zip

func main() throws {
    let fileManager = FileManager.default
    let qrCodeData = try String(contentsOfFile: "qr_codes/qr_data.txt", encoding: .utf8)

    let passJsonURL = URL(fileURLWithPath: "pass.pkpass/pass.json")
    let passJsonData = try Data(contentsOf: passJsonURL)
    var passJson = try JSONSerialization.jsonObject(with: passJsonData, options: []) as! [String: Any]

    passJson["barcode"] = [
        "message": qrCodeData,
        "format": "PKBarcodeFormatQR",
        "messageEncoding": "iso-8859-1"
    ]

    let updatedPassJsonData = try JSONSerialization.data(withJSONObject: passJson, options: .prettyPrinted)
    try updatedPassJsonData.write(to: passJsonURL)

    let passDirectoryURL = URL(fileURLWithPath: "pass.pkpass")
    let fileURLs = try fileManager.contentsOfDirectory(at: passDirectoryURL, includingPropertiesForKeys: nil)
    var manifest = [String: String]()
    for fileURL in fileURLs {
        if fileURL.lastPathComponent == "manifest.json" || fileURL.lastPathComponent == "signature" {
            continue
        }
        let fileData = try Data(contentsOf: fileURL)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA1_DIGEST_LENGTH))
        fileData.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(fileData.count), &hash)
        }
        let hashString = hash.map { String(format: "%02x", $0) }.joined()
        manifest[fileURL.lastPathComponent] = hashString
    }
    let manifestURL = passDirectoryURL.appendingPathComponent("manifest.json")
    let manifestData = try JSONSerialization.data(withJSONObject: manifest, options: .prettyPrinted)
    try manifestData.write(to: manifestURL)

    // Sign the manifest.json file
    let privateKeyPath = "certificates/key.pem"
    let certificatePath = "certificates/certificate.pem"
    let signaturePath = "pass.pkpass/signature"
    let opensslCommand = "openssl smime -binary -sign -certfile \(certificatePath) -signer \(certificatePath) -inkey \(privateKeyPath) -in \(manifestURL.path) -out \(signaturePath) -outform DER -nodetach"

    let process = Process()
    process.launchPath = "/bin/sh"
    process.arguments = ["-c", opensslCommand]
    process.launch()
    process.waitUntilExit()

    // Zip the pass package
    try Zip.zipFiles(paths: [passDirectoryURL], zipFilePath: URL(fileURLWithPath: "wallet_pass/pass.pkpass"), password: nil, progress: nil)

    let walletPassDirectoryURL = URL(fileURLWithPath: "wallet_pass")
    if !fileManager.fileExists(atPath: walletPassDirectoryURL.path) {
        try fileManager.createDirectory(at: walletPassDirectoryURL, withIntermediateDirectories: true)
    }

    let zipFilePath = walletPassDirectoryURL.appendingPathComponent("pass.pkpass")
    try Zip.zipFiles(paths: [passDirectoryURL], zipFilePath: zipFilePath, password: nil, progress: nil)
}

do {
    try main()
} catch {
    print("An error occurred: \(error)")
}