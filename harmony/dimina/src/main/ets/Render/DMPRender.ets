import { DMPApp } from '../DApp/DMPApp';
import { DMPWebViewController } from '../HybridContainer/DMPWebViewController';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { DMPMap } from '../Utils/DMPMap';


export class DMPRender {
  controllerMap: Map<number, DMPWebViewController> = new Map()
  app: DMPApp;

  constructor(app: DMPApp) {
    this.app = app
    // 在 Web 组件初始化之前，通过此接口加载 Web 引擎的动态库文件，以提高启动性能。
    // web_webview.WebviewController.initializeWebEngine()
  }


  executeScript(script: string, webViewId: number, callback?: AsyncCallback<string>) {
    const controller = this.controllerMap.get(webViewId)
    if (controller) {
      controller.runJavaScript(script, (error, result) => {
        if (error) {
          console.info(`run JavaScript error: ` + JSON.stringify(error))
          return;
        }
      });
    }
  }

  getController(webViewId: number): DMPWebViewController {
    const controller = this.controllerMap.get(webViewId)
    return controller!
  }

  setController(webViewId: number,controller:DMPWebViewController){
    this.controllerMap.set(webViewId, controller)
  }

  removeController(webViewId: number) {
    this.controllerMap.delete(webViewId)
  }

  public fromContainerNext(data: DMPMap, webViewId: number) {
    const dataString = data.toStr();
    this.executeScript(`DiminaRenderBridge.onMessage(${dataString})`, webViewId)
  }

  public fromServiceNext(dataString: string, webViewId: number) {
    this.executeScript(`DiminaRenderBridge.onMessage(${dataString})`, webViewId)
  }

  public fromWebviewNext(data: DMPMap, webViewId: number) {
    if (this.app.render.getController(webViewId)) {
      const dataString = data.toStr();
      const controller = this.app.render.getController(webViewId)
      controller.subController && controller.subController.runJavaScript(`DiminaRenderBridge.onMessage(${dataString})`, (error, result) => {
        if (error) {
          console.info(`run webview JavaScript error: ` + JSON.stringify(error))
          return;
        }
      });
    }
  }

  public postMessage(data: DMPMap, webViewId: number) {
    const dataString = data.toStr();
    this.executeScript(`DiminaRenderBridge.onMessage(${dataString})`, webViewId)
  }
}
