import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:langwise/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  testWidgets('app starts successfully', (WidgetTester tester) async {
    final previousGetTestMode = Get.testMode;
    final previousErrorWidgetBuilder = ErrorWidget.builder;
    final previousFlutterErrorHandler = FlutterError.onError;
    final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
    addTearDown(() async {
      Get.testMode = previousGetTestMode;
      ErrorWidget.builder = previousErrorWidgetBuilder;
      FlutterError.onError = previousFlutterErrorHandler;
      PlatformDispatcher.instance.onError = previousPlatformErrorHandler;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.idle();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    Get.testMode = true;
    app.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
