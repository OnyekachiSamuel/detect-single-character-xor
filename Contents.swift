import Foundation

func buildText(from text: String) -> [Unicode.Scalar: Float64] {
    var result: [Unicode.Scalar: Float64] = [:]

    for char in Array(text.unicodeScalars) {

        if let value = result[char] {
            result[char] = value + 1

        } else {
            result[char] = 1
        }
    }

    for char in result {
        result[char.key] = char.value / Float64(text.count)
    }

    return result
}

func readText(from fileName: String) -> [Unicode.Scalar: Float64] {

    guard  let fileURL = Bundle.main.url(forResource: fileName,
                                         withExtension: "txt")
        else { return [:] }

    let content = try? String(contentsOf: fileURL,
                              encoding: .utf8)
    var result: [Unicode.Scalar: Float64] = [:]

    if let content = content {
        result = buildText(from: content)
    }

    return result
}

func decodeHex(from hexString: String) -> [UInt8] {

    var index = hexString.startIndex
    var result : [UInt8] = []

    for _ in  0..<hexString.count / 2 {

        let nextIndex = hexString.index(index, offsetBy: 2)

        if let hexDecodedValue = UInt8(hexString[index..<nextIndex], radix: 16) {

            result.append(hexDecodedValue)
        }

        index = nextIndex
    }

    return result
}

func scoreEnglishLetter(text: String,
                        characterFrequency: [Unicode.Scalar: Float64]) -> Float64 {

    var score: Float64 = 0
    for char in text.unicodeScalars {
        if let frequency = characterFrequency[char] {
            score += frequency
        }
    }

    return score / Float64(text.count)
}

func singleXOR(from hexDecodedValue: [UInt8],
               key: UInt8) -> [UInt8] {
    var result = [UInt8](repeating: 0, count: hexDecodedValue.count)

    for (index, value) in hexDecodedValue.enumerated() {
        result[index] = value ^ key
    }

    return result
}

func findSingleXORkey(from hexDecodedValue: [UInt8],
                      characterFrequency: [Unicode.Scalar: Float64]) -> (result: [UInt8], score: Float64) {

    var lastScore: Float64 = 0

    var result: [UInt8] = []

    for key in 0..<256 {
        let output = singleXOR(from: hexDecodedValue, key: UInt8(key))
        if let string =  String(bytes: output, encoding: .utf8) {
            let score = scoreEnglishLetter(text:  string,
                                           characterFrequency: characterFrequency)
            if score > lastScore {
                result = output
                lastScore = score
            }
        }
    }

    return (result, lastScore)
}

func readHexStrings(from file: String) -> [String] {

    guard  let fileURL = Bundle.main.url(forResource: file,
                                         withExtension: "txt"),
        let content = try? String(contentsOf: fileURL,
                                  encoding: .utf8)
        else { return [] }

    let hexStrings = content.components(separatedBy: .newlines)

    return hexStrings
}

func runTest() {

    var lastScore: Float64 = 0
    let letterFrequency = readText(from: "aliceInWonderland")
    var result: [UInt8] = []

    let hexStrings = readHexStrings(from: "4")

    for hexString in hexStrings {
        let output = findSingleXORkey(from: decodeHex(from: hexString),
                                      characterFrequency: letterFrequency)

        if output.score > lastScore {
            result = output.result
            lastScore = output.score
        }
    }

    if let text = String(bytes: result, encoding: .utf8) {
        print(text)
    }
}

runTest()











