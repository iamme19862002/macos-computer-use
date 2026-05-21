#!/usr/bin/env python3
"""macOS Computer Use - Universal macOS UI Automation CLI"""

import argparse
import subprocess
import json
import os
import sys
import time
from pathlib import Path

SCREENSHOT_DIR = Path.home() / ".macos_computer_use" / "screenshots"

def run_applescript(script):
    """Execute AppleScript and return result"""
    result = subprocess.run(
        ["osascript", "-e", script],
        capture_output=True,
        text=True
    )
    return result.stdout.strip(), result.stderr.strip()

def screenshot(args):
    """Capture screenshot and return file:// URL"""
    SCREENSHOT_DIR.mkdir(parents=True, exist_ok=True)
    
    timestamp = time.time()
    filename = f"screenshot_{timestamp}.png"
    filepath = SCREENSHOT_DIR / filename
    
    # Use screencapture command
    result = subprocess.run([
        "/usr/sbin/screencapture",
        "-x",  # Disable sounds
        "-C",  # Include cursor
        str(filepath)
    ])
    
    if result.returncode == 0:
        filesize = filepath.stat().st_size
        
        # Get cursor position
        pos_script = """
            tell application "System Events"
                set pos to position of mouse
                return (item 1 of pos) & "," & (item 2 of pos)
            end tell
        """
        pos_output, _ = run_applescript(pos_script)
        if pos_output:
            x, y = pos_output.split(",")
            cursor_pos = {"x": int(float(x)), "y": int(float(y))}
        else:
            cursor_pos = {"x": 0, "y": 0}
        
        url = f"file://{filepath}"
        
        result = {
            "success": True,
            "url": url,
            "filepath": str(filepath),
            "filename": filename,
            "size_bytes": filesize,
            "image_width": 0,
            "image_height": 0,
            "cursor_position": cursor_pos
        }
    else:
        result = {
            "success": False,
            "error": "Failed to capture screenshot"
        }
    
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        if result["success"]:
            print(f"✓ Screenshot saved")
            print(f"  URL: {result['url']}")
            print(f"  Size: {result['size_bytes']} bytes")
            print(f"  Cursor: ({result['cursor_position']['x']}, {result['cursor_position']['y']})")
        else:
            print(f"✗ Failed: {result.get('error', 'Unknown error')}")

def cursor_position(args):
    """Get current mouse position"""
    script = """
        tell application "System Events"
            set pos to position of mouse
            return (item 1 of pos) & "," & (item 2 of pos)
        end tell
    """
    output, _ = run_applescript(script)
    
    if output:
        x, y = output.split(",")
        result = {"x": int(float(x)), "y": int(float(y))}
    else:
        result = {"x": 0, "y": 0}
    
    if args.json:
        print(json.dumps(result))
    else:
        print(f"Cursor position: ({result['x']}, {result['y']})")

def mouse_move(args):
    """Move mouse to position"""
    x, y = args.x, args.y
    
    script = f"""
        tell application "System Events"
            set position of mouse to {{{x}, {y}}}
        end tell
    """
    run_applescript(script)
    
    if args.json:
        print(json.dumps({
            "success": True,
            "action": "mouse_move",
            "coordinate": [x, y]
        }))
    else:
        print(f"✓ Mouse moved to ({x}, {y})")

def left_click(args):
    """Left click at position"""
    x, y = args.x, args.y
    
    if x is not None and y is not None:
        # Move to position first
        move_script = f"""
            tell application "System Events"
                set position of mouse to {{{x}, {y}}}
            end tell
        """
        run_applescript(move_script)
        time.sleep(0.1)
    
    script = """
        tell application "System Events"
            click at (position of mouse)
        end tell
    """
    run_applescript(script)
    
    if args.x is not None and args.y is not None:
        pos = (args.x, args.y)
    else:
        pos_script = """
            tell application "System Events"
                set pos to position of mouse
                return (item 1 of pos) & "," & (item 2 of pos)
            end tell
        """
        output, _ = run_applescript(pos_script)
        if output:
            x_pos, y_pos = output.split(",")
            pos = (int(float(x_pos)), int(float(y_pos)))
        else:
            pos = (0, 0)
    
    if args.json:
        print(json.dumps({
            "success": True,
            "action": "left_click",
            "coordinate": list(pos)
        }))
    else:
        print(f"✓ Left click at ({pos[0]}, {pos[1]})")

def right_click(args):
    """Right click at position"""
    x, y = args.x, args.y
    
    if x is not None and y is not None:
        move_script = f"""
            tell application "System Events"
                set position of mouse to {{{x}, {y}}}
            end tell
        """
        run_applescript(move_script)
        time.sleep(0.1)
    
    script = """
        tell application "System Events"
            click at (position of mouse) using {control down}
        end tell
    """
    run_applescript(script)
    
    if args.x is not None and args.y is not None:
        pos = (args.x, args.y)
    else:
        pos_script = """
            tell application "System Events"
                set pos to position of mouse
                return (item 1 of pos) & "," & (item 2 of pos)
            end tell
        """
        output, _ = run_applescript(pos_script)
        if output:
            x_pos, y_pos = output.split(",")
            pos = (int(float(x_pos)), int(float(y_pos)))
        else:
            pos = (0, 0)
    
    if args.json:
        print(json.dumps({
            "success": True,
            "action": "right_click",
            "coordinate": list(pos)
        }))
    else:
        print(f"✓ Right click at ({pos[0]}, {pos[1]})")

def middle_click(args):
    """Middle click at position"""
    x, y = args.x, args.y
    
    if x is not None and y is not None:
        move_script = f"""
            tell application "System Events"
                set position of mouse to {{{x}, {y}}}
            end tell
        """
        run_applescript(move_script)
        time.sleep(0.1)
    
    script = """
        tell application "System Events"
            click at (position of mouse) using {option down}
        end tell
    """
    run_applescript(script)
    
    if args.x is not None and args.y is not None:
        pos = (args.x, args.y)
    else:
        pos_script = """
            tell application "System Events"
                set pos to position of mouse
                return (item 1 of pos) & "," & (item 2 of pos)
            end tell
        """
        output, _ = run_applescript(pos_script)
        if output:
            x_pos, y_pos = output.split(",")
            pos = (int(float(x_pos)), int(float(y_pos)))
        else:
            pos = (0, 0)
    
    if args.json:
        print(json.dumps({
            "success": True,
            "action": "middle_click",
            "coordinate": list(pos)
        }))
    else:
        print(f"✓ Middle click at ({pos[0]}, {pos[1]})")

def double_click(args):
    """Double click at position"""
    x, y = args.x, args.y
    
    if x is not None and y is not None:
        move_script = f"""
            tell application "System Events"
                set position of mouse to {{{x}, {y}}}
            end tell
        """
        run_applescript(move_script)
        time.sleep(0.1)
    
    script = """
        tell application "System Events"
            double click at (position of mouse)
        end tell
    """
    run_applescript(script)
    
    if args.x is not None and args.y is not None:
        pos = (args.x, args.y)
    else:
        pos_script = """
            tell application "System Events"
                set pos to position of mouse
                return (item 1 of pos) & "," & (item 2 of pos)
            end tell
        """
        output, _ = run_applescript(pos_script)
        if output:
            x_pos, y_pos = output.split(",")
            pos = (int(float(x_pos)), int(float(y_pos)))
        else:
            pos = (0, 0)
    
    if args.json:
        print(json.dumps({
            "success": True,
            "action": "double_click",
            "coordinate": list(pos)
        }))
    else:
        print(f"✓ Double click at ({pos[0]}, {pos[1]})")

def drag(args):
    """Drag from current position to target"""
    to_x, to_y = args.to_x, args.to_y
    
    script = f"""
        tell application "System Events"
            set startPos to position of mouse
            mouse down at startPos
            delay 0.1
            set position of mouse to {{{to_x}, {to_y}}}
            delay 0.1
            mouse up at {{{to_x}, {to_y}}}
        end tell
    """
    run_applescript(script)
    
    if args.json:
        print(json.dumps({
            "success": True,
            "action": "drag",
            "to_coordinate": [to_x, to_y]
        }))
    else:
        print(f"✓ Dragged to ({to_x}, {to_y})")

def scroll(args):
    """Scroll at position"""
    x, y = args.x, args.y
    direction = args.direction.lower()
    amount = args.amount
    
    # Map direction to AppleScript delta
    delta_map = {
        "up": "-1",
        "down": "1",
        "left": "-1",
        "right": "1"
    }
    
    delta = delta_map.get(direction, "1")
    
    if direction in ["up", "down"]:
        script = f"""
            tell application "System Events"
                set position of mouse to {{{x}, {y}}}
                delay 0.1
                scroll wheel by {{{delta}}}
            end tell
        """
    else:
        script = f"""
            tell application "System Events"
                set position of mouse to {{{x}, {y}}}
                delay 0.1
                scroll wheel by {{0, {delta}}}
            end tell
        """
    
    run_applescript(script)
    
    if args.json:
        print(json.dumps({
            "success": True,
            "action": "scroll",
            "coordinate": [x, y],
            "direction": direction,
            "amount": amount
        }))
    else:
        print(f"✓ Scrolled {direction} at ({x}, {y})")

def key(args):
    """Press key or key combination"""
    keys = args.keys
    
    # Parse key combination
    key_parts = keys.split("+")
    modifiers = []
    final_key = ""
    
    key_map = {
        "command": "command down",
        "cmd": "command down",
        "shift": "shift down",
        "option": "option down",
        "alt": "option down",
        "control": "control down",
        "ctrl": "control down",
        "return": "return",
        "enter": "return",
        "tab": "tab",
        "space": "space",
        "backspace": "delete",
        "delete": "delete",
        "escape": "escape",
        "esc": "escape",
        "left": "left arrow",
        "right": "right arrow",
        "up": "up arrow",
        "down": "down arrow",
        "pageup": "page up",
        "pagedown": "page down",
        "home": "home",
        "end": "end"
    }
    
    for part in key_parts:
        part = part.strip().lower()
        if part in key_map:
            if "down" in key_map[part]:
                modifiers.append(key_map[part])
            else:
                final_key = key_map[part]
        else:
            final_key = part
    
    if modifiers:
        modifier_str = ", ".join(modifiers)
        script = f"""
            tell application "System Events"
                keystroke "{final_key}" using {{{modifier_str}}}
            end tell
        """
    else:
        script = f"""
            tell application "System Events"
                keystroke "{final_key}"
            end tell
        """
    
    run_applescript(script)
    
    if args.json:
        print(json.dumps({
            "success": True,
            "action": "key",
            "keys": keys
        }))
    else:
        print(f"✓ Key pressed: {keys}")

def type_text(args):
    """Type text"""
    text = args.text
    
    # Escape quotes in text
    escaped_text = text.replace('"', '\\"')
    
    script = f'''
        tell application "System Events"
            keystroke "{escaped_text}"
        end tell
    '''
    run_applescript(script)
    
    if args.json:
        print(json.dumps({
            "success": True,
            "action": "type",
            "text": text
        }))
    else:
        print(f"✓ Typed: {text}")

def main():
    parser = argparse.ArgumentParser(
        prog="macos-computer-use",
        description="macOS Universal Computer Control CLI"
    )
    
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # Screenshot
    screenshot_parser = subparsers.add_parser("screenshot", help="Capture screenshot")
    screenshot_parser.add_argument("--json", action="store_true", help="JSON output")
    screenshot_parser.set_defaults(func=screenshot)
    
    # Cursor Position
    cursor_parser = subparsers.add_parser("cursor-position", help="Get cursor position")
    cursor_parser.add_argument("--json", action="store_true", help="JSON output")
    cursor_parser.set_defaults(func=cursor_position)
    
    # Mouse Move
    mouse_move_parser = subparsers.add_parser("mouse-move", help="Move mouse")
    mouse_move_parser.add_argument("-x", type=int, required=True, help="X coordinate")
    mouse_move_parser.add_argument("-y", type=int, required=True, help="Y coordinate")
    mouse_move_parser.add_argument("--json", action="store_true", help="JSON output")
    mouse_move_parser.set_defaults(func=mouse_move)
    
    # Left Click
    left_click_parser = subparsers.add_parser("left-click", help="Left click")
    left_click_parser.add_argument("-x", type=int, help="X coordinate")
    left_click_parser.add_argument("-y", type=int, help="Y coordinate")
    left_click_parser.add_argument("--json", action="store_true", help="JSON output")
    left_click_parser.set_defaults(func=left_click)
    
    # Right Click
    right_click_parser = subparsers.add_parser("right-click", help="Right click")
    right_click_parser.add_argument("-x", type=int, help="X coordinate")
    right_click_parser.add_argument("-y", type=int, help="Y coordinate")
    right_click_parser.add_argument("--json", action="store_true", help="JSON output")
    right_click_parser.set_defaults(func=right_click)
    
    # Middle Click
    middle_click_parser = subparsers.add_parser("middle-click", help="Middle click")
    middle_click_parser.add_argument("-x", type=int, help="X coordinate")
    middle_click_parser.add_argument("-y", type=int, help="Y coordinate")
    middle_click_parser.add_argument("--json", action="store_true", help="JSON output")
    middle_click_parser.set_defaults(func=middle_click)
    
    # Double Click
    double_click_parser = subparsers.add_parser("double-click", help="Double click")
    double_click_parser.add_argument("-x", type=int, help="X coordinate")
    double_click_parser.add_argument("-y", type=int, help="Y coordinate")
    double_click_parser.add_argument("--json", action="store_true", help="JSON output")
    double_click_parser.set_defaults(func=double_click)
    
    # Drag
    drag_parser = subparsers.add_parser("drag", help="Drag from current position")
    drag_parser.add_argument("--to-x", type=int, required=True, help="Target X")
    drag_parser.add_argument("--to-y", type=int, required=True, help="Target Y")
    drag_parser.add_argument("--json", action="store_true", help="JSON output")
    drag_parser.set_defaults(func=drag)
    
    # Scroll
    scroll_parser = subparsers.add_parser("scroll", help="Scroll")
    scroll_parser.add_argument("-x", type=int, required=True, help="X coordinate")
    scroll_parser.add_argument("-y", type=int, required=True, help="Y coordinate")
    scroll_parser.add_argument("-d", "--direction", required=True, help="Direction: up/down/left/right")
    scroll_parser.add_argument("-a", "--amount", type=int, default=100, help="Scroll amount")
    scroll_parser.add_argument("--json", action="store_true", help="JSON output")
    scroll_parser.set_defaults(func=scroll)
    
    # Key
    key_parser = subparsers.add_parser("key", help="Press key combination")
    key_parser.add_argument("-k", "--keys", required=True, help="Keys (e.g., command+c)")
    key_parser.add_argument("--json", action="store_true", help="JSON output")
    key_parser.set_defaults(func=key)
    
    # Type
    type_parser = subparsers.add_parser("type", help="Type text")
    type_parser.add_argument("-t", "--text", required=True, help="Text to type")
    type_parser.add_argument("--json", action="store_true", help="JSON output")
    type_parser.set_defaults(func=type_text)
    
    args = parser.parse_args()
    args.func(args)

if __name__ == "__main__":
    main()