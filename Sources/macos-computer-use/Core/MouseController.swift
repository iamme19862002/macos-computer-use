import CoreGraphics

enum ScrollDirection: String {
    case up, down, left, right
}

struct MouseController {
    /// 移动鼠标到指定坐标
    static func moveTo(x: Int, y: Int) {
        let point = CGPoint(x: x, y: y)
        let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                           mouseCursorPosition: point, mouseButton: .left)
        event?.post(tap: .cghidEventTap)
    }

    /// 获取当前鼠标位置
    static func currentPosition() -> CGPoint {
        return CGEvent(source: nil)?.location ?? .zero
    }

    /// 左键点击
    static func leftClick(at point: CGPoint? = nil) {
        if let p = point {
            moveTo(x: Int(p.x), y: Int(p.y))
        }

        let current = CGEvent(source: nil)?.location ?? .zero
        let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                          mouseCursorPosition: current, mouseButton: .left)
        let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                        mouseCursorPosition: current, mouseButton: .left)

        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    /// 右键点击
    static func rightClick(at point: CGPoint? = nil) {
        if let p = point {
            moveTo(x: Int(p.x), y: Int(p.y))
        }

        let current = CGEvent(source: nil)?.location ?? .zero
        let down = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown,
                          mouseCursorPosition: current, mouseButton: .right)
        let up = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp,
                        mouseCursorPosition: current, mouseButton: .right)

        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    /// 中键点击
    static func middleClick(at point: CGPoint? = nil) {
        if let p = point {
            moveTo(x: Int(p.x), y: Int(p.y))
        }

        let current = CGEvent(source: nil)?.location ?? .zero
        let down = CGEvent(mouseEventSource: nil, mouseType: .otherMouseDown,
                          mouseCursorPosition: current, mouseButton: .center)
        let up = CGEvent(mouseEventSource: nil, mouseType: .otherMouseUp,
                        mouseCursorPosition: current, mouseButton: .center)

        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    /// 双击
    static func doubleClick(at point: CGPoint? = nil) {
        if let p = point {
            moveTo(x: Int(p.x), y: Int(p.y))
        }

        let current = CGEvent(source: nil)?.location ?? .zero

        // First click
        var down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                          mouseCursorPosition: current, mouseButton: .left)
        var up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                        mouseCursorPosition: current, mouseButton: .left)
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)

        // Small delay
        usleep(100_000) // 100ms

        // Second click
        down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                      mouseCursorPosition: current, mouseButton: .left)
        up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                    mouseCursorPosition: current, mouseButton: .left)
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    /// 拖拽
    static func drag(from: CGPoint, to: CGPoint) {
        // Move to start position
        moveTo(x: Int(from.x), y: Int(from.y))

        // Press left button
        let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                          mouseCursorPosition: from, mouseButton: .left)
        down?.post(tap: .cghidEventTap)

        // Small delay
        usleep(100_000)

        // Move to end position (drag)
        let move = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged,
                          mouseCursorPosition: to, mouseButton: .left)
        move?.post(tap: .cghidEventTap)

        // Small delay
        usleep(100_000)

        // Release left button
        let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                        mouseCursorPosition: to, mouseButton: .left)
        up?.post(tap: .cghidEventTap)
    }

    /// 滚动
    static func scroll(at point: CGPoint, direction: ScrollDirection, amount: Int) {
        // Move to position first
        moveTo(x: Int(point.x), y: Int(point.y))

        var scrollEvent: CGEvent?

        switch direction {
        case .up:
            scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1,
                                 wheel1: Int32(amount), wheel2: 0, wheel3: 0)
        case .down:
            scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1,
                                 wheel1: Int32(-amount), wheel2: 0, wheel3: 0)
        case .left:
            scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2,
                                 wheel1: 0, wheel2: Int32(amount), wheel3: 0)
        case .right:
            scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2,
                                 wheel1: 0, wheel2: Int32(-amount), wheel3: 0)
        }

        scrollEvent?.post(tap: .cghidEventTap)
    }
}
