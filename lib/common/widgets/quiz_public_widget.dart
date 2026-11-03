
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quiz_play/models/quiz_play_style.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'tap_scale_widget.dart';

class QuizPublicQuizWidget extends StatefulWidget {
  final double borderRadius;
  final QuizModel? data;
  final QuizPlayStyle? quizPlayStyle;
  final Color bgColor;
  const QuizPublicQuizWidget({
    super.key, 
    this.borderRadius = 5, 
    this.data,
    this.quizPlayStyle,
    this.bgColor = Colors.black,
  });

  @override
  State<QuizPublicQuizWidget> createState() => _QuizPublicQuizWidgetState();
}

class _QuizPublicQuizWidgetState extends State<QuizPublicQuizWidget> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver{
  /// 窗口是否正在发生改变
  bool windowIsResized = false;

  /// 组件是否可见
  StreamController<bool> isVisibleController = StreamController<bool>.broadcast();

  Timer? windowIsResizedTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if(Platform.isMacOS || Platform.isWindows || Platform.isLinux){
      if(!windowIsResized){
        windowIsResized = true;
        if(mounted) setState(() {});
        windowIsResizedTimer?.cancel();
        windowIsResizedTimer = null;
      }
      windowIsResizedTimer ??= Timer(const Duration(seconds: 1), () {
        windowIsResized = false;
        if(mounted) setState(() {});
      });
    }
    
  }


  @override
  void dispose() {
    windowIsResizedTimer?.cancel();
    isVisibleController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return TapScaleWidget(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: FittedBox(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width / (16 / 9),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: widget.bgColor,
                child: VisibilityDetector(
                  key: ValueKey("visibility_${widget.data?.hashCode}"),
                  onVisibilityChanged: (visibilityInfo) {
                    if(isVisibleController.isClosed) return;
                    isVisibleController.sink.add(visibilityInfo.visibleFraction != 0);
                  },
                  child: IgnorePointer(
                    ignoring: true,
                    child: Builder(
                      builder: (context) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            scrollbarTheme: ScrollbarThemeData(
                              thumbColor: WidgetStateProperty.all(Colors.transparent),
                              trackColor: WidgetStateProperty.all(Colors.transparent),
                            ),
                          ),
                          child: StreamBuilder(
                            initialData: true,
                            stream: isVisibleController.stream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return Container();
                              if (!(snapshot.data??false)) return Container();
                              return windowIsResized ? Container() : DefaultTextStyle(
                                style: const TextStyle(fontFamily: "LangWiseFont"),
                                child: Theme(
                                  data: ThemeData().copyWith(
                                    textTheme: ThemeData().textTheme.apply(fontFamily: "LangWiseFont"),
                                  ),
                                  child: QuizPlayWidget(
                                    key: ValueKey("quiz_${widget.data?.hashCode}"),
                                    data: widget.data,
                                    isDemo: true,
                                    quizPlayStyle: widget.quizPlayStyle,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

