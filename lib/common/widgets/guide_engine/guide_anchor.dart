import 'package:flutter/material.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';

class GuideAnchor extends StatefulWidget {
  final String id;
  final String route;
  final Widget child;
  final VoidCallback? action;

  const GuideAnchor({required this.id, required this.route, required this.child, this.action, Key? key}) : super(key: key);

  @override
  State<GuideAnchor> createState() => _GuideAnchorState();
}

class _GuideAnchorState extends State<GuideAnchor> {
  final GlobalKey _key = GlobalKey();
  final Object _actionToken = Object();

  @override
  void initState() {
    super.initState();
    if (widget.id.trim().isEmpty) return;
    GuideManager.instance.register(widget.id, _key);
    final action = widget.action;
    if (action != null) {
      GuideManager.instance.registerAction(widget.id, action, token: _actionToken);
    }
  }

  @override
  void dispose() {
    if (widget.id.trim().isNotEmpty) {
      GuideManager.instance.unregister(widget.id, _key);
      GuideManager.instance.unregisterAction(widget.id, token: _actionToken);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id.trim().isEmpty) {
      return widget.child;
    }
    return Container(
      key: _key,
      child: Listener(
        behavior: HitTestBehavior.deferToChild,
        onPointerDown: (_) {
          GuideManager.instance.onAnchorTapped(widget.id);
        },
        child: widget.child,
      ),
    );
  }
}