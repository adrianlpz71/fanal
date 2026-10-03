package com.example.fanal

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

// FragmentActivity: necesaria para el diálogo de huella de local_auth.
//
// También recibe ficheros compartidos con Faro ("Compartir → Faro" o "Abrir con"): copia el
// contenido a la caché privada de la app y pasa la ruta a Flutter por el canal "faro/share".
// No se pide ningún permiso de almacenamiento: Android concede acceso solo a ese fichero.
class MainActivity : FlutterFragmentActivity() {
    private var channel: MethodChannel? = null
    private var pending: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "faro/share").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialFile" -> {
                        result.success(pending)
                        pending = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (savedInstanceState == null) pending = readShared(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val file = readShared(intent) ?: return
        channel?.invokeMethod("fileShared", file) ?: run { pending = file }
    }

    private fun readShared(intent: Intent?): Map<String, String>? {
        val uri: Uri = when (intent?.action) {
            Intent.ACTION_SEND -> intent.getParcelableExtra(Intent.EXTRA_STREAM)
            Intent.ACTION_VIEW -> intent.data
            else -> null
        } ?: return null
        return try {
            val name = displayName(uri) ?: "fichero"
            val dir = File(cacheDir, "shared").apply { mkdirs() }
            dir.listFiles()?.forEach { it.delete() } // solo se guarda el último
            val out = File(dir, name.replace(Regex("[^A-Za-z0-9._ -]"), "_"))
            contentResolver.openInputStream(uri)?.use { input ->
                out.outputStream().use { input.copyTo(it) }
            } ?: return null
            mapOf("path" to out.absolutePath, "name" to name, "mime" to (contentResolver.getType(uri) ?: ""))
        } catch (e: Exception) {
            null
        }
    }

    private fun displayName(uri: Uri): String? =
        contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c ->
            if (c.moveToFirst()) c.getString(0) else null
        } ?: uri.lastPathSegment
}
