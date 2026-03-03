package com.stylokey.keyboard

import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class FlutterImeService : InputMethodService() {

    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var channel: MethodChannel? = null

    // ── Prevent IME from going full-screen ─────────────────────────────────
    override fun onEvaluateFullscreenMode(): Boolean = false

    override fun onCreate() {
        super.onCreate()

        flutterEngine = FlutterEngine(this).also { engine ->
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            engine.lifecycleChannel.appIsResumed()

            channel = MethodChannel(
                engine.dartExecutor.binaryMessenger,
                "com.example.keyboard12345/ime"
            ).apply {
                setMethodCallHandler { call, result ->
                    val ic = currentInputConnection
                    when (call.method) {
                        "commitText" -> {
                            val text = call.argument<String>("text") ?: ""
                            ic?.commitText(text, 1)
                            result.success(null)
                        }
                        "setComposingText" -> {
                            val text = call.argument<String>("text") ?: ""
                            if (text.isEmpty()) ic?.finishComposingText()
                            else ic?.setComposingText(text, 1)
                            result.success(null)
                        }
                        // 더블탭 업그레이드용: 기존 composing/committed 글자를 지우고 새 글자로 교체
                        "replaceComposing" -> {
                            val newText = call.argument<String>("text") ?: ""
                            ic?.beginBatchEdit()
                            ic?.finishComposingText()          // 현재 composing 확정
                            ic?.deleteSurroundingText(1, 0)    // 확정된 글자 삭제
                            if (newText.isNotEmpty()) {
                                ic?.setComposingText(newText, 1) // 새 글자 composing으로 설정
                            }
                            ic?.endBatchEdit()
                            result.success(null)
                        }
                        "deleteSurroundingText" -> {
                            ic?.deleteSurroundingText(1, 0)
                            result.success(null)
                        }
                        "performEditorAction" -> {
                            val opts = currentInputEditorInfo?.imeOptions
                                ?: EditorInfo.IME_ACTION_DONE
                            sendDefaultEditorAction(
                                (opts and EditorInfo.IME_MASK_ACTION) == EditorInfo.IME_ACTION_NONE
                            )
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                }
            }
        }
    }

    override fun onCreateInputView(): View {
        val engine = flutterEngine ?: return View(this)

        // ── Use TextureView (no separate z-layer) so it doesn't cover the app ──
        val textureView = FlutterTextureView(this)
        flutterView = FlutterView(this, textureView).also { fv ->
            fv.attachToFlutterEngine(engine)
        }

        // ── Wrap in a FrameLayout with a fixed keyboard height ──────────────
        val density = resources.displayMetrics.density
        val keyboardHeight = (285 * density).toInt()

        return FrameLayout(this).apply {
            setBackgroundColor(0xFFD1D5DB.toInt())
            addView(
                flutterView,
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    keyboardHeight
                )
            )
        }
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        flutterEngine?.lifecycleChannel?.appIsResumed()
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        flutterEngine?.lifecycleChannel?.appIsPaused()
    }

    override fun onDestroy() {
        flutterView?.detachFromFlutterEngine()
        flutterEngine?.destroy()
        flutterEngine = null
        super.onDestroy()
    }
}
