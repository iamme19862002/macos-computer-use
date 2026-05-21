import ArgumentParser
import CoreGraphics

struct LeftClickCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "left-click",
        abstract: "左键点击（可选坐标）"
    )

    @Option(name: .short, help: "X 坐标（可选）")
    var x: Int?

    @Option(name: .short, help: "Y 坐标（可选）")
    var y: Int?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let point: CGPoint? = (x != nil && y != nil) ? CGPoint(x: x!, y: y!) : nil
        MouseController.leftClick(at: point)

        if json {
            if let px = x, let py = y {
                print("""
                {
                  "success": true,
                  "action": "left_click",
                  "coordinate": [\(px), \(py)]
                }
                """)
            } else {
                print("""
                {
                  "success": true,
                  "action": "left_click"
                }
                """)
            }
        } else {
            if let px = x, let py = y {
                print("✓ Left clicked at (\(px), \(py))")
            } else {
                print("✓ Left clicked at current position")
            }
        }
    }
}
