import * as fcl from "@onflow/fcl/src/fcl"
import { EventEmitter } from "events";
import IdMapping from "./id_mapping";

window.fcl = fcl;
window.addEventListener("message", d => {
  console.log("Message Received", d.data);
});

class FCLNativeBridge extends EventEmitter {

  constructor() {
    super();
    this.idMapping = new IdMapping();
    this.callbacks = new Map();
    this.wrapResults = new Map();
    this.isFCLNative = true;
    this.isDebug = true;
  }

  getConfig() {
    fcl.config().all().then((info) => {
      this.postMessage("getConfig", 888, info);
    })
  }

  currentUser() {
    fcl.currentUser().snapshot().then((userInfo) => {
      this.postMessage("currentUser", 888, userInfo);
    })
  }

  getAccount(addr) {
    console.log("AAAAAAA -> getAccount", addr);
    fcl.send([fcl.getAccount(addr)]).then((account) => {
      console.log("AAAAAAA -> getAccount", account);
      fcl.decode(account).then((response) => {
        console.log("AAAAAAA -> decode", response);
        this.postMessage("account", 888, response)
      })
    })
  }

  reauth() {
    fcl.reauthenticate().then((userInfo) => {
      this.postMessage("reauth", 888, userInfo);
    });
  }

  /**
   * @private Internal js -> native message handler
   */
  postMessage(handler, id, data) {
    console.log("AAAAAAA -> postMessage", data);
    let object = {
      id: id,
      name: handler,
      object: data,
    };
    if (window.fclnative.postMessage) {
      console.log("AAA -> window.fclnative.postMessage(object);");
      window.fclnative.postMessage(object);
    } else {
      // old clients
      console.log("AAA -> old clients");
      window.webkit.messageHandlers[handler].postMessage(object);
    }
  }

  /**
  * @private Internal native result -> js
  */
  sendResponse(id, result) {
    let originId = this.idMapping.tryPopId(id) || id;
    let callback = this.callbacks.get(id);
    let wrapResult = this.wrapResults.get(id);
    let data = { id: originId };
    if (typeof result === "object" && result.result) {
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
    }
  }

  /**
  * @private Internal native error -> js
  */
  sendError(id, error) {
    console.log(`<== ${id} sendError ${error}`);
    let callback = this.callbacks.get(id);
    if (callback) {
      callback(error instanceof Error ? error : new Error(error), null);
      this.callbacks.delete(id);
    }
  }
}

window.fclnative = {
  Bridge: FCLNativeBridge,
  postMessage: null,
};