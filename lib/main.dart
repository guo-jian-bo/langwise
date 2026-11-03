import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
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
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/show_big_resource_dialog.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:quiz_play/component/tips_video_widget.dart';

import 'app/modules/management/common/manage_sandbox_float_widget.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/song_mv_observers.dart';
import 'common/behavior/desktop_scroll_behavior.dart';
import 'common/behavior/route_transition_observer.dart';
import 'common/public_controller/manage_sandbox_controller.dart';
import 'common/public_controller/mv_player_global_float_controller.dart';
import 'common/stores/stores.dart';
import 'common/translations/language_translations.dart';
import 'common/values/values.dart';
import 'common/widgets/performance_overlay_widget.dart';
import 'config.dart';
import 'package:langwise/utils/audio_handler.dart';

import 'utils/dio_interceptors/dio_interceptor_utils.dart';
import 'utils/dio_interceptors/request_auth_interceptor.dart';

/// integration_test模式 集成测试模式下跳过会干扰测试进程的启动逻辑。
/// flutter test integration_test/app_test.dart -d macos --dart-define=INTEGRATION_TEST=true
/// flutter run -d macos --dart-define=INTEGRATION_TEST=true   
const bool kIsIntegrationTest = bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false);

void main() async {
  debugPrint('kIsIntegrationTest: $kIsIntegrationTest');
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      // release 下吞掉 debugPrint
    };
  }

  runZonedGuarded(
    () async{

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
        WidgetsFlutterBinding.ensureInitialized();
        await initApp();
        LanguageTranslations languageTranslations = await initLocalLanguage();
        String buildType = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
        runApp(MyApp(
          isLogin: UserStore.to.isLogin,
          buildType: buildType,
          languageTranslations: languageTranslations,
        ));
      }
    }, 
    (error, stackTrace){
      ErrorLogUtils.to.logError(error, stackTrace);
    },
    zoneSpecification: !kReleaseMode ? null : ZoneSpecification(
      print: (self, parent, zone, line) {
        // release 下吞掉 print
      },
    ),
  );
  
}

/// 初始化桌面端窗口
Future<void> initDesktop() async {
  if (!Platform.isLinux && !Platform.isWindows && !Platform.isMacOS) return;

  await windowManager.ensureInitialized();
  final WindowOptions windowOptions = const WindowOptions(
    center: true,
    minimumSize: Size(533, 300),
  );
  final completer = Completer<void>();

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    try {
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  });

  await completer.future;
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
  try {
    _logHttpInit("开始初始化HTTP环境");
    // await StorageUtil().remove(STORAGE_HTTP_ENV_KEY);

    String buildType = StorageUtil().getString(STORAGE_HTTP_ENV_KEY);
    if (buildType.isEmpty) buildType = HttpEnvKey.pro;
    await StorageUtil().setString(STORAGE_HTTP_ENV_KEY, buildType);
    _logHttpInit("当前HTTP环境:$buildType");

    final HttpEnv httpEnv = UserStore.to.getHttpEnv();
    _logHttpInit("HTTP配置读取完成，host:${httpEnv.host}");

    await LoginHelper().init(httpEnv);
    _logHttpInit("LoginHelper初始化完成");

    String deviceId = StorageUtil().getString(STORAGE_DEVICE_ID_KEY);
    final Uri? hostUri = Uri.tryParse(httpEnv.host);
    _logHttpInit(
      "初始化上下文 env:$buildType scheme:${hostUri?.scheme} host:${hostUri?.host} port:${hostUri?.hasPort == true ? hostUri?.port : 443} deviceIdEmpty:${deviceId.isEmpty} deviceIdLength:${deviceId.length} accessTokenEmpty:${UserStore.to.accessToken.isEmpty} refreshTokenEmpty:${UserStore.to.refreshToken.isEmpty} currentRoute:${Get.currentRoute}",
    );

    DioInterceptorUtils.reset();
    _logHttpInit("已重置WiseHttp拦截器");
    // WiseHttp(baseUrl: httpEnv.host).addInterceptor(await RequestAuthInterceptorUtils.auth());
    WiseHttp(baseUrl: httpEnv.host);
    DioInterceptorUtils.addInterceptor(RequestAuthInterceptor());
    DioInterceptorUtils.addInterceptor(SystemMaintenanceInterceptor());
    DioInterceptorUtils.addInterceptor(RequestsInterceptor());
    DioInterceptorUtils.addInterceptor(RetryCurrentInterceptor());
    DioInterceptorUtils.addInterceptor(CacheInterceptor());
    _logHttpInit("HTTP环境初始化完成");

    // 添加性能监控拦截器
    if (Get.isRegistered<PerformanceService>()) {
      WiseHttp().addInterceptor(PerformanceInterceptor());
    }

    DioInterceptorUtils.addInterceptor(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        print(object);
        LogManager().addLog(object);
      },
    ));
  } catch (e) {
    _logHttpInit("HTTP环境初始化失败 $e");
  }
}

void _logHttpInit(String message) {
  final log = "[HTTP][INIT] $message";
  print(log);
  ErrorLogUtils.to.logInfo(log);
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

Future<void> initCacheConfig() async {
  try {
    // 初始化缓存管理器
    final dir = await getApplicationCacheDirectory();
    await ResourceCacheManager.instance.init(
      basePath: '${dir.path}/resource_cache',
    );

    await AppDBUtils.instance.initialize();
  } catch (_) {}
}

Future<void> initApp() async {
  // WidgetsFlutterBinding.ensureInitialized();
  VideoPlayer.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft, // 横屏，设备左侧朝上。
    DeviceOrientation.landscapeRight // 横屏，设备右侧朝上。
  ]);

  try {
    await StorageUtil().init();
    initDesktop();
    if (!kIsIntegrationTest) initError();

    Refresh();

    // 启动时清理残存的临时文件
    // FileUtils.cleanupTempImages();
    // await CacheManagerUtils.instance.clearCache();

    await initCacheConfig();

    // 初始化课程更新状态管理服务
    Get.put(CourseUpdateStore(), permanent: true);

    // 初始化性能监控服务
    Get.put(PerformanceService(), permanent: true);

    Get.put<UserStore>(UserStore());

    /// 初始化全局悬浮窗
    Get.put(MvPlayerGlobalFloatController(), permanent: true);

    await AppBuildChannelUtils.init();

    /// 初始化管理端沙盒
    Get.put(ManageSandboxController(), permanent: true);

    await initHttp();

    TipsVideoWidget.expandHandler = (context, widget) {
      final ConfigController configController = Get.find<ConfigController>();
      final String localLang = configController.userSetting.value.localLang;
      return ShowBigResourceDialog.showVideo(
        context: context,
        relationVideo: EnKnowledgeEntityRelationVideo(
          videoUrl: widget.videoPath.trim(),
          startSeconds: widget.startSeconds,
          endSeconds: widget.endSeconds,
          ass: widget.ass,
          translate: widget.translateAss == null ? null : [LanguageText(lang: localLang, text: widget.translateAss)],
          firstImageUrl: widget.posterPath,
          isMute: widget.autoPlayMuted,
        ),
        translateLangCode: localLang,
      );
    };

    SequenceTipsVideoWidget.expandHandler = (context, widget) {
      final ConfigController configController = Get.find<ConfigController>();
      final String localLang = configController.userSetting.value.localLang;
      final double aspectRatio = widget.width.isFinite && widget.height.isFinite && widget.height > 0 ? widget.width / widget.height : 1;
      return ShowBigResourceDialog.showVideo(
        context: context,
        relationVideo: EnKnowledgeEntityRelationVideo(
          videoUrl: widget.videoPath.trim(),
          startSeconds: widget.startSeconds,
          endSeconds: widget.endSeconds,
          ass: widget.ass,
          translate: widget.translateAss == null ? null : [LanguageText(lang: localLang, text: widget.translateAss)],
          firstImageUrl: widget.posterPath,
          isMute: widget.autoPlayMuted,
        ),
        translateLangCode: localLang,
        aspectRatio: aspectRatio,
      );
    };

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
  } catch (e, stackTrace) {
    ErrorLogUtils.to.logError(e, stackTrace);
  }
}

class MyApp extends StatelessWidget {
  final String buildType;
  final bool isLogin;
  final LanguageTranslations languageTranslations;
  final NavigatorObserver? navigatorObserver;

  const MyApp({
    super.key,
    this.isLogin = false,
    this.navigatorObserver,
    required this.languageTranslations,
    required this.buildType,
  });

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
            splashColor: Colors.transparent,
            scaffoldBackgroundColor: const Color(0xFF0E0F0F),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Color(0xFF0EA5E9), // 设置光标颜色
              selectionColor: Color(0xFF0EA5E9).withValues(alpha: 0.6), // 设置文字选中时的背景色
              selectionHandleColor: Color(0xFF0EA5E9), // 设置选中时两端滑块（水滴状）的颜色
            ),
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
            MqttNotificationMessage.instance,
          ],
          routingCallback: (value) {
            PlayAudioUtils.instance.stopAll();
            TipsVideoManager.instance.stopAll();
          },
          builder: (context, child) {
            child = MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: MyAppBuildWidget(child: child ?? const SizedBox()),
            );

            if (buildType == HttpEnvKey.pro) {
              return botToastBuilder(context, child);
            }
            // 将子组件包裹在性能监控组件中
            child = PerformanceOverlayWidget(
              showInRelease: true,
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
                  const ManageSandboxFloatWidget(),
                  const MvPlayerGlobalFloatWidget(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
