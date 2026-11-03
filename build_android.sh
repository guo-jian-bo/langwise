

echo "🚀 构建 Flutter Android 应用..."
flutter build apk --target-platform android-arm,android-arm64 --split-per-abi -v || {
  echo "❌ Flutter 构建失败"; exit 1
}

echo "✅ 所有步骤完成! APK安装包已创建"
