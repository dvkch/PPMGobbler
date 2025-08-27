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
            let inMemory = PPMImage<PPMPixelBW>(image: TestFile.inMemory)
            compareImages(image, inMemory)

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            let inMemory = PPMImage<PPMPixelGrey>(image: TestFile.inMemory)
            compareImages(image, inMemory)

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            let inMemory = PPMImage<PPMPixelRGB>(image: TestFile.inMemory)
            compareImages(image, inMemory)
        }
        
        print("> Idempotency")
        switch file.format {
        case .P1, .P4:
            let image = try PPMImage<PPMPixelBW>(data: contents)
            let encodedData = try image.data(format: file.format, levels: file.levels)
            XCTAssertEqual(contents, encodedData)

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            let encodedData = try image.data(format: file.format, levels: file.levels)
            XCTAssertEqual(contents, encodedData)

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            let encodedData = try image.data(format: file.format, levels: file.levels)
            XCTAssertEqual(contents, encodedData)
        }
        
        guard file.variants.isEmpty == false else { return }
        print("> Variants")
        for variant in file.variants {
            let variantData = try Data(contentsOf: file.variantURL(for: variant))
            
            let variantRGB = try PPMImage<PPMPixelRGB>(data: variantData)
            let originalRGB = try PPMImage<PPMPixelRGB>(data: contents)
            compareImages(variantRGB, originalRGB)
            
            let variantGrey = try PPMImage<PPMPixelGrey>(data: variantData)
            let originalGrey = try PPMImage<PPMPixelGrey>(data: contents)
            compareImages(variantGrey, originalGrey)
            
            let variantBW = try PPMImage<PPMPixelBW>(data: variantData)
            let originalBW = try PPMImage<PPMPixelBW>(data: contents)
            compareImages(variantBW, originalBW)
        }
    }
    
#if canImport(CoreGraphics)
    func testCGImage(_ file: TestFile) throws {
        print("----- Testing \(file) (CGImage) -----")
        let contents = try Data(contentsOf: file.url)

        switch file.format {
        case .P1, .P4:
            let image = try PPMImage<PPMPixelBW>(data: contents)
            let cgImage = try image.cgImage()
            XCTAssertEqual(cgImage.width, Int(image.width))
            XCTAssertEqual(cgImage.height, Int(image.height))
            XCTAssertEqual(cgImage.colorSpace?.name as String?, "kCGColorSpaceDeviceGray")
            XCTAssertEqual(cgImage.bitsPerComponent, 8)
            XCTAssertEqual(cgImage.bitsPerPixel, 8)

            let fromCGImage = try PPMImage<PPMPixelBW>(cgImage: cgImage)
            compareImages(image, fromCGImage)

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            let cgImage = try image.cgImage()
            XCTAssertEqual(cgImage.width, Int(image.width))
            XCTAssertEqual(cgImage.height, Int(image.height))
            XCTAssertEqual(cgImage.colorSpace?.name as String?, "kCGColorSpaceDeviceGray")
            XCTAssertEqual(cgImage.bitsPerComponent, 8)
            XCTAssertEqual(cgImage.bitsPerPixel, 8)

            let fromCGImage = try PPMImage<PPMPixelGrey>(cgImage: cgImage)
            compareImages(image, fromCGImage)

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            let cgImage = try image.cgImage()
            XCTAssertEqual(cgImage.width, Int(image.width))
            XCTAssertEqual(cgImage.height, Int(image.height))
            XCTAssertEqual(cgImage.colorSpace?.name as String?, "kCGColorSpaceDeviceRGB")
            XCTAssertEqual(cgImage.bitsPerComponent, 8)
            XCTAssertEqual(cgImage.bitsPerPixel, 32)

            let fromCGImage = try PPMImage<PPMPixelRGB>(cgImage: cgImage)
            compareImages(image, fromCGImage)
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
            let uiImage = try image.uiImage()
            XCTAssertEqual(Int(image.width), uiImage.cgImage!.width)
            XCTAssertEqual(Int(image.height), uiImage.cgImage!.height)
            
            let fromUIImage = try PPMImage<PPMPixelBW>(uiImage: uiImage)
            compareImages(image, fromUIImage)

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            let uiImage = try image.uiImage()
            XCTAssertNotNil(uiImage)
            XCTAssertEqual(Int(image.width), uiImage.cgImage!.width)
            XCTAssertEqual(Int(image.height), uiImage.cgImage!.height)

            let fromUIImage = try PPMImage<PPMPixelGrey>(uiImage: uiImage)
            compareImages(image, fromUIImage)

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            let uiImage = try image.uiImage()
            XCTAssertNotNil(uiImage)
            XCTAssertEqual(Int(image.width), uiImage.cgImage!.width)
            XCTAssertEqual(Int(image.height), uiImage.cgImage!.height)

            let fromUIImage = try PPMImage<PPMPixelRGB>(uiImage: uiImage)
            compareImages(image, fromUIImage)
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
            let nsImage = try image.nsImage()
            XCTAssertEqual(CGFloat(image.width), nsImage.size.width)
            XCTAssertEqual(CGFloat(image.height), nsImage.size.height)
            
            let fromNSImage = try PPMImage<PPMPixelBW>(nsImage: nsImage)
            compareImages(image, fromNSImage)

        case .P2, .P5:
            let image = try PPMImage<PPMPixelGrey>(data: contents)
            let nsImage = try image.nsImage()
            XCTAssertEqual(CGFloat(image.width), nsImage.size.width)
            XCTAssertEqual(CGFloat(image.height), nsImage.size.height)
            
            let fromNSImage = try PPMImage<PPMPixelGrey>(nsImage: nsImage)
            compareImages(image, fromNSImage)

        case .P3, .P6:
            let image = try PPMImage<PPMPixelRGB>(data: contents)
            let nsImage = try image.nsImage()
            XCTAssertEqual(CGFloat(image.width), nsImage.size.width)
            XCTAssertEqual(CGFloat(image.height), nsImage.size.height)
            
            let fromNSImage = try PPMImage<PPMPixelRGB>(nsImage: nsImage)
            compareImages(image, fromNSImage)
        }
    }
#endif
    
    func compareImages<P: PPMPixel>(_ imageA: PPMImage<P>, _ imageB: PPMImage<P>) {
        XCTAssertEqual(imageA.width, imageB.width)
        XCTAssertEqual(imageA.height, imageB.height)

        for x in 0..<imageA.width {
            for y in 0..<imageA.height {
                XCTAssertEqual(imageA[x, y].r, imageB[x, y].r, accuracy: 1 / 255.0, "Pixel at (\(x), \(y)).r")
                XCTAssertEqual(imageA[x, y].g, imageB[x, y].g, accuracy: 1 / 255.0, "Pixel at (\(x), \(y)).g")
                XCTAssertEqual(imageA[x, y].b, imageB[x, y].b, accuracy: 1 / 255.0, "Pixel at (\(x), \(y)).b")
            }
        }
    }
}
