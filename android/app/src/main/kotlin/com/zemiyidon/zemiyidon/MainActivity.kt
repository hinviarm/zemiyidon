package com.zemiyidon.zemiyidon

import android.os.Bundle
import android.view.Window
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
    }

    private fun enableEdgeToEdge() {
        val window: Window = window
        WindowCompat.setDecorFitsSystemWindows(window, false) // Mode bord-à-bord

        // Utilisation de WindowInsetsControllerCompat pour gérer l'affichage des barres système
        val controllerCompat = WindowInsetsControllerCompat(window, window.decorView)
        controllerCompat.hide(WindowInsetsCompat.Type.systemBars()) // Cacher la barre de navigation et la status bar
        controllerCompat.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE // Réapparition au swipe

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        }
        // Suppression des appels à setStatusBarColor et setNavigationBarColor (OBSOLETES)
    }
}
