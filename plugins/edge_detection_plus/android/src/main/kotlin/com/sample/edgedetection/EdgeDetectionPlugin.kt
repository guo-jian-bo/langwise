package com.sample.edgedetection

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.sample.edgedetection.scan.ScanActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlin.collections.mapOf

class EdgeDetectionPlugin : FlutterPlugin, ActivityAware {
    private var handler: EdgeDetectionHandler? = null

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        handler = EdgeDetectionHandler()
        val channel = MethodChannel(
            binding.binaryMessenger, "edge_detection"
        )
        channel.setMethodCallHandler(handler)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {}

    override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
        handler?.setActivityPluginBinding(activityPluginBinding)
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}
}

class EdgeDetectionHandler : MethodCallHandler, PluginRegistry.ActivityResultListener {
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var result: Result? = null
    private var methodCall: MethodCall? = null

    companion object {
        const val INITIAL_BUNDLE = "initial_bundle"
        const val FROM_GALLERY = "from_gallery"
        const val SAVE_TO = "save_to"
        const val CAN_USE_GALLERY = "can_use_gallery"
        const val SCAN_TITLE = "scan_title"
        const val CROP_TITLE = "crop_title"
        const val CROP_BLACK_WHITE_TITLE = "crop_black_white_title"
        const val CROP_RESET_TITLE = "crop_reset_title"
    }

    fun setActivityPluginBinding(activityPluginBinding: ActivityPluginBinding) {
        activityPluginBinding.addActivityResultListener(this)
        this.activityPluginBinding = activityPluginBinding
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            getActivity() == null -> {
                result.error(
                    "no_activity",
                    "edge_detection plugin requires a foreground activity.",
                    null
                )
                return
            }

            call.method.equals("edge_detect") -> {
                openCameraActivity(call, result)
            }

            call.method.equals("edge_detect_gallery") -> {
                openGalleryActivity(call, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getActivity(): Activity? {
        return activityPluginBinding?.activity
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
//        val value = data?.getStringExtra("crop") ?: ""
//        val aspectX = data?.getStringExtra("aspectX") ?: ""
//
//        val tlX = data?.getDoubleExtra("tlX", 0.0) ?: 0.0
//        val tlY = data?.getDoubleExtra("tlY", 0.0) ?: 0.0
//
//        val trX = data?.getDoubleExtra("trX", 0.0) ?: 0.0
//        val trY = data?.getDoubleExtra("trY", 0.0) ?: 0.0
//
//        val brX = data?.getDoubleExtra("brX", 0.0) ?: 0.0
//        val brY = data?.getDoubleExtra("brY", 0.0) ?: 0.0
//
//        val blX = data?.getDoubleExtra("blX", 0.0) ?: 0.0
//        val blY = data?.getDoubleExtra("blY", 0.0) ?: 0.0
//
//
//        Log.i("EdgeDetectionPlugin回调tlX:", tlX.toString());
//        Log.i("EdgeDetectionPlugin回调tlY:", tlY.toString());
//
//        Log.i("EdgeDetectionPlugin回调trX:", trX.toString());
//        Log.i("EdgeDetectionPlugin回调trY:", trY.toString());
//
//
//        Log.i("EdgeDetectionPlugin回调brX:", brX.toString());
//        Log.i("EdgeDetectionPlugin回调brY:", brY.toString());
//
//
//        Log.i("EdgeDetectionPlugin回调blX:", blX.toString());
//        Log.i("EdgeDetectionPlugin回调blY:", blY.toString());
//
//        // 返回矩形区域
//        val map = mutableMapOf(
//            "topLeft" to mutableMapOf("x" to tlX, "y" to tlY),
//            "topRight" to mutableMapOf("x" to trX, "y" to trY),
//            "bottomRight" to mutableMapOf("x" to brX, "y" to brY),
//            "bottomLeft" to mutableMapOf("x" to blX, "y" to blY)
//        )

        if (requestCode == REQUEST_CODE) {
            when (resultCode) {
                Activity.RESULT_OK -> {
//                    result?.success(map)
//                    clearMethodCallAndResult()
                    finishWithSuccess(true)
                }

                Activity.RESULT_CANCELED -> {
//                    result?.success(null)
//                    clearMethodCallAndResult()
                    finishWithSuccess(false)
                }

                ERROR_CODE -> {
                    finishWithError(
                        ERROR_CODE.toString(),
                        data?.getStringExtra("RESULT") ?: "ERROR"
                    )
                }
            }
            return true
        }
        return false
    }

    private fun openCameraActivity(call: MethodCall, result: Result) {
        if (!setPendingMethodCallAndResult(call, result)) {
            finishWithAlreadyActiveError()
            return
        }

        val initialIntent =
            Intent(Intent(getActivity()?.applicationContext, ScanActivity::class.java))

        val bundle = Bundle()
        bundle.putString(SAVE_TO, call.argument<String>(SAVE_TO) as String)
        bundle.putString(SCAN_TITLE, call.argument<String>(SCAN_TITLE) as String)
        bundle.putString(CROP_TITLE, call.argument<String>(CROP_TITLE) as String)
        bundle.putString(
            CROP_BLACK_WHITE_TITLE,
            call.argument<String>(CROP_BLACK_WHITE_TITLE) as String
        )
        bundle.putString(CROP_RESET_TITLE, call.argument<String>(CROP_RESET_TITLE) as String)
        bundle.putBoolean(CAN_USE_GALLERY, call.argument<Boolean>(CAN_USE_GALLERY) as Boolean)

        initialIntent.putExtra(INITIAL_BUNDLE, bundle)

        getActivity()?.startActivityForResult(initialIntent, REQUEST_CODE)
    }

    private fun openGalleryActivity(call: MethodCall, result: Result) {
        if (!setPendingMethodCallAndResult(call, result)) {
            finishWithAlreadyActiveError()
            return
        }
        val initialIntent =
            Intent(Intent(getActivity()?.applicationContext, ScanActivity::class.java))

        val bundle = Bundle()
        bundle.putString(SAVE_TO, call.argument<String>(SAVE_TO) as String)
        bundle.putString(CROP_TITLE, call.argument<String>(CROP_TITLE) as String)
        bundle.putString(
            CROP_BLACK_WHITE_TITLE,
            call.argument<String>(CROP_BLACK_WHITE_TITLE) as String
        )
        bundle.putString(CROP_RESET_TITLE, call.argument<String>(CROP_RESET_TITLE) as String)
        bundle.putBoolean(FROM_GALLERY, call.argument<Boolean>(FROM_GALLERY) as Boolean)

        initialIntent.putExtra(INITIAL_BUNDLE, bundle)

        getActivity()?.startActivityForResult(initialIntent, REQUEST_CODE)
    }

    private fun setPendingMethodCallAndResult(
        methodCall: MethodCall,
        result: Result
    ): Boolean {
        if (this.result != null) {
            return false
        }
        this.methodCall = methodCall
        this.result = result
        return true
    }

    private fun finishWithAlreadyActiveError() {
        finishWithError("already_active", "Edge detection is already active")
    }

    private fun finishWithError(errorCode: String, errorMessage: String) {
        result?.error(errorCode, errorMessage, null)
        clearMethodCallAndResult()
    }

    private fun finishWithSuccess(res: Boolean) {
        result?.success(res)
        clearMethodCallAndResult()
    }

    private fun clearMethodCallAndResult() {
        methodCall = null
        result = null
    }
}
