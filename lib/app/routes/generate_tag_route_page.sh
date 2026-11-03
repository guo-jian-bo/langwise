#!/bin/bash

# =============================================================================
# 普通页面生成脚本（TagRoutes 多实例版）
# 参考 tag_routes_migration_prompt.md 与 generate_manage_page.sh
#
# 用法:
#   ./lib/app/routes/generate_tag_route_page.sh <page_name> [选项]
#
# 参数:
#   page_name       snake_case 页面名称，例如 about_us
#
# 选项:
#   -m, --module    父级模块目录（相对于 lib/app/modules），例如 user_center
#   -t, --title     面包屑/页面标题，例如 '关于我们'
#   -r, --route     路由常量名，默认由 page_name 转为 UPPER_SNAKE_CASE
#   -k, --path      路由 path，默认由 page_name 转为 kebab-case
#   --no-checklist  不写入 tag_routes_migration_checklist.md
#   -h, --help      显示帮助
#
# 示例:
#   ./lib/app/routes/generate_tag_route_page.sh about_us -m user_center -t '关于我们'
#   ./lib/app/routes/generate_tag_route_page.sh practice_questions_eval -t '做题结果'
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
MODULES_DIR="$PROJECT_ROOT/lib/app/modules"
APP_ROUTES_FILE="$SCRIPT_DIR/app_routes.dart"
APP_PAGES_FILE="$SCRIPT_DIR/app_pages.dart"
TAG_ROUTES_FILE="$SCRIPT_DIR/tag_routes.dart"
CHECKLIST_FILE="$SCRIPT_DIR/tag_routes_migration_checklist.md"

to_pascal_case() {
  echo "$1" | awk -F'_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' OFS=''
}

to_upper_snake() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

to_kebab_case() {
  echo "$1" | tr '_' '-'
}

usage() {
  echo ""
  echo -e "${CYAN}普通页面生成脚本${NC} - 生成 TagRoutes 多实例页面三件套"
  echo ""
  echo "用法: $0 <page_name> [选项]"
  echo ""
  echo "参数:"
  echo "  page_name           snake_case 页面名称，例如 about_us"
  echo ""
  echo "选项:"
  echo "  -m, --module DIR    父级模块目录（相对于 lib/app/modules），例如 user_center"
  echo "  -t, --title TEXT    页面标题，例如 '关于我们'"
  echo "  -r, --route NAME    路由常量名，默认由 page_name 自动生成"
  echo "  -k, --path PATH     路由 path，默认由 page_name 自动生成，例如 /about-us"
  echo "  --no-checklist      不写入 tag_routes_migration_checklist.md"
  echo "  -h, --help          显示帮助"
  echo ""
  echo "示例:"
  echo "  $0 about_us -m user_center -t '关于我们'"
  echo "  $0 official_course_details_target -m official_course_details -t '官方课程目标'"
  echo ""
  echo "生成的文件:"
  echo "  lib/app/modules/[module/]<page>/controllers/<page>_controller.dart"
  echo "  lib/app/modules/[module/]<page>/bindings/<page>_binding.dart"
  echo "  lib/app/modules/[module/]<page>/views/<page>_view.dart"
  echo ""
  echo "自动接入文件:"
  echo "  lib/app/routes/app_routes.dart"
  echo "  lib/app/routes/tag_routes.dart"
  echo "  lib/app/routes/app_pages.dart"
  echo "  lib/app/routes/tag_routes_migration_checklist.md"
  echo ""
  exit 0
}

append_import_before() {
  local file_path="$1"
  local import_line="$2"
  local anchor="$3"

  if grep -Fq "$import_line" "$file_path"; then
    return 0
  fi

  python3 - "$file_path" "$import_line" "$anchor" <<'PY'
from pathlib import Path
import sys

file_path = Path(sys.argv[1])
import_line = sys.argv[2]
anchor = sys.argv[3]
text = file_path.read_text()

if anchor not in text:
    raise SystemExit(f"Anchor not found in {file_path}: {anchor}")

text = text.replace(anchor, import_line + "\n" + anchor, 1)
file_path.write_text(text)
PY
}

insert_before_once() {
  local file_path="$1"
  local marker="$2"
  local block="$3"
  local duplicate_check="$4"

  if grep -Fq "$duplicate_check" "$file_path"; then
    return 0
  fi

  python3 - "$file_path" "$marker" "$block" <<'PY'
from pathlib import Path
import sys

file_path = Path(sys.argv[1])
marker = sys.argv[2]
block = sys.argv[3]
text = file_path.read_text()

if marker not in text:
    raise SystemExit(f"Marker not found in {file_path}: {marker}")

text = text.replace(marker, block + "\n" + marker, 1)
file_path.write_text(text)
PY
}

PAGE_NAME=""
MODULE_PATH=""
BREADCRUMB_TITLE=""
ROUTE_CONST=""
ROUTE_PATH=""
UPDATE_CHECKLIST=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--module)
      MODULE_PATH="$2"
      shift 2
      ;;
    -t|--title)
      BREADCRUMB_TITLE="$2"
      shift 2
      ;;
    -r|--route)
      ROUTE_CONST="$2"
      shift 2
      ;;
    -k|--path)
      ROUTE_PATH="$2"
      shift 2
      ;;
    --no-checklist)
      UPDATE_CHECKLIST=false
      shift
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
      else
        echo -e "${RED}错误: 不支持的多余参数: $1${NC}"
        usage
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
  echo -e "${YELLOW}提示: 未指定页面标题，使用默认值 '${BREADCRUMB_TITLE}'${NC}"
fi

if [ -z "$ROUTE_CONST" ]; then
  ROUTE_CONST="$(to_upper_snake "$PAGE_NAME")"
fi

if [ -z "$ROUTE_PATH" ]; then
  ROUTE_PATH="/$(to_kebab_case "$PAGE_NAME")"
fi

if [[ "$ROUTE_PATH" != /* ]]; then
  ROUTE_PATH="/$ROUTE_PATH"
fi

PASCAL_NAME="$(to_pascal_case "$PAGE_NAME")"
VIEW_CLASS="${PASCAL_NAME}View"
CONTROLLER_CLASS="${PASCAL_NAME}Controller"
BINDING_CLASS="${PASCAL_NAME}Binding"

if [ -n "$MODULE_PATH" ]; then
  PAGE_DIR="$MODULES_DIR/$MODULE_PATH/$PAGE_NAME"
  MODULE_VIEW_IMPORT="../modules/$MODULE_PATH/$PAGE_NAME/views/${PAGE_NAME}_view.dart"
  MODULE_BINDING_IMPORT="../modules/$MODULE_PATH/$PAGE_NAME/bindings/${PAGE_NAME}_binding.dart"
  PARENT_DIR="$MODULES_DIR/$MODULE_PATH"
else
  PAGE_DIR="$MODULES_DIR/$PAGE_NAME"
  MODULE_VIEW_IMPORT="../modules/$PAGE_NAME/views/${PAGE_NAME}_view.dart"
  MODULE_BINDING_IMPORT="../modules/$PAGE_NAME/bindings/${PAGE_NAME}_binding.dart"
  PARENT_DIR="$MODULES_DIR"
fi

CONTROLLERS_DIR="$PAGE_DIR/controllers"
BINDINGS_DIR="$PAGE_DIR/bindings"
VIEWS_DIR="$PAGE_DIR/views"

CONTROLLER_FILE="$CONTROLLERS_DIR/${PAGE_NAME}_controller.dart"
BINDING_FILE="$BINDINGS_DIR/${PAGE_NAME}_binding.dart"
VIEW_FILE="$VIEWS_DIR/${PAGE_NAME}_view.dart"

VIEW_IMPORT_LINE="import '$MODULE_VIEW_IMPORT';"
BINDING_IMPORT_LINE="import '$MODULE_BINDING_IMPORT';"

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN} 页面信息${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "  页面名称(snake):  ${GREEN}${PAGE_NAME}${NC}"
echo -e "  类名(Pascal):     ${GREEN}${PASCAL_NAME}${NC}"
echo -e "  路由常量(UPPER):  ${GREEN}${ROUTE_CONST}${NC}"
echo -e "  路由路径(path):   ${GREEN}${ROUTE_PATH}${NC}"
echo -e "  页面标题:         ${GREEN}${BREADCRUMB_TITLE}${NC}"
if [ -n "$MODULE_PATH" ]; then
  echo -e "  模块目录:         ${GREEN}${MODULE_PATH}${NC}"
fi
echo ""

if [ -d "$PAGE_DIR" ]; then
  echo -e "${RED}错误: 页面目录已存在: $PAGE_DIR${NC}"
  exit 1
fi

if [ ! -d "$PARENT_DIR" ]; then
  echo -e "${RED}错误: 父级模块目录不存在: $PARENT_DIR${NC}"
  exit 1
fi

if grep -Eq "static const ${ROUTE_CONST}[[:space:]]*=" "$APP_ROUTES_FILE"; then
  echo -e "${RED}错误: Routes.${ROUTE_CONST} 已存在于 app_routes.dart${NC}"
  exit 1
fi

if grep -Fq "Routes.${ROUTE_CONST}:" "$TAG_ROUTES_FILE"; then
  echo -e "${RED}错误: Routes.${ROUTE_CONST} 已存在于 tag_routes.dart${NC}"
  exit 1
fi

mkdir -p "$CONTROLLERS_DIR" "$BINDINGS_DIR" "$VIEWS_DIR"

echo -e "${GREEN}✅ 创建目录${NC}"

cat > "$CONTROLLER_FILE" <<EOF
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

class ${CONTROLLER_CLASS} extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  ${CONTROLLER_CLASS}({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.${ROUTE_CONST};

  @override
  String get breadcrumbTitle => "${BREADCRUMB_TITLE}";

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
EOF

echo -e "${GREEN}✅ 生成 Controller:${NC} ${CONTROLLER_FILE#$PROJECT_ROOT/}"

cat > "$BINDING_FILE" <<EOF
import 'package:get/get.dart';

import '../controllers/${PAGE_NAME}_controller.dart';

class ${BINDING_CLASS} extends Bindings {
  final String tagText;
  ${BINDING_CLASS}({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<${CONTROLLER_CLASS}>(
      () => ${CONTROLLER_CLASS}(tagText: tagText),
      tag: tagText,
    );
  }
}
EOF

echo -e "${GREEN}✅ 生成 Binding:${NC} ${BINDING_FILE#$PROJECT_ROOT/}"

cat > "$VIEW_FILE" <<EOF
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/${PAGE_NAME}_binding.dart';
import '../controllers/${PAGE_NAME}_controller.dart';

class ${VIEW_CLASS} extends GetView<${CONTROLLER_CLASS}> {
  final String tagText;
  const ${VIEW_CLASS}({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ${VIEW_CLASS}(tagText: tag),
      binding: ${BINDING_CLASS}(tagText: tag),
      routeName: Routes.${ROUTE_CONST},
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: 1680.wMin,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40.wMin,
            left: 40.wMin,
            right: 40.wMin,
            bottom: 10.wMin + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            children: [
              const BackWidget(title: "${BREADCRUMB_TITLE}"),
              Expanded(
                child: Center(
                  child: Text(
                    "${BREADCRUMB_TITLE}",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

echo -e "${GREEN}✅ 生成 View:${NC} ${VIEW_FILE#$PROJECT_ROOT/}"

python3 - "$APP_ROUTES_FILE" "$ROUTE_CONST" "$ROUTE_PATH" <<'PY'
from pathlib import Path
import re
import sys

file_path = Path(sys.argv[1])
route_const = sys.argv[2]
route_path = sys.argv[3]
text = file_path.read_text()

route_line = f"  static const {route_const} = _Paths.{route_const};\n"
path_line = f"  static const {route_const} = '{route_path}';\n"

routes_pattern = r"(\n)(\})(\n\nabstract class _Paths \{)"
if not re.search(routes_pattern, text):
    raise SystemExit("Cannot find Routes class ending in app_routes.dart")
text = re.sub(routes_pattern, rf"\1{route_line}\2\3", text, count=1)

paths_anchor = "abstract class _Paths {\n  _Paths._();\n\n"
if paths_anchor not in text:
    raise SystemExit("Cannot find _Paths anchor in app_routes.dart")
text = text.replace(paths_anchor, paths_anchor + path_line + "\n", 1)

file_path.write_text(text)
PY

echo -e "${GREEN}✅ 配置 app_routes.dart:${NC} Routes.${ROUTE_CONST} + _Paths.${ROUTE_CONST}"

append_import_before "$TAG_ROUTES_FILE" "$VIEW_IMPORT_LINE" "import 'routes.dart';"

TAG_ROUTE_ENTRY="    Routes.${ROUTE_CONST}: ${VIEW_CLASS}.to,"
insert_before_once "$TAG_ROUTES_FILE" "  };" "$TAG_ROUTE_ENTRY" "$TAG_ROUTE_ENTRY"

echo -e "${GREEN}✅ 配置 tag_routes.dart:${NC} import + Routes.${ROUTE_CONST}: ${VIEW_CLASS}.to"

append_import_before "$APP_PAGES_FILE" "$VIEW_IMPORT_LINE" "import 'app_routes_code.dart';"
append_import_before "$APP_PAGES_FILE" "$BINDING_IMPORT_LINE" "import 'app_routes_code.dart';"

APP_PAGE_ENTRY=$(cat <<EOF
    GetPage(
      name: _Paths.${ROUTE_CONST},
      page: () => const ${VIEW_CLASS}(tagText: ''),
      binding: ${BINDING_CLASS}(tagText: ''),
    ),
EOF
)

insert_before_once "$APP_PAGES_FILE" "  ];" "$APP_PAGE_ENTRY" "name: _Paths.${ROUTE_CONST},"

echo -e "${GREEN}✅ 配置 app_pages.dart:${NC} import + GetPage"

if [ "$UPDATE_CHECKLIST" = true ] && [ -f "$CHECKLIST_FILE" ]; then
  if ! grep -Fq "Routes.${ROUTE_CONST}" "$CHECKLIST_FILE"; then
    if ! grep -Fq "## 脚本新增页面" "$CHECKLIST_FILE"; then
      cat >> "$CHECKLIST_FILE" <<EOF

---

## 脚本新增页面
- [x] Routes.${ROUTE_CONST}
EOF
    else
      echo "- [x] Routes.${ROUTE_CONST}" >> "$CHECKLIST_FILE"
    fi
    echo -e "${GREEN}✅ 配置 tag_routes_migration_checklist.md:${NC} - [x] Routes.${ROUTE_CONST}"
  else
    echo -e "${YELLOW}提示:${NC} checklist 已存在 Routes.${ROUTE_CONST}，跳过"
  fi
fi

chmod +x "$SCRIPT_DIR/generate_tag_route_page.sh"

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
echo "    - lib/app/routes/app_routes.dart"
echo "    - lib/app/routes/tag_routes.dart"
echo "    - lib/app/routes/app_pages.dart"
if [ "$UPDATE_CHECKLIST" = true ] && [ -f "$CHECKLIST_FILE" ]; then
  echo "    - lib/app/routes/tag_routes_migration_checklist.md"
fi
echo ""
