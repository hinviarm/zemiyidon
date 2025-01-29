package com.zemiyidon.zemiyidon

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

import android.view.Window
import android.view.WindowInsets
import android.view.WindowInsetsController
import androidx.core.view.WindowCompat

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
    }

    private fun enableEdgeToEdge() {
        val window: Window = window
        WindowCompat.setDecorFitsSystemWindows(window, false) // Permet le mode "edge-to-edge"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val controller = window.insetsController
            if (controller != null) {
                controller.hide(WindowInsets.Type.statusBars()) // Cache uniquement la **Status Bar**
                controller.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                    android.view.View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                            or android.view.View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    )
        }
    }
}
