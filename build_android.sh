# 查看崩溃日志方法：
# 第一步：在友盟后台找到崩溃日志
# 登录 友盟+控制台。
# 进入你的移动应用项目。
# 在左侧菜单点击 【错误分析】 -> 【错误列表】。
# 找到一条具体的崩溃记录，点击进入详情。
# 在详情页中，你会看到 【堆栈信息】。
# 如果是混淆后的堆栈，你会看到类似：libapp.so + 0x123456 或者 a.b.c(Unknown Source)。
# 第二步：提取崩溃日志到本地
# flutter symbolize 命令需要一个文件输入。
# 在友盟页面上，把那段“乱码”的堆栈信息（Stack Trace）完整地复制下来。
# 在电脑上新建一个文本文件，比如叫 crash.txt。
# 把复制的内容粘贴进去并保存。
# 第三步：运行还原命令
# 现在你手里有了两样东西：
# 你保存的 crash.txt。
# 打包时生成的 ./symbols/app.android-arm64.symbols（那个字典文件）。
# 在终端执行：
# flutter symbolize -i crash.txt -d ./symbols/app.android-arm64.symbols
# 结果： 终端会直接输出还原后的、你能看懂的代码行号。

echo "🚀 构建 Flutter Android 应用..."
flutter build apk --target-platform android-arm,android-arm64 --split-per-abi --obfuscate --split-debug-info=./symbols -v || {
  echo "❌ Flutter 构建失败"; exit 1
}

echo "✅ 所有步骤完成! APK安装包已创建"
