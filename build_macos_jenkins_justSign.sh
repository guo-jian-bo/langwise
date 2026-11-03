#!/bin/bash

# 第一次执行之前先要赋予权限 chmod +x build_macos_jenkins_justSign.sh
# 用途：公司内部员工包。保持沙盒路径兼容旧缓存，只做签名不做公证。
APP_NAME="乃师"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
ZIP_PATH="${APP_NAME}.zip"
DMG_PATH="${APP_NAME}.dmg"
TEAM_ID="FNSQ8V88DV"
CREATE_ZIP_BACKUP="${CREATE_ZIP_BACKUP:-false}"

# 注意：此脚本只签名不公证，无需配置 APPLE_ID 和密码

echo "=========================================="
echo "⚙️  模式：内部沙盒版，只签名不公证"
echo "=========================================="

# 获取开发者证书名称
DEVELOPER_CERT=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed -E 's/.*\) ([^"]*) ".*$/\1/')

if [ -z "$DEVELOPER_CERT" ]; then
  echo "❌ 未找到有效的Developer ID Application证书，请确保已安装"
  echo "💡 提示：可以在钥匙串访问中查看是否有 Developer ID Application 证书"
  exit 1
else
  echo "✅ 找到开发者证书: $DEVELOPER_CERT"
fi

# 1. 构建 Flutter 应用（不清理）
echo "🚀 开始构建 Flutter macOS 应用..."
flutter build macos --release || {
  echo "❌ Flutter 构建失败"
  exit 1
}

# 2. 校验构建产物
if [ ! -d "$APP_PATH" ]; then
  echo "❌ 找不到构建的应用: $APP_PATH"
  exit 1
fi
echo "✅ 构建产物已生成: ${APP_NAME}.app"

# 3. 代码签名
echo "🔏 为应用及其框架进行代码签名..."

# 处理 entitlements 文件
ENTITLEMENTS_FILE="macos/Runner/InternalSandbox.entitlements"
TEMP_ENTITLEMENTS_FILE="$(mktemp /tmp/naishi-entitlements.XXXXXX.plist)"
cleanup() {
  rm -f "$TEMP_ENTITLEMENTS_FILE"
}
trap cleanup EXIT
if [ -f "$ENTITLEMENTS_FILE" ]; then
  cp "$ENTITLEMENTS_FILE" "$TEMP_ENTITLEMENTS_FILE"
else
  echo "⚠️ 未找到 entitlements 文件: $ENTITLEMENTS_FILE"
  exit 1
fi

# Flutter build 产物会带开发版 provisioning profile，和 Developer ID 重签名混用容易导致启动失败。
PROFILE_PATH="$APP_PATH/Contents/embedded.provisionprofile"
if [ -f "$PROFILE_PATH" ]; then
  echo "⚠️ 移除开发版 provisioning profile..."
  rm -f "$PROFILE_PATH"
fi

# 签名主应用
echo "🔄 签名主应用..."
codesign --force --options runtime \
  --sign "$DEVELOPER_CERT" \
  --timestamp \
  --deep \
  --entitlements "$TEMP_ENTITLEMENTS_FILE" \
  "$APP_PATH" 2>&1 || {
  echo "❌ 应用签名失败"
  exit 1
}

# 验证签名
echo "🔍 验证签名..."
codesign -vvv --deep --strict "$APP_PATH" 2>&1 || {
  echo "❌ 签名验证失败"
  echo "💡 详细错误信息："
  codesign -vvv --deep "$APP_PATH"
  exit 1
}
echo "✅ 签名验证通过"

# 4. 打包成 DMG（使用create-dmg）
echo "🖥️ 准备创建 DMG 安装包..."

# 清理旧的挂载点
echo "🧹 清理旧的挂载点..."
for i in {0..3}; do
  hdiutil detach "/Volumes/${APP_NAME} Installer${i:+ $i}" -force 2>/dev/null
done
rm -f "$DMG_PATH"

# 检查是否安装了create-dmg
if ! command -v create-dmg &> /dev/null; then
  echo "⚠️ create-dmg未安装，正在通过Homebrew安装..."
  brew install create-dmg || {
    echo "❌ create-dmg安装失败"
    exit 1
  }
fi

# 检查背景图片和图标是否存在
if [ ! -f "build_assets/dmg_background.png" ]; then
  echo "⚠️ 未找到背景图片: build_assets/dmg_background.png，将使用默认背景"
  BACKGROUND_PARAM=""
else
  BACKGROUND_PARAM="--background build_assets/dmg_background.png"
fi

if [ ! -f "build_assets/langwise_installer.icns" ]; then
  echo "⚠️ 未找到卷图标: build_assets/langwise_installer.icns，将使用默认图标"
  VOLICON_PARAM=""
else
  VOLICON_PARAM="--volicon build_assets/langwise_installer.icns"
fi

# 创建DMG
echo "🖥️ 创建DMG安装包..."
create-dmg \
  --volname "${APP_NAME} Installer" \
  ${VOLICON_PARAM} \
  --window-pos 200 120 \
  --window-size 800 422 \
  --icon-size 100 \
  --icon "${APP_NAME}.app" 260 200 \
  --hide-extension "${APP_NAME}.app" \
  --app-drop-link 565 200 \
  ${BACKGROUND_PARAM} \
  --no-internet-enable \
  "$DMG_PATH" \
  "$APP_PATH" 2>&1 || {
  echo "❌ DMG创建失败"
  exit 1
}

# 5. 为DMG文件签名
echo "🔏 为DMG文件签名..."
codesign --force --sign "$DEVELOPER_CERT" --timestamp "$DMG_PATH" 2>&1 || {
  echo "❌ DMG签名失败"
  exit 1
}

# 验证DMG签名
echo "🔍 验证DMG签名..."
codesign -vvv "$DMG_PATH" 2>&1 || {
  echo "⚠️ DMG签名验证有警告（可能不影响使用）"
}

# 6. 可选：创建ZIP备份（通过环境变量控制）
if [[ "$CREATE_ZIP_BACKUP" == "true" ]]; then
  echo "📦 创建ZIP备份..."
  ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH" || {
    echo "⚠️ ZIP备份创建失败"
  }
  echo "✅ ZIP备份已创建: $ZIP_PATH"
else
  echo "ℹ️ 跳过ZIP备份创建"
fi

echo ""
echo "=========================================="
echo "✅ 所有步骤完成！"
echo "=========================================="
echo "📦 DMG安装包: $DMG_PATH"
echo "🔏 签名状态: 已签名（未公证）"
echo "🗂️ 数据路径: 保持沙盒模式，兼容历史缓存目录"
echo ""
echo "⚠️  重要提示："
echo "   - 此版本未经过 Apple 公证"
echo "   - 用户首次打开时需要在'系统设置 → 隐私与安全性'中手动允许运行"
echo "   - 仅适合内部测试或企业内部分发"
echo "   - 如需公开分发，请使用完整的签名+公证流程"
echo "=========================================="

# 显示DMG文件大小
if [ -f "$DMG_PATH" ]; then
  FILE_SIZE=$(du -h "$DMG_PATH" | cut -f1)
  echo "📊 DMG文件大小: $FILE_SIZE"
fi
