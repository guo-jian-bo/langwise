#!/bin/bash

# 第一次执行之前先要赋予权限 chmod +x build_macos.sh
# 配置参数
APP_NAME="LangWise"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
ZIP_PATH="${APP_NAME}.zip"
DMG_PATH="${APP_NAME}.dmg"
TEAM_ID="FNSQ8V88DV"
# 你的apple账户
# 登录到Apple ID账户页面，在"安全"部分找到"应用专用密码"选项，生成一个新的应用专用密码（专门用于公证服务）
# =======
# APPLE_ID="970649831@qq.com"
# APPLE_ID="247012899@qq.com"
# APPLE_ID="qyflutter@gmail.com"

if [ -z "${APPLE_ID+x}" ]; then
    echo "错误：APPLE_ID 环境变量未定义，请执行以下命令"
    echo "echo 'export APPLE_ID="your-apple-id@email.com"' >> ~/.zshrc"
    echo "source ~/.zshrc"
    exit 1  # 退出脚本，返回非0状态码表示错误
elif [ -z "$APPLE_ID" ]; then
    echo "错误：APPLE_ID 环境变量未定义，请执行以下命令"
    echo "echo 'export APPLE_ID="your-apple-id@email.com"' >> ~/.zshrc"
    echo "source ~/.zshrc"
    exit 1
fi

# 🔐 从钥匙串获取密码（推荐）
APP_PASSWORD=$(security find-generic-password -a "$APPLE_ID" -w -s "flutter_notarization") || {
    echo "APPLE_ID"
    echo "❌ 无法从钥匙串获取密码，请先运行："
    echo "   security add-generic-password -a '你的账户' -w '你的密码' -s 'flutter_notarization'"
    exit 1
}


if [ -n "$APP_PASSWORD" ]; then
    echo "成功获取到APP_PASSWORD"
else
    echo "未获取到APP_PASSWORD"
    exit 1
fi

# 获取开发者证书名称
DEVELOPER_CERT=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed -E 's/.*\) ([^"]*) ".*$/\1/')

if [ -z "$DEVELOPER_CERT" ]; then
  echo "❌ 未找到有效的Developer ID Application证书，请确保已安装"; exit 1
else
  echo "✅ 找到开发者证书: $DEVELOPER_CERT"
fi

# 1. 清理并构建 Flutter 应用
echo "🚀 开始清理和构建 Flutter macOS 应用..."
flutter clean && flutter build macos --release || {
  echo "❌ Flutter 构建失败"; exit 1
}

# 1.5. 重命名应用为乃师
echo "📝 重命名应用为乃师..."
ORIGINAL_APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
NEW_APP_NAME="乃师"
NEW_APP_PATH="build/macos/Build/Products/Release/${NEW_APP_NAME}.app"
ZIP_PATH="${NEW_APP_NAME}.zip"
DMG_PATH="${NEW_APP_NAME}.dmg"

if [ -d "$ORIGINAL_APP_PATH" ]; then
  mv "$ORIGINAL_APP_PATH" "$NEW_APP_PATH" || {
    echo "❌ 重命名应用失败"; exit 1
  }
  echo "✅ 应用已重命名为: ${NEW_APP_NAME}.app"
  # 更新APP_PATH变量指向新的路径
  APP_PATH="$NEW_APP_PATH"
else
  echo "❌ 找不到构建的应用: $ORIGINAL_APP_PATH"; exit 1
fi

# 2. 使用正确的选项进行代码签名
echo "🔏 为应用及其框架进行代码签名..."

# 移除可能存在的调试权限
ENTITLEMENTS_FILE="macos/Runner/Release.entitlements"
if grep -q "com.apple.security.get-task-allow" "$ENTITLEMENTS_FILE"; then
  echo "⚠️ 移除调试权限..."
  sed -i '' 's/<key>com.apple.security.get-task-allow<\/key>.*<true\/>/<key>com.apple.security.get-task-allow<\/key><false\/>/' "$ENTITLEMENTS_FILE" || {
    echo "❌ 无法修改权限文件"; exit 1
  }
fi

# 签名主应用
echo "🔄 签名主应用..."
codesign --force --options runtime --sign "$DEVELOPER_CERT" --timestamp --deep \
  --entitlements "macos/Runner/Release.entitlements" "$APP_PATH" || {
  echo "❌ 应用签名失败"; exit 1
}

# 验证签名
echo "🔍 验证签名..."
codesign -vvv --deep --strict "$APP_PATH" || {
  echo "❌ 签名验证失败"; exit 1
}

# 3. 打包成 .zip（公证必须用 .zip 或 .pkg）
echo "📦 打包应用为ZIP文件..."
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH" || {
  echo "❌ ZIP打包失败"; exit 1
}

# 4. 提交公证
echo "🔐 提交Apple公证..."
xcrun notarytool submit "$ZIP_PATH" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_PASSWORD" \
  --wait || {
  echo "❌ 公证提交失败"; exit 1
}

# 5. 附加公证结果到应用
echo "📌 附加公证结果到应用..."
xcrun stapler staple "$APP_PATH" || {
  echo "❌ 附加公证结果失败"; exit 1
}

# 6. 打包成 DMG（使用create-dmg）
echo "🖥️ 清理旧的挂载点和文件..."
# 尝试卸载所有可能重名的卷，忽略错误
hdiutil detach "/Volumes/${NEW_APP_NAME} Installer" -force 2>/dev/null
hdiutil detach "/Volumes/${NEW_APP_NAME} Installer 1" -force 2>/dev/null
hdiutil detach "/Volumes/${NEW_APP_NAME} Installer 2" -force 2>/dev/null
hdiutil detach "/Volumes/${NEW_APP_NAME} Installer 3" -force 2>/dev/null
rm -f "$DMG_PATH"
echo "🖥️ 创建DMG安装包..."

# 检查是否安装了create-dmg
if ! command -v create-dmg &> /dev/null; then
  echo "⚠️ create-dmg未安装，正在通过Homebrew安装..."
  brew install create-dmg || {
    echo "❌ create-dmg安装失败"; exit 1
  }
fi

# 创建DMG
# --volname "${APP_NAME} Installer" \  # DMG挂载后显示的卷名
# --window-pos 200 120 \               # DMG窗口在屏幕上的位置(x, y坐标)
# --window-size 800 400 \              # DMG窗口的大小(宽x高)
# --icon-size 100 \                    # 图标大小(像素)
# --icon "${APP_NAME}.app" 200 190 \   # 应用图标及其在窗口中的位置
# --hide-extension "${APP_NAME}.app" \ # 隐藏应用的.app扩展名
# --app-drop-link 600 185 \            # "应用程序"文件夹链接的位置
# --no-internet-enable \               # 禁止网络访问DMG
# "$DMG_PATH" \                        # 输出DMG文件路径
# "$APP_PATH"                          # 要打包的应用路径
# 其他参数：
# --background "path/to/background.png" \  # 添加背景图片
# --text-size 12 \                         # 文本大小
# --text-font "宋体" \                     # 文本字体
# --text-color 0x000000 \                  # 文本颜色(十六进制)
# --arrange-by none \                      # 图标排列方式(none, name, date, kind, size)
# --window-border \                        # 添加窗口边框
# --shadow \                               # 添加窗口阴影
# --icon "Applications" 600 185 \          # 自定义"应用程序"文件夹图标
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

# 7. 为DMG文件签名
echo "🔏 为DMG文件签名..."
codesign --force --sign "$DEVELOPER_CERT" --timestamp "$DMG_PATH" || {
  echo "❌ DMG签名失败"; exit 1
}

# 8. 清理临时文件
echo "🧹 清理临时文件..."
rm "$ZIP_PATH"

echo "✅ 所有步骤完成! DMG安装包已创建: ${DMG_PATH}"