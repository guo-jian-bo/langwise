import 'package:appium_flutter_server/appium_flutter_server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/values/storage.dart';
import 'package:lib_common/common.dart';
import 'package:langwise/main.dart' as app;

void main() {

  initializeTest(
    callback: (WidgetTester tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await app.initApp();
      final languageTranslations = await app.initLocalLanguage();
      final String buildType = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
      await tester.pumpWidget(app.MyApp(
        isLogin: UserStore.to.isLogin,
        buildType: buildType,
        languageTranslations: languageTranslations,
      ));
      await tester.pumpAndSettle();
    },
  );
  
}