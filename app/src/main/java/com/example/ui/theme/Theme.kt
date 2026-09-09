package com.example.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val VelocityColorScheme =
  darkColorScheme(
    primary = ElectricCyan,
    onPrimary = PureBlack,
    secondary = DeepCyan,
    onSecondary = PureBlack,
    tertiary = NeonYellow,
    background = PureBlack,
    surface = SurfaceDark,
    onBackground = TextPrimary,
    onSurface = TextPrimary,
    surfaceVariant = SurfaceElevated,
    onSurfaceVariant = TextSecondary,
    outline = BorderDark,
    error = NeonPink,
    onError = TextPrimary,
  )

@Composable
fun MyApplicationTheme(
  darkTheme: Boolean = true,
  dynamicColor: Boolean = false,
  content: @Composable () -> Unit,
) {
  MaterialTheme(
    colorScheme = VelocityColorScheme,
    typography = Typography,
    content = content,
  )
}
