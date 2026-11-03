#!/bin/bash

# 配置参数
APP_NAME="LangWise"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
DMG_PATH="${APP_NAME}.dmg"

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
  --volname "${APP_NAME} Installer" \
  --volicon "build_assets/langwise_installer.icns" \
  --window-pos 200 120 \
  --window-size 800 422 \
  --icon-size 100 \
  --icon "${APP_NAME}.app" 260 200 \
  --hide-extension "${APP_NAME}.app" \
  --app-drop-link 565 200 \
  --background "build_assets/dmg_background.png" \
  --no-internet-enable \
  "$DMG_PATH" \
  "$APP_PATH" || {
  echo "❌ DMG创建失败"; exit 1
}

echo "✅ DMG安装包已创建: ${DMG_PATH}"