#!/bin/bash

# 代码质量检查脚本
# 基于项目全局规则的自动化代码复杂度检测
# 使用方法: ./scripts/code_quality_check.sh

set -e

echo "🔍 开始代码质量检查..."
echo "======================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查结果统计
ERROR_COUNT=0
WARNING_COUNT=0

# 1. Dart 分析器检查
echo -e "${BLUE}📊 运行 Dart 分析器...${NC}"
if flutter analyze --no-fatal-infos; then
    echo -e "${GREEN}✅ Dart 分析器检查通过${NC}"
else
    echo -e "${RED}❌ Dart 分析器发现问题${NC}"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi
echo ""

# 2. 代码格式检查
echo -e "${BLUE}🎨 检查代码格式...${NC}"
if dart format --set-exit-if-changed lib/ test/; then
    echo -e "${GREEN}✅ 代码格式检查通过${NC}"
else
    echo -e "${YELLOW}⚠️  代码格式需要调整，运行 'dart format .' 修复${NC}"
    WARNING_COUNT=$((WARNING_COUNT + 1))
fi
echo ""

# 3. 测试覆盖率检查
echo -e "${BLUE}🧪 运行测试并检查覆盖率...${NC}"
if flutter test --coverage; then
    echo -e "${GREEN}✅ 测试执行完成${NC}"
    
    # 检查覆盖率文件是否存在
    if [ -f "coverage/lcov.info" ]; then
        # 如果安装了 lcov，显示覆盖率摘要
        if command -v lcov &> /dev/null; then
            echo -e "${BLUE}📈 测试覆盖率报告:${NC}"
            lcov --summary coverage/lcov.info
        else
            echo -e "${YELLOW}💡 提示: 安装 lcov 可查看详细覆盖率报告 (brew install lcov)${NC}"
        fi
        
        # 生成 HTML 覆盖率报告
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            echo -e "${GREEN}📊 HTML覆盖率报告已生成: coverage/html/index.html${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  未生成覆盖率文件${NC}"
        WARNING_COUNT=$((WARNING_COUNT + 1))
    fi
else
    echo -e "${RED}❌ 测试执行失败${NC}"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi
echo ""

# 4. 代码复杂度检查（手动检查）
echo -e "${BLUE}🔬 代码复杂度检查指南:${NC}"
echo "根据项目全局规则第10章，请手动检查以下指标:"
echo "  • 圈复杂度: ≤ 8 (通过 flutter analyze 检测)"
echo "  • 函数长度: ≤ 15行 (不包括空行和注释)"
echo "  • 参数数量: ≤ 3个"
echo "  • 嵌套深度: ≤ 3层"
echo "  • 类长度: ≤ 300行"
echo ""

# 5. 查找可能的复杂度问题
echo -e "${BLUE}🔍 扫描潜在复杂度问题...${NC}"

# 查找长函数（简单的行数统计）
echo -e "${YELLOW}📏 检查可能过长的函数:${NC}"
find lib -name "*.dart" -exec grep -l "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*([^)]*)[[:space:]]*{" {} \; | while read file; do
    # 这是一个简化的检查，实际项目中可能需要更复杂的解析
    long_functions=$(awk '/^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\([^)]*\)[[:space:]]*\{/{start=NR; brace=1; next} brace>0{if(/\{/) brace++; if(/\}/) brace--; if(brace==0 && NR-start>20) print FILENAME ":" start "-" NR " (" (NR-start) " lines)"}' "$file" 2>/dev/null || true)
    if [ -n "$long_functions" ]; then
        echo "  $long_functions"
        WARNING_COUNT=$((WARNING_COUNT + 1))
    fi
done

# 查找深层嵌套
echo -e "${YELLOW}🔄 检查深层嵌套:${NC}"
find lib -name "*.dart" -exec grep -n "^[[:space:]]\{12,\}if\|^[[:space:]]\{12,\}for\|^[[:space:]]\{12,\}while" {} + | head -10

# 查找多参数函数
echo -e "${YELLOW}📝 检查多参数函数:${NC}"
find lib -name "*.dart" -exec grep -n "([^)]*,[^)]*,[^)]*,[^)]*," {} + | head -10

echo ""

# 6. 依赖检查
echo -e "${BLUE}📦 检查依赖...${NC}"
if flutter pub deps --style=compact; then
    echo -e "${GREEN}✅ 依赖检查完成${NC}"
else
    echo -e "${RED}❌ 依赖检查失败${NC}"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi
echo ""

# 7. 安全检查
echo -e "${BLUE}🔒 安全检查...${NC}"
echo "检查敏感信息泄露:"
if grep -r "password\|secret\|key\|token" lib/ --include="*.dart" | grep -v "// ignore" | head -5; then
    echo -e "${YELLOW}⚠️  发现可能的敏感信息，请检查是否为硬编码密钥${NC}"
    WARNING_COUNT=$((WARNING_COUNT + 1))
else
    echo -e "${GREEN}✅ 未发现明显的敏感信息泄露${NC}"
fi
echo ""

# 8. 生成质量报告
echo -e "${BLUE}📋 生成代码质量报告...${NC}"
REPORT_FILE="code_quality_report_$(date +%Y%m%d_%H%M%S).md"

cat > "$REPORT_FILE" << EOF
# 代码质量检查报告

**检查时间**: $(date)
**项目**: Langwise
**检查脚本**: code_quality_check.sh

## 检查结果摘要

- ❌ 错误数量: $ERROR_COUNT
- ⚠️ 警告数量: $WARNING_COUNT

## 代码复杂度标准（项目全局规则第10章）

| 指标 | 标准 | 检查方式 |
|------|------|----------|
| 圈复杂度 | ≤ 8 | flutter analyze |
| 函数长度 | ≤ 15行 | 手动检查 + 脚本扫描 |
| 参数数量 | ≤ 3个 | 手动检查 + 脚本扫描 |
| 嵌套深度 | ≤ 3层 | 手动检查 + 脚本扫描 |
| 类长度 | ≤ 300行 | 手动检查 |

## 改进建议

1. **高优先级重构**: 圈复杂度>10、函数长度>20行、嵌套深度>4层
2. **中优先级重构**: 参数数量>5个、类长度>500行、重复代码块
3. **低优先级优化**: 命名优化、注释完善、代码格式调整

## 设计模式建议

- **策略模式**: 替代复杂的if-else分支逻辑
- **状态机模式**: 管理复杂的状态转换逻辑
- **责任链模式**: 处理复杂的业务流程和条件判断
- **建造者模式**: 构建复杂对象，减少构造函数参数

## 下次检查

建议每周运行一次代码质量检查，持续改进代码质量。

EOF

echo -e "${GREEN}📊 质量报告已生成: $REPORT_FILE${NC}"
echo ""

# 9. 总结
echo "======================================"
echo -e "${BLUE}📊 代码质量检查完成${NC}"
echo -e "错误数量: ${RED}$ERROR_COUNT${NC}"
echo -e "警告数量: ${YELLOW}$WARNING_COUNT${NC}"

if [ $ERROR_COUNT -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 恭喜！代码质量检查全部通过！${NC}"
    exit 0
elif [ $ERROR_COUNT -eq 0 ]; then
    echo -e "${YELLOW}⚠️  有警告需要关注，但无严重错误${NC}"
    exit 0
else
    echo -e "${RED}❌ 发现错误，请修复后重新检查${NC}"
    exit 1
fi