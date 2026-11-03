package com.sample.edgedetection.crop

import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.Bundle
import android.util.Log
import android.view.View
import com.sample.edgedetection.EdgeDetectionHandler
import com.sample.edgedetection.SourceManager
import com.sample.edgedetection.processor.Corners
import com.sample.edgedetection.processor.TAG
import com.sample.edgedetection.processor.cropPicture
import com.sample.edgedetection.processor.enhancePicture
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.opencv.android.Utils
import org.opencv.core.Mat
import java.io.File
import java.io.FileOutputStream

class CropPresenter(
    private val iCropView: ICropView.Proxy,
    private val initialBundle: Bundle
) {
    // 原图
    private val picture: Mat? = SourceManager.pic

    // DTDO 顶点坐标/裁剪区域
    private val corners: Corners? = SourceManager.corners

    // 裁剪后的图片
    private var croppedPicture: Mat? = null
    private var enhancedPicture: Bitmap? = null
    // 裁剪后的图片Bitmap格式
    private var croppedBitmap: Bitmap? = null
    private var rotateBitmap: Bitmap? = null
    private var rotateBitmapDegree: Int = -90

    fun onViewsReady(paperWidth: Int, paperHeight: Int) {
        //  核心功能是根据提供的裁剪区域（corners）和图像尺寸（size），以及纸张尺寸（paperWidth 和 paperHeight），计算出裁剪区域的四个点，并调整它们的比例.
        iCropView.getPaperRect().onCorners2Crop(corners, picture?.size(), paperWidth, paperHeight)

        // 将原图转成bitmap
        val bitmap = Bitmap.createBitmap(
            picture?.width() ?: 1080, picture?.height()
                ?: 1920, Bitmap.Config.ARGB_8888
        )

        Utils.matToBitmap(picture, bitmap, true)

        // 获取image视图
        iCropView.getPaper().setImageBitmap(bitmap)
    }

    // 裁剪图片
    fun crop() {
        if (picture == null) {
            Log.i(TAG, "picture null?")
            return
        }

        if (croppedBitmap != null) {
            Log.i(TAG, "already cropped")
            return
        }

        // 获取裁剪后的图片
        Observable.create<Mat> {
            it.onNext(cropPicture(picture, iCropView.getPaperRect().getCorners2Crop()))
        }
            .subscribeOn(Schedulers.computation())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { pc ->
                Log.i(TAG, "cropped picture: $pc")
                // 裁剪后的图片
                croppedPicture = pc
                // 裁剪后的图片Bitmap格式
                croppedBitmap =
                    Bitmap.createBitmap(pc.width(), pc.height(), Bitmap.Config.ARGB_8888)
                Utils.matToBitmap(pc, croppedBitmap)

                iCropView.getCroppedPaper().setImageBitmap(croppedBitmap)
                iCropView.getPaper().visibility = View.GONE
                iCropView.getPaperRect().visibility = View.GONE
            }
    }

    // 增强
    fun enhance() {
        if (croppedBitmap == null) {
            Log.i(TAG, "picture null?")
            return
        }

        val imgToEnhance: Bitmap? = when {
            enhancedPicture != null -> {
                enhancedPicture
            }

            rotateBitmap != null -> {
                rotateBitmap
            }

            else -> {
                croppedBitmap
            }
        }

        Observable.create<Bitmap> {
            it.onNext(enhancePicture(imgToEnhance))
        }
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { pc ->

                enhancedPicture = pc
                rotateBitmap = enhancedPicture

                iCropView.getCroppedPaper().setImageBitmap(pc)
            }
    }

    fun reset() {
        if (croppedBitmap == null) {
            Log.i(TAG, "picture null?")
            return
        }
        rotateBitmap = croppedBitmap
        enhancedPicture = croppedBitmap

        iCropView.getCroppedPaper().setImageBitmap(croppedBitmap)
    }

    fun rotate() {
        if (croppedBitmap == null && enhancedPicture == null) {
            Log.i(TAG, "picture null?")
            return
        }

        if (enhancedPicture != null && rotateBitmap == null) {
            Log.i(TAG, "enhancedPicture ***** TRUE")
            rotateBitmap = enhancedPicture
        }

        if (rotateBitmap == null) {
            Log.i(TAG, "rotateBitmap ***** TRUE")
            rotateBitmap = croppedBitmap
        }

        Log.i(TAG, "ROTATE BITMAP DEGREE --> $rotateBitmapDegree")

        rotateBitmap = rotateBitmap?.rotateInt(rotateBitmapDegree)

        iCropView.getCroppedPaper().setImageBitmap(rotateBitmap)

        enhancedPicture = rotateBitmap
        croppedBitmap = croppedBitmap?.rotateInt(rotateBitmapDegree)
    }

    fun save() {
        val file = File(initialBundle.getString(EdgeDetectionHandler.SAVE_TO) as String)
        Log.i("TAG,save,file:", file.toString())

        val rotatePic = rotateBitmap
        if (null != rotatePic) {
            // 旋转后的图片
            val outStream = FileOutputStream(file)
            // 压缩
            rotatePic.compress(Bitmap.CompressFormat.JPEG, 100, outStream)
            outStream.flush()
            outStream.close()
            rotatePic.recycle()
            Log.i(TAG, "RotateBitmap Saved")
        } else {
            // first save enhanced picture, if picture is not enhanced, save cropped picture, otherwise nothing to do
            val pic = enhancedPicture

            if (null != pic) {
                // 增强后的图片
                val outStream = FileOutputStream(file)
                pic.compress(Bitmap.CompressFormat.JPEG, 100, outStream)
                outStream.flush()
                outStream.close()
                pic.recycle()
                Log.i(TAG, "EnhancedPicture Saved")
            } else {
                // 裁剪后的图片
                val cropPic = croppedBitmap
                if (null != cropPic) {
                    val outStream = FileOutputStream(file)
                    cropPic.compress(Bitmap.CompressFormat.JPEG, 100, outStream)
                    outStream.flush()
                    outStream.close()
                    cropPic.recycle()
                    Log.i(TAG, "CroppedBitmap Saved")
                }
            }
        }
    }

    // Extension function to rotate a bitmap
    private fun Bitmap.rotateInt(degree: Int): Bitmap {
        // Initialize a new matrix
        val matrix = Matrix()

        // Rotate the bitmap
        matrix.postRotate(degree.toFloat())

        // Resize the bitmap
        val scaledBitmap = Bitmap.createScaledBitmap(
            this,
            width,
            height,
            true
        )

        // Create and return the rotated bitmap
        return Bitmap.createBitmap(
            scaledBitmap,
            0,
            0,
            scaledBitmap.width,
            scaledBitmap.height,
            matrix,
            true
        )
    }
}
