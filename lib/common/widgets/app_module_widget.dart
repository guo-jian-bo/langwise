import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/values.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 应用模块组件
///
/// 用于显示课程大纲中的模块项，包括名称显示和操作菜单
class AppModuleWidget extends StatelessWidget {
  /// 索引
  final int index;

  /// 所属的级别实体
  final LevelResponseEntity levelEntity;

  /// 模块实体
  final ModuleResponseEntity moduleEntity;

  final Widget addWidget;

  final bool isNeedMargin;

  /// 可选的选项菜单组件，外部传入
  final Widget? optionsMenu;

  /// 校对模块回调
  final Function(int index, LevelResponseEntity levelEntity, ModuleResponseEntity moduleEntity)? onCheckModule;

  /// 构造函数
  const AppModuleWidget(
      {Key? key,
      required this.index,
      required this.levelEntity,
      required this.moduleEntity,
      required this.addWidget,
      this.isNeedMargin = false,
      this.optionsMenu,
      this.onCheckModule})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      margin: isNeedMargin ? EdgeInsets.only(right: 32.wMin) : null,
      child: Row(
        children: [
          Container(
            width: 360.wMin,
            color: Colors.transparent,
            child: Column(
              children: [
                _buildModuleHeader(),
                Gaps.getHeight(16.wMin),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      child: CachedImageWidget(moduleEntity.coverUrl ?? '',
                          width: 360.wMin,
                          height: 506.wMin,
                          fit: BoxFit.contain,
                          borderRadius: BorderRadius.circular(8.wMin),
                          errorWidget: buildImage(
                            Assets.managerImageNotFound,
                            width: 360.wMin,
                            height: 506.wMin,
                            fit: BoxFit.contain,
                          )),
                    ),
                    _buildInfoLayer(),
                  ],
                ),
              ],
            ),
          ),
          addWidget,
        ],
      ),
    );
  }

  /// 构建模块头部
  Widget _buildModuleHeader() {
    return Container(
      height: 76.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceTertiary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              moduleEntity.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 28.ww,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 5.ww),
// 如果有外部传入的菜单组件则显示它
          if (optionsMenu != null) optionsMenu!,
        ],
      ),
    );
  }

  Widget _buildInfoLayer() {
    return Container(
      height: 56.wMax,
      padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin),
      margin: EdgeInsets.only(left: 10.wMin, right: 10.wMin, bottom: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cBlackAlpha70,
      ),
      child: _buildInfoChild(),
    );
  }

  Widget _buildInfoChild() {
    if (moduleEntity.bookAnalysisStatus.isUnresolved) {
      return TapScaleWidget(
          onTap: OptimizeUtils.noneThrottle(() {
            onCheckModule?.call(index, levelEntity, moduleEntity);
          }, 100),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "已拍${moduleEntity.pageCount ?? 0}张词汇",
                    style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 20.wMin, fontWeight: FontWeight.w500),
                  ),
                ),
                Flexible(
                  child: Text(
                    "去识别知识点",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.cSurfaceBrand, fontSize: 20.wMin, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ));
    } else if (moduleEntity.bookAnalysisStatus.isParsing) {
      return TapScaleWidget(
          onTap: OptimizeUtils.noneThrottle(() {
            onCheckModule?.call(index, levelEntity, moduleEntity);
          }, 100),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "正在识别知识点",
                    style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 20.wMin, fontWeight: FontWeight.w500),
                  ),
                ),
                Flexible(
                  child: Text(
                    "预计${moduleEntity.realEstimatedTime}分钟",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.cSurfaceBrand, fontSize: 20.wMin, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ));
    } else if (moduleEntity.bookAnalysisStatus.isPending) {
      return TapScaleWidget(
          onTap: OptimizeUtils.noneThrottle(() {
            onCheckModule?.call(index, levelEntity, moduleEntity);
          }, 100),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "已识别知识点",
                  style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 20.wMin, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin, top: 8.wMin, bottom: 8.wMin),
                  margin: EdgeInsets.only(left: 8.wMin, top: 10.wMin, bottom: 10.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.wMin),
                    color: AppTheme.cFeedbackInfoBorder,
                  ),
                  child: Text(
                    "${moduleEntity.pageCount ?? 0}",
                    style: TextStyle(color: AppTheme.cStaticPrimary, fontSize: 20.wMin, fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                Text(
                  "去校对",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppTheme.cSurfaceBrand, fontSize: 20.wMin, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ));
    }

    return TapScaleWidget(
        onTap: OptimizeUtils.noneThrottle(() {
          onCheckModule?.call(index, levelEntity, moduleEntity);
        }, 100),
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "已识别知识点",
                style: TextStyle(color: AppTheme.cTextPrimary, fontSize: 20.wMin, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: EdgeInsets.only(left: 16.wMin, right: 16.wMin, top: 8.wMin, bottom: 8.wMin),
                margin: EdgeInsets.only(left: 8.wMin, top: 10.wMin, bottom: 10.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cFeedbackInfoBorder,
                ),
                child: Text(
                  "${moduleEntity.analysisCount ?? 0}",
                  style: TextStyle(color: AppTheme.cStaticPrimary, fontSize: 20.wMin, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              Text(
                "去校对",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.cSurfaceBrand, fontSize: 20.wMin, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ));
  }
}
