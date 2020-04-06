package com.yeahdev.yeah_passwords

import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.nfc.NfcAdapter
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.yeahdev.yeah_passwords/intent"
        const val CHECK_NFC_STATE_METHOD = "check_nfc_state"
        const val TOGGLE_NFC_STATE_METHOD = "toggle_nfc_state"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when(call.method) {
                CHECK_NFC_STATE_METHOD -> {
                    var nfcAdapter = NfcAdapter.getDefaultAdapter(this)
                    result.success(nfcAdapter.isEnabled())
                }
                TOGGLE_NFC_STATE_METHOD -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                        startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
                    } else {
                        startActivity(Intent(Settings.ACTION_WIRELESS_SETTINGS))
                    }
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
