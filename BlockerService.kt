package com.example.noor

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.media.MediaPlayer
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class BlockerService : Service() {
    private val h = Handler(Looper.getMainLooper())

    companion object {
        // ডিফল্ট ব্লক তালিকা (অ্যাপের ভেতর থেকে বদলানো যায়)
        val DEFAULT_BLOCKED = setOf(
            "com.facebook.katana", "com.facebook.lite", "com.facebook.orca", "com.facebook.mlite",
            "com.instagram.android", "com.instagram.barcelona",
            "com.zhiliaoapp.musically", "com.ss.android.ugc.trill",
            "com.google.android.youtube",
            "com.snapchat.android", "com.twitter.android",
            "org.telegram.messenger", "org.telegram.messenger.web",
            "com.reddit.frontpage", "com.pinterest", "com.linkedin.android",
            "video.like", "com.imo.android.imoim", "sg.bigo.live", "com.kwai.video",
            "com.discord", "tv.twitch.android.app", "com.tumblr"
        )
    }

    private var mp: MediaPlayer? = null

    private fun blockedSet(): Set<String> {
        val s = getSharedPreferences("noor", MODE_PRIVATE).getString("blocked", null)
        return if (s == null) DEFAULT_BLOCKED else s.split(",").filter { it.isNotEmpty() }.toSet()
    }

    private var lastFg = ""
    private var lastQuery = 0L
    private var lastNag = 0L
    private var overlay: View? = null

    private val loop = object : Runnable {
        override fun run() {
            try { tick() } catch (_: Exception) {}
            h.postDelayed(this, 700)
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

    override fun onStartCommand(i: Intent?, f: Int, id: Int): Int {
        if (i?.action == "AZAN") playAzan(i?.getStringExtra("name") ?: "")
        return START_STICKY
    }

    // res/raw/azan.mp3 থাকলে বাজায়, না থাকলে শুধু নোটিফিকেশন দেয়
    private fun playAzan(name: String) {
        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
            .notify(3, notif("nag", "আযান – $name", "$name নামাজের সময় হয়েছে"))
        val res = resources.getIdentifier("azan", "raw", packageName)
        if (res == 0) return
        try {
            mp?.release()
            val m = MediaPlayer.create(this, res) ?: return
            m.setOnCompletionListener {
                it.release()
                mp = null
            }
            m.start()
            mp = m
        } catch (_: Exception) {}
    }
    override fun onBind(i: Intent?): IBinder? = null

    override fun onDestroy() {
        h.removeCallbacks(loop)
        hideOverlay()
        mp?.release()
        super.onDestroy()
    }

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

    private fun showOverlay() {
        if (overlay != null) return
        val wm = getSystemService(WINDOW_SERVICE) as WindowManager
        val root = LinearLayout(this)
        root.orientation = LinearLayout.VERTICAL
        root.gravity = Gravity.CENTER
        root.setBackgroundColor(Color.parseColor("#0B1A19"))
        root.setPadding(64, 64, 64, 64)

        val tv = TextView(this)
        tv.text = "নামাজ বাকি!\n\nনামাজ আদায় করে কনফার্ম করুন, তারপর এই অ্যাপ খুলবে।"
        tv.setTextColor(Color.WHITE)
        tv.textSize = 22f
        tv.gravity = Gravity.CENTER

        val ok = Button(this)
        ok.text = "আলহামদুলিল্লাহ, নামাজ পড়েছি"
        ok.setOnClickListener {
            getSharedPreferences("noor", MODE_PRIVATE).edit()
                .putLong("confirmed", System.currentTimeMillis())
                .putBoolean("force", false)
                .apply()
            hideOverlay()
        }

        val back = Button(this)
        back.text = "ফিরে যান"
        back.setOnClickListener {
            goHome()
            hideOverlay()
        }

        root.addView(tv)
        root.addView(ok)
        root.addView(back)

        val lp = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.OPAQUE
        )
        wm.addView(root, lp)
        overlay = root
    }

    private fun hideOverlay() {
        val v = overlay ?: return
        try {
            (getSystemService(WINDOW_SERVICE) as WindowManager).removeView(v)
        } catch (_: Exception) {}
        overlay = null
    }

    private fun goHome() {
        val i = Intent(Intent.ACTION_MAIN)
        i.addCategory(Intent.CATEGORY_HOME)
        i.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(i)
    }

    private fun tick() {
        val p = getSharedPreferences("noor", MODE_PRIVATE)
        val now = System.currentTimeMillis()
        val times = (p.getString("times", "") ?: "").split(",").mapNotNull { it.toLongOrNull() }
        val last = times.filter { it <= now }.maxOrNull()
        val locked = p.getBoolean("force", false) ||
            (last != null && last > p.getLong("confirmed", 0L))
        updateForeground(now)

        if (locked && lastFg in blockedSet()) showOverlay() else hideOverlay()
        if (!locked) return

        if (now - lastNag > 5 * 60_000) {
            lastNag = now
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
                .notify(2, notif("nag", "নামাজ বাকি!", "নামাজ পড়ে অ্যাপে কনফার্ম করুন"))
        }
    }
}
