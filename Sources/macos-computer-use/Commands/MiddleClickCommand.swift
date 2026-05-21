import ArgumentParser
import CoreGraphics

struct MiddleClickCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "middle-click",
        abstract: "中键点击（可选坐标）"
    )

    @Option(name: .short, help: "X 坐标（可选）")
    var x: Int?

    @Option(name: .short, help: "Y 坐标（可选）")
    var y: Int?

    @Flag(name: .shortAndLong, help: "JSON 输出")
    var json = false

    func run() async throws {
        let point: CGPoint? = (x != nil && y != nil) ? CGPoint(x: x!, y: y!) : nil
        MouseController.middleClick(at: point)

        if json {
            if let px = x, let py = y {
                print("""
                {
                  "success": true,
                  "action": "middle_click",
                  "coordinate": [\(px), \(py)]
                }
                """)
            } else {
                print("""
                {
                  "success": true,
                  "action": "middle_click"
                }
                """)
            }
        } else {
            if let px = x, let py = y {
                print("✓ Middle clicked at (\(px), \(py))")
            } else {
                print("✓ Middle clicked at current position")
            }
        }
    }
}
