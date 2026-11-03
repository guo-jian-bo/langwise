#!/bin/bash

# 第一次执行之前先要赋予权限 chmod +x resign_macos.sh
# 用途：对已签名的 ZIP 直接提交公证，然后生成 DMG

# 配置参数
NEW_APP_NAME="乃师"
APP_PATH="build/macos/Build/Products/Release/${NEW_APP_NAME}.app"
ZIP_PATH="${NEW_APP_NAME}.zip"
DMG_PATH="${NEW_APP_NAME}.dmg"
TEAM_ID="FNSQ8V88DV"

# 检查 ZIP 是否存在
if [ ! -f "$ZIP_PATH" ]; then
  echo "❌ 找不到已签名的ZIP文件: $ZIP_PATH"; exit 1
fi
echo "✅ 找到ZIP文件: $ZIP_PATH"

# 检查 .app 是否存在（staple 和 DMG 需要）
if [ ! -d "$APP_PATH" ]; then
  echo "❌ 找不到应用: $APP_PATH（staple和DMG步骤需要）"; exit 1
fi
echo "✅ 找到应用: $APP_PATH"

# 检查 APPLE_ID
if [ -z "${APPLE_ID+x}" ] || [ -z "$APPLE_ID" ]; then
    echo "错误：APPLE_ID 环境变量未定义，请执行以下命令"
    echo "echo 'export APPLE_ID=\"your-apple-id@email.com\"' >> ~/.zshrc"
    echo "source ~/.zshrc"
    exit 1
fi

# 🔐 从钥匙串获取密码
APP_PASSWORD=$(security find-generic-password -a "$APPLE_ID" -w -s "flutter_notarization") || {
    echo "❌ 无法从钥匙串获取密码，请先运行："
    echo "   security add-generic-password -a '你的账户' -w '你的密码' -s 'flutter_notarization'"
    exit 1
}

if [ -z "$APP_PASSWORD" ]; then
    echo "未获取到APP_PASSWORD"
    exit 1
fi
echo "✅ 成功获取到APP_PASSWORD"

# 获取开发者证书名称（DMG签名需要）
DEVELOPER_CERT=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed -E 's/.*\) ([^"]*) ".*$/\1/')

if [ -z "$DEVELOPER_CERT" ]; then
  echo "❌ 未找到有效的Developer ID Application证书，请确保已安装"; exit 1
else
  echo "✅ 找到开发者证书: $DEVELOPER_CERT"
fi

# 1. 提交公证
echo "🔐 提交Apple公证..."
xcrun notarytool submit "$ZIP_PATH" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_PASSWORD" \
  --wait || {
  echo "❌ 公证提交失败"; exit 1
}

# 2. 附加公证结果到应用
echo "📌 附加公证结果到应用..."
xcrun stapler staple "$APP_PATH" || {
  echo "❌ 附加公证结果失败"; exit 1
}

# 3. 打包成 DMG
echo "🖥️ 清理旧的挂载点和文件..."
hdiutil detach "/Volumes/${NEW_APP_NAME} Installer" -force 2>/dev/null
hdiutil detach "/Volumes/${NEW_APP_NAME} Installer 1" -force 2>/dev/null
hdiutil detach "/Volumes/${NEW_APP_NAME} Installer 2" -force 2>/dev/null
hdiutil detach "/Volumes/${NEW_APP_NAME} Installer 3" -force 2>/dev/null
rm -f "$DMG_PATH"

echo "🖥️ 创建DMG安装包..."
if ! command -v create-dmg &> /dev/null; then
  echo "⚠️ create-dmg未安装，正在通过Homebrew安装..."
  brew install create-dmg || {
    echo "❌ create-dmg安装失败"; exit 1
  }
fi

create-dmg \
  --volname "${NEW_APP_NAME} Installer" \
  --volicon "build_assets/langwise_installer.icns" \
  --window-pos 200 120 \
  --window-size 800 422 \
  --icon-size 100 \
  --icon "${NEW_APP_NAME}.app" 260 200 \
  --hide-extension "${NEW_APP_NAME}.app" \
  --app-drop-link 565 200 \
  --background "build_assets/dmg_background.png" \
  --no-internet-enable \
  "$DMG_PATH" \
  "$APP_PATH" || {
  echo "❌ DMG创建失败"; exit 1
}

# 4. 为DMG文件签名
echo "🔏 为DMG文件签名..."
codesign --force --sign "$DEVELOPER_CERT" --timestamp "$DMG_PATH" || {
  echo "❌ DMG签名失败"; exit 1
}

# 5. 清理临时文件
echo "🧹 清理临时文件..."
rm -f "$ZIP_PATH"

echo "✅ 所有步骤完成! DMG安装包已创建: ${DMG_PATH}"
