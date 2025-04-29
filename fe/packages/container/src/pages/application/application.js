import './application.scss'
import { sleep } from '@/utils/util'

export class Application {
	constructor() {
		this.el = null
		this.window = null
		this.root = null
		this.views = []
		this.rootView = null
		this.parent = null
		this.done = true
		this._queue = Promise.resolve() // 操作队列，保证动画串行
		this.init()
	}

	// 队列执行器，确保操作串行
	_enqueue(fn) {
		this._queue = this._queue.then(() => fn())
		return this._queue
	}

	init() {
		this.el = document.createElement('div')
		this.el.classList.add('dimina-application')
		this.window = document.createElement('div')
		this.window.classList.add('dimina-native-window')
		this.el.appendChild(this.window)
	}

	initRootView(view) {
		this.rootView = view
		view.parent = this
		view.el.classList.add('dimina-native-view--instage')
		view.el.style.zIndex = 1
		this.root = view
		this.window.appendChild(view.el)
		view.viewDidLoad()
	}

	async pushView(view) {
		// 防抖
		if (!this.done) {
			return
		}
		this.done = false

		// 在视图栈里找到上一个视图
		const preView = this.views[this.views.length - 1]

		// 当前视图入栈
		view.parent = this
		this.views.push(view)
		view.el.style.zIndex = this.views.length
		view.el.classList.add('dimina-native-view--before-enter')
		this.window.appendChild(view.el)
		view?.viewDidLoad()
		await sleep(1)

		// 上一个视图向左动画推出
		preView.el.classList.remove('dimina-native-view--instage')
		preView.el.classList.add('dimina-native-view--slide-out')
		preView.el.classList.add('dimina-native-view--linear-anima')

		// 当前视图向左动画推入
		view.el.classList.add('dimina-native-view--enter-anima')
		view.el.classList.add('dimina-native-view--instage')
		await sleep(540)

		// 动画结束之后移出相关class
		preView.el.classList.remove('dimina-native-view--linear-anima')
		view.el.classList.remove('dimina-native-view--before-enter')
		view.el.classList.remove('dimina-native-view--enter-anima')
		view.el.classList.remove('dimina-native-view--instage')

		this.done = true
	}

	async popView() {
		if (this.views.length < 2) {
			return
		}

		if (!this.done) {
			return
		}

		this.done = false

		const preView = this.views[this.views.length - 2]
		const currentView = this.views[this.views.length - 1]

		preView.el.classList.remove('dimina-native-view--slide-out')
		preView.el.classList.add('dimina-native-view--instage')
		preView.el.classList.add('dimina-native-view--enter-anima')

		currentView.el.classList.remove('dimina-native-view--instage')
		currentView.el.classList.add('dimina-native-view--before-enter')
		currentView.el.classList.add('dimina-native-view--enter-anima')

		await sleep(540)
		this.views.pop()
		this.window.removeChild(currentView.el)
		preView.el.classList.remove('dimina-native-view--enter-anima')

		this.done = true
	}

	presentView(view, useCache) {
		return this._enqueue(() => this._presentView(view, useCache))
	}

	async _presentView(view, useCache) {
		if (!this.done) {
			return
		}
		this.done = false

		const preView = this.views[this.views.length - 1]
		view.parent = this
		view.el.style.zIndex = this.views.length + 1
		view.el.classList.add('dimina-native-view--before-present')
		view.el.classList.add('dimina-native-view--enter-anima')
		preView?.el.classList.add('dimina-native-view--before-presenting')
		preView?.el.classList.remove('dimina-native-view--instage')
		preView?.el.classList.add('dimina-native-view--enter-anima')
		preView?.onPresentOut()
		view.onPresentIn()
		!useCache && this.el.appendChild(view.el)
		this.views.push(view)
		!useCache && view.viewDidLoad && view.viewDidLoad()
		if (useCache) {
			view.restoreColorStyle()
		}

		await sleep(20)
		preView?.el.classList.add('dimina-native-view--presenting')
		view.el.classList.add('dimina-native-view--instage')
		await sleep(540)
		view.el.classList.remove('dimina-native-view--before-present')
		view.el.classList.remove('dimina-native-view--enter-anima')
		preView?.el.classList.remove('dimina-native-view--enter-anima')
		preView?.el.classList.remove('dimina-native-view--before-presenting')

		this.done = true
	}

	dismissView(opts = {}) {
		return this._enqueue(() => this._dismissView(opts))
	}

	async _dismissView(opts = {}) {
		if (!this.done) {
			return
		}
		this.done = false

		const preView = this.views[this.views.length - 2]
		const currentView = this.views[this.views.length - 1]
		// 是否销毁当前的容器
		const { destroy = true } = opts

		currentView.el.classList.add('dimina-native-view--enter-anima')
		preView?.el.classList.add('dimina-native-view--enter-anima')
		preView?.el.classList.add('dimina-native-view--before-presenting')
		await sleep(0)
		currentView.el.classList.add('dimina-native-view--before-present')
		currentView.el.classList.remove('dimina-native-view--instage')
		preView?.el.classList.remove('dimina-native-view--presenting')

		preView?.onPresentIn()
		currentView?.onPresentOut()

		await sleep(540)

		if (destroy) {
			currentView.destroy()
			this.el.removeChild(currentView.el)
		}

		this.views.pop()
		preView?.el.classList.remove('dimina-native-view--enter-anima')
		preView?.el.classList.remove('dimina-native-view--before-presenting')

		this.done = true
	}

	async destroyRootView(view) {
		view.destroy()
		this.el.removeChild(view.el)
	}

	updateStatusBarColor(color) {
		this.parent?.updateDeviceBarColor(color)
	}
}
