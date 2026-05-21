#!/bin/bash

# macos-computer-use CLI 测试脚本
# 模拟 AI Agent 调用并验证输出

# 不要在测试失败时退出
# set -e

CLI="macos-computer-use"
PASSED=0
FAILED=0

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试辅助函数
print_header() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
}

print_success() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASSED++))
}

print_failure() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    echo "  Error: $2"
    ((FAILED++))
}

print_info() {
    echo -e "${YELLOW}ℹ INFO${NC}: $1"
}

# 验证 JSON 字段是否存在
validate_json_field() {
    local json="$1"
    local field="$2"
    local expected_type="$3"
    
    if echo "$json" | jq -e ".$field" > /dev/null 2>&1; then
        local value=$(echo "$json" | jq -r ".$field")
        
        case "$expected_type" in
            boolean)
                if [[ "$value" == "true" || "$value" == "false" ]]; then
                    return 0
                fi
                ;;
            string)
                if [[ -n "$value" ]]; then
                    return 0
                fi
                ;;
            number)
                if [[ "$value" =~ ^[0-9]+$ ]]; then
                    return 0
                fi
                ;;
            array)
                if echo "$json" | jq -e ".$field | type == \"array\"" > /dev/null 2>&1; then
                    return 0
                fi
                ;;
            object)
                if echo "$json" | jq -e ".$field | type == \"object\"" > /dev/null 2>&1; then
                    return 0
                fi
                ;;
            *)
                return 0
                ;;
        esac
    fi
    return 1
}

# 检查 CLI 是否安装
check_cli_installed() {
    print_header "环境检查"
    
    if ! command -v $CLI &> /dev/null; then
        print_failure "CLI 安装检查" "macos-computer-use 未安装或未在 PATH 中"
        echo "请先运行: ./install.sh"
        exit 1
    fi
    
    print_success "CLI 已安装"
    
    # 获取版本信息
    local version=$($CLI --version 2>&1 || echo "unknown")
    print_info "版本: $version"
}

# 测试 1: 帮助信息
test_help() {
    print_header "测试 1: 帮助信息"
    
    local output=$($CLI --help 2>&1)
    
    if echo "$output" | grep -q "macOS 通用计算机控制"; then
        print_success "主帮助信息包含标题"
    else
        print_failure "主帮助信息" "未找到标题"
    fi
    
    if echo "$output" | grep -q "screenshot"; then
        print_success "帮助信息包含 screenshot 子命令"
    else
        print_failure "帮助信息" "未找到 screenshot 子命令"
    fi
    
    if echo "$output" | grep -q "cursor-position"; then
        print_success "帮助信息包含 cursor-position 子命令"
    else
        print_failure "帮助信息" "未找到 cursor-position 子命令"
    fi
}

# 测试 2: 光标位置
test_cursor_position() {
    print_header "测试 2: 光标位置 (cursor-position)"
    
    local output=$($CLI cursor-position --json 2>&1)
    
    # 验证 JSON 格式
    if ! echo "$output" | jq empty 2>/dev/null; then
        print_failure "光标位置 JSON 格式" "无效的 JSON 输出"
        echo "  输出: $output"
        return
    fi
    
    # 验证字段
    if validate_json_field "$output" "x" "number"; then
        local x=$(echo "$output" | jq -r '.x')
        print_success "x 坐标存在且为数字: $x"
    else
        print_failure "x 坐标" "不存在或非数字"
    fi
    
    if validate_json_field "$output" "y" "number"; then
        local y=$(echo "$output" | jq -r '.y')
        print_success "y 坐标存在且为数字: $y"
    else
        print_failure "y 坐标" "不存在或非数字"
    fi
    
    # 验证坐标范围（屏幕坐标通常为正值）
    local x=$(echo "$output" | jq -r '.x')
    local y=$(echo "$output" | jq -r '.y')
    
    if [[ "$x" -ge 0 && "$y" -ge 0 ]]; then
        print_success "坐标值在有效范围内"
    else
        print_failure "坐标范围" "坐标值为负: x=$x, y=$y"
    fi
}

# 测试 3: 截图
test_screenshot() {
    print_header "测试 3: 截图 (screenshot)"
    
    local output=$($CLI screenshot --json 2>&1)
    
    # 验证 JSON 格式
    if ! echo "$output" | jq empty 2>/dev/null; then
        print_failure "截图 JSON 格式" "无效的 JSON 输出"
        echo "  输出: $output"
        return
    fi
    
    # 验证 success 字段
    if validate_json_field "$output" "success" "boolean"; then
        local success=$(echo "$output" | jq -r '.success')
        if [[ "$success" == "true" ]]; then
            print_success "截图成功"
        else
            print_failure "截图" "success 为 false"
        fi
    else
        print_failure "success 字段" "不存在或非布尔值"
    fi
    
    # 验证 URL 字段
    if validate_json_field "$output" "url" "string"; then
        local url=$(echo "$output" | jq -r '.url')
        if [[ "$url" =~ ^file:// ]]; then
            print_success "URL 格式正确: $url"
        else
            print_failure "URL 格式" "不以 file:// 开头: $url"
        fi
    else
        print_failure "url 字段" "不存在或为空"
    fi
    
    # 验证文件路径
    if validate_json_field "$output" "filepath" "string"; then
        local filepath=$(echo "$output" | jq -r '.filepath')
        if [[ -f "$filepath" ]]; then
            print_success "截图文件存在: $filepath"
            
            # 验证文件大小
            local size=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null)
            if [[ "$size" -gt 0 ]]; then
                print_success "文件大小有效: $size bytes"
            else
                print_failure "文件大小" "文件为空"
            fi
        else
            print_failure "截图文件" "文件不存在: $filepath"
        fi
    else
        print_failure "filepath 字段" "不存在或为空"
    fi
    
    # 验证尺寸字段
    if validate_json_field "$output" "image_width" "number"; then
        local width=$(echo "$output" | jq -r '.image_width')
        print_success "图片宽度: $width"
    else
        print_failure "image_width 字段" "不存在或非数字"
    fi
    
    if validate_json_field "$output" "image_height" "number"; then
        local height=$(echo "$output" | jq -r '.image_height')
        print_success "图片高度: $height"
    else
        print_failure "image_height 字段" "不存在或非数字"
    fi
    
    # 验证光标位置
    if validate_json_field "$output" "cursor_position" "object"; then
        local cursor_x=$(echo "$output" | jq -r '.cursor_position.x')
        local cursor_y=$(echo "$output" | jq -r '.cursor_position.y')
        print_success "光标位置: ($cursor_x, $cursor_y)"
    else
        print_failure "cursor_position 字段" "不存在或非对象"
    fi
}

# 测试 4: 鼠标移动
test_mouse_move() {
    print_header "测试 4: 鼠标移动 (mouse-move)"
    
    # 记录当前位置
    local original_pos=$($CLI cursor-position --json 2>&1)
    local orig_x=$(echo "$original_pos" | jq -r '.x')
    local orig_y=$(echo "$original_pos" | jq -r '.y')
    
    # 移动鼠标到指定位置
    local target_x=200
    local target_y=200
    
    local output=$($CLI mouse-move -x $target_x -y $target_y --json 2>&1)
    
    # 验证 JSON 格式
    if ! echo "$output" | jq empty 2>/dev/null; then
        print_failure "鼠标移动 JSON 格式" "无效的 JSON 输出"
        echo "  输出: $output"
        return
    fi
    
    # 验证 success
    if validate_json_field "$output" "success" "boolean"; then
        local success=$(echo "$output" | jq -r '.success')
        if [[ "$success" == "true" ]]; then
            print_success "鼠标移动命令执行成功"
        else
            print_failure "鼠标移动" "success 为 false"
        fi
    else
        print_failure "success 字段" "不存在"
    fi
    
    # 验证 action 字段
    if validate_json_field "$output" "action" "string"; then
        local action=$(echo "$output" | jq -r '.action')
        if [[ "$action" == "mouse_move" ]]; then
            print_success "action 字段正确: $action"
        else
            print_failure "action 字段" "期望 mouse_move，实际: $action"
        fi
    else
        print_failure "action 字段" "不存在"
    fi
    
    # 验证坐标
    if validate_json_field "$output" "coordinate" "array"; then
        local coord_x=$(echo "$output" | jq -r '.coordinate[0]')
        local coord_y=$(echo "$output" | jq -r '.coordinate[1]')
        if [[ "$coord_x" -eq "$target_x" && "$coord_y" -eq "$target_y" ]]; then
            print_success "返回坐标正确: [$coord_x, $coord_y]"
        else
            print_failure "返回坐标" "期望 [$target_x, $target_y]，实际 [$coord_x, $coord_y]"
        fi
    else
        print_failure "coordinate 字段" "不存在或非数组"
    fi
    
    # 验证实际光标位置（允许一定误差）
    sleep 0.1
    local new_pos=$($CLI cursor-position --json 2>&1)
    local new_x=$(echo "$new_pos" | jq -r '.x')
    local new_y=$(echo "$new_pos" | jq -r '.y')
    
    local diff_x=$((new_x - target_x))
    local diff_y=$((new_y - target_y))
    
    if [[ ${diff_x#-} -le 5 && ${diff_y#-} -le 5 ]]; then
        print_success "光标实际移动到位: ($new_x, $new_y)"
    else
        print_failure "光标实际位置" "期望 ($target_x, $target_y)，实际 ($new_x, $new_y)"
    fi
    
    # 恢复原始位置
    $CLI mouse-move -x $orig_x -y $orig_y > /dev/null 2>&1
    print_info "光标位置已恢复"
}

# 测试 5: 点击操作
test_click() {
    print_header "测试 5: 点击操作 (left-click)"
    
    # 测试当前位置点击
    local output=$($CLI left-click --json 2>&1)
    
    if ! echo "$output" | jq empty 2>/dev/null; then
        print_failure "点击 JSON 格式" "无效的 JSON 输出"
        echo "  输出: $output"
        return
    fi
    
    if validate_json_field "$output" "success" "boolean"; then
        local success=$(echo "$output" | jq -r '.success')
        if [[ "$success" == "true" ]]; then
            print_success "当前位置点击成功"
        else
            print_failure "当前位置点击" "success 为 false"
        fi
    else
        print_failure "success 字段" "不存在"
    fi
    
    if validate_json_field "$output" "action" "string"; then
        local action=$(echo "$output" | jq -r '.action')
        if [[ "$action" == "left_click" ]]; then
            print_success "action 字段正确: $action"
        else
            print_failure "action 字段" "期望 left_click，实际: $action"
        fi
    else
        print_failure "action 字段" "不存在"
    fi
    
    # 测试指定位置点击
    output=$($CLI left-click -x 300 -y 300 --json 2>&1)
    
    if validate_json_field "$output" "coordinate" "array"; then
        local coord_x=$(echo "$output" | jq -r '.coordinate[0]')
        local coord_y=$(echo "$output" | jq -r '.coordinate[1]')
        if [[ "$coord_x" -eq 300 && "$coord_y" -eq 300 ]]; then
            print_success "指定位置点击成功: [$coord_x, $coord_y]"
        else
            print_failure "指定位置" "坐标不匹配"
        fi
    else
        print_failure "coordinate 字段" "不存在"
    fi
}

# 测试 6: 按键操作
test_key() {
    print_header "测试 6: 按键操作 (key)"
    
    # 测试单键
    local output=$($CLI key --keys "return" --json 2>&1)
    
    if ! echo "$output" | jq empty 2>/dev/null; then
        print_failure "按键 JSON 格式" "无效的 JSON 输出"
        echo "  输出: $output"
        return
    fi
    
    if validate_json_field "$output" "success" "boolean"; then
        local success=$(echo "$output" | jq -r '.success')
        if [[ "$success" == "true" ]]; then
            print_success "单键操作成功"
        else
            print_failure "单键操作" "success 为 false"
        fi
    else
        print_failure "success 字段" "不存在"
    fi
    
    if validate_json_field "$output" "keys" "string"; then
        local keys=$(echo "$output" | jq -r '.keys')
        if [[ "$keys" == "return" ]]; then
            print_success "keys 字段正确: $keys"
        else
            print_failure "keys 字段" "期望 return，实际: $keys"
        fi
    else
        print_failure "keys 字段" "不存在"
    fi
    
    # 测试组合键
    output=$($CLI key --keys "command+space" --json 2>&1)
    
    if validate_json_field "$output" "success" "boolean"; then
        local success=$(echo "$output" | jq -r '.success')
        if [[ "$success" == "true" ]]; then
            print_success "组合键操作成功 (command+space)"
        else
            print_failure "组合键操作" "success 为 false"
        fi
    else
        print_failure "success 字段" "不存在"
    fi
}

# 测试 7: 文本输入
test_type() {
    print_header "测试 7: 文本输入 (type)"
    
    local test_text="Hello123"
    local output=$($CLI type --text "$test_text" --json 2>&1)
    
    if ! echo "$output" | jq empty 2>/dev/null; then
        print_failure "文本输入 JSON 格式" "无效的 JSON 输出"
        echo "  输出: $output"
        return
    fi
    
    if validate_json_field "$output" "success" "boolean"; then
        local success=$(echo "$output" | jq -r '.success')
        if [[ "$success" == "true" ]]; then
            print_success "文本输入成功"
        else
            print_failure "文本输入" "success 为 false"
        fi
    else
        print_failure "success 字段" "不存在"
    fi
    
    if validate_json_field "$output" "text" "string"; then
        local text=$(echo "$output" | jq -r '.text')
        if [[ "$text" == "$test_text" ]]; then
            print_success "text 字段正确: $text"
        else
            print_failure "text 字段" "期望 $test_text，实际: $text"
        fi
    else
        print_failure "text 字段" "不存在"
    fi
}

# 测试 8: 拖拽
test_drag() {
    print_header "测试 8: 拖拽 (drag)"
    
    # 先移动到一个起始位置
    $CLI mouse-move -x 100 -y 100 > /dev/null 2>&1
    
    local output=$($CLI drag --to-x 300 --to-y 300 --json 2>&1)
    
    if ! echo "$output" | jq empty 2>/dev/null; then
        print_failure "拖拽 JSON 格式" "无效的 JSON 输出"
        echo "  输出: $output"
        return
    fi
    
    if validate_json_field "$output" "success" "boolean"; then
        local success=$(echo "$output" | jq -r '.success')
        if [[ "$success" == "true" ]]; then
            print_success "拖拽命令执行成功"
        else
            print_failure "拖拽" "success 为 false"
        fi
    else
        print_failure "success 字段" "不存在"
    fi
    
    if validate_json_field "$output" "action" "string"; then
        local action=$(echo "$output" | jq -r '.action')
        if [[ "$action" == "left_click_drag" ]]; then
            print_success "action 字段正确: $action"
        else
            print_failure "action 字段" "期望 left_click_drag，实际: $action"
        fi
    else
        print_failure "action 字段" "不存在"
    fi
    
    if validate_json_field "$output" "from" "array"; then
        print_success "from 坐标存在"
    else
        print_failure "from 字段" "不存在"
    fi
    
    if validate_json_field "$output" "to" "array"; then
        local to_x=$(echo "$output" | jq -r '.to[0]')
        local to_y=$(echo "$output" | jq -r '.to[1]')
        if [[ "$to_x" -eq 300 && "$to_y" -eq 300 ]]; then
            print_success "to 坐标正确: [$to_x, $to_y]"
        else
            print_failure "to 坐标" "期望 [300, 300]，实际 [$to_x, $to_y]"
        fi
    else
        print_failure "to 字段" "不存在"
    fi
}

# 测试 9: 滚动
test_scroll() {
    print_header "测试 9: 滚动 (scroll)"
    
    local output=$($CLI scroll -x 500 -y 500 --direction down --amount 100 --json 2>&1)
    
    if ! echo "$output" | jq empty 2>/dev/null; then
        print_failure "滚动 JSON 格式" "无效的 JSON 输出"
        echo "  输出: $output"
        return
    fi
    
    if validate_json_field "$output" "success" "boolean"; then
        local success=$(echo "$output" | jq -r '.success')
        if [[ "$success" == "true" ]]; then
            print_success "滚动命令执行成功"
        else
            print_failure "滚动" "success 为 false"
        fi
    else
        print_failure "success 字段" "不存在"
    fi
    
    if validate_json_field "$output" "direction" "string"; then
        local direction=$(echo "$output" | jq -r '.direction')
        if [[ "$direction" == "down" ]]; then
            print_success "direction 字段正确: $direction"
        else
            print_failure "direction 字段" "期望 down，实际: $direction"
        fi
    else
        print_failure "direction 字段" "不存在"
    fi
    
    if validate_json_field "$output" "amount" "number"; then
        local amount=$(echo "$output" | jq -r '.amount')
        if [[ "$amount" -eq 100 ]]; then
            print_success "amount 字段正确: $amount"
        else
            print_failure "amount 字段" "期望 100，实际: $amount"
        fi
    else
        print_failure "amount 字段" "不存在或非数字"
    fi
}

# 测试 10: 错误处理
test_error_handling() {
    print_header "测试 10: 错误处理"
    
    # 测试无效的滚动方向
    local output=$($CLI scroll -x 100 -y 100 --direction invalid --json 2>&1 || true)
    
    if [[ -n "$output" ]]; then
        print_info "无效参数返回了输出（可能包含错误信息）"
        echo "  输出: $output"
    fi
    
    # 测试缺少必需参数
    output=$($CLI mouse-move --json 2>&1) || true
    if echo "$output" | grep -qi "error\|missing\|required"; then
        print_success "缺少必需参数时返回错误信息"
    else
        print_info "缺少参数的处理行为: $output"
    fi
}

# 生成测试报告
print_report() {
    echo ""
    echo "========================================"
    echo "           测试报告"
    echo "========================================"
    echo -e "${GREEN}通过: $PASSED${NC}"
    echo -e "${RED}失败: $FAILED${NC}"
    echo "========================================"
    
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 所有测试通过！${NC}"
        return 0
    else
        echo -e "${RED}⚠️  存在失败的测试${NC}"
        return 1
    fi
}

# 主函数
main() {
    echo "🧪 macos-computer-use CLI 测试脚本"
    echo "====================================="
    echo ""
    
    # 检查依赖
    if ! command -v jq &> /dev/null; then
        echo "❌ 请先安装 jq: brew install jq"
        exit 1
    fi
    
    check_cli_installed
    test_help
    test_cursor_position
    test_screenshot
    test_mouse_move
    test_click
    test_key
    test_type
    test_drag
    test_scroll
    test_error_handling
    
    print_report
}

# 运行测试
main "$@"
