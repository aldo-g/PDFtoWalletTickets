import class Foundation.Bundle

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("Swift_App_Swift_App.bundle").path
        let buildPath = "/Users/alastairgrant/Personal/Code_Projects/PDFtoWalletTickets/Swift_App/.build/arm64-apple-macosx/debug/Swift_App_Swift_App.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}