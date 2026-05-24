package com.example.upi_analyzer_app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.app.Notification
import android.util.Log

class TransactionNotificationListener : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName ?: return

        if (packageName in listOf("com.google.android.apps.nbu.paisa.user", "com.phonepe.app", "com.paytm.app")) {
            val notification = sbn.notification
            val text = notification.extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: return

            val rawMessage = mapOf(
                "id" to "ntf_${sbn.id}_${System.currentTimeMillis()}",
                "raw_body" to text,
                "timestamp" to System.currentTimeMillis(),
                "status" to "pending"
            )

            try {
                val dbHelper = DatabaseHelper(applicationContext)
                dbHelper.insertRawMessage(rawMessage)
                Log.d("UPI_Parser", "Inserted notification from $packageName")
            } catch (e: Exception) {
                Log.e("UPI_Parser", "Failed to insert notification", e)
            }
        }
    }
}
