#!/bin/bash

# ============================================
# 脚本：DMG 签名并提交公证
# 用法：./sign_and_notarize_dmg.sh [选项] <DMG文件路径>
# 示例：
#   ./sign_and_notarize_dmg.sh 乃师.dmg                    # 完整流程（签名+公证）
#   ./sign_and_notarize_dmg.sh --no-sign 乃师.dmg         # 跳过签名，仅公证
#   ./sign_and_notarize_dmg.sh --sign-only 乃师.dmg       # 仅签名，不公证
#   ./sign_and_notarize_dmg.sh --no-backup 乃师.dmg       # 不创建备份
# ============================================

# 配置参数
TEAM_ID="FNSQ8V88DV"

# 默认选项
SIGN_DMG=true           # 是否签名 DMG
NOTARIZE=true           # 是否提交公证
CREATE_BACKUP=true      # 是否创建备份
SKIP_APP_CHECK=false    # 是否跳过应用签名检查
VERBOSE=false           # 是否详细输出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "${CYAN}📌 $1${NC}"
}

# 显示使用方法
show_usage() {
    echo "用法: $0 [选项] <DMG文件路径>"
    echo ""
    echo "选项："
    echo "  --no-sign              跳过 DMG 签名（仅提交公证）"
    echo "  --sign-only            仅签名，不提交公证"
    echo "  --no-backup            不创建备份文件"
    echo "  --skip-app-check       跳过应用签名检查"
    echo "  --verbose              显示详细输出"
    echo "  -h, --help             显示帮助信息"
    echo ""
    echo "示例："
    echo "  $0 乃师.dmg                           # 完整流程（签名+公证）"
    echo "  $0 --no-sign 乃师.dmg                # 跳过签名，仅公证"
    echo "  $0 --sign-only 乃师.dmg              # 仅签名，不公证"
    echo "  $0 --no-backup 乃师.dmg              # 不创建备份"
    echo "  $0 --skip-app-check 乃师.dmg         # 跳过应用签名检查"
    echo ""
    echo "前置要求："
    echo "  1. DMG 内部的 .app 必须已经签名（除非使用 --skip-app-check）"
    echo "  2. 已设置 APPLE_ID 环境变量（公证时需要）"
    echo "  3. 已保存应用专用密码到钥匙串（公证时需要）"
    echo ""
    echo "设置方法："
    echo "  export APPLE_ID='your-apple-id@email.com'"
    echo "  security add-generic-password -a 'your-apple-id@email.com' -w '密码' -s 'flutter_notarization'"
    echo ""
    exit 1
}

# 解析命令行参数
DMG_PATH=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-sign)
            SIGN_DMG=false
            shift
            ;;
        --sign-only)
            NOTARIZE=false
            shift
            ;;
        --no-backup)
            CREATE_BACKUP=false
            shift
            ;;
        --skip-app-check)
            SKIP_APP_CHECK=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_usage
            ;;
        -*)
            print_error "未知选项: $1"
            show_usage
            ;;
        *)
            DMG_PATH="$1"
            shift
            ;;
    esac
done

# 检查参数
if [ -z "$DMG_PATH" ]; then
    print_error "请提供 DMG 文件路径"
    show_usage
fi

# 检查文件是否存在
if [ ! -f "$DMG_PATH" ]; then
    print_error "找不到文件: $DMG_PATH"
    exit 1
fi

# 检查文件扩展名
if [[ ! "$DMG_PATH" =~ \.dmg$ ]]; then
    print_error "文件不是 DMG 格式: $DMG_PATH"
    exit 1
fi

# 获取绝对路径
DMG_PATH=$(realpath "$DMG_PATH")
DMG_DIR=$(dirname "$DMG_PATH")
DMG_BASENAME=$(basename "$DMG_PATH")
DMG_NAME="${DMG_BASENAME%.dmg}"

# 显示配置信息
echo ""
echo "=========================================="
print_info "配置信息"
echo "=========================================="
echo "📦 DMG 文件: $DMG_BASENAME"
echo "📏 文件大小: $(du -h "$DMG_PATH" | cut -f1)"
echo "🔏 签名 DMG: $(if $SIGN_DMG; then echo "是"; else echo "否"; fi)"
echo "📋 提交公证: $(if $NOTARIZE; then echo "是"; else echo "否"; fi)"
echo "💾 创建备份: $(if $CREATE_BACKUP; then echo "是"; else echo "否"; fi)"
echo "🔍 跳过应用检查: $(if $SKIP_APP_CHECK; then echo "是"; else echo "否"; fi)"
echo "=========================================="

# 如果需要公证，检查环境变量
if $NOTARIZE; then
    # 检查 Apple ID 环境变量
    if [ -z "${APPLE_ID+x}" ] || [ -z "$APPLE_ID" ]; then
        print_error "APPLE_ID 环境变量未定义"
        echo ""
        echo "请执行以下命令设置 Apple ID："
        echo "  export APPLE_ID=\"your-apple-id@email.com\""
        echo ""
        echo "或永久保存："
        echo "  echo 'export APPLE_ID=\"your-apple-id@email.com\"' >> ~/.zshrc"
        echo "  source ~/.zshrc"
        exit 1
    fi

    print_info "使用 Apple ID: $APPLE_ID"

    # 从钥匙串获取密码
    print_info "从钥匙串获取应用专用密码..."
    APP_PASSWORD=$(security find-generic-password -a "$APPLE_ID" -w -s "flutter_notarization" 2>/dev/null)

    if [ -z "$APP_PASSWORD" ]; then
        print_error "无法从钥匙串获取密码"
        echo ""
        echo "请先运行以下命令保存密码到钥匙串："
        echo "  security add-generic-password -a '$APPLE_ID' -w '你的应用专用密码' -s 'flutter_notarization'"
        echo ""
        echo "如何获取应用专用密码："
        echo "  1. 登录 https://appleid.apple.com"
        echo "  2. 进入'安全'部分"
        echo "  3. 点击'生成密码'"
        echo "  4. 输入密码标签（如：flutter_notarization）"
        echo "  5. 复制生成的密码"
        exit 1
    fi

    print_success "成功获取密码"
fi

# 如果需要签名，获取开发者证书
if $SIGN_DMG; then
    print_info "查找开发者证书..."
    DEVELOPER_CERT=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed -E 's/.*\) ([^"]*) ".*$/\1/')

    if [ -z "$DEVELOPER_CERT" ]; then
        print_error "未找到有效的 Developer ID Application 证书"
        echo ""
        echo "请确保："
        echo "  1. 已在钥匙串中安装 Developer ID Application 证书"
        echo "  2. 证书未过期"
        echo ""
        echo "查看可用证书："
        echo "  security find-identity -v -p codesigning"
        exit 1
    fi

    print_success "找到开发者证书: $DEVELOPER_CERT"
fi

# ============================================
# 步骤 1: 检查 DMG 内部的 .app 签名（可选）
# ============================================
if ! $SKIP_APP_CHECK && ($SIGN_DMG || $NOTARIZE); then
    echo ""
    print_step "步骤 1: 检查 DMG 内部的 .app 签名"

    # 创建临时目录挂载 DMG
    TEMP_MOUNT="/Volumes/${DMG_NAME}_temp"
    TEMP_CHECK_DIR=$(mktemp -d)

    print_info "挂载 DMG 检查内部应用..."
    hdiutil attach "$DMG_PATH" -mountpoint "$TEMP_MOUNT" -nobrowse -quiet 2>/dev/null

    if [ $? -ne 0 ]; then
        print_error "无法挂载 DMG 文件"
        rm -rf "$TEMP_CHECK_DIR"
        exit 1
    fi

    # 查找 .app 文件
    APP_FILE=$(find "$TEMP_MOUNT" -maxdepth 1 -name "*.app" -type d | head -1)

    if [ -z "$APP_FILE" ]; then
        print_error "在 DMG 中找不到 .app 文件"
        hdiutil detach "$TEMP_MOUNT" -force -quiet 2>/dev/null
        rm -rf "$TEMP_CHECK_DIR"
        exit 1
    fi

    APP_NAME=$(basename "$APP_FILE")
    print_info "找到应用: $APP_NAME"

    # 检查 .app 签名
    print_info "验证应用签名..."
    if $VERBOSE; then
        codesign -vvv --deep --strict "$APP_FILE" 2>&1
    else
        codesign -vvv --deep --strict "$APP_FILE" 2>&1 > /dev/null
    fi

    if [ $? -ne 0 ]; then
        print_error "应用签名无效或未签名"
        print_warning "请先对应用进行签名，然后再打包成 DMG"
        if ! $VERBOSE; then
            echo "使用 --verbose 查看详细错误信息"
        fi
        hdiutil detach "$TEMP_MOUNT" -force -quiet 2>/dev/null
        rm -rf "$TEMP_CHECK_DIR"
        exit 1
    fi

    print_success "应用签名验证通过"

    # 卸载 DMG
    hdiutil detach "$TEMP_MOUNT" -force -quiet 2>/dev/null
    rm -rf "$TEMP_CHECK_DIR"
fi

# ============================================
# 步骤 2: 备份原始 DMG（可选）
# ============================================
if $CREATE_BACKUP && ($SIGN_DMG || $NOTARIZE); then
    echo ""
    print_step "步骤 2: 备份原始 DMG"
    BACKUP_PATH="${DMG_PATH%.dmg}_backup.dmg"

    if [ ! -f "$BACKUP_PATH" ]; then
        cp "$DMG_PATH" "$BACKUP_PATH"
        print_success "已备份到: $BACKUP_PATH"
    else
        print_warning "备份文件已存在，跳过备份"
    fi
fi

# ============================================
# 步骤 3: 签名 DMG 文件（可选）
# ============================================
if $SIGN_DMG; then
    echo ""
    print_step "步骤 3: 签名 DMG 文件"

    # 先尝试移除现有签名（如果有）
    print_info "移除现有签名（如果有）..."
    codesign --remove-signature "$DMG_PATH" 2>/dev/null

    # 签名 DMG
    print_info "使用证书签名: $DEVELOPER_CERT"
    if $VERBOSE; then
        codesign --force --sign "$DEVELOPER_CERT" \
            --timestamp \
            --options runtime \
            "$DMG_PATH" 2>&1
    else
        codesign --force --sign "$DEVELOPER_CERT" \
            --timestamp \
            --options runtime \
            "$DMG_PATH" 2>&1 > /dev/null
    fi

    if [ $? -ne 0 ]; then
        print_error "DMG 签名失败"
        exit 1
    fi

    print_success "DMG 签名完成"

    # 验证 DMG 签名
    print_info "验证 DMG 签名..."
    if $VERBOSE; then
        codesign -vvv "$DMG_PATH" 2>&1
    else
        codesign -vvv "$DMG_PATH" 2>&1 > /dev/null
    fi

    if [ $? -ne 0 ]; then
        print_warning "签名验证有警告，但可能不影响公证"
    else
        print_success "DMG 签名验证通过"
    fi
fi

# ============================================
# 步骤 4: 提交公证（可选）
# ============================================
if $NOTARIZE; then
    echo ""
    print_step "步骤 4: 提交 Apple 公证"
    print_info "这可能需要 1-5 分钟，请耐心等待..."

    # 记录开始时间
    START_TIME=$(date +%s)

    # 提交公证
    if $VERBOSE; then
        xcrun notarytool submit "$DMG_PATH" \
            --apple-id "$APPLE_ID" \
            --team-id "$TEAM_ID" \
            --password "$APP_PASSWORD" \
            --wait 2>&1
    else
        xcrun notarytool submit "$DMG_PATH" \
            --apple-id "$APPLE_ID" \
            --team-id "$TEAM_ID" \
            --password "$APP_PASSWORD" \
            --wait 2>&1 > /dev/null
    fi

    NOTARY_RESULT=$?

    # 计算耗时
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    print_info "公证耗时: ${DURATION} 秒"

    if [ $NOTARY_RESULT -ne 0 ]; then
        print_error "公证提交失败"
        echo ""
        print_info "获取详细日志..."
        xcrun notarytool log \
            --apple-id "$APPLE_ID" \
            --team-id "$TEAM_ID" \
            --password "$APP_PASSWORD" \
            "$DMG_PATH" 2>&1 | head -50
        exit 1
    fi

    print_success "公证通过！"

    # ============================================
    # 步骤 5: 附加公证结果到 DMG
    # ============================================
    echo ""
    print_step "步骤 5: 附加公证结果到 DMG"
    if $VERBOSE; then
        xcrun stapler staple "$DMG_PATH" 2>&1
    else
        xcrun stapler staple "$DMG_PATH" 2>&1 > /dev/null
    fi

    if [ $? -ne 0 ]; then
        print_error "附加公证结果失败"
        print_warning "但公证已通过，用户可以手动安装"
    else
        print_success "公证结果已附加到 DMG"
    fi
fi

# ============================================
# 步骤 6: 最终验证
# ============================================
if $SIGN_DMG || $NOTARIZE; then
    echo ""
    print_step "步骤 6: 最终验证"
    
    if $SIGN_DMG; then
        print_info "验证 DMG 签名..."
        codesign -vvv "$DMG_PATH" 2>&1 | head -5
    fi
    
    if $NOTARIZE; then
        print_info "验证 DMG 公证状态..."
        spctl -a -v --type install "$DMG_PATH" 2>&1

        if [ $? -eq 0 ]; then
            print_success "DMG 已通过公证验证"
        else
            print_warning "验证命令执行有警告"
        fi
    fi
fi

# ============================================
# 完成
# ============================================
echo ""
echo "=========================================="
print_success "所有步骤完成！"
echo "=========================================="
echo "📦 DMG 文件: $DMG_PATH"
echo "📏 最终大小: $(du -h "$DMG_PATH" | cut -f1)"

if $CREATE_BACKUP && [ -n "$BACKUP_PATH" ] && [ -f "$BACKUP_PATH" ]; then
    echo "📋 备份文件: $BACKUP_PATH"
fi

echo ""
echo "🔏 签名状态: $(if $SIGN_DMG; then echo "已签名"; else echo "未签名"; fi)"
echo "📋 公证状态: $(if $NOTARIZE; then echo "已公证"; else echo "未公证"; fi)"

if $NOTARIZE; then
    echo ""
    print_info "验证命令："
    echo "  spctl -a -v --type install \"$DMG_PATH\""
    echo "  codesign -vvv \"$DMG_PATH\""
    echo ""
    print_success "用户可以正常打开，不会看到安全警告！"
elif $SIGN_DMG && ! $NOTARIZE; then
    echo ""
    print_warning "仅签名模式："
    echo "  - 此版本未经过 Apple 公证"
    echo "  - 用户首次打开时需要在系统设置中手动允许运行"
    echo "  - 仅适合内部测试或企业内部分发"
fi
echo "=========================================="

# 可选：询问是否删除备份
if $CREATE_BACKUP && [ -n "$BACKUP_PATH" ] && [ -f "$BACKUP_PATH" ] && $NOTARIZE; then
    echo ""
    read -p "是否删除备份文件？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$BACKUP_PATH"
        print_success "备份文件已删除"
    else
        print_info "备份文件保留: $BACKUP_PATH"
    fi
fi