//
//  DMPNavigator.swift
//  dimina
//
//  Created by Lehem on 2025/4/17.
//

import Foundation
import SwiftUI
import UIKit
import ObjectiveC

// 用于存储关联对象的键
private var navigatorAssociationKey: UInt8 = 0

/// DMPNavigator 是一个导航管理器，用于接管整个应用的导航动作
public class DMPNavigator: NSObject {
    // app 弱引用
    private weak var app: DMPApp?

    // 页面生命周期管理
    private lazy var pageLifecycle: DMPPageLifecycle? = DMPPageLifecycle(app: app!)

    // 当前的导航控制器
    public private(set) weak var navigationController: UINavigationController?

    // 页面记录
    private var pageRecords: [DMPPageRecord] = []

    // 公开初始化方法
    public init(app: DMPApp? = nil) {
        self.app = app
        super.init()
    }

    public func setup(navigationController: UINavigationController) {
        self.navigationController = navigationController
                
        objc_setAssociatedObject(navigationController, &navigatorAssociationKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // 禁用系统返回手势
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    /// 创建自定义返回按钮
    public func createBackButton(darkStyle: Bool = false) -> UIBarButtonItem {
        let imageName = darkStyle ? "arrow-back-dark" : "arrow-back-light"
        
        // 确保图片正确加载
        guard let backImage = UIImage(named: imageName) else {
            print("警告: 无法加载返回按钮图片 \(imageName)")
            // 创建一个简单的返回按钮作为备用
            return UIBarButtonItem(
                title: "返回",
                style: .plain,
                target: self,
                action: #selector(handleBackButtonTapped)
            )
        }
        
        // 创建渲染模式为原始图片的UIImage，保留SVG原始颜色
        let originalImage = backImage.withRenderingMode(.alwaysOriginal)
        
        // 创建自定义返回按钮
        let backButton = UIBarButtonItem(
            image: originalImage,
            style: .plain,
            target: self,
            action: #selector(handleBackButtonTapped)
        )
        
        return backButton
    }
    
    /// 处理返回按钮点击事件
    @objc public func handleBackButtonTapped() {
        // 确保在主线程上调用 navigateBack
        DispatchQueue.main.async { [weak self] in
            self?.navigateBack()
        }
    }

    /// 启动到指定页面
    @MainActor
    public func launch(to path: String, query: [String: Any]? = nil, animated: Bool = true) async {
        guard let navigationController = navigationController else {
            print("导航控制器未设置")
            return
        }

        pageLifecycle?.onHide(webviewId: app!.getCurrentWebViewId())

        // 使用DMPPageController创建页面
        let pageController = DMPPageController(
            pagePath: path,
            query: query,
            appConfig: app!.getAppConfig()!,
            app: app,
            navigator: self,
            isRoot: true
        )

        let pageRecord = DMPPageRecord(webViewId: pageController.getWebView().getWebViewId(), fromWebViewId: app!.getCurrentWebViewId(), pagePath: path)
        pageRecord.query = query
        pageRecord.navStyle = app?.getBundleAppConfig()?.getPageConfig(pagePath: path) 
        pageRecords.append(pageRecord)

        await app?.service?.loadSubPackage(pagePath: path)

        navigationController.pushViewController(pageController, animated: animated)

        pageLifecycle?.onShow(webviewId: pageController.getWebView().getWebViewId())
    }

    /// 导航到指定页面
    @MainActor
    public func navigateTo(to path: String, query: [String: Any]? = nil, animated: Bool = true) async {
        guard let navigationController = navigationController else {
            print("导航控制器未设置")
            return
        }

        pageLifecycle?.onHide(webviewId: app!.getCurrentWebViewId())

        // 使用DMPPageController创建页面
        let pageController = DMPPageController(
            pagePath: path,
            query: query,
            appConfig: app!.getAppConfig()!,
            app: app,
            navigator: self,
            isRoot: false
        )

        let pageRecord = DMPPageRecord(webViewId: pageController.getWebView().getWebViewId(), fromWebViewId: app!.getCurrentWebViewId(), pagePath: path)
        pageRecord.query = query
        pageRecord.navStyle = app?.getBundleAppConfig()?.getPageConfig(pagePath: path) 
        pageRecords.append(pageRecord)
        
        // 打印调试信息
        print("navigateTo: Creating page controller for path: \(path), isRoot: false")

        await app?.service?.loadSubPackage(pagePath: path)
        
        // 推入视图控制器
        navigationController.pushViewController(pageController, animated: animated)

        pageLifecycle?.onShow(webviewId: pageController.getWebView().getWebViewId())
    }
    
    /// 返回上一页或多页
    @MainActor
    public func navigateBack(delta: Int = 1, animated: Bool = true, destroy: Bool = true) {
        guard let navigationController = navigationController else {
            print("导航控制器未设置")
            return
        }
        
        // 检查是否可以返回
        if navigationController.viewControllers.count <= 1 {
            if destroy {
                app?.destroy()
            }
            return
        }
        
        // 计算要返回的目标控制器索引
        let currentIndex = navigationController.viewControllers.count - 1
        let targetIndex = max(currentIndex - delta, 0)
        
        // 如果目标是根控制器，直接返回到根
        if targetIndex == 0 {
            pageLifecycle?.onUnload(webviewId: app!.getCurrentWebViewId())
            pageRecords.removeAll()
            navigationController.popToRootViewController(animated: animated)
            return
        }
        
        // 处理返回逻辑
        for _ in 0..<delta {
            if navigationController.viewControllers.count <= 1 || pageRecords.isEmpty {
                break
            }
            
            pageLifecycle?.onUnload(webviewId: app!.getCurrentWebViewId())
            pageRecords.removeLast()
        }
        
        // 返回到目标控制器
        let targetViewController = navigationController.viewControllers[targetIndex]
        navigationController.popToViewController(targetViewController, animated: animated)
        
        // 显示前一个页面
        if let previousPageRecord = pageRecords.last {
            pageLifecycle?.onShow(webviewId: previousPageRecord.webViewId)
        }
    }

    @MainActor
    public func redirectTo(to path: String, query: [String: Any]? = nil) async {
        guard let navigationController = navigationController else {
            print("导航控制器未设置")
            return
        }

        let currentIndex = navigationController.viewControllers.count - 1
        
        // 如果当前只有一个页面，则需要特殊处理
        if currentIndex == 0 {
            pageLifecycle?.onUnload(webviewId: app!.getCurrentWebViewId())
            
            if !pageRecords.isEmpty {
                pageRecords.removeLast()
            }
            
            let pageController = DMPPageController(
                pagePath: path,
                query: query,
                appConfig: app!.getAppConfig()!,
                app: app,
                navigator: self,
                isRoot: true
            )
            
            let pageRecord = DMPPageRecord(webViewId: pageController.getWebView().getWebViewId(), fromWebViewId: app!.getCurrentWebViewId(), pagePath: path)
            pageRecord.query = query
            pageRecord.navStyle = app?.getBundleAppConfig()?.getPageConfig(pagePath: path) 
            pageRecords.append(pageRecord)
            
            await app?.service?.loadSubPackage(pagePath: path)

            let viewControllers = [pageController]
            navigationController.setViewControllers(viewControllers, animated: false)
            
            pageLifecycle?.onShow(webviewId: pageController.getWebView().getWebViewId())
            
            return
        }
        
        // 先触发当前页面的卸载生命周期
        pageLifecycle?.onUnload(webviewId: app!.getCurrentWebViewId())
        
        if !pageRecords.isEmpty {
            pageRecords.removeLast()
        }
        
        let pageController = DMPPageController(
            pagePath: path,
            query: query,
            appConfig: app!.getAppConfig()!,
            app: app,
            navigator: self,
            isRoot: false
        )
        
        let pageRecord = DMPPageRecord(webViewId: pageController.getWebView().getWebViewId(), fromWebViewId: app!.getCurrentWebViewId(), pagePath: path)
        pageRecord.query = query
        pageRecord.navStyle = app?.getBundleAppConfig()?.getPageConfig(pagePath: path) 
        pageRecords.append(pageRecord)
        
        var viewControllers = navigationController.viewControllers
        viewControllers.removeLast()
        viewControllers.append(pageController)
        navigationController.setViewControllers(viewControllers, animated: false)
        pageLifecycle?.onShow(webviewId: pageController.getWebView().getWebViewId())
    }

    @MainActor
    public func relaunch(to path: String, query: [String: Any]? = nil, animated: Bool = true) async {
        guard let navigationController = navigationController else {
            print("导航控制器未设置")
            return
        }

        navigationController.popToRootViewController(animated: animated)
        pageRecords.removeAll()

        await launch(to: path, query: query, animated: animated)
    }

    /// 返回到根页面
    private func goBackToRoot(animated: Bool = true) {
        guard let navigationController = navigationController else {
            print("导航控制器未设置")
            return
        }

        navigationController.popToRootViewController(animated: animated)
        pageRecords.removeAll()
    }

    /// 获取当前页面记录
    public func getTopPageRecord() -> DMPPageRecord? {
        return pageRecords.last
    }
}
