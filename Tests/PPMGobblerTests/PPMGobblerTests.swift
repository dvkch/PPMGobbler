import XCTest
@testable import PPMGobbler

final class PPMGobblerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testAll() throws {
        for file in TestFile.allCases {
            try testFile(file)
        }

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
    }
}
