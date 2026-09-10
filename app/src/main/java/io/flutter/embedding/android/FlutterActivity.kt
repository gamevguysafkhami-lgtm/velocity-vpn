package io.flutter.embedding.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.example.VelocityVpnMainScreen
import com.example.ui.theme.MyApplicationTheme

/**
 * Clean native bridge providing the sole FlutterActivity launcher entrypoint
 * for the Velocity VPN Android container emulator preview.
 */
open class FlutterActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContent {
            MyApplicationTheme {
                VelocityVpnMainScreen()
            }
        }
    }
}
