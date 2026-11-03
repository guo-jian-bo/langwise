@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ================================
:: 配置
:: ================================
set "source_file=scripts/langwise_only10_installVC_incmd_smart_uninstallOld.iss"

:: ================================
:: 获取版本号
:: ================================
set "appVersion=%~1"

if "%appVersion%"=="" (

    echo 未提供版本号参数，正在从 pubspec.yaml 读取...

    if not exist "pubspec.yaml" (
        echo 错误：pubspec.yaml 文件不存在
        pause
        exit /b 1
    )

    set "fullVersion="

    for /f "tokens=2 delims=: " %%a in ('findstr /b /i "version:" pubspec.yaml') do (
        set "fullVersion=%%a"
    )

    if "!fullVersion!"=="" (
        echo 错误：无法读取 version
        pause
        exit /b 1
    )

    echo 原始版本字符串：!fullVersion!

    :: 去掉 + 后面的 build number
    for /f "tokens=1 delims=+" %%a in ("!fullVersion!") do (
        set "appVersion=%%a"
    )

    echo 读取到版本号：!appVersion!

) else (
    echo 使用命令行版本号：%appVersion%
)

if "!appVersion!"=="" (
    echo 错误：未获取到版本号
    pause
    exit /b 1
)

:: ================================
:: 目标目录
:: ================================
set "target_dir=%~2"

if not "!target_dir!"=="" (
    echo 目标路径：!target_dir!
) else (
    echo 未提供目标路径
)

:: ================================
:: 验证版本号
:: ================================
echo !appVersion! | findstr /r "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul

if errorlevel 1 (
    echo 警告：版本号格式建议为 x.y.z
)

echo.
echo 当前版本号：!appVersion!
echo.

:: ================================
:: 1. Git 强制同步
:: ================================
echo [1/8] Git 强制同步...

set "current_branch="

for /f %%i in ('git rev-parse --abbrev-ref HEAD 2^>nul') do (
    set "current_branch=%%i"
)

if "!current_branch!"=="" (
    echo 错误：当前目录不是 Git 仓库
    pause
    exit /b 1
)

echo 当前分支：!current_branch!

echo 获取远程更新...
git fetch --all

if errorlevel 1 (
    echo 错误：git fetch 失败
    pause
    exit /b 1
)

echo 重置代码...
git reset --hard origin/!current_branch!

if errorlevel 1 (
    echo 错误：git reset 失败
    pause
    exit /b 1
)

echo 清理未跟踪文件...
git clean -fd

echo Git 同步完成

:: ================================
:: 2. Flutter Clean
:: ================================
echo [2/8] flutter clean...

flutter clean

if errorlevel 1 (
    echo 警告：flutter clean 失败
)

:: ================================
:: 3. 删除 lock 文件
:: ================================
echo [3/8] 删除 lock 文件...

for /r %%i in (pubspec.lock) do (
    del /f /q "%%i" >nul 2>nul
)

echo lock 文件删除完成

:: ================================
:: 4. flutter pub get
:: ================================
echo [4/8] flutter pub get...

flutter pub get

if errorlevel 1 (
    echo 错误：flutter pub get 失败
    pause
    exit /b 1
)

echo pub get 完成

:: ================================
:: 5. Flutter Build
:: ================================
echo [5/8] flutter build windows --release...

flutter build windows --release

if errorlevel 1 (
    echo 错误：flutter build windows 失败
    pause
    exit /b 1
)

echo build 完成

:: ================================
:: 6. 检查 ISS 文件
:: ================================
echo [6/8] 检查 ISS 文件...

if not exist "%source_file%" (
    echo 错误：ISS 文件不存在
    echo %source_file%
    pause
    exit /b 1
)

:: ================================
:: 7. 复制 ISS 文件
:: ================================
echo [7/8] 复制 ISS 文件...

copy /y "%source_file%" "." >nul

if errorlevel 1 (
    echo 错误：复制 ISS 文件失败
    pause
    exit /b 1
)

if not "!target_dir!"=="" (

    if not exist "!target_dir!" (
        mkdir "!target_dir!"
    )

    copy /y "%source_file%" "!target_dir!" >nul

    if errorlevel 1 (
        echo 警告：复制到目标目录失败
    ) else (
        echo 已复制到目标目录
    )
)

echo ISS 文件复制完成

:: ================================
:: 8. Inno Setup 编译
:: ================================
echo [8/8] 执行 ISCC 编译...

ISCC "/DMyAppVersion=!appVersion!" "langwise_only10_installVC_incmd_smart_uninstallOld.iss"

if errorlevel 1 (
    echo 错误：ISCC 编译失败
    pause
    exit /b 1
)

echo ISCC 编译完成

:: ================================
:: 打开输出目录
:: ================================
echo 打开输出目录...

if exist "Output" (
    start "" "Output"
) else if exist "build\windows\x64\runner\Release" (
    start "" "build\windows\x64\runner\Release"
)

echo.
echo =====================================
echo 所有操作完成
echo 版本号：!appVersion!
echo =====================================
pause

exit /b 0