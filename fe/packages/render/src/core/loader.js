import message from './message'
import { Module } from './module'

class Loader {
	constructor() {
		this.staticModules = {}
	}

	loadResource(opts) {
		const { bridgeId, appId, pagePath, root, baseUrl = '/' } = opts

		const filename = pagePath.replace(/\//g, '_')
		const appStyleResourcePath = `${baseUrl}${appId}/main/app.css`
		const styleResourcePath = `${baseUrl}${appId}/${root}/${filename}.css`
		const viewResourcePath = `${baseUrl}${appId}/${root}/${filename}.js`

		Promise.allSettled([
			this.loadStyleFile(appStyleResourcePath),
			this.loadStyleFile(styleResourcePath),
			this.loadScriptFile(viewResourcePath),
		]).then(
			(results) => {
				window.modRequire(pagePath)
				message.invoke({
					type: 'renderResourceLoaded',
					target: 'service',
					body: {
						bridgeId,
					},
				})

				const errors = results
					.filter(result => result.status === 'rejected')
					.map(result => result.reason)
				if (errors.length) {
					console.error('[system]', '[render]', `资源加载失败: ${errors}`)
				}
			},
		)
	}

	loadStyleFile(path) {
		return new Promise((resolve, reject) => {
			const style = document.createElement('link')
			style.rel = 'stylesheet'
			style.href = path
			style.onload = () => {
				resolve()
			}
			style.onerror = () => {
				reject(new Error(`样式文件加载失败: ${path}`))
			}
			document.head.append(style)
		})
	}

	loadScriptFile(path) {
		return new Promise((resolve, reject) => {
			const script = document.createElement('script')
			script.src = path
			script.onload = () => {
				resolve()
			}
			script.onerror = () => {
				reject(new Error(`脚本文件加载失败: ${path}`))
			}
			document.head.append(script)
		})
	}

	/**
	 * 创建渲染层映射实例
	 * window.Module -> create
	 * @param {{path: string, scopeId: string, usingComponents: object, render: Function}} moduleInfo
	 */
	createModule(moduleInfo) {
		const { path, usingComponents } = moduleInfo
		if (this.staticModules[path]) {
			return
		}

		this.staticModules[path] = new Module(moduleInfo)

		for (const componentPath of Object.values(usingComponents)) {
			window.modRequire(componentPath)
		}
	}

	/**
	 * serviceResourceLoaded && renderResourceLoaded ->
	 * [Container]resourceLoaded -> [Service]resourceLoaded -> [Service]initialDataReady -> [Container]initialDataReady -> [Render]setInitialData
	 * @param {*} initialData
	 */
	setInitialData(initialData) {
		for (const [path, data] of Object.entries(initialData)) {
			if (!data) {
				continue
			}
			const module = this.staticModules[path]
			if (!module) {
				continue
			}
			module.setInitialData(data)
		}
	}

	getModuleByPath(path) {
		return this.staticModules[path]
	}
}

export default new Loader()
