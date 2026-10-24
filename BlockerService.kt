package com.example.noor

import android.app.*
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Intent
import android.os.Handler
import android.os.IBinder
import android.os.Looper

class BlockerService : Service() {
    private val h = Handler(Looper.getMainLooper())

    // ব্লক করা অ্যাপের প্যাকেজ নাম (পরে সেটিংস থেকে বদলানোর ব্যবস্থা করা যাবে)
    private val blocked = setOf(
        "com.facebook.katana",
        "com.zhiliaoapp.musically",
        "com.ss.android.ugc.trill",
        "com.google.android.youtube"
    )
    private var lastFg = ""
    private var lastQuery = 0L
    private var lastNag = 0L

    private val loop = object : Runnable {
        override fun run() {
            try { tick() } catch (_: Exception) {}
            h.postDelayed(this, 1000)
        }
    }

    override fun onCreate() {
        super.onCreate()
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        nm.createNotificationChannel(NotificationChannel("gate", "নামাজ গেট", NotificationManager.IMPORTANCE_LOW))
        nm.createNotificationChannel(NotificationChannel("nag", "নামাজের রিমাইন্ডার", NotificationManager.IMPORTANCE_HIGH))
        startForeground(1, notif("gate", "ইস্তিকামাহ", "নামাজ গেট চালু আছে"))
        lastQuery = System.currentTimeMillis() - 5000
        h.post(loop)
    }

    override fun onStartCommand(i: Intent?, f: Int, id: Int) = START_STICKY
    override fun onBind(i: Intent?): IBinder? = null
    override fun onDestroy() { h.removeCallbacks(loop); super.onDestroy() }

    private fun notif(ch: String, title: String, text: String): Notification {
        val open = PendingIntent.getActivity(
            this, 0, packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        return Notification.Builder(this, ch)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title).setContentText(text)
            .setContentIntent(open).setAutoCancel(ch == "nag").build()
    }

    private fun updateForeground(now: Long) {
        val usm = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val ev = usm.queryEvents(lastQuery, now)
        val e = UsageEvents.Event()
        while (ev.hasNextEvent()) {
            ev.getNextEvent(e)
            if (e.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) lastFg = e.packageName
        }
        lastQuery = now
    }

    private fun tick() {
        val p = getSharedPreferences("noor", MODE_PRIVATE)
        val now = System.currentTimeMillis()
        val times = (p.getString("times", "") ?: "").split(",").mapNotNull { it.toLongOrNull() }
        val last = times.filter { it <= now }.maxOrNull()
        val locked = last != null && last > p.getLong("confirmed", 0L)
        updateForeground(now)
        if (!locked) return

        if (lastFg in blocked) {
            val i = packageManager.getLaunchIntentForPackage(packageName)!!
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            startActivity(i)
            lastFg = packageName
        }
        if (now - lastNag > 5 * 60_000) {
            lastNag = now
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
                .notify(2, notif("nag", "নামাজ বাকি!", "নামাজ পড়ে অ্যাপে কনফার্ম করুন"))
        }
    }
}
