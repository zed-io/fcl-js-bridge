
import { EventEmitter } from "events";
import * as fcl from "@onflow/fcl"

class FCLProvider extends EventEmitter {
  constructor() {
    super();

    this.idMapping = new Map();
    this.callbacks = new Map();
    this.isZed = true;
  }

  setConfig() {
    fcl.config()
      .put("app.detail.title", "222222")
  }

  reauthenticate() {
    let object = {
      id: 11,
      message: "Hello word"
    }
    this.postMessage("fcl", 1, object);
  }

  reauthenticate2() {
    let object = {
      id: 11,
      message: "Hello word"
    }
    window.fclProvider.postMessage(object)
  }

  /**
 * @private Internal js -> native message handler
 */
  postMessage(handler, id, data) {
    webkit.messageHandlers._fcl_.postMessage(data)
  }

  /**
 * @private Internal native result -> js
 */
  sendResponse(id, result) {
    let originId = this.idMapping.tryPopId(id) || id;
    let callback = this.callbacks.get(id);
    let wrapResult = this.wrapResults.get(id);
    let data = { jsonrpc: "2.0", id: originId };
    if (typeof result === "object" && result.jsonrpc && result.result) {
      data.result = result.result;
    } else {
      data.result = result;
    }
    if (this.isDebug) {
      console.log(
        `<== sendResponse id: ${id}, result: ${JSON.stringify(
          result
        )}, data: ${JSON.stringify(data)}`
      );
    }
    if (callback) {
      wrapResult ? callback(null, data) : callback(null, result);
      this.callbacks.delete(id);
    } else {
      console.log(`callback id: ${id} not found`);
      // check if it's iframe callback
      for (var i = 0; i < window.frames.length; i++) {
        const frame = window.frames[i];
        try {
          if (frame.ethereum.callbacks.has(id)) {
            frame.ethereum.sendResponse(id, result);
          }
        } catch (error) {
          console.log(`send response to frame error: ${error}`);
        }
      }
    }
  }

}

window.fclProvider = {
  Provider: FCLProvider,
  postMessage: null,
}