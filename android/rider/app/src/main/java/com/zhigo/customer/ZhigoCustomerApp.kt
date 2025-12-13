package com.zhigo.customer

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class ZhigoCustomerApp : Application() {
    override fun onCreate() {
        super.onCreate()
    }
}
