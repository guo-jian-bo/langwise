import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let orientationChannel = FlutterMethodChannel(name: "orientation_control",
                                                      binaryMessenger: controller.binaryMessenger)
        orientationChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "forceLandscape" {
                self.forceLandscapeOrientation()
                result("success")
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        // 统一的插件注册
        GeneratedPluginRegistrant.register(with: self)
        
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

    //强制更新界面方向为横左
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
