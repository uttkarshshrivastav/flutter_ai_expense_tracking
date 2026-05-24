package com.example.upi_analyzer_app

import android.content.Context
import android.database.Cursor
import android.provider.Telephony
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class SmsPlatformChannel(private val context: Context) {
    private val CHANNEL = "com.example.upi_analyzer_app/sms"

    fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "queryFinancialSms" -> {
                    val sinceTimestamp = call.argument<Long>("sinceTimestamp") ?: 0L
                    val financialSenders = call.argument<List<String>>("financialSenders") ?: emptyList()
                    val smsList = queryFinancialSms(sinceTimestamp, financialSenders)
                    result.success(smsList)
                }
                "insertRawMessage" -> {
                    val rawMessage = call.argument<Map<String, Any>>("rawMessage") ?: emptyMap()
                    val dbHelper = DatabaseHelper(context)
                    dbHelper.insertRawMessage(rawMessage)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun queryFinancialSms(sinceTimestamp: Long, financialSenders: List<String>): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()
        val cursor: Cursor? = context.contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            arrayOf(Telephony.Sms._ID, Telephony.Sms.ADDRESS, Telephony.Sms.BODY, Telephony.Sms.DATE),
            "${Telephony.Sms.DATE} >= ?",
            arrayOf(sinceTimestamp.toString()),
            "${Telephony.Sms.DATE} DESC"
        )

        cursor?.use {
            val idIndex = it.getColumnIndex(Telephony.Sms._ID)
            val addressIndex = it.getColumnIndex(Telephony.Sms.ADDRESS)
            val bodyIndex = it.getColumnIndex(Telephony.Sms.BODY)
            val dateIndex = it.getColumnIndex(Telephony.Sms.DATE)

            while (it.moveToNext()) {
                val sender = it.getString(addressIndex) ?: continue
                val body = it.getString(bodyIndex) ?: continue

                if (financialSenders.any { s -> sender.contains(s, ignoreCase = true) }) {
                    smsList.add(
                        mapOf(
                            "id" to it.getString(idIndex),
                            "sender" to sender,
                            "body" to body,
                            "timestamp" to it.getLong(dateIndex)
                        )
                    )
                }
            }
        }
        return smsList
    }
}
