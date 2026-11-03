import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:api/api.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart' show MvPlayerGlobalFloatWidget, Refresh;
import 'package:langwise/log_widget.dart';
import 'package:langwise/theme/dark_theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:login_module/http/http_env.dart';
import 'package:login_module/login_helper.dart';
import 'package:login_module/http/request_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resource_cache_package/resource_cache_package.dart';
import 'package:themed/themed.dart';

import 'package:ui_essentials/ui_essentials.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:umeng_apm_sdk/umeng_apm_sdk.dart';
import 'package:video_player/video_player.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wise_http/wise_http.dart';
import 'package:langwise/utils/performance_interceptor.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/song_mv_observers.dart';
import 'common/behavior/desktop_scroll_behavior.dart';
import 'common/behavior/route_transition_observer.dart';
import 'common/public_controller/mv_player_global_float_controller.dart';
import 'common/stores/stores.dart';
import 'common/translations/language_translations.dart';
import 'common/values/values.dart';
import 'common/widgets/performance_overlay_widget.dart';
import 'common/widgets/guide_engine/guide_manager.dart';
import 'config.dart';
import 'package:langwise/utils/audio_handler.dart';
import 'package:flutter_driver/driver_extension.dart';

/// * 仅在跑 flutter_driver 测试时启用：
/// * flutter drive --target=test_driver/app.dart --dart-define=ENABLE_DRIVER=true
const bool kEnableDriver = bool.fromEnvironment('ENABLE_DRIVER', defaultValue: false);


void main() async {
  if (kEnableDriver) {
    enableFlutterDriverExtension();
  }
  bool initSuccess = await UmengUtils.initApm(
    appRunner: (observer) async {
      await initApp();
      LanguageTranslations languageTranslations = await initLocalLanguage();
      String buildType = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
      return MyApp(
        isLogin: UserStore.to.isLogin,
        buildType: buildType,
        languageTranslations: languageTranslations,
        navigatorObserver: observer,
      );
    },
  );

  if (!initSuccess) {
    runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await initApp();
      LanguageTranslations languageTranslations = await initLocalLanguage();
      String buildType = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
      runApp(MyApp(
        isLogin: UserStore.to.isLogin,
        buildType: buildType,
        languageTranslations: languageTranslations,
      ));
    }, (error, stackTrace) {
      ErrorLogUtils.to.logError(error, stackTrace);
    });
  }
}

/// 初始化桌面端窗口
Future<void> initDesktop() async {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      center: true,
      minimumSize: Size(533, 300),
    );
    if (Platform.isMacOS) {
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.maximize();
        await windowManager.show();
        await windowManager.focus();
      });
    } else {
      bool agreePrivacy = StorageUtil().getBool(STORAGE_USER_AGREE_PRIVACY_KEY);
      if (agreePrivacy) {
        //已同意用户协议
        windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.maximize();
          await windowManager.show();
          await windowManager.focus();
        });
      } else {
        windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.show();
          await windowManager.focus();
        });
      }
    }
  }
}

/// 初始化语言
Future<LanguageTranslations> initLocalLanguage() async {
  Get.put(LanguageTranslations());
  final languageTranslations = LanguageTranslations();
  await languageTranslations.initLanguage();

  return languageTranslations;
}

/// 初始化http
Future<void> initHttp() async {
  // await StorageUtil().remove(STORAGE_HTTP_ENV_KEY);

  String buildType = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
  if (buildType.isEmpty) buildType = HttpEnvKey.pro;
  await StorageUtil().setString(STORAGE_HTTP_ENV_KEY, buildType);

  final HttpEnv httpEnv = UserStore.to.getHttpEnv();

  await LoginHelper().init(httpEnv);

  String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
  WiseHttp().reset();
  WiseHttp(baseUrl: httpEnv.host).addInterceptor(AuthInterceptor(
    config: AuthConfig(
      refreshUrl: Model.refreshToken,
      request: RefreshRequest(
        platform: LoginHelper().getPlatform(),
        platformName: LoginHelper().getPlatformName(),
        platformId: deviceId,
        refreshToken: UserStore.to.refreshToken,
      ),
      onFetchHeader: () async {
        var seconds = await GeneralUtil.getSyncDate();
        final signature = SignatureUtil.generateSignature(httpEnv.appId, httpEnv.appSecret, seconds);
        return {'APP-SIGNATURE': '$seconds;$signature'};
      },
      onFetchAccessToken: () => UserStore.to.accessToken,
      onAuthSucceed: (dynamic response) async {
        // 更新本地token
        final userInfo = ResponseEntity<AuthSmsLoginResponseEntity>.fromJson(
          response,
          fromJson: (json) => AuthSmsLoginResponseEntity.fromJson(json),
        );
        if (userInfo.data != null) {
          UserStore.to.setUserInfo(userInfo.data!);
        } else {
          await UserStore.to.clearUserInfo();
          if (Get.currentRoute != Routes.SIGN_IN_UP) {
            Get.offAllNamed(Routes.SIGN_IN_UP);
          }
        }
        
      },
      onAuthError: (err) async {
        LogManager().addLog(err);
        ErrorLogUtils.to.logError(err.message, err.stackTrace);
        await UserStore.to.clearUserInfo();
        if (Get.currentRoute != Routes.SIGN_IN_UP) {
          Get.offAllNamed(Routes.SIGN_IN_UP);
        }
      },
    ),
  ));
  // WiseHttp().addInterceptor(DnsInterceptor());
  WiseHttp().addInterceptor(SystemMaintenanceInterceptor());
  WiseHttp().addInterceptor(RequestsInterceptor());
  WiseHttp().addInterceptor(RetryCurrentInterceptor());
  WiseHttp().addInterceptor(CacheInterceptor());

  // 添加性能监控拦截器
  if (Get.isRegistered<PerformanceService>()) {
    WiseHttp().addInterceptor(PerformanceInterceptor());
  }

  WiseHttp().addInterceptor(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (object) {
      print(object);
      LogManager().addLog(object);
    },
  ));
  
}

void initError() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // 记录Widget错误到文件
    ErrorLogUtils.to.logError(details.exception, details.stack);
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text('Widget 崩溃了 ${details.exceptionAsString()}', style: const TextStyle(color: Colors.white)),
      ),
    );
  };
  // 捕获FlutterError
  FlutterError.onError = (FlutterErrorDetails details) {
    // 记录Flutter错误到文件
    ErrorLogUtils.to.logError(details.exception, details.stack);
    // 继续默认处理
    FlutterError.dumpErrorToConsole(details);
  };
  // 捕获未捕获的异步错误
  PlatformDispatcher.instance.onError = (error, stack) {
    // 记录未捕获的异步错误到文件
    ErrorLogUtils.to.logError(error, stack);
    // 返回true表示错误已处理
    return true;
  };
}

Future<void> initCacheConfig() async{

  /// 之前的缓存目录 清理掉这个
  String oldCachePath = "libCachedImageData";
  final oldCacheDir = await getTemporaryDirectory();
  final oldCacheDirPath = '${oldCacheDir.path}${Platform.pathSeparator}$oldCachePath';
  if (Directory(oldCacheDirPath).existsSync()) {
    Directory(oldCacheDirPath).delete(recursive: true);
  }

  // 初始化缓存管理器
  final dir = await getApplicationCacheDirectory();
  await ResourceCacheManager.instance.init(
    ResourceCacheConfig(
      basePath: '${dir.path}/resource_cache',
      enableLog: false,
    ),
  );

  await AppDBUtils.instance.initialize();
}

Future<void> initApp() async {
  // WidgetsFlutterBinding.ensureInitialized();
  VideoPlayer.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  initDesktop();
  initError();

  await StorageUtil().init();

  Refresh();

  // 启动时清理残存的临时文件
  FileUtils.cleanupTempImages();
  // await CacheManagerUtils.instance.clearCache();

  await initCacheConfig();

  // 初始化课程更新状态管理服务
  Get.put(CourseUpdateStore(), permanent: true);

  // 初始化性能监控服务
  Get.put(PerformanceService(), permanent: true);

  // LanguageTranslations languageTranslations = await initLocalLanguage();
  Get.put<UserStore>(UserStore());

  /// 初始化全局悬浮窗 
  Get.put(MvPlayerGlobalFloatController(), permanent: true);

  await initHttp();

  await AppLinksUtils.initAppLinks();

  // 配置音频会话，确保后台/锁屏播放（仅移动端需要）
  if (Platform.isIOS || Platform.isAndroid) {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  final handler = await AudioService.init(
    builder: () => NSAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'langwise.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidStopForegroundOnPause: false,
    ),
  );
  Get.put<NSAudioHandler>(handler, permanent: true);
}

class MyApp extends StatelessWidget {
  final String buildType;
  final bool isLogin;
  final LanguageTranslations languageTranslations;
  final NavigatorObserver? navigatorObserver;

  const MyApp({
    Key? key,
    this.isLogin = false,
    this.navigatorObserver,
    required this.languageTranslations,
    required this.buildType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    Size designSize = orientation == Orientation.landscape ? const Size(1920, 1080) : const Size(1080, 1920);
    ScreenUtils(designSize: designSize).initialize(context);
    AppConst.height = MediaQuery.of(context).size.height;
    AppConst.width = MediaQuery.of(context).size.width;
    final botToastBuilder = BotToastInit();

    return ScreenUtilInit(
      designSize: designSize,
      child: Themed(
        defaultTheme: darkTheme,
        child: GetMaterialApp(
          title: Config.appName,
          debugShowCheckedModeBanner: false,
          scrollBehavior: DesktopScrollBehavior(),
          defaultTransition: Transition.downToUp,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            // fontFamily: "LangWiseFont",
            // fontFamilyFallback: const ["LangWiseFont"],
            scaffoldBackgroundColor: const Color(0xFF0E0F0F),
          ),
          translations: languageTranslations,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Get.locale,
          fallbackLocale: languageTranslations.fallbackLocale,
          supportedLocales: languageTranslations.supportedLocales,
          getPages: AppPages.routes,
          initialRoute: AppPages.INITIAL,
          navigatorObservers: [
            BotToastNavigatorObserver(),
            navigatorObserver ?? ApmNavigatorObserver.singleInstance,
            AppPages.observer,
            SongMvObservers(),
            RouteTransitionObserver.instance,
          ],
          routingCallback: (value) {
            PlayAudioUtils.instance.stopAll();
          },
          builder: (context, child) {
            child = MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: MyAppBuildWidget(child: child ?? const SizedBox()),
            );

            child = WillPopScope(
              onWillPop: () async {
                return !GuideManager.instance.isGuiding;
              },
              child: child,
            );
            if (buildType == HttpEnvKey.pro) {
              return botToastBuilder(context, child);
            }
            // 将子组件包裹在性能监控组件中
            child = PerformanceOverlayWidget(
              showInRelease: false, // 只在调试模式显示
              child: child,
            );

            // 添加日志窗口
            child = FloatingLogWindow(child: child);

            return botToastBuilder(context, child);
          },
        ),
      ),
    );
  }
}

class MyAppBuildWidget extends StatelessWidget {
  final Widget child;
  const MyAppBuildWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) {

              return Stack(
                children: [
                  child,
                  const MvPlayerGlobalFloatWidget()
                ],
              );

              
            },
          ),
        ],
      ),
    );
  }
}
