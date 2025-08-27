import XCTest
@testable import PPMGobbler

#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if canImport(UIKit)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

final class PPMGobblerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testAll() throws {
        for file in TestFile.allCases {
            try testFile(file)
        }

        #if canImport(CoreGraphics)
        for file in TestFile.allCases {
            try testCGImage(file)
        }
        #endif

        #if canImport(UIKit)
        for file in TestFile.allCases {
            try testUIImage(file)
        }
        #endif

        #if os(macOS)
        for file in TestFile.allCases {
            try testNSImage(file)
        }
        #endif
    }
    
    func testFile(_ file: TestFile) throws {
        print("----- Testing \(file) -----")
        let contents = try Data(contentsOf: file.url)

        print("> Reading")
        switch file.format {
        case .P1, .P4:
            let image = try PPMImage<PPMPixelBW>(data: contents)
            XCTAssertEqual(image.width, TestFile.inMemory.width)
            XCTAssertEqual(image.height, TestFile.inMemory.height)
            
            let inMemory = PPMImage<PPMPixelBW>(image: TestFile.inMemory)
            for x in 0..<image.width {
                for y in 0..<image.height {
                    XCTAssertEqual(image[x, y], inMemory[x, y], "Pixel at (\(x), \(y))")
                }
            }

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            XCTAssertEqual(image.width, TestFile.inMemory.width)
            XCTAssertEqual(image.height, TestFile.inMemory.height)

            let inMemory = PPMImage<PPMPixelGrey>(image: TestFile.inMemory)
            for x in 0..<image.width {
                for y in 0..<image.height {
                    XCTAssertEqual(image[x, y].value, inMemory[x, y].value, accuracy: 1 / 255.0, "Pixel at (\(x), \(y))")
                }
            }

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            XCTAssertEqual(image.width, TestFile.inMemory.width)
            XCTAssertEqual(image.height, TestFile.inMemory.height)
            
            let inMemory = PPMImage<PPMPixelRGB>(image: TestFile.inMemory)
            for x in 0..<image.width {
                for y in 0..<image.height {
                    XCTAssertEqual(image[x, y].r, inMemory[x, y].r, accuracy: 1 / 255.0, "Pixel at (\(x), \(y), R)")
                    XCTAssertEqual(image[x, y].g, inMemory[x, y].g, accuracy: 1 / 255.0, "Pixel at (\(x), \(y), G)")
                    XCTAssertEqual(image[x, y].b, inMemory[x, y].b, accuracy: 1 / 255.0, "Pixel at (\(x), \(y), B)")
                }
            }
        }
        
        print("> Idempotency")
        switch file.format {
        case .P1, .P4:
            let image = try PPMImage<PPMPixelBW>(data: contents)
            let encodedData = image.data(format: file.format, levels: file.levels)
            XCTAssertEqual(contents, encodedData)

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            let encodedData = image.data(format: file.format, levels: file.levels)
            XCTAssertEqual(contents, encodedData)

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            let encodedData = image.data(format: file.format, levels: file.levels)
            XCTAssertEqual(contents, encodedData)
        }
        
        guard file.variants.isEmpty == false else { return }
        print("> Variants")
        for variant in file.variants {
            let variantData = try Data(contentsOf: file.variantURL(for: variant))
            
            let variantRGB = try PPMImage<PPMPixelRGB>(data: variantData)
            let originalRGB = try PPMImage<PPMPixelRGB>(data: contents)
            XCTAssertEqual(variantRGB, originalRGB)
            
            let variantGrey = try PPMImage<PPMPixelGrey>(data: variantData)
            let originalGrey = try PPMImage<PPMPixelGrey>(data: contents)
            XCTAssertEqual(variantGrey, originalGrey)
            
            let variantBW = try PPMImage<PPMPixelBW>(data: variantData)
            let originalBW = try PPMImage<PPMPixelBW>(data: contents)
            XCTAssertEqual(variantBW, originalBW)
        }
    }
    
#if canImport(CoreGraphics)
    func testCGImage(_ file: TestFile) throws {
        print("----- Testing \(file) (CGImage) -----")
        let contents = try Data(contentsOf: file.url)

        switch file.format {
        case .P1, .P4:
            let image = try PPMImage<PPMPixelBW>(data: contents)
            let cgImage = image.cgImage
            XCTAssertNotNil(cgImage)
            XCTAssertEqual(cgImage!.width, Int(image.width))
            XCTAssertEqual(cgImage!.height, Int(image.height))
            XCTAssertEqual(cgImage!.colorSpace?.name as String?, "kCGColorSpaceDeviceGray")
            XCTAssertEqual(cgImage!.bitsPerComponent, 8)
            XCTAssertEqual(cgImage!.bitsPerPixel, 8)

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            let cgImage = image.cgImage
            XCTAssertNotNil(cgImage)
            XCTAssertEqual(cgImage!.width, Int(image.width))
            XCTAssertEqual(cgImage!.height, Int(image.height))
            XCTAssertEqual(cgImage!.colorSpace?.name as String?, "kCGColorSpaceDeviceGray")
            XCTAssertEqual(cgImage!.bitsPerComponent, 8)
            XCTAssertEqual(cgImage!.bitsPerPixel, 8)

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            let cgImage = image.cgImage
            XCTAssertNotNil(cgImage)
            XCTAssertEqual(cgImage!.width, Int(image.width))
            XCTAssertEqual(cgImage!.height, Int(image.height))
            XCTAssertEqual(cgImage!.colorSpace?.name as String?, "kCGColorSpaceDeviceRGB")
            XCTAssertEqual(cgImage!.bitsPerComponent, 8)
            XCTAssertEqual(cgImage!.bitsPerPixel, 32)
        }
    }
#endif

#if canImport(UIKit)
    func testUIImage(_ file: TestFile) throws {
        print("----- Testing \(file) (UIImage) -----")
        let contents = try Data(contentsOf: file.url)

        switch file.format {
        case .P1, .P4:
            let image = try PPMImage<PPMPixelBW>(data: contents)
            let uiImage = image.uiImage
            XCTAssertNotNil(uiImage)
            XCTAssertEqual(Int(image.width), uiImage!.cgImage!.width)
            XCTAssertEqual(Int(image.height), uiImage!.cgImage!.height)

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            let uiImage = image.uiImage
            XCTAssertNotNil(uiImage)
            XCTAssertEqual(Int(image.width), uiImage!.cgImage!.width)
            XCTAssertEqual(Int(image.height), uiImage!.cgImage!.height)

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            let uiImage = image.uiImage
            XCTAssertNotNil(uiImage)
            XCTAssertEqual(Int(image.width), uiImage!.cgImage!.width)
            XCTAssertEqual(Int(image.height), uiImage!.cgImage!.height)
        }
    }
#endif

#if os(macOS)
    func testNSImage(_ file: TestFile) throws {
        print("----- Testing \(file) (NSImage) -----")
        let contents = try Data(contentsOf: file.url)

        switch file.format {
        case .P1, .P4:
            let image = try PPMImage<PPMPixelBW>(data: contents)
            let nsImage = image.nsImage
            XCTAssertNotNil(nsImage)
            XCTAssertEqual(CGFloat(image.width), nsImage!.size.width)
            XCTAssertEqual(CGFloat(image.height), nsImage!.size.height)

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            let nsImage = image.nsImage
            XCTAssertNotNil(nsImage)
            XCTAssertEqual(CGFloat(image.width), nsImage!.size.width)
            XCTAssertEqual(CGFloat(image.height), nsImage!.size.height)

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            let nsImage = image.nsImage
            XCTAssertNotNil(nsImage)
            XCTAssertEqual(CGFloat(image.width), nsImage!.size.width)
            XCTAssertEqual(CGFloat(image.height), nsImage!.size.height)
        }
    }
#endif
}
