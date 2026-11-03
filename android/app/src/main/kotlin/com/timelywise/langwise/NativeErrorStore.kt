package com.timelywise.langwise

import android.content.Context
import android.util.Log
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.Executors

object NativeErrorStore {
    private const val LOG_PREFIX = "[LangwiseApplication.kt]"
    private const val LOG_TAG = "Langwise"
    private const val DIR_NAME = "native_errors"
    private const val FILE_NAME = "pending.jsonl"
    private const val MAX_FILE_BYTES = 1024 * 1024L
    private const val MAX_TYPE_LENGTH = 20
    private const val MAX_TAG_LENGTH = 50
    private const val MAX_MESSAGE_LENGTH = 300
    private const val MAX_THREAD_LENGTH = 40
    private const val MAX_STACK_LENGTH = 1200
    private const val MAX_EXTRA_LENGTH = 200

    private val executor = Executors.newSingleThreadExecutor()
    private val fileLock = Any()

    fun writeHandledError(context: Context, tag: String, throwable: Throwable, extra: String? = null) {
        val appContext = context.applicationContext
        val threadName = Thread.currentThread().name
        executor.execute {
            try {
                appendLine(
                    appContext = appContext,
                    jsonLine = buildLightJson(
                        type = "native_error",
                        tag = tag,
                        message = throwable.message ?: throwable.javaClass.simpleName,
                        thread = threadName,
                        stack = Log.getStackTraceString(throwable),
                        extra = extra,
                    ),
                )
            } catch (t: Throwable) {
                Log.e(LOG_TAG, "$LOG_PREFIX 写入原生错误失败: ${t.message}", t)
            }
        }
    }

    fun writeUnhandledJavaCrash(context: Context, threadName: String, throwable: Throwable) {
        try {
            appendLine(
                appContext = context.applicationContext,
                jsonLine = buildLightJson(
                    type = "java_crash",
                    tag = "uncaught",
                    message = throwable.message ?: throwable.javaClass.simpleName,
                    thread = threadName,
                    stack = Log.getStackTraceString(throwable),
                    extra = null,
                ),
            )
        } catch (_: Throwable) {
        }
    }

    fun consumePendingErrors(context: Context): String {
        val file = getFile(context.applicationContext)
        if (!file.exists()) {
            Log.i(LOG_TAG, "$LOG_PREFIX 开始读取待消费日志，当前条数: 0")
            Log.i(LOG_TAG, "$LOG_PREFIX 读取待消费日志成功，返回条数: 0")
            return "[]"
        }
        return synchronized(fileLock) {
            try {
                val lines = file.readLines(Charsets.UTF_8).filter { it.isNotBlank() }
                Log.i(LOG_TAG, "$LOG_PREFIX 开始读取待消费日志，当前条数: ${lines.size}")
                val result = "[${lines.joinToString(",")}]"
                if (file.exists()) {
                    file.delete()
                }
                Log.i(LOG_TAG, "$LOG_PREFIX 读取待消费日志成功，返回条数: ${lines.size}")
                result
            } catch (t: Throwable) {
                Log.e(LOG_TAG, "$LOG_PREFIX 读取待消费日志失败: ${t.message}", t)
                "[]"
            }
        }
    }

    private fun getDir(context: Context): File {
        return File(context.filesDir, DIR_NAME)
    }

    private fun getFile(context: Context): File {
        return File(getDir(context), FILE_NAME)
    }

    private fun appendLine(appContext: Context, jsonLine: String) {
        synchronized(fileLock) {
            val file = getFile(appContext)
            file.parentFile?.mkdirs()
            maybeRotate(file)
            FileOutputStream(file, true).bufferedWriter(Charsets.UTF_8).use { writer ->
                writer.append(jsonLine)
                writer.append('\n')
            }
        }
    }

    private fun buildLightJson(
        type: String,
        tag: String,
        message: String,
        thread: String,
        stack: String?,
        extra: String?,
    ): String {
        val json = JSONObject()
        json.put("type", trimToMaxLength(type, MAX_TYPE_LENGTH))
        json.put("time", SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date()))
        json.put("tag", trimToMaxLength(tag, MAX_TAG_LENGTH))
        json.put("message", trimToMaxLength(message, MAX_MESSAGE_LENGTH))
        json.put("thread", trimToMaxLength(thread, MAX_THREAD_LENGTH))
        if (!stack.isNullOrBlank()) {
            json.put("stack", trimToMaxLength(stack.replace('\n', ' '), MAX_STACK_LENGTH))
        }
        if (!extra.isNullOrBlank()) {
            json.put("extra", trimToMaxLength(extra, MAX_EXTRA_LENGTH))
        }
        return json.toString()
    }

    private fun trimToMaxLength(text: String, maxLength: Int): String {
        val cleanText = text.replace(Regex("\\s+"), " ").trim()
        if (cleanText.length <= maxLength) return cleanText
        return cleanText.substring(0, maxLength)
    }

    private fun maybeRotate(file: File) {
        if (!file.exists()) return
        if (file.length() < MAX_FILE_BYTES) return
        if (file.exists()) {
            file.delete()
        }
    }
}
