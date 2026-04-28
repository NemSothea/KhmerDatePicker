import XCTest
#if canImport(CoreText)
import CoreText
#endif
@testable import KhmerDatePicker

final class KhmerFontTests: XCTestCase {

    func testPostScriptNamesAreStable() {
        XCTAssertNil(KhmerFont.system.postScriptName)
        XCTAssertEqual(KhmerFont.kantumruyPro.postScriptName, "KantumruyPro-Regular")
        XCTAssertEqual(KhmerFont.custom(name: "Acme-Bold").postScriptName, "Acme-Bold")
    }

    func testBundledFontFilesArePresent() {
        let bundle = Bundle.module
        XCTAssertNotNil(
            bundle.url(forResource: "KantumruyPro-Regular", withExtension: "ttf"),
            "KantumruyPro-Regular.ttf must ship in the package bundle"
        )
        XCTAssertNotNil(
            bundle.url(forResource: "KantumruyPro-Italic", withExtension: "ttf"),
            "KantumruyPro-Italic.ttf must ship in the package bundle"
        )
        XCTAssertNotNil(
            bundle.url(forResource: "OFL", withExtension: "txt"),
            "OFL.txt license must ship alongside the bundled fonts"
        )
    }

    #if canImport(CoreText)
    func testKantumruyProRegistersAndResolves() {
        KhmerFontRegistrar.registerBundledFontsIfNeeded()

        let descriptor = CTFontDescriptorCreateWithNameAndSize(
            "KantumruyPro-Regular" as CFString,
            16
        )
        let font = CTFontCreateWithFontDescriptor(descriptor, 16, nil)
        let resolvedName = CTFontCopyPostScriptName(font) as String
        XCTAssertEqual(
            resolvedName,
            "KantumruyPro-Regular",
            "CoreText should resolve the bundled PostScript name after registration"
        )
    }
    #endif
}
