package com.ummati.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerTimesWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.prayer_widget)

            views.setTextViewText(R.id.tv_city, widgetData.getString("city", ""))
            views.setTextViewText(R.id.tv_date, widgetData.getString("date", ""))
            views.setTextViewText(R.id.tv_fajr, widgetData.getString("fajr", "--:--"))
            views.setTextViewText(R.id.tv_dhuhr, widgetData.getString("dhuhr", "--:--"))
            views.setTextViewText(R.id.tv_asr, widgetData.getString("asr", "--:--"))
            views.setTextViewText(R.id.tv_maghrib, widgetData.getString("maghrib", "--:--"))
            views.setTextViewText(R.id.tv_isha, widgetData.getString("isha", "--:--"))

            // Open app on widget tap
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.prayer_widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
