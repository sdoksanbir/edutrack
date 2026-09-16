package com.example.ozel_ders_takip

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationId = intent.getIntExtra("notificationId", 0)
        val title = intent.getStringExtra("title") ?: "Ders Hatırlatması"
        val body = intent.getStringExtra("body") ?: "Dersiniz yakında başlayacak"
        
        Log.d("AlarmReceiver", "Alarm tetiklendi: notificationId=$notificationId, title=$title")
        
        // Bildirim kanalını oluştur (Android 8.0+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "lesson_reminders",
                "Ders Hatırlatmaları",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Planlanmış dersler için hatırlatma bildirimleri"
                enableVibration(true)
                enableLights(true)
            }
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
        
        // Bildirimi göster
        val notification = NotificationCompat.Builder(context, "lesson_reminders")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setAutoCancel(true)
            .build()
        
        val notificationManager = NotificationManagerCompat.from(context)
        try {
            notificationManager.notify(notificationId, notification)
            Log.d("AlarmReceiver", "✅ Bildirim gösterildi: notificationId=$notificationId")
        } catch (e: Exception) {
            Log.e("AlarmReceiver", "❌ Bildirim gösterilemedi: $e")
        }
    }
}
