#!/bin/bash
# 作用：重置macOS应用的所有系统权限，使应用如首次运行一样需要重新请求权限
# 用法：./reset_permissions.sh [bundle_id]

# 如果未提供应用包名，则使用默认包名
if [ -z "$1" ]; then
  APP_BUNDLE_ID="com.timelywise.langwise"
  echo "未提供应用包名，使用默认值: $APP_BUNDLE_ID"
else
  APP_BUNDLE_ID="$1"
  echo "使用指定的应用包名: $APP_BUNDLE_ID"
fi

# 定义所有可能的权限服务
SERVICES=(
  "Camera"
  "Microphone"
  "Photos"
  "Calendar"
  "Reminders"
  "AddressBook"
  "Location"
  "SystemPolicyAllFiles"
  "MediaLibrary"
  "SystemPolicyDesktopFolder"
  "SystemPolicyDocumentsFolder"
  "SystemPolicyDownloadsFolder"
  "SystemPolicyNetworkVolumes"
  "SystemPolicyRemovableVolumes"
)

# 重置每个服务的权限
for SERVICE in "${SERVICES[@]}"; do
  echo "重置 $SERVICE 权限..."
  tccutil reset $SERVICE $APP_BUNDLE_ID

  # 检查命令执行状态
  if [ $? -eq 0 ]; then
    echo "✅ $SERVICE 权限重置成功"
  else
    echo "❌ $SERVICE 权限重置失败"
  fi
done

echo ""
echo "🎉 权限重置操作已完成"
echo "📱 下次启动应用时，系统将重新请求权限"