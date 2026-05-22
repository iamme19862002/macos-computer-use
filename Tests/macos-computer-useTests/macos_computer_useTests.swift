import CoreGraphics
import Foundation
import Testing
@testable import macos_computer_use

// MARK: - KeyMap Tests

struct KeyMapTests {

    @Test func testModifierKeyMappings() {
        let modifiers: [(String, CGKeyCode)] = [
            ("command", 0x37), ("cmd", 0x37),
            ("shift", 0x38), ("shift_l", 0x38), ("l_shift", 0x38),
            ("option", 0x3A), ("alt", 0x3A),
            ("control", 0x3B), ("ctrl", 0x3B),
            ("right_shift", 0x3C), ("shift_r", 0x3C), ("r_shift", 0x3C),
            ("right_option", 0x3D), ("option_r", 0x3D), ("alt_r", 0x3D), ("r_alt", 0x3D),
            ("right_control", 0x3E), ("control_r", 0x3E), ("ctrl_r", 0x3E), ("r_control", 0x3E),
            ("fn", 0x3F),
        ]
        for (name, expected) in modifiers {
            #expect(KeyMap.cgKeyCode(for: name) == expected, "Key '\(name)' should map to \(expected)")
        }
    }

    @Test func testNavigationKeyMappings() {
        let navKeys: [(String, CGKeyCode)] = [
            ("return", 0x24), ("enter", 0x24),
            ("tab", 0x30),
            ("space", 0x31),
            ("backspace", 0x33), ("delete", 0x33),
            ("escape", 0x35), ("esc", 0x35),
            ("forward_delete", 0x75), ("forwarddelete", 0x75), ("del", 0x75),
            ("left", 0x7B), ("right", 0x7C), ("down", 0x7D), ("up", 0x7E),
            ("home", 0x73), ("end", 0x77),
            ("page_up", 0x74), ("pageup", 0x74), ("prior", 0x74),
            ("page_down", 0x79), ("pagedown", 0x79), ("next", 0x79),
            ("insert", 0x72), ("ins", 0x72),
        ]
        for (name, expected) in navKeys {
            #expect(KeyMap.cgKeyCode(for: name) == expected, "Key '\(name)' should map to \(expected)")
        }
    }

    @Test func testFunctionKeyMappings() {
        let fnKeys: [(String, CGKeyCode)] = [
            ("f1", 0x7A), ("f2", 0x78), ("f3", 0x63), ("f4", 0x76),
            ("f5", 0x60), ("f6", 0x61), ("f7", 0x62), ("f8", 0x64),
            ("f9", 0x65), ("f10", 0x6D), ("f11", 0x67), ("f12", 0x6F),
            ("f13", 0x69), ("f14", 0x6B), ("f15", 0x71),
        ]
        for (name, expected) in fnKeys {
            #expect(KeyMap.cgKeyCode(for: name) == expected, "Key '\(name)' should map to \(expected)")
        }
    }

    @Test func testLetterKeyMappings() {
        let letters: [(String, CGKeyCode)] = [
            ("a", 0x00), ("b", 0x0B), ("c", 0x08), ("d", 0x02),
            ("e", 0x0E), ("f", 0x03), ("g", 0x05), ("h", 0x04),
            ("i", 0x22), ("j", 0x26), ("k", 0x28), ("l", 0x25),
            ("m", 0x2E), ("n", 0x2D), ("o", 0x1F), ("p", 0x23),
            ("q", 0x0C), ("r", 0x0F), ("s", 0x01), ("t", 0x11),
            ("u", 0x20), ("v", 0x09), ("w", 0x0D), ("x", 0x07),
            ("y", 0x10), ("z", 0x06),
        ]
        for (name, expected) in letters {
            #expect(KeyMap.cgKeyCode(for: name) == expected, "Key '\(name)' should map to \(expected)")
        }
    }

    @Test func testNumberKeyMappings() {
        let numbers: [(String, CGKeyCode)] = [
            ("0", 0x1D), ("1", 0x12), ("2", 0x13), ("3", 0x14),
            ("4", 0x15), ("5", 0x17), ("6", 0x16), ("7", 0x1A),
            ("8", 0x1C), ("9", 0x19),
        ]
        for (name, expected) in numbers {
            #expect(KeyMap.cgKeyCode(for: name) == expected, "Key '\(name)' should map to \(expected)")
        }
    }

    @Test func testPunctuationKeyMappings() {
        let punctuations: [(String, CGKeyCode)] = [
            ("minus", 0x1B), ("equal", 0x18),
            ("bracketleft", 0x21), ("bracketright", 0x1E),
            ("backslash", 0x2A), ("semicolon", 0x29),
            ("quote", 0x27), ("grave", 0x32),
            ("comma", 0x2B), ("period", 0x2F), ("slash", 0x2C),
        ]
        for (name, expected) in punctuations {
            #expect(KeyMap.cgKeyCode(for: name) == expected, "Key '\(name)' should map to \(expected)")
        }
    }

    @Test func testCaseInsensitiveLookup() {
        #expect(KeyMap.cgKeyCode(for: "COMMAND") == 0x37 as CGKeyCode)
        #expect(KeyMap.cgKeyCode(for: "Command") == 0x37 as CGKeyCode)
        #expect(KeyMap.cgKeyCode(for: "RETURN") == 0x24 as CGKeyCode)
        #expect(KeyMap.cgKeyCode(for: "Return") == 0x24 as CGKeyCode)
        #expect(KeyMap.cgKeyCode(for: "A") == 0x00 as CGKeyCode)
        #expect(KeyMap.cgKeyCode(for: "F1") == 0x7A as CGKeyCode)
    }

    @Test func testUnknownKeyReturnsNil() {
        #expect(KeyMap.cgKeyCode(for: "unknown_key") == nil)
        #expect(KeyMap.cgKeyCode(for: "") == nil)
        #expect(KeyMap.cgKeyCode(for: "f20") == nil)
    }

    @Test func testKeyCodeForCharacter() {
        #expect(KeyMap.keyCodeForCharacter("a") == 0x00)
        #expect(KeyMap.keyCodeForCharacter("A") == 0x00)
        #expect(KeyMap.keyCodeForCharacter("1") == 0x12)
        #expect(KeyMap.keyCodeForCharacter("z") == 0x06)
        #expect(KeyMap.keyCodeForCharacter("!") == nil)
    }
}

// MARK: - KeyboardController Tests

struct KeyboardControllerTests {

    @Test func testParseSingleKey() {
        let keys = KeyboardController.parseKeys("a")
        #expect(keys.count == 1)
        #expect(keys[0] == 0x00)
    }

    @Test func testParseKeyCombination() {
        let keys = KeyboardController.parseKeys("command+c")
        #expect(keys.count == 2)
        #expect(keys[0] == 0x37)
        #expect(keys[1] == 0x08)
    }

    @Test func testParseMultipleModifiers() {
        let keys = KeyboardController.parseKeys("command+shift+4")
        #expect(keys.count == 3)
        #expect(keys[0] == 0x37)
        #expect(keys[1] == 0x38)
        #expect(keys[2] == 0x15) // Key "4" maps to 0x15, not 0x19 (which is "9")
    }

    @Test func testParseKeysWithSpaces() {
        let keys = KeyboardController.parseKeys("command + c")
        #expect(keys.count == 2)
        #expect(keys[0] == 0x37)
        #expect(keys[1] == 0x08)
    }

    @Test func testParseEmptyString() {
        let keys = KeyboardController.parseKeys("")
        #expect(keys.isEmpty)
    }

    @Test func testParseUnknownKey() {
        let keys = KeyboardController.parseKeys("unknown")
        #expect(keys.isEmpty)
    }

    @Test func testParseMixedValidInvalid() {
        let keys = KeyboardController.parseKeys("command+unknown+c")
        #expect(keys.count == 2)
        #expect(keys[0] == 0x37)
        #expect(keys[1] == 0x08)
    }
}

// MARK: - CommandResult Tests

struct CommandResultTests {

    @Test func testCommandResultInit() {
        let result = CommandResult(success: true)
        #expect(result.success == true)
        #expect(result.data == nil)
        #expect(result.error == nil)
        #expect(!result.timestamp.isEmpty)
    }

    @Test func testCommandResultWithData() {
        let data: [String: Any] = ["key": "value", "count": 42]
        let result = CommandResult(success: true, data: data)
        #expect(result.success == true)
        #expect(result.data != nil)
        #expect(result.data?["key"]?.value as? String == "value")
    }

    @Test func testCommandResultWithError() {
        let error = CommandError(code: .targetNotFound, message: "Element not found")
        let result = CommandResult(success: false, error: error)
        #expect(result.success == false)
        #expect(result.error != nil)
        #expect(result.error?.code == .targetNotFound)
        #expect(result.error?.message == "Element not found")
    }

    @Test func testCommandErrorDetails() {
        let error = CommandError(code: .timeout, message: "Operation timed out", details: "Waited 10s")
        #expect(error.code == .timeout)
        #expect(error.message == "Operation timed out")
        #expect(error.details == "Waited 10s")
    }

    @Test func testExitStatusRawValues() {
        #expect(ExitStatus.success.rawValue == 0)
        #expect(ExitStatus.invalidArguments.rawValue == 1)
        #expect(ExitStatus.targetNotFound.rawValue == 2)
        #expect(ExitStatus.permissionDenied.rawValue == 3)
        #expect(ExitStatus.timeout.rawValue == 4)
        #expect(ExitStatus.executionFailed.rawValue == 5)
        #expect(ExitStatus.assertionFailed.rawValue == 6)
        #expect(ExitStatus.internalError.rawValue == 99)
    }

    @Test func testExitStatusCodable() throws {
        let status = ExitStatus.permissionDenied
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ExitStatus.self, from: data)
        #expect(decoded == .permissionDenied)
    }
}

// MARK: - AnyCodable Tests

struct AnyCodableTests {

    @Test func testAnyCodableString() {
        let ac = AnyCodable("hello")
        #expect(ac.value as? String == "hello")
    }

    @Test func testAnyCodableInt() {
        let ac = AnyCodable(42)
        #expect(ac.value as? Int == 42)
    }

    @Test func testAnyCodableDouble() {
        let ac = AnyCodable(3.14)
        #expect(ac.value as? Double == 3.14)
    }

    @Test func testAnyCodableBool() {
        let ac = AnyCodable(true)
        #expect(ac.value as? Bool == true)
    }

    @Test func testAnyCodableArray() {
        let ac = AnyCodable([1, 2, 3])
        #expect(ac.value as? [Int] != nil)
    }

    @Test func testAnyCodableDictionary() {
        let ac = AnyCodable(["key": "value"])
        #expect(ac.value as? [String: String] != nil)
    }

    @Test func testAnyCodableEncodeDecodeString() throws {
        let original = AnyCodable("test")
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        #expect(decoded.value as? String == "test")
    }

    @Test func testAnyCodableEncodeDecodeInt() throws {
        let original = AnyCodable(123)
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        #expect(decoded.value as? Int == 123)
    }

    @Test func testAnyCodableEncodeDecodeBool() throws {
        let original = AnyCodable(false)
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        #expect(decoded.value as? Bool == false)
    }

    @Test func testAnyCodableEncodeDecodeDouble() throws {
        let original = AnyCodable(2.718)
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        #expect(decoded.value as? Double == 2.718)
    }

    @Test func testAnyCodableEncodeDecodeArray() throws {
        let original = AnyCodable(["a", "b", "c"])
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        let array = decoded.value as? [String]
        #expect(array != nil)
        #expect(array?.count == 3)
        #expect(array?[0] == "a")
    }

    @Test func testAnyCodableEncodeDecodeDictionary() throws {
        let original = AnyCodable(["name": "test", "count": 5])
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        let dict = decoded.value as? [String: Any]
        #expect(dict != nil)
    }

    @Test func testAnyCodableFallback() throws {
        struct CustomType: CustomStringConvertible {
            var description: String { "custom" }
        }
        let original = AnyCodable(CustomType())
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        #expect(decoded.value as? String == "custom")
    }
}

// MARK: - FileSystem Tests

struct FileSystemTests {

    @Test func testFileExists() {
        let path = "/tmp/test_file_\(Foundation.UUID().uuidString).txt"
        let content = "Hello, World!"

        // Write file
        let writeResult = fileManagerWrite(path: path, text: content)
        #expect(writeResult == true)

        // Check exists
        #expect(FileManager.default.fileExists(atPath: path) == true)

        // Read file
        let readData = FileManager.default.contents(atPath: path)
        #expect(readData != nil)
        let readString = String(data: readData!, encoding: .utf8)
        #expect(readString == content)

        // Cleanup
        try? FileManager.default.removeItem(atPath: path)
    }

    @Test func testDirectoryOperations() {
        let dirPath = "/tmp/test_dir_\(Foundation.UUID().uuidString)"

        // Create directory
        try? FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true)
        #expect(FileManager.default.fileExists(atPath: dirPath) == true)

        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir)
        #expect(isDir.boolValue == true)

        // List directory
        let contents = try? FileManager.default.contentsOfDirectory(atPath: dirPath)
        #expect(contents != nil)
        #expect(contents!.isEmpty)

        // Cleanup
        try? FileManager.default.removeItem(atPath: dirPath)
    }

    @Test func testFileWriteAppend() {
        let path = "/tmp/test_append_\(Foundation.UUID().uuidString).txt"
        let line1 = "Line 1\n"
        let line2 = "Line 2\n"

        // Write first line
        _ = fileManagerWrite(path: path, text: line1)

        // Append second line
        _ = fileManagerWrite(path: path, text: line2, append: true)

        let data = FileManager.default.contents(atPath: path)
        let content = String(data: data!, encoding: .utf8)
        #expect(content == line1 + line2)

        // Cleanup
        try? FileManager.default.removeItem(atPath: path)
    }

    @Test func testNonExistentFile() {
        let path = "/tmp/non_existent_file_\(Foundation.UUID().uuidString).txt"
        #expect(FileManager.default.fileExists(atPath: path) == false)
    }
}

// Helper for file write in tests
func fileManagerWrite(path: String, text: String, append: Bool = false) -> Bool {
    let url = URL(fileURLWithPath: path)
    let data = text.data(using: .utf8)!
    if append, FileManager.default.fileExists(atPath: path) {
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            _ = try? fileHandle.seekToEnd()
            try? fileHandle.write(contentsOf: data)
            try? fileHandle.close()
            return true
        }
        return false
    }
    try? data.write(to: url)
    return FileManager.default.fileExists(atPath: path)
}

// MARK: - TestCommand Tests

struct TestCommandTests {

    @Test func testTestStartCommandConfiguration() {
        let config = TestStartCommand.configuration
        #expect(config.commandName == "test-start")
        #expect(config.abstract.contains("测试") || config.abstract.contains("test"))
    }

    @Test func testTestEndCommandConfiguration() {
        let config = TestEndCommand.configuration
        #expect(config.commandName == "test-end")
    }

    @Test func testStepCommandConfiguration() {
        let config = StepCommand.configuration
        #expect(config.commandName == "step")
    }
}

// MARK: - ExitStatus Tests

struct ExitStatusTests {

    @Test func testAllExitStatuses() {
        let allCases: [macos_computer_use.ExitStatus] = [
            .success, .invalidArguments, .targetNotFound,
            .permissionDenied, .timeout, .executionFailed,
            .assertionFailed, .internalError
        ]
        #expect(allCases.count == 8)

        for status in allCases {
            #expect(status.rawValue >= 0)
        }
    }

    @Test func testExitStatusUniqueness() {
        let values = [
            ExitStatus.success.rawValue,
            ExitStatus.invalidArguments.rawValue,
            ExitStatus.targetNotFound.rawValue,
            ExitStatus.permissionDenied.rawValue,
            ExitStatus.timeout.rawValue,
            ExitStatus.executionFailed.rawValue,
            ExitStatus.assertionFailed.rawValue,
            ExitStatus.internalError.rawValue,
        ]
        let uniqueValues = Set(values)
        #expect(uniqueValues.count == values.count)
    }

    @Test func testExitStatusSuccessIsZero() {
        #expect(ExitStatus.success.rawValue == 0)
    }
}

// MARK: - JSONUtils Tests

struct JSONUtilsTests {

    @Test func testPrintJSONWithValidDict() {
        let dict: [String: Any] = ["success": true, "message": "ok"]
        // Should not crash
        printJSON(dict)
    }

    @Test func testPrintJSONWithNestedDict() {
        let dict: [String: Any] = [
            "success": true,
            "data": [
                "name": "test",
                "count": 42
            ]
        ]
        printJSON(dict)
    }

    @Test func testPrintJSONWithArray() {
        let dict: [String: Any] = [
            "items": ["a", "b", "c"]
        ]
        printJSON(dict)
    }

    @Test func testPrintJSONWithNumbers() {
        let dict: [String: Any] = [
            "int": 42,
            "double": 3.14,
            "bool": true
        ]
        printJSON(dict)
    }
}

// MARK: - Sleep Tests

struct SleepTests {

    @Test func testWaitManagerSleep() {
        let start = Foundation.Date()
        WaitManager.sleep(milliseconds: 100)
        let elapsed = Foundation.Date().timeIntervalSince(start)
        #expect(elapsed >= 0.08) // Allow small tolerance
        #expect(elapsed < 0.3)
    }

    @Test func testWaitManagerSleepShort() {
        let start = Foundation.Date()
        WaitManager.sleep(milliseconds: 50)
        let elapsed = Foundation.Date().timeIntervalSince(start)
        #expect(elapsed >= 0.03)
        #expect(elapsed < 0.2)
    }
}

// MARK: - Integration Tests

struct IntegrationTests {

    @Test func testMouseControllerCurrentPosition() {
        let pos = MouseController.currentPosition()
        #expect(pos.x >= 0)
        #expect(pos.y >= 0)
    }

    @Test func testMouseControllerMoveTo() {
        let originalPos = MouseController.currentPosition()
        MouseController.moveTo(x: 100, y: 100)
        let newPos = MouseController.currentPosition()
        // Mouse may be constrained by screen bounds or accessibility
        #expect(newPos.x >= 0)
        #expect(newPos.y >= 0)
        // Restore position
        MouseController.moveTo(x: Int(originalPos.x), y: Int(originalPos.y))
    }

    @Test func testScrollDirectionCases() {
        let directions: [ScrollDirection] = [.up, .down, .left, .right]
        for dir in directions {
            #expect(dir.rawValue.isEmpty == false)
        }
    }

    @Test func testUIElementInfoCodable() throws {
        let info = UIElementInfo(
            role: "button",
            title: "OK",
            value: nil,
            bounds: WindowBounds(x: 10, y: 20, width: 100, height: 30),
            identifier: "ok-button",
            description: nil,
            isEnabled: true,
            isFocused: false,
            children: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(info)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(UIElementInfo.self, from: data)

        #expect(decoded.role == "button")
        #expect(decoded.title == "OK")
        #expect(decoded.identifier == "ok-button")
        #expect(decoded.isEnabled == true)
        #expect(decoded.isFocused == false)
        #expect(decoded.bounds.x == 10)
        #expect(decoded.bounds.y == 20)
        #expect(decoded.bounds.width == 100)
        #expect(decoded.bounds.height == 30)
    }

    @Test func testWindowBoundsCodable() throws {
        let bounds = WindowBounds(x: 0, y: 0, width: 1920, height: 1080)
        let encoder = JSONEncoder()
        let data = try encoder.encode(bounds)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(WindowBounds.self, from: data)
        #expect(decoded.width == 1920)
        #expect(decoded.height == 1080)
    }

    @Test func testAppManagerFindRunningApps() {
        let apps = AppManager.findRunningApps(named: "Finder")
        #expect(!apps.isEmpty)
    }

    @Test func testSystemInfoManager() {
        let info = SystemInfoManager.getSystemInfo()
        #expect(info.osVersion.isEmpty == false)
        #expect(info.hostname.isEmpty == false)
    }

    @Test func testScreenInfo() {
        let info = SystemInfoManager.getScreenInfo()
        #expect(info.width > 0)
        #expect(info.height > 0)
    }

    @Test func testDisplayList() {
        let displays = SystemInfoManager.getDisplayList()
        #expect(!displays.isEmpty)
        #expect(displays[0].id >= 0)
    }

    @Test func testClipboardManager() {
        let testString = "test_\(Foundation.UUID().uuidString)"
        _ = ClipboardManager.copyText(testString)
        let result = ClipboardManager.getText()
        #expect(result == testString)
    }

    @Test func testProcessManagerList() {
        let processes = ProcessManager.listProcesses()
        #expect(!processes.isEmpty)
        // Finder may appear as full path, use contains check
        #expect(processes.contains { $0.name.contains("Finder") })
    }

    @Test func testKeyboardControllerTypeText() {
        // Test that typeText doesn't crash for simple input
        KeyboardController.typeText("hello")
        KeyboardController.typeText("123")
        KeyboardController.typeText("Hello World")
    }

    @Test func testCommandResultJSONOutput() {
        let result = CommandResult(success: true, data: ["key": "value"])
        result.printJSON(pretty: true)
        result.printJSON(pretty: false)
    }
}
