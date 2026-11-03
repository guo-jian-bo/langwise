import 'package:animated_reorderable_list/src/builder/reorderable_animated_builder.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// 跨容器拖拽数据
///
/// 用于在拖拽项目跨越不同容器时传递必要的信息
class CrossContainerData {
  /// 源容器ID
  final dynamic fromContainerId;

  /// 在源容器中的索引
  final int fromIndex;

  /// 拖拽的项目数据
  final DragInfo dragInfo;

  CrossContainerData({
    required this.fromContainerId,
    required this.fromIndex,
    required this.dragInfo,
  });
}

/// 跨容器拖拽事件类型
enum CrossContainerEventType {
  /// 项目从一个容器拖动到另一个容器
  itemDraggedToContainer,

  /// 删除容器中的项目
  removeItemFromContainer,

  /// 添加项目到容器
  addItemToContainer,
}

/// 跨容器事件
class CrossContainerEvent {
  /// 事件类型
  final CrossContainerEventType type;

  /// 事件关联的数据
  final CrossContainerData data;

  CrossContainerEvent({
    required this.type,
    required this.data,
  });

  @override
  String toString() {
    return 'CrossContainerEvent(type: $type, fromId: ${data.fromContainerId}, fromIndex: ${data.fromIndex}})';
  }
}

/// 跨容器通信器
///
/// 简单封装 StreamController，用于容器间通信
class CrossContainerCommunicator {
  /// 事件流控制器
  final StreamController<CrossContainerEvent> _eventController = StreamController<CrossContainerEvent>.broadcast();

  /// 构造函数
  CrossContainerCommunicator();

  /// 获取事件流
  Stream<CrossContainerEvent> get events => _eventController.stream;

  /// 发送事件
  void sendEvent(CrossContainerEvent event) {
    if (kDebugMode) {
      print('CrossContainerCommunicator: Sending event ${event.type} from 容器ID: ${event.data.fromContainerId}');
      _eventController.add(event);
    }
  }

  /// 监听特定容器的事件
  /// 返回 StreamSubscription 对象，使用时需要保存并最终调用 cancel()
  StreamSubscription<CrossContainerEvent> listenToContainer({
    required dynamic containerId,
    required void Function(CrossContainerEvent event) onEvent,
  }) {
    return events.listen(onEvent);
  }

  /// 释放资源
  void dispose() {
    _eventController.close();
  }
}
