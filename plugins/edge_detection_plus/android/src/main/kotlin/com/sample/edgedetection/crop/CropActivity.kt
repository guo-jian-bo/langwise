package com.sample.edgedetection.crop

import android.content.Intent
import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.ImageView

import com.sample.edgedetection.EdgeDetectionHandler
import com.sample.edgedetection.R
import com.sample.edgedetection.base.BaseActivity
import com.sample.edgedetection.view.PaperRectangle
import com.sample.edgedetection.SourceManager
import com.sample.edgedetection.processor.Corners
import com.sample.edgedetection.processor.TAG

import org.opencv.core.Point
import org.opencv.android.Utils
import org.opencv.core.Mat

import java.io.File
import java.io.FileOutputStream

import android.graphics.Bitmap
import android.graphics.Matrix

import com.sample.edgedetection.processor.cropPicture
import com.sample.edgedetection.processor.enhancePicture
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class CropActivity : BaseActivity(), ICropView.Proxy {

    // 原图
    private val picture: Mat? = SourceManager.pic

    // DTDO 顶点坐标/裁剪区域
    private val corners: Corners? = SourceManager.corners

    private var showMenuItems = false

    private lateinit var mPresenter: CropPresenter

    private lateinit var initialBundle: Bundle

    override fun prepare() {
        this.initialBundle = intent.getBundleExtra(EdgeDetectionHandler.INITIAL_BUNDLE) as Bundle
        this.title = initialBundle.getString(EdgeDetectionHandler.CROP_TITLE)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        findViewById<View>(R.id.paper).post {
            // 我们必须在post中初始化所有东西当视图被绘制出来我们有整个视图的实际高度和宽度
            // we have to initialize everything in post when the view has been drawn and we have the actual height and width of the whole view
            mPresenter.onViewsReady(
                findViewById<View>(R.id.paper).width,
                findViewById<View>(R.id.paper).height
            )
        }
    }

    override fun provideContentViewId(): Int = R.layout.activity_crop

    // 初始化Presenter
    override fun initPresenter() {
        // 获取bundle
        val initialBundle = intent.getBundleExtra(EdgeDetectionHandler.INITIAL_BUNDLE) as Bundle
        // 裁剪工具初始化(传入当前视图this)
        mPresenter = CropPresenter(this, initialBundle)

        // 底部按钮回调
        findViewById<ImageView>(R.id.crop).setOnClickListener {
            // 点击底部按钮
            Log.e(TAG, "Crop touched!")
            // 顶部控制面板不显示
            // changeMenuVisibility(false)

            // 获取矩形区域
            // getPaperRect().onCorners2Crop(corners, picture?.size(), paperWidth, paperHeight)

            /******图片处理*****/
//            // 将原图转成bitmap
//            val bitmap = Bitmap.createBitmap(
//                picture?.width() ?: 1080, picture?.height()
//                    ?: 1920, Bitmap.Config.ARGB_8888
//            )
//            Utils.matToBitmap(picture, bitmap, true)
//            // 获取image视图
//            getPaper().setImageBitmap(bitmap)
//
//            /******图片缓存路径*****/
//            // 获取图片缓存的路径
//            val file = File(initialBundle.getString(EdgeDetectionHandler.SAVE_TO) as String)
//            Log.i("TAG,点击底部按钮, save,file:", file.toString())
//            // 保存原图
//            val outStream = FileOutputStream(file)
//            //  压缩
//            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outStream)
//            outStream.flush()
//            outStream.close()
//            // 释放图片资源
//            //  bitmap.recycle()
//            Log.i(TAG, "😆😆原图Picture Saved")
//
//            // 获取矩形区域
//            var points: List<Point> = getPaperRect().getCornersDetected();
//            val intent = Intent()
//            var tlX: Double = (points[0]).x;
//            var tlY: Double = (points[0]).y;
//
//            var trX: Double = (points[1]).x;
//            var trY: Double = (points[1]).y;
//
//            var brX: Double = (points[2]).x;
//            var brY: Double = (points[2]).y;
//
//            var blX: Double = (points[3]).x;
//            var blY: Double = (points[3]).y;
//
//            Log.i(
//                TAG,
//                "😆😆CropActivity, 角点坐标POINTS tl: ${points[0]},tr:${points[1]}, br:${points[2]}, bl:${points[3]}"
//            )
//
//            intent.putExtra("tlX", tlX);
//            intent.putExtra("tlY", tlY);
//
//            intent.putExtra("trX", trX);
//            intent.putExtra("trY", trY);
//
//            intent.putExtra("brX", brX);
//            intent.putExtra("brY", brY);
//
//            intent.putExtra("blX", blX);
//            intent.putExtra("blY", blY);
//            // TODO 传给ScanActivity的onActivityResult
//            setResult(Activity.RESULT_OK, intent)
//            System.gc()
//            finish()

            mPresenter.crop()
            changeMenuVisibility(true)
            /*
             mPresenter.crop()
             changeMenuVisibility(true)
             */
        }
    }

    // 整个页面
    override fun getPaper(): ImageView = findViewById(R.id.paper)

    // 矩形区域
    override fun getPaperRect() = findViewById<PaperRectangle>(R.id.paper_rect)

    // 裁剪视图
    override fun getCroppedPaper() = findViewById<ImageView>(R.id.picture_cropped)

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.crop_activity_menu, menu)

        menu.setGroupVisible(R.id.enhance_group, showMenuItems)

        menu.findItem(R.id.rotation_image).isVisible = showMenuItems

        menu.findItem(R.id.gray).title =
            initialBundle.getString(EdgeDetectionHandler.CROP_BLACK_WHITE_TITLE) as String
        menu.findItem(R.id.reset).title =
            initialBundle.getString(EdgeDetectionHandler.CROP_RESET_TITLE) as String

        if (showMenuItems) {
            menu.findItem(R.id.action_label).isVisible = true
            findViewById<ImageView>(R.id.crop).visibility = View.GONE
        } else {
            menu.findItem(R.id.action_label).isVisible = false
            findViewById<ImageView>(R.id.crop).visibility = View.VISIBLE
        }

        return super.onCreateOptionsMenu(menu)
    }


    private fun changeMenuVisibility(showMenuItems: Boolean) {
        this.showMenuItems = showMenuItems
        invalidateOptionsMenu()
    }

    // handle button activities
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            android.R.id.home -> {
                onBackPressed()
                return true
            }

            R.id.action_label -> {
                Log.e(TAG, "Saved touched!")
                item.isEnabled = false
                mPresenter.save()
                setResult(Activity.RESULT_OK)
                System.gc()
                finish()

//                val intent = Intent()
//                var points: List<Point> = getPaperRect().getCorners2Crop();
//
//                var tlX: Double = (points[0]).x;
//                var tlY: Double = (points[0]).y;
//
//                var trX: Double = (points[1]).x;
//                var trY: Double = (points[1]).y;
//
//                var brX: Double = (points[2]).x;
//                var brY: Double = (points[2]).y;
//
//                var blX: Double = (points[3]).x;
//                var blY: Double = (points[3]).y;
//
//                Log.i("😆😆CropActivity传值tlX:", tlX.toString());
//
//                intent.putExtra("tlX", tlX);
//                intent.putExtra("tlY", tlY);
//
//                intent.putExtra("trX", trX);
//                intent.putExtra("trY", trY);
//
//                intent.putExtra("brX", brX);
//                intent.putExtra("brY", brY);
//
//                intent.putExtra("blX", blX);
//                intent.putExtra("blY", blY);
//                // TODO 传给ScanActivity的onActivityResult
//                setResult(Activity.RESULT_OK, intent)
//                System.gc()
//                finish()
                return true
            }

            R.id.rotation_image -> {
                Log.e(TAG, "Rotate touched!")
                mPresenter.rotate()
                return true
            }

            R.id.gray -> {
                Log.e(TAG, "Black White touched!")
                mPresenter.enhance()
                return true
            }

            R.id.reset -> {
                Log.e(TAG, "Reset touched!")
                mPresenter.reset()
                return true
            }

            else -> return super.onOptionsItemSelected(item)
        }
    }
}
