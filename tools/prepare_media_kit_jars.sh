#!/usr/bin/env bash
# 方案 1：在 flutter build apk 前把本地缓存的 media_kit libmpv jar 回填到
# 模块 buildDir，使 media_kit_libs_android_video 的 downloadDependencies 任务
# 命中缓存而跳过 GitHub 下载。零源码改动。
#
# jar 的版本号与 MD5 从 media_kit_libs_android_video 包的 android/build.gradle
# 动态解析（版本号取自 pubspec.lock 定位包），无硬编码；包升级后自动适配。
# 共享缓存缺失时自动用 curl 从 GitHub 下载（仅首次联网，之后走本地缓存）。
#
# 用法：
#   ./tools/prepare_media_kit_jars.sh
#   MEDIA_KIT_JARS_DIR=/some/path ./tools/prepare_media_kit_jars.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

md5_of() {
  if command -v md5 >/dev/null 2>&1; then
    md5 -q "$1"
  else
    md5sum "$1" | awk '{print $1}'
  fi
}

# 1. 从 pubspec.lock 解析 media_kit_libs_android_video 版本
LOCK="$ROOT_DIR/pubspec.lock"
PKG_VER=$(awk '/^  media_kit_libs_android_video:/{f=1;next} f&&/^    version:/{v=$2; gsub(/"/,"",v); print v; exit}' "$LOCK")
if [ -z "$PKG_VER" ]; then
  echo "[media_kit] 无法从 pubspec.lock 解析 media_kit_libs_android_video 版本" >&2
  exit 1
fi

# 2. 定位包内 android/build.gradle
PUB_CACHE_DIR="${PUB_CACHE:-$HOME/.pub-cache}"
GRADLE_FILE=$(ls "$PUB_CACHE_DIR"/hosted/*/media_kit_libs_android_video-"$PKG_VER"/android/build.gradle 2>/dev/null | head -1)
if [ -z "$GRADLE_FILE" ]; then
  echo "[media_kit] 未找到包 build.gradle: media_kit_libs_android_video-$PKG_VER（请先执行 flutter pub get）" >&2
  exit 1
fi

# 3. 解析 filesToDownload 中每个 jar 的 url 与 md5
#    行格式: ["url": "...", "md5": "...", "destination": file("$buildDir/vX.Y.Z/...")]
JARS_URL=()
JARS_MD5=()
while IFS= read -r line; do
  u=$(printf '%s' "$line" | sed -E 's/.*"url": "([^"]+)".*/\1/')
  m=$(printf '%s' "$line" | sed -E 's/.*"md5": "([^"]+)".*/\1/')
  [ -n "$u" ] && [ -n "$m" ] || continue
  JARS_URL+=("$u")
  JARS_MD5+=("$m")
done < <(grep -E '"url":.*"md5":' "$GRADLE_FILE")

if [ "${#JARS_URL[@]}" -eq 0 ]; then
  echo "[media_kit] 未能从 build.gradle 解析下载列表: $GRADLE_FILE" >&2
  exit 1
fi

# 4. 从 url 提取 jar 版本号（releases/download/vX.Y.Z/...）
VERSION=$(printf '%s' "${JARS_URL[0]}" | sed -E 's#.*/(v[0-9][0-9.]*)/[^/]+$#\1#')
if [ -z "$VERSION" ]; then
  echo "[media_kit] 未能从 url 解析版本号: ${JARS_URL[0]}" >&2
  exit 1
fi

# 5. 缓存目录
SRC_DIR="${MEDIA_KIT_JARS_DIR:-$HOME/.cache/media_kit-jars/$VERSION}"
DST_DIR="$ROOT_DIR/build/media_kit_libs_android_video/$VERSION"
mkdir -p "$SRC_DIR" "$DST_DIR"

downloaded=0
copied=0
skipped=0
i=0
for u in "${JARS_URL[@]}"; do
  f="${u##*/}"
  want="${JARS_MD5[$i]}"
  i=$((i + 1))
  src="$SRC_DIR/$f"
  dst="$DST_DIR/$f"

  # build 缓存已命中，直接跳过
  if [ -f "$dst" ]; then
    dst_md5=$(md5_of "$dst")
    if [ "$dst_md5" = "$want" ]; then
      skipped=$((skipped + 1))
      continue
    fi
  fi

  # 确保共享缓存有匹配的 jar，否则下载
  need_download=1
  if [ -f "$src" ]; then
    src_md5=$(md5_of "$src")
    [ "$src_md5" = "$want" ] && need_download=0
  fi
  if [ "$need_download" = "1" ]; then
    echo "[media_kit] 本地缓存缺失，开始下载: $f"
    curl -fSL --retry 3 --connect-timeout 15 -o "$src" "$u"
    src_md5=$(md5_of "$src")
    if [ "$src_md5" != "$want" ]; then
      echo "[media_kit] 下载后 MD5 不匹配: $f (got=$src_md5 want=$want)，已删除" >&2
      rm -f "$src"
      exit 1
    fi
    downloaded=$((downloaded + 1))
  fi

  cp -f "$src" "$dst"
  copied=$((copied + 1))
done

echo "[media_kit] 已就位: pkg=$PKG_VER ver=$VERSION downloaded=$downloaded copied=$copied skipped=$skipped -> $DST_DIR"
