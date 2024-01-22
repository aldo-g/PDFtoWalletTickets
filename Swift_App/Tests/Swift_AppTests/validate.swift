import XCTest
import CommonCrypto

class ManifestHashTest: XCTestCase {
    func testManifestHashes() throws {
        // Create a FileManager instance
        let fileManager = FileManager.default

        // Load the manifest.json file
        let manifestURL = URL(fileURLWithPath: "pass.pkpass/manifest.json")
        let manifestData = try Data(contentsOf: manifestURL)
        let manifest = try JSONSerialization.jsonObject(with: manifestData, options: []) as! [String: String]

        // Get a list of all files in the pass.pkpass directory
        let passDirectoryURL = URL(fileURLWithPath: "pass.pkpass")
        let fileURLs = try fileManager.contentsOfDirectory(at: passDirectoryURL, includingPropertiesForKeys: nil)

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

            // Compare the computed hash with the hash in the manifest
            XCTAssertEqual(hashString, manifest[fileURL.lastPathComponent], "Hash for \(fileURL.lastPathComponent) does not match the hash in the manifest")
        }
    }
}