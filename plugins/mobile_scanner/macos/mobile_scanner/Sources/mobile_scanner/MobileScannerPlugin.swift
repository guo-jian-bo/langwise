import AVFoundation
import FlutterMacOS
import Vision
import AppKit
import VideoToolbox

public class MobileScannerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let registry: FlutterTextureRegistry
    
    // Sink for publishing event changes
    var sink: FlutterEventSink!
    
    // Texture id of the camera preview
    var textureId: Int64!
    
    // Capture session of the camera
    var captureSession: AVCaptureSession?
    
    // The selected camera
    weak var device: AVCaptureDevice!
    
    // Image to be sent to the texture
    var latestBuffer: CVImageBuffer!
    
    // optional window to limit scan search
    var scanWindow: CGRect?
    
    /// Whether to return the input image with the barcode event.
    /// This is static to avoid accessing `self` in the `VNDetectBarcodesRequest` callback.
    private static var returnImage: Bool = false
    
    var detectionSpeed: DetectionSpeed = DetectionSpeed.noDuplicates
    
    var timeoutSeconds: Double = 0
    
    var symbologies:[VNBarcodeSymbology] = []
    
    var position = AVCaptureDevice.Position.back
    
    private var stopped: Bool {
        return device == nil || captureSession == nil
    }
    
    private var paused: Bool {
        return stopped && textureId != nil
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = MobileScannerPlugin(registrar.textures)
        let method = FlutterMethodChannel(name:
                                            "dev.steenbakker.mobile_scanner/scanner/method", binaryMessenger: registrar.messenger)
        let event = FlutterEventChannel(name:
                                            "dev.steenbakker.mobile_scanner/scanner/event", binaryMessenger: registrar.messenger)
        registrar.addMethodCallDelegate(instance, channel: method)
        event.setStreamHandler(instance)
    }
    
    init(_ registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("原生method: \(call.method),arguments:\(String(describing: call.arguments))")
        switch call.method {
        case "state":
            checkPermission(call, result)
        case "request":
            requestPermission(call, result)
        case "getCameras":
            getCameras(call, result)
        case "start":
            start(call, result)
        case "toggleTorch":
            toggleTorch(result)
        case "setScale":
            setScale(call, result)
        case "resetScale":
            resetScale(call, result)
        case "pause":
            pause(result)
        case "stop":
            stop(result)
        case "updateScanWindow":
            updateScanWindow(call, result)
        case "analyzeImage":
            analyzeImage(call, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // FlutterStreamHandler
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    // FlutterStreamHandler
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
    
    // FlutterTexture
    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if latestBuffer == nil {
            return nil
        }
        return Unmanaged<CVPixelBuffer>.passRetained(latestBuffer)
    }
    
    var nextScanTime = 0.0
    var imagesCurrentlyBeingProcessed = false
    
    // Gets called when a new image is added to the buffer
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Ignore invalid texture id.
        if textureId == nil {
            return
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        latestBuffer = imageBuffer
        registry.textureFrameAvailable(textureId)
        
        let currentTime = Date().timeIntervalSince1970
        let eligibleForScan = currentTime > nextScanTime && !imagesCurrentlyBeingProcessed
        if ((detectionSpeed == DetectionSpeed.normal || detectionSpeed == DetectionSpeed.noDuplicates) && eligibleForScan || detectionSpeed == DetectionSpeed.unrestricted) {
            nextScanTime = currentTime + timeoutSeconds
            imagesCurrentlyBeingProcessed = true
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if self!.latestBuffer == nil {
                    return
                }
                var cgImage: CGImage?
                VTCreateCGImageFromCVPixelBuffer(self!.latestBuffer, options: nil, imageOut: &cgImage)
                let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!)
                do {
                    let barcodeRequest: VNDetectBarcodesRequest = VNDetectBarcodesRequest(completionHandler: { [weak self] (request, error) in
                        self?.imagesCurrentlyBeingProcessed = false
                        
                        if error != nil {
                            DispatchQueue.main.async {
                                self?.sink?(FlutterError(
                                    code: MobileScannerErrorCodes.BARCODE_ERROR,
                                    message: error?.localizedDescription, details: nil))
                            }
                            return
                        }
                        
                        guard let results: [VNBarcodeObservation] = request.results as? [VNBarcodeObservation] else {
                            return
                        }
                        
                        if results.isEmpty {
                            return
                        }
                        
                        let barcodes: [VNBarcodeObservation] = results.compactMap({ barcode in
                            // If there is a scan window, check if the barcode is within said scan window.
                            //                            if self?.scanWindow != nil && cgImage != nil && !(self?.isBarCodeInScanWindow(self!.scanWindow!, barcode, cgImage!) ?? false) {
                            //                                return nil
                            //                            }
                            
                            return barcode
                        })
                        
                        print("--实时捕捉barcodes1:\(barcodes)---")
                        
                        DispatchQueue.main.async {
                            guard let image = cgImage else {
                                self?.sink?([
                                    "name": "barcode",
                                    "data": barcodes.map({ $0.toMap() }),
                                ])
                                return
                            }
                            
                            
                            // The image dimensions are always provided.
                            // The image bytes are only non-null when `returnImage` is true.
                            let imageData: [String: Any?] = [
                                "bytes": MobileScannerPlugin.returnImage ? FlutterStandardTypedData(bytes: image.jpegData(compressionQuality: 0.8)!) : nil,
                                "width": Double(image.width),
                                "height": Double(image.height),
                            ]
                            
                            self?.sink?([
                                "name": "barcode",
                                "data": barcodes.map({ $0.toMap() }),
                                "image": imageData,
                            ])
                        }
                    })
                    
                    if self?.symbologies.isEmpty == false {
                        // Add the symbologies the user wishes to support.
                        barcodeRequest.symbologies = self!.symbologies
                    }
                    
                    try imageRequestHandler.perform([barcodeRequest])
                } catch let error {
                    DispatchQueue.main.async {
                        self?.sink?(FlutterError(
                            code: MobileScannerErrorCodes.BARCODE_ERROR,
                            message: error.localizedDescription, details: nil))
                    }
                }
            }
        }
    }
    
    // 可用相机列表
    public func getCameras(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let devices = AVCaptureDevice.devices(for: .video)
        let cameras = devices.map { device in
            return [
                "id": device.uniqueID,
                "name": device.localizedName,
                "position": positionToString(device.position)
            ]
        }
        result(cameras)
    }
    
    // 检查相机权限
    func checkPermission(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined:
                result(0)
            case .authorized:
                result(1)
            default:
                result(2)
            }
        } else {
            result(1)
        }
    }
    
    // 请求权限
    func requestPermission(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if #available(macOS 10.14, *) {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { result($0) })
        } else {
            result(0)
        }
    }
    
    // 更新矩形区域
    func updateScanWindow(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let argReader = MapArgumentReader(call.arguments as? [String: Any])
        let scanWindowData: Array? = argReader.floatArray(key: "rect")
        
        if (scanWindowData == nil) {
            result(nil)
            return
        }
        
        /*
         dart 传入的rect对象根据fromLTRB方法, 由left、top、right、bottom参数决定的的矩形区域
         所以转换成iOS的坐标系CGRect算法是
         left: 对应iOS的x
         top: 对应iOS的y
         right: 对应iOS的水平方向最大x
         bottom: 对应iOS的水平方向最大y
         */
        let minX = scanWindowData![0]
        let minY = scanWindowData![1]
        
        /*
         水平方向最大x-minx 等于iOS的矩形区域宽度
         垂直方向最大y-minY 等于iOS的矩形区域高度
         */
        let width = scanWindowData![2]  - minX
        let height = scanWindowData![3] - minY
        
        scanWindow = CGRect(x: minX, y: minY, width: width, height: height)
        result(nil)
    }
    
    func isBarCodeInScanWindow(_ scanWindow: CGRect, _ barcode: VNBarcodeObservation, _ inputImage: CGImage) -> Bool {
        // 图片尺寸
        let imageWidth = CGFloat(inputImage.width)
        let imageHeight = CGFloat(inputImage.height)
        
        // 扫描到的区域坐标
        let barcodeminX = barcode.boundingBox.minX
        let barcodeminY = barcode.boundingBox.minY
        let barcodewidth = (barcode.boundingBox.maxX - barcodeminX)
        let barcodeheight = (barcode.boundingBox.maxY - barcodeminY)
        let barcodeBox = CGRect(x: barcodeminX * imageWidth , y: barcodeminY * imageHeight, width: barcodewidth * imageWidth, height: barcodeheight * imageHeight)
        
        print("-isBarCodeInScanWindow, barcode:\(barcode.boundingBox), barcodeBox:\(barcodeBox)---")
        print("--isBarCodeInScanWindow, 图片尺寸imageWidth:\(imageWidth),imageHeight:\(imageHeight)---")
        // 自定义识别区域坐标
        let minX = scanWindow.minX * imageWidth
        let minY = scanWindow.minY * imageHeight
        let width = scanWindow.width * imageWidth
        let height = scanWindow.height * imageHeight
        print("--自定义识别区域isBarCodeInScanWindow, minX:\(minX), minY:\(minY),width:\(width),height:\(height)---")
        let scaledScanWindow = CGRect(x: minX, y: minY, width: width, height: height)
        return scaledScanWindow.contains(barcodeBox)
        //  return scaledScanWindow.contains(barcode.boundingBox)
    }
    
    //    func isBarCodeInScanWindow(_ scanWindow: CGRect, _ barcode: VNBarcodeObservation, _ inputImage: CVImageBuffer) -> Bool {
    //        let size = CVImageBufferGetEncodedSize(inputImage)
    //
    //        let imageWidth = size.width
    //        let imageHeight = size.height
    //        print("--isBarCodeInScanWindow, barcode:\(barcode.boundingBox)---")
    //        print("--isBarCodeInScanWindow, imageWidth:\(imageWidth),imageHeight:\(imageHeight)---")
    //
    //        let minX = scanWindow.minX * imageWidth
    //        let minY = scanWindow.minY * imageHeight
    //        let width = scanWindow.width * imageWidth
    //        let height = scanWindow.height * imageHeight
    //        print("--isBarCodeInScanWindow, minX:\(minX), minY:\(minY),width:\(width),height:\(height)---")
    //
    //        let scaledScanWindow = CGRect(x: minX, y: minY, width: width, height: height)
    //        return scaledScanWindow.contains(barcode.boundingBox)
    //    }
    
    func start(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if (device != nil || captureSession != nil) {
            result(FlutterError(code: MobileScannerErrorCodes.ALREADY_STARTED_ERROR,
                                message: MobileScannerErrorCodes.ALREADY_STARTED_ERROR_MESSAGE,
                                details: nil))
            return
        }
        
        textureId = textureId ?? registry.register(self)
        captureSession = AVCaptureSession()
        
        let argReader = MapArgumentReader(call.arguments as? [String: Any])
        let torch:Bool = argReader.bool(key: "torch") ?? false
        let facing:Int = argReader.int(key: "facing") ?? 1
        let speed:Int = argReader.int(key: "speed") ?? 0
        let timeoutMs:Int = argReader.int(key: "timeout") ?? 0
        let deviceId: String? = argReader.string(key: "deviceId")
        symbologies = argReader.toSymbology()
        MobileScannerPlugin.returnImage = argReader.bool(key: "returnImage") ?? false
        
        timeoutSeconds = Double(timeoutMs) / 1000.0
        detectionSpeed = DetectionSpeed(rawValue: speed)!
        
        // Set the camera to use
        position = facing == 0 ? AVCaptureDevice.Position.front : .back
        
        // 打开相机
        if let deviceId = deviceId {
            guard let specifiedDevice = AVCaptureDevice(uniqueID: deviceId) else {
                result(FlutterError(code: "DEVICE_NOT_FOUND",
                                    message: "Camera \(deviceId) not available",
                                    details: nil))
                return
            }
            device = specifiedDevice
            print("选择的设备deviceId: \(String(describing: deviceId)),\(String(describing: device))")
        } else {
            let osVersion = ProcessInfo.processInfo.operatingSystemVersion
            print("系统版本: \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)")
            
            if ((Double(String("\((osVersion.majorVersion)).\(osVersion.minorVersion)")) ?? 15.1) >= 15.1) {
                // 10.14 的 API/适配外接摄像头
                device = AVCaptureDevice.devices(for: .video).first
                print("--原生初始化设备15.1, device:\(String(describing: device))---")
            } else {
                // 10.15+ 的 API
                if #available(macOS 10.15, *) {
                    // 10.15+ 的 API
                    device = AVCaptureDevice.DiscoverySession(
                        deviceTypes: [.builtInWideAngleCamera],
                        mediaType: .video,
                        position: position
                    ).devices.first
                    print("--原生初始化设备10.15, device:\(String(describing: device))---")
                } else {
                    device = AVCaptureDevice.devices(for: .video).first
                    print("--原生初始化设备, device:\(String(describing: device))---")
                }
            }
        }
        
        
        //         if #available(macOS 10.15, *) {
        //             // 10.15+ 的 API
        //             device = AVCaptureDevice.DiscoverySession(
        //                 deviceTypes: [.builtInWideAngleCamera],
        //                 mediaType: .video,
        //                 position: position
        //             ).devices.first
        //             print("--原生初始化设备10.15, device:\(device)---")
        //         } else if #available(macOS 10.14, *) {
        //             // 10.14 的 API
        //             device = AVCaptureDevice.devices(for: .video).first
        //             print("--原生初始化设备10.14, device:\(device)---")
        //         } else {
        //             // 更低版本的备用逻辑
        //             device = AVCaptureDevice.devices(for: .video).first
        //             print("--原生初始化设备（低于10.14）, device:\(device)---")
        //         }
        
        print("--原生初始化设备device:\(String(describing: device))---")
        
        if (device == nil) {
            result(FlutterError(code: MobileScannerErrorCodes.NO_CAMERA_ERROR,
                                message: MobileScannerErrorCodes.NO_CAMERA_ERROR_MESSAGE,
                                details: nil))
            return
        }
        
        // Turn on the torch if requested.
        if (torch) {
            self.turnTorchOn()
        }
        
        device.addObserver(self, forKeyPath: #keyPath(AVCaptureDevice.torchMode), options: .new, context: nil)
        captureSession!.beginConfiguration()
        
        // Add device input
        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession!.addInput(input)
        } catch {
            result(FlutterError(
                code: MobileScannerErrorCodes.CAMERA_ERROR,
                message: error.localizedDescription, details: nil))
            return
        }
        captureSession!.sessionPreset = AVCaptureSession.Preset.photo
        // Add video output.
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        captureSession!.addOutput(videoOutput)
        for connection in videoOutput.connections {
            if position == .front && connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
        captureSession!.commitConfiguration()
        // 开始捕捉
        captureSession!.startRunning()
        let dimensions = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
        let size = ["width": Double(dimensions.width), "height": Double(dimensions.height)]
        print("---原生尺寸size: \(size)---")
        let answer: [String : Any?] = [
            "textureId": textureId,
            "size": size,
            "currentTorchState": device.hasTorch ? device.torchMode.rawValue : -1,
        ]
        result(answer)
    }
    
    // TODO: this method should be removed when iOS and MacOS share their implementation.
    private func toggleTorchInternal() {
        guard let device = self.device else {
            return
        }
        
        if (!device.hasTorch) {
            return
        }
        
        if #available(macOS 15.0, *) {
            if(!device.isTorchAvailable) {
                return
            }
        }
        
        var newTorchMode: AVCaptureDevice.TorchMode = device.torchMode
        
        switch(device.torchMode) {
        case AVCaptureDevice.TorchMode.auto:
            if #available(macOS 10.15, *) {
                newTorchMode = device.isTorchActive ? AVCaptureDevice.TorchMode.off : AVCaptureDevice.TorchMode.on
            }
            break;
        case AVCaptureDevice.TorchMode.off:
            newTorchMode = AVCaptureDevice.TorchMode.on
            break;
        case AVCaptureDevice.TorchMode.on:
            newTorchMode = AVCaptureDevice.TorchMode.off
            break;
        default:
            return;
        }
        
        if (!device.isTorchModeSupported(newTorchMode) || device.torchMode == newTorchMode) {
            return;
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = newTorchMode
            device.unlockForConfiguration()
        } catch(_) {}
    }
    
    /// Turn the torch on.
    private func turnTorchOn() {
        guard let device = self.device else {
            return
        }
        
        if (!device.hasTorch || !device.isTorchModeSupported(.on) || device.torchMode == .on) {
            return
        }
        
        if #available(macOS 15.0, *) {
            if(!device.isTorchAvailable) {
                return
            }
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = .on
            device.unlockForConfiguration()
        } catch(_) {}
    }
    
    /// Reset the zoom scale.
    private func resetScale(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        // The zoom scale is not yet supported on MacOS.
        result(nil)
    }
    
    /// Set the zoom scale.
    private func setScale(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        // The zoom scale is not yet supported on MacOS.
        result(nil)
    }
    
    private func toggleTorch(_ result: @escaping FlutterResult) {
        self.toggleTorchInternal()
        result(nil)
    }
    
    // 暂停相机
    func pause(_ result: FlutterResult) {
        if (paused || stopped) {
            result(nil)
            
            return
        }
        releaseCamera()
        
        result(nil)
    }
    
    // 停止相机
    func stop(_ result: FlutterResult) {
        if (!paused && stopped) {
            result(nil)
            
            return
        }
        releaseCamera()
        releaseTexture()
        
        result(nil)
    }
    
    // 释放相机
    private func releaseCamera() {
        guard let captureSession = captureSession else {
            return
        }
        
        captureSession.stopRunning()
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
        device.removeObserver(self, forKeyPath: #keyPath(AVCaptureDevice.torchMode))
        
        latestBuffer = nil
        self.captureSession = nil
        device = nil
    }
    
    // 释放外接纹理
    private func releaseTexture() {
        registry.unregisterTexture(textureId)
        textureId = nil
    }
    
    // 分析图片
    func analyzeImage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let argReader = MapArgumentReader(call.arguments as? [String: Any])
        let symbologies:[VNBarcodeSymbology] = argReader.toSymbology()
        
        guard let filePath: String = argReader.string(key: "filePath") else {
            result(nil)
            return
        }
        
        let fileUrl = URL(fileURLWithPath: filePath)
        
        guard let ciImage = CIImage(contentsOf: fileUrl) else {
            result(nil)
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation.up, options: [:])
        
        do {
            let barcodeRequest: VNDetectBarcodesRequest = VNDetectBarcodesRequest(
                completionHandler: { [] (request, error) in
                    
                    print("开始捕捉,request:\(request)")
                    if error != nil {
                        DispatchQueue.main.async {
                            result(FlutterError(
                                code: MobileScannerErrorCodes.BARCODE_ERROR,
                                message: error?.localizedDescription, details: nil))
                        }
                        return
                    }
                    
                    guard let barcodes: [VNBarcodeObservation] = request.results as? [VNBarcodeObservation] else {
                        return
                    }
                    
                    if barcodes.isEmpty {
                        return
                    }
                    
                    result([
                        "name": "barcode",
                        "data": barcodes.map({ $0.toMap() }),
                    ])
                })
            
            if !symbologies.isEmpty {
                // Add the symbologies the user wishes to support.
                barcodeRequest.symbologies = symbologies
            }
            
            try imageRequestHandler.perform([barcodeRequest])
        } catch let error {
            DispatchQueue.main.async {
                result(FlutterError(
                    code: MobileScannerErrorCodes.BARCODE_ERROR,
                    message: error.localizedDescription, details: nil))
            }
        }
    }
    
    // Observer for torch state
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "torchMode":
            // Off = 0, On = 1, Auto = 2
            let state = change?[.newKey] as? Int
            let event: [String: Any?] = ["name": "torchState", "data": state]
            sink?(event)
        default:
            break
        }
    }
    
    // 摄像头位置转换
    private func positionToString(_ position: AVCaptureDevice.Position) -> String {
        switch position {
        case .back: return "back"
        case .front: return "front"
        case .unspecified: return "external"
        @unknown default: return "unknown"
        }
    }
}

class MapArgumentReader {
    let args: [String: Any]?
    
    init(_ args: [String: Any]?) {
        self.args = args
    }
    
    func string(key: String) -> String? {
        return args?[key] as? String
    }
    
    func int(key: String) -> Int? {
        return (args?[key] as? NSNumber)?.intValue
    }
    
    func bool(key: String) -> Bool? {
        return (args?[key] as? NSNumber)?.boolValue
    }
    
    func stringArray(key: String) -> [String]? {
        return args?[key] as? [String]
    }
    
    func toSymbology() -> [VNBarcodeSymbology] {
        guard let syms:[Int] = args?["formats"] as? [Int] else {
            return []
        }
        if(syms.contains(0)){
            return []
        }
        var barcodeFormats:[VNBarcodeSymbology] = []
        syms.forEach { id in
            if let bc:VNBarcodeSymbology = VNBarcodeSymbology.fromInt(id) {
                barcodeFormats.append(bc)
            }
        }
        return barcodeFormats
    }
    
    func floatArray(key: String) -> [CGFloat]? {
        return args?[key] as? [CGFloat]
    }
    
}

extension CGImage {
    public func jpegData(compressionQuality: CGFloat) -> Data? {
        let mutableData = CFDataCreateMutable(nil, 0)
        
        let formatHint: CFString
        
        if #available(macOS 11.0, *) {
            formatHint = UTType.jpeg.identifier as CFString
        } else {
            formatHint = kUTTypeJPEG
        }
        
        guard let destination = CGImageDestinationCreateWithData(mutableData!, formatHint, 1, nil) else {
            return nil
        }
        
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality,
        ]
        
        CGImageDestinationAddImage(destination, self, options)
        
        if !CGImageDestinationFinalize(destination) {
            return nil
        }
        
        return mutableData as Data?
    }
}

extension VNBarcodeObservation {
    private func distanceBetween(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }
    
    public func toMap() -> [String: Any?] {
        return [
            "corners": [
                ["x": topLeft.x, "y": topLeft.y],
                ["x": topRight.x, "y": topRight.y],
                ["x": bottomRight.x, "y": bottomRight.y],
                ["x": bottomLeft.x, "y": bottomLeft.y],
            ],
            "format": symbology.toInt ?? -1,
            "rawValue": payloadStringValue ?? "",
            "size": [
                "width": distanceBetween(topLeft, topRight),
                "height": distanceBetween(topLeft, bottomLeft),
            ],
        ]
    }
}

extension VNBarcodeSymbology {
    static func fromInt(_ mapValue:Int) -> VNBarcodeSymbology? {
        if #available(macOS 12.0, *) {
            if(mapValue == 8){
                return VNBarcodeSymbology.codabar
            }
        }
        switch(mapValue){
        case 1:
            return VNBarcodeSymbology.code128
        case 2:
            return VNBarcodeSymbology.code39
        case 4:
            return VNBarcodeSymbology.code93
        case 16:
            return VNBarcodeSymbology.dataMatrix
        case 32:
            return VNBarcodeSymbology.ean13
        case 64:
            return VNBarcodeSymbology.ean8
        case 128:
            return VNBarcodeSymbology.itf14
        case 256:
            return VNBarcodeSymbology.qr
        case 1024:
            return VNBarcodeSymbology.upce
        case 2048:
            return VNBarcodeSymbology.pdf417
        case 4096:
            return VNBarcodeSymbology.aztec
        default:
            return nil
        }
    }
    
    var toInt: Int? {
        if #available(macOS 12.0, *) {
            if(self == VNBarcodeSymbology.codabar){
                return 8
            }
        }
        switch(self){
        case VNBarcodeSymbology.code128:
            return 1
        case VNBarcodeSymbology.code39:
            return 2
        case VNBarcodeSymbology.code93:
            return 4
        case VNBarcodeSymbology.dataMatrix:
            return 16
        case VNBarcodeSymbology.ean13:
            return 32
        case VNBarcodeSymbology.ean8:
            return 64
        case VNBarcodeSymbology.itf14:
            return 128
        case VNBarcodeSymbology.qr:
            return 256
        case VNBarcodeSymbology.upce:
            return 1024
        case VNBarcodeSymbology.pdf417:
            return 2048
        case VNBarcodeSymbology.aztec:
            return 4096
        default:
            return -1
        }
    }
}
