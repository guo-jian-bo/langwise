#!/bin/bash

# =============================================================================
# 管理端页面生成脚本
# 遵循 GETX_MULTI_INSTANCE_GUIDE.md 规范
#
# 用法:
#   ./generate_manage_page.sh <page_name> [选项]
#
# 参数:
#   page_name       snake_case 页面名称，例如 manage_topic
#
# 选项:
#   -p, --parent    父级目录（相对于 management/），例如 manage_content
#   -t, --title     面包屑标题，例如 '话题管理'
#   -h, --help      显示帮助
#
# 示例:
#   ./generate_manage_page.sh manage_topic -t '话题管理'
#   ./generate_manage_page.sh manage_topic -p manage_content -t '话题管理'
#   ./generate_manage_page.sh manage_topic -p manage_study -t '话题管理'
# =============================================================================

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
MANAGEMENT_DIR="$PROJECT_ROOT/lib/app/modules/management"

# ======================== 工具函数 ========================

# snake_case -> PascalCase
to_pascal_case() {
  echo "$1" | awk -F'_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' OFS=''
}

# snake_case -> UPPER_SNAKE_CASE
to_upper_snake() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

# snake_case -> kebab-case
to_kebab_case() {
  echo "$1" | tr '_' '-'
}

# 生成 n 个 ../ 的相对路径前缀
dots() {
  local count=$1
  local result=""
  for ((i=0; i<count; i++)); do
    result="../$result"
  done
  echo "$result"
}

# 显示帮助
usage() {
  echo ""
  echo -e "${CYAN}管理端页面生成脚本${NC} - 遵循 GETX_MULTI_INSTANCE_GUIDE.md 规范"
  echo ""
  echo "用法: $0 <page_name> [选项]"
  echo ""
  echo "参数:"
  echo "  page_name           snake_case 页面名称，例如 manage_topic"
  echo ""
  echo "选项:"
  echo "  -p, --parent DIR    父级目录（相对于 management/），例如 manage_content"
  echo "  -t, --title TEXT    面包屑标题，例如 '话题管理'"
  echo "  -h, --help          显示帮助"
  echo ""
  echo "示例:"
  echo "  $0 manage_topic -t '话题管理'"
  echo "  $0 manage_topic -p manage_content -t '话题管理'"
  echo ""
  echo "生成的文件:"
  echo "  management/[parent/]<name>/controllers/<name>_controller.dart"
  echo "  management/[parent/]<name>/bindings/<name>_binding.dart"
  echo "  management/[parent/]<name>/views/<name>_view.dart"
  echo ""
  exit 0
}

# ======================== 解析参数 ========================

PAGE_NAME=""
PARENT_DIR=""
BREADCRUMB_TITLE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--parent)
      PARENT_DIR="$2"
      shift 2
      ;;
    -t|--title)
      BREADCRUMB_TITLE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    -*)
      echo -e "${RED}未知选项: $1${NC}"
      usage
      ;;
    *)
      if [ -z "$PAGE_NAME" ]; then
        PAGE_NAME="$1"
      fi
      shift
      ;;
  esac
done

if [ -z "$PAGE_NAME" ]; then
  echo -e "${RED}错误: 必须指定 page_name${NC}"
  usage
fi

if [ -z "$BREADCRUMB_TITLE" ]; then
  BREADCRUMB_TITLE="$PAGE_NAME"
  echo -e "${YELLOW}提示: 未指定面包屑标题，使用默认值 '${BREADCRUMB_TITLE}'${NC}"
fi

# ======================== 计算命名 ========================

PASCAL_NAME=$(to_pascal_case "$PAGE_NAME")
UPPER_NAME=$(to_upper_snake "$PAGE_NAME")
KEBAB_NAME=$(to_kebab_case "$PAGE_NAME")

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN} 页面信息${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "  页面名称(snake):  ${GREEN}${PAGE_NAME}${NC}"
echo -e "  类名(Pascal):     ${GREEN}${PASCAL_NAME}${NC}"
echo -e "  路由常量(UPPER):  ${GREEN}${UPPER_NAME}${NC}"
echo -e "  路径(kebab):      ${GREEN}/${KEBAB_NAME}${NC}"
echo -e "  面包屑标题:       ${GREEN}${BREADCRUMB_TITLE}${NC}"
if [ -n "$PARENT_DIR" ]; then
  echo -e "  父级目录:         ${GREEN}${PARENT_DIR}${NC}"
fi
echo ""

# ======================== 计算路径 ========================

if [ -n "$PARENT_DIR" ]; then
  PAGE_DIR="$MANAGEMENT_DIR/$PARENT_DIR/$PAGE_NAME"
  # 从 controllers/views/bindings 目录到 management/ 需要几个 ../
  # management/[parent]/[name]/[subdir]/ -> 3个../到management
  MGMT_DEPTH=3
  # 从 controllers/views 目录到 app/ 需要几个 ../
  # management/[parent]/[name]/[subdir]/ -> management -> modules -> app = 5个../
  APP_DEPTH=5
else
  PAGE_DIR="$MANAGEMENT_DIR/$PAGE_NAME"
  # management/[name]/[subdir]/ -> 2个../到management
  MGMT_DEPTH=2
  # management/[name]/[subdir]/ -> management -> modules -> app = 4个../
  APP_DEPTH=4
fi

CONTROLLERS_DIR="$PAGE_DIR/controllers"
BINDINGS_DIR="$PAGE_DIR/bindings"
VIEWS_DIR="$PAGE_DIR/views"

# 相对路径
ROUTES_IMPORT="$(dots $APP_DEPTH)routes/routes.dart"
UTILS_IMPORT="$(dots $MGMT_DEPTH)utils/manage_breadcrumb_utils.dart"
SCAFFOLD_IMPORT="$(dots $MGMT_DEPTH)common/manage_scaffold.dart"

# ======================== 检查目录 ========================

if [ -d "$PAGE_DIR" ]; then
  echo -e "${RED}错误: 目录已存在: $PAGE_DIR${NC}"
  exit 1
fi

# 检查 management 目录是否存在
if [ ! -d "$MANAGEMENT_DIR" ]; then
  echo -e "${RED}错误: management 目录不存在: $MANAGEMENT_DIR${NC}"
  exit 1
fi

# 如果有父目录，检查是否存在
if [ -n "$PARENT_DIR" ] && [ ! -d "$MANAGEMENT_DIR/$PARENT_DIR" ]; then
  echo -e "${RED}错误: 父级目录不存在: $MANAGEMENT_DIR/$PARENT_DIR${NC}"
  exit 1
fi

# ======================== 创建目录 ========================

mkdir -p "$CONTROLLERS_DIR"
mkdir -p "$BINDINGS_DIR"
mkdir -p "$VIEWS_DIR"

echo -e "${GREEN}✅ 创建目录${NC}"

# ======================== 生成 Controller ========================

CONTROLLER_FILE="$CONTROLLERS_DIR/${PAGE_NAME}_controller.dart"
cat > "$CONTROLLER_FILE" << DART_EOF
import 'package:get/get.dart';

import '${ROUTES_IMPORT}';
import '${UTILS_IMPORT}';

class ${PASCAL_NAME}Controller extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ${PASCAL_NAME}Controller({required this.tag});

  @override
  String get breadcrumbRoute => Routes.${UPPER_NAME};

  @override
  String get breadcrumbTitle => '${BREADCRUMB_TITLE}';

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    // TODO: 初始化逻辑
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
DART_EOF

echo -e "${GREEN}✅ 生成 Controller:${NC} ${CONTROLLER_FILE#$PROJECT_ROOT/}"

# ======================== 生成 Binding ========================

BINDING_FILE="$BINDINGS_DIR/${PAGE_NAME}_binding.dart"
cat > "$BINDING_FILE" << DART_EOF
import 'package:get/get.dart';

import '../controllers/${PAGE_NAME}_controller.dart';

class ${PASCAL_NAME}Binding extends Bindings {
  final String tag;
  ${PASCAL_NAME}Binding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<${PASCAL_NAME}Controller>(
      () => ${PASCAL_NAME}Controller(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
DART_EOF

echo -e "${GREEN}✅ 生成 Binding:${NC} ${BINDING_FILE#$PROJECT_ROOT/}"

# ======================== 生成 View ========================

VIEW_FILE="$VIEWS_DIR/${PAGE_NAME}_view.dart"
cat > "$VIEW_FILE" << DART_EOF
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '${ROUTES_IMPORT}';
import '${SCAFFOLD_IMPORT}';
import '../bindings/${PAGE_NAME}_binding.dart';
import '../controllers/${PAGE_NAME}_controller.dart';

class ${PASCAL_NAME}View extends GetView<${PASCAL_NAME}Controller> {
  final String tagText;
  const ${PASCAL_NAME}View({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  /// 静态跳转方法（生成唯一 tag，支持多实例）
  static Future<T?> to<T>({dynamic arguments}) async {
    final tag = '\${Routes.${UPPER_NAME}}_\${DateTime.now().millisecondsSinceEpoch}';
    return await Get.to<T>(
      ${PASCAL_NAME}View(tagText: tag),
      binding: ${PASCAL_NAME}Binding(tag: tag),
      routeName: Routes.${UPPER_NAME},
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      body: Center(
        child: Text('${BREADCRUMB_TITLE}'),
      ),
    );
  }
}
DART_EOF

echo -e "${GREEN}✅ 生成 View:${NC} ${VIEW_FILE#$PROJECT_ROOT/}"

# ======================== 自动配置现有文件 ========================

APP_ROUTES_FILE="$PROJECT_ROOT/lib/app/routes/app_routes.dart"
REGISTRY_FILE="$MANAGEMENT_DIR/utils/manage_page_registry.dart"
APP_PAGES_FILE="$PROJECT_ROOT/lib/app/routes/app_pages.dart"

# 计算 ManagePageRegistry 中的 import 路径
if [ -n "$PARENT_DIR" ]; then
  REGISTRY_VIEW_IMPORT="../${PARENT_DIR}/${PAGE_NAME}/views/${PAGE_NAME}_view.dart"
  PAGES_VIEW_IMPORT="../modules/management/${PARENT_DIR}/${PAGE_NAME}/views/${PAGE_NAME}_view.dart"
  PAGES_BINDING_IMPORT="../modules/management/${PARENT_DIR}/${PAGE_NAME}/bindings/${PAGE_NAME}_binding.dart"
else
  REGISTRY_VIEW_IMPORT="../${PAGE_NAME}/views/${PAGE_NAME}_view.dart"
  PAGES_VIEW_IMPORT="../modules/management/${PAGE_NAME}/views/${PAGE_NAME}_view.dart"
  PAGES_BINDING_IMPORT="../modules/management/${PAGE_NAME}/bindings/${PAGE_NAME}_binding.dart"
fi

# ---- Step 1: 在 app_routes.dart 中添加 Routes 常量和 _Paths 常量 ----
# Step 1a: 在 Routes 类的 } 之前插入常量（第一个独立的 }）
awk -v route_line="  static const ${UPPER_NAME} = _Paths.MANAGEMENT + _Paths.${UPPER_NAME};" \
    '
    /^abstract class _Paths/ { routes_inserted = 1 }
    !routes_inserted && /^}/ {
      print route_line
      routes_inserted = 1
    }
    { print }
    ' "$APP_ROUTES_FILE" > "${APP_ROUTES_FILE}.tmp" && mv "${APP_ROUTES_FILE}.tmp" "$APP_ROUTES_FILE"

# Step 1b: 在 _Paths 类的 } 之前插入路径常量（文件最后一个 }）
awk -v path_line="  static const ${UPPER_NAME} = '/${KEBAB_NAME}';" \
    '
    { lines[NR] = $0; count = NR }
    END {
      for (i = 1; i <= count; i++) {
        if (i == count && lines[i] == "}") {
          print path_line
        }
        print lines[i]
      }
    }
    ' "$APP_ROUTES_FILE" > "${APP_ROUTES_FILE}.tmp" && mv "${APP_ROUTES_FILE}.tmp" "$APP_ROUTES_FILE"

echo -e "${GREEN}✅ 配置 app_routes.dart:${NC} Routes.${UPPER_NAME} + _Paths.${UPPER_NAME}"

# ---- Step 2: 在 manage_page_registry.dart 中注册 ----
awk -v import_line="import '${REGISTRY_VIEW_IMPORT}';" \
    -v registry_line="    Routes.${UPPER_NAME}: ${PASCAL_NAME}View.to," \
    '
    # 在 routes.dart import 之前插入新 import
    /import.*routes\/routes\.dart/ && !import_done {
      print import_line
      import_done = 1
    }
    # 在 }; 之前插入注册条目（只匹配 _pages Map 的结束）
    /^  };$/ && !reg_done {
      print registry_line
      reg_done = 1
    }
    { print }
    ' "$REGISTRY_FILE" > "${REGISTRY_FILE}.tmp" && mv "${REGISTRY_FILE}.tmp" "$REGISTRY_FILE"

echo -e "${GREEN}✅ 配置 manage_page_registry.dart:${NC} Routes.${UPPER_NAME}: ${PASCAL_NAME}View.to"

# ---- Step 3 已移除：不再自动写入 app_pages.dart ----
# 管理端页面使用 ManagePageRegistry.jumpTo() 跳转，不需要在 app_pages.dart 中注册命名路由

# ======================== 完成 ========================

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} ✅ 全部完成！已自动配置以下文件：${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "  ${BLUE}新建文件:${NC}"
echo "    - ${CONTROLLER_FILE#$PROJECT_ROOT/}"
echo "    - ${BINDING_FILE#$PROJECT_ROOT/}"
echo "    - ${VIEW_FILE#$PROJECT_ROOT/}"
echo ""
echo -e "  ${BLUE}已修改文件:${NC}"
echo "    - lib/app/routes/app_routes.dart  (Routes + _Paths 常量)"
echo "    - lib/app/modules/management/utils/manage_page_registry.dart  (import + 注册)"
echo ""
