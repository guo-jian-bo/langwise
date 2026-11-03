package com.sample.edgedetection.view

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.util.Log
import android.view.MotionEvent
import android.view.View
import com.sample.edgedetection.processor.Corners
import com.sample.edgedetection.processor.TAG
import org.opencv.core.Point
import org.opencv.core.Size
import kotlin.math.abs


class PaperRectangle : View {
    constructor(context: Context) : super(context)
    constructor(context: Context, attributes: AttributeSet) : super(context, attributes)
    constructor(context: Context, attributes: AttributeSet, defTheme: Int) : super(
        context,
        attributes,
        defTheme
    )

    private val rectPaint = Paint()
    private val circlePaint = Paint()
    private var ratioX: Double = 1.0
    private var ratioY: Double = 1.0
    private var tl: Point = Point()
    private var tr: Point = Point()
    private var br: Point = Point()
    private var bl: Point = Point()
    private val path: Path = Path()
    private var point2Move = Point()
    private var cropMode = false
    private var latestDownX = 0.0F
    private var latestDownY = 0.0F

    init {
        rectPaint.color = Color.argb(128, 255, 255, 255)
        rectPaint.isAntiAlias = true
        rectPaint.isDither = true
        rectPaint.strokeWidth = 6F
        rectPaint.style = Paint.Style.FILL_AND_STROKE
        rectPaint.strokeJoin = Paint.Join.ROUND    // set the join to round you want
        rectPaint.strokeCap = Paint.Cap.ROUND      // set the paint cap to round too
        rectPaint.pathEffect = CornerPathEffect(10f)

        circlePaint.color = Color.WHITE
        circlePaint.isDither = true
        circlePaint.isAntiAlias = true
        circlePaint.strokeWidth = 4F
        circlePaint.style = Paint.Style.STROKE
    }

    // 在检测到图像的四个角点后，根据这些角点坐标调整视图中的裁剪区域（即矩形框)
    fun onCornersDetected(corners: Corners) {
        ratioX = corners.size.width.div(measuredWidth)
        ratioY = corners.size.height.div(measuredHeight)
        for (i in 0..3) {
            for (j in i + 1..3) {
                if (corners.corners[i]?.equals(corners.corners[j]) == true) {
                    resize()
                    path.reset()
                    path.close()
                    invalidate()
                    return
                }
            }
        }

        tl = corners.corners[0] ?: Point()
        tr = corners.corners[1] ?: Point()
        br = corners.corners[2] ?: Point()
        bl = corners.corners[3] ?: Point()

        Log.i(TAG, "角点坐标POINTS tl ------>  $tl corners")
        Log.i(TAG, "角点坐标POINTS tr ------>  $tr corners")
        Log.i(TAG, "角点坐标POINTS br ------>  $br corners")
        Log.i(TAG, "角点坐标POINTS bl ------>  $bl corners")

        resize()
        path.reset()
        path.moveTo(tl.x.toFloat(), tl.y.toFloat())
        path.lineTo(tr.x.toFloat(), tr.y.toFloat())
        path.lineTo(br.x.toFloat(), br.y.toFloat())
        path.lineTo(bl.x.toFloat(), bl.y.toFloat())
        path.close()
        invalidate()
    }

    // 返回顶点坐标
    fun getCornersDetected(): List<Point> {
        return listOf(tl, tr, br, bl)
    }

    fun onCornersNotDetected() {
        path.reset()
        invalidate()
    }

    /*
    核心功能是根据提供的裁剪区域（corners）和图像尺寸（size），以及纸张尺寸（paperWidth 和 paperHeight），计算出裁剪区域的四个点，并调整它们的比例.
    最后调用 resize() 和 movePoints() 方法来更新视图。
     */
    fun onCorners2Crop(corners: Corners?, size: Size?, paperWidth: Int, paperHeight: Int) {
        if (size == null) {
            return
        }

        // 设置为裁剪模式
        cropMode = true

        // 获取四个角点，如果 corners 为 null，则使用默认值
        tl = corners?.corners?.get(0) ?: Point(size.width * 0.1, size.height * 0.1)
        tr = corners?.corners?.get(1) ?: Point(size.width * 0.9, size.height * 0.1)
        br = corners?.corners?.get(2) ?: Point(size.width * 0.9, size.height * 0.9)
        bl = corners?.corners?.get(3) ?: Point(size.width * 0.1, size.height * 0.9)
        ratioX = size.width?.div(paperWidth) ?: 1.0
        ratioY = size.height?.div(paperHeight) ?: 1.0
        resize()
        movePoints()
    }

    fun getCorners2Crop(): List<Point> {
        reverseSize()
        return listOf(tl, tr, br, bl)
    }

    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)
        Log.i(
            TAG,
            "矩形视图onDraw,cropMode:$cropMode, 角点坐标POINTS tl: $tl,tr: $tr, br: $br, bl: $bl "
        )
        rectPaint.color = Color.WHITE
        rectPaint.strokeWidth = 6F
        rectPaint.style = Paint.Style.STROKE
        canvas?.drawPath(path, rectPaint)

        rectPaint.color = Color.argb(128, 255, 255, 255)
        rectPaint.strokeWidth = 0F
        rectPaint.style = Paint.Style.FILL
        canvas?.drawPath(path, rectPaint)

        if (cropMode) {
            canvas?.drawCircle(tl.x.toFloat(), tl.y.toFloat(), 20F, circlePaint)
            canvas?.drawCircle(tr.x.toFloat(), tr.y.toFloat(), 20F, circlePaint)
            canvas?.drawCircle(bl.x.toFloat(), bl.y.toFloat(), 20F, circlePaint)
            canvas?.drawCircle(br.x.toFloat(), br.y.toFloat(), 20F, circlePaint)
        }
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
//        Log.i(
//            TAG,
//            "矩形视图onTouchEvent,cropMode:$cropMode, 角点坐标POINTS tl ------>  $tl corners"
//        )
        if (!cropMode) {
            return false
        }
        when (event?.action) {
            MotionEvent.ACTION_DOWN -> {
                latestDownX = event.x
                latestDownY = event.y
                calculatePoint2Move(event.x, event.y)
            }

            MotionEvent.ACTION_MOVE -> {
                point2Move.x = (event.x - latestDownX) + point2Move.x
                point2Move.y = (event.y - latestDownY) + point2Move.y
                movePoints()
                latestDownY = event.y
                latestDownX = event.x
            }
        }
        return true
    }

    private fun calculatePoint2Move(downX: Float, downY: Float) {
        val points = listOf(tl, tr, br, bl)
        point2Move = points.minByOrNull { abs((it.x - downX).times(it.y - downY)) }
            ?: tl
    }

    private fun movePoints() {
        path.reset()
        path.moveTo(tl.x.toFloat(), tl.y.toFloat())
        path.lineTo(tr.x.toFloat(), tr.y.toFloat())
        path.lineTo(br.x.toFloat(), br.y.toFloat())
        path.lineTo(bl.x.toFloat(), bl.y.toFloat())
        path.close()
        invalidate()
    }

    // 四个角点的坐标调整到纸张视图上的相对位置
    private fun resize() {
        tl.x = tl.x.div(ratioX)
        tl.y = tl.y.div(ratioY)
        tr.x = tr.x.div(ratioX)
        tr.y = tr.y.div(ratioY)
        br.x = br.x.div(ratioX)
        br.y = br.y.div(ratioY)
        bl.x = bl.x.div(ratioX)
        bl.y = bl.y.div(ratioY)
    }

    // 角点的坐标反向调整回原图的尺寸
    private fun reverseSize() {
        tl.x = tl.x.times(ratioX)
        tl.y = tl.y.times(ratioY)
        tr.x = tr.x.times(ratioX)
        tr.y = tr.y.times(ratioY)
        br.x = br.x.times(ratioX)
        br.y = br.y.times(ratioY)
        bl.x = bl.x.times(ratioX)
        bl.y = bl.y.times(ratioY)
    }
}
