import { DMPMap } from '../Utils/DMPMap'
import { DMPContainerBridgesModule } from './DMPContainerBridgesModule'

import vibrator from '@ohos.vibrator';
import { BusinessError } from '@ohos.base';
import { DMPBridgeCallback } from './DMPTSUtil'

export class DMPContainerBridgesModuleVibrate extends DMPContainerBridgesModule {
  getExportMethods(): string[] {
    return ['vibrateLong', 'vibrateShort'];
  }

  vibrateLong(data: DMPMap, callback: DMPBridgeCallback) {
    this.vibrate(200)
  }

  vibrateShort(data: DMPMap, callback: DMPBridgeCallback) {
    this.vibrate(100)
  }


  //
  private vibrate(time: number) {

    try {
      vibrator.startVibration({
        type: 'time',
        duration: time,
      }, {
        id: 0,
        usage: 'alarm'
      }, (error: BusinessError) => {
        if (error) {
          console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        console.info('Succeed in starting vibration');
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }
}

// type RequestVibrateCallBack = (result: Boolean) => void ;



