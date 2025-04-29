import { invokeAPI } from '@/api/common'

/**
 * 显示消息提示框
 * https://developers.weixin.qq.com/miniprogram/dev/api/ui/interaction/wx.showToast.html
 */
export function showToast(opts) {
	invokeAPI('showToast', opts)
}

/**
 * 隐藏消息提示框
 * https://developers.weixin.qq.com/miniprogram/dev/api/ui/interaction/wx.hideToast.html
 */
export function hideToast(opts) {
	invokeAPI('hideToast', opts)
}

/**
 * 显示模态对话框
 * https://developers.weixin.qq.com/miniprogram/dev/api/ui/interaction/wx.showModal.html
 */
export function showModal(opts) {
	invokeAPI('showModal', opts)
}

/**
 * 显示 loading 提示框。需主动调用 wx.hideLoading 才能关闭提示框
 * https://developers.weixin.qq.com/miniprogram/dev/api/ui/interaction/wx.showLoading.html
 */
export function showLoading(opts) {
	invokeAPI('showLoading', opts)
}

/**
 * 显示操作菜单
 * https://developers.weixin.qq.com/miniprogram/dev/api/ui/interaction/wx.showActionSheet.html
 */
export function showActionSheet(opts) {
	invokeAPI('showActionSheet', opts)
}

/**
 * 隐藏 loading 提示框
 * https://developers.weixin.qq.com/miniprogram/dev/api/ui/interaction/wx.hideLoading.html
 */
export function hideLoading(opts) {
	invokeAPI('hideLoading', opts)
}

/**
 * 开启小程序页面返回询问对话框
 * https://developers.weixin.qq.com/miniprogram/dev/api/ui/interaction/wx.enableAlertBeforeUnload.html
 */
export function enableAlertBeforeUnload(opts) {
	invokeAPI('enableAlertBeforeUnload', opts)
}

/**
 * 关闭小程序页面返回询问对话框
 */
export function disableAlertBeforeUnload(opts) {
	invokeAPI('disableAlertBeforeUnload', opts)
}
