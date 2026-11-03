#!/bin/bash
# 作用：清除macOS应用的所有数据，使应用恢复到首次安装状态
# 用法：./clean_app_data.sh [bundle_id]

# 如果未提供应用包名，则使用默认包名
if [ -z "$1" ]; then
  APP_BUNDLE_ID="com.timelywise.langwise"
  echo "未提供应用包名，使用默认值: $APP_BUNDLE_ID"
else
  APP_BUNDLE_ID="$1"
  echo "使用指定的应用包名: $APP_BUNDLE_ID"
fi

# 确保应用未运行
echo "🔍 检查应用运行状态..."
APP_PROCESS=$(pgrep -f "$APP_BUNDLE_ID")

if [ ! -z "$APP_PROCESS" ]; then
  echo "⚠️ 发现应用正在运行，请先关闭应用后再执行此脚本"
  echo "👉 运行以下命令关闭应用:"
  echo "   killall -9 \"$APP_BUNDLE_ID\""
  exit 1
fi

echo "✅ 应用未运行，继续清理操作"
echo ""

# 清除容器目录
CONTAINER_PATH="$HOME/Library/Containers/$APP_BUNDLE_ID"
if [ -d "$CONTAINER_PATH" ]; then
  echo "🗑️ 正在删除应用容器目录: $CONTAINER_PATH"
  rm -rf "$CONTAINER_PATH"
  echo "✅ 容器目录已清除"
else
  echo "❓ 容器目录不存在: $CONTAINER_PATH"
fi

# 清除Application Support目录
APP_SUPPORT_PATH="$HOME/Library/Application Support/$APP_BUNDLE_ID"
if [ -d "$APP_SUPPORT_PATH" ]; then
  echo "🗑️ 正在删除应用支持目录: $APP_SUPPORT_PATH"
  rm -rf "$APP_SUPPORT_PATH"
  echo "✅ 应用支持目录已清除"
else
  echo "❓ 应用支持目录不存在: $APP_SUPPORT_PATH"
fi

# 清除偏好设置
PLIST_PATH="$HOME/Library/Preferences/$APP_BUNDLE_ID.plist"
if [ -f "$PLIST_PATH" ]; then
  echo "🗑️ 正在删除偏好设置文件: $PLIST_PATH"
  rm "$PLIST_PATH"
  echo "✅ 偏好设置已清除"
else
  echo "❓ 偏好设置文件不存在: $PLIST_PATH"
fi

# 清除缓存目录
CACHE_PATH="$HOME/Library/Caches/$APP_BUNDLE_ID"
if [ -d "$CACHE_PATH" ]; then
  echo "🗑️ 正在删除缓存目录: $CACHE_PATH"
  rm -rf "$CACHE_PATH"
  echo "✅ 缓存目录已清除"
else
  echo "❓ 缓存目录不存在: $CACHE_PATH"
fi

# 清除日志目录
LOGS_PATH="$HOME/Library/Logs/$APP_BUNDLE_ID"
if [ -d "$LOGS_PATH" ]; then
  echo "🗑️ 正在删除日志目录: $LOGS_PATH"
  rm -rf "$LOGS_PATH"
  echo "✅ 日志目录已清除"
else
  echo "❓ 日志目录不存在: $LOGS_PATH"
fi

echo ""
echo "🎉 应用数据清理操