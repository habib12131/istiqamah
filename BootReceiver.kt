package com.example.noor

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.content.ContextCompat

object Azan {
    val NAMES = listOf("ফজর", "যোহর", "আসর", "মাগরিব", "এশা")

    fun canExact(c: Context): Boolean {
        if (Build.VERSION.SDK_INT < 31) return true
        return (c.getSystemService(Context.ALARM_SERVICE) as AlarmManager).canScheduleExactAlarms()
    }

    // "times" তালিকার প্রতিটি ভবিষ্যৎ ওয়াক্তের জন্য অ্যালার্ম বসায়
    fun schedule(c: Context) {
        val am = c.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val p = c.getSharedPreferences("noor", Context.MODE_PRIVATE)
        val times = (p.getString("times", "") ?: "").split(",").mapNotNull { it.toLongOrNull() }
        val now = System.currentTimeMillis()
        val exact = canExact(c)
        times.forEachIndexed { i, t ->
            val pi = pending(c, i, NAMES[i % 5])
            if (t > now) {
                try {
                    if (exact) am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, t, pi)
                    else am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, t, pi)
                } catch (_: Exception) {}
            } else {
                am.cancel(pi)
            }
        }
    }

    private fun pending(c: Context, i: Int, name: String): PendingIntent {
        val intent = Intent(c, AzanReceiver::class.java)
        intent.putExtra("name", name)
        return PendingIntent.getBroadcast(
            c, 100 + i, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }
}

class AzanReceiver : BroadcastReceiver() {
    override fun onReceive(c: Context, i: Intent) {
        val s = Intent(c, BlockerService::class.java)
        s.action = "AZAN"
        s.putExtra("name", i.getStringExtra("name") ?: "")
        ContextCompat.startForegroundService(c, s)
    }
}

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(c: Context, i: Intent) {
        if (i.action == Intent.ACTION_BOOT_COMPLETED) {
            Azan.schedule(c)
            ContextCompat.startForegroundService(c, Intent(c, BlockerService::class.java))
        }
    }
}
