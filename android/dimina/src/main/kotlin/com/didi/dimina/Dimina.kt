package com.didi.dimina

import android.app.Activity
import android.content.Context
import com.didi.dimina.bean.MiniProgram
import com.didi.dimina.common.LogUtils
import com.didi.dimina.common.StoreUtils
import com.didi.dimina.core.MiniApp

/**
 * Author: Doslin
 */
class Dimina private constructor(context: Context) {
    // 伴生对象用于实现单例模式和提供初始化入口
    companion object {
        @Volatile
        private var instance: Dimina? = null

        /**
         * 初始化 SDK
         * @param context 应用上下文
         * @param config 可选的配置参数
         * @return Dimina 实例
         */
        fun initialize(context: Context, config: DiminaConfig? = null): Dimina {
            return instance ?: synchronized(this) {
                instance ?: Dimina(context.applicationContext).also { instance = it }.apply {
                    // 应用配置
                    config?.let { applyConfig(it) }
                }
            }
        }

        /**
         * 获取 Dimina 实例
         * @throws IllegalStateException 如果尚未初始化
         */
        fun getInstance(): Dimina {
            return instance ?: throw IllegalStateException("Dimina SDK not initialized. Please call initialize() first.")
        }
    }

    // 配置类
    data class DiminaConfig(
        val debugMode: Boolean = false,
    )

    private val appContext: Context = context

    init {
        // 基础初始化逻辑
        setupCoreComponents()
    }

    // 初始化核心组件
    private fun setupCoreComponents() {
        StoreUtils.initialize(context = appContext)
    }

    // 应用配置
    private fun applyConfig(config: DiminaConfig) {
        // 根据配置调整 SDK 行为
        if (config.debugMode) {
            enableDebugLogging()
        }
    }

    // 配置相关方法
    private fun enableDebugLogging() {
        // 开启调试日志
        LogUtils.initialize(true)
    }

    /**
     * 启动小程序
     * @param context 上下文
     * @param miniProgram 要启动的小程序对象
     */
    fun startMiniProgram(context: Activity, miniProgram: MiniProgram) {
        val miniApp = MiniApp.getInstance()
        miniApp.openApp(context, miniProgram)
    }
}