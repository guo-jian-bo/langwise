import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 本地通知插件配置
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        // iOS 10+ 通知代理设置
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// 在隐式 Flutter Engine 初始化后注册插件和原生通道。
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let orientationChannel = FlutterMethodChannel(
            name: "orientation_control",
            binaryMessenger: engineBridge.applicationRegistrar.messenger()
        )
        orientationChannel.setMethodCallHandler { [weak self] call, result in
            if call.method == "forceLandscape" {
                self?.forceLandscapeOrientation()
                result("success")
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// 强制更新界面方向为横左。
    private func forceLandscapeOrientation() {
        DispatchQueue.main.async {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeLeft))
            }
        }
    }
}
