import * as fcl from "@onflow/fcl/src/fcl"
import { EventEmitter } from "events";

window.fcl = fcl;
window.addEventListener("message", d => {
  console.log("Message Received", d.data);
});

class FCLNativeBridge extends EventEmitter {

  constructor() {
    super();
    this.callbacks = new Map();
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
    fcl.send([fcl.getAccount(addr)]).then((account) => {
      fcl.decode(account).then((response) => {
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
  postMessage(name, id, data) {
    let object = {
      id: id,
      name: name,
      object: data,
    };
    if (window.fclnative.postMessage) {
      webkit.messageHandlers._fcl_.postMessage(jsonString)
    } else {
      // old clients
      window.webkit.messageHandlers[name].postMessage(object);
    }
  }
}

window.fclnative = {
  Bridge: FCLNativeBridge,
  postMessage: null,
};

window.fclbridge = new fclnative.Bridge();
fclnative.postMessage = (jsonString) => {
  webkit.messageHandlers._fcl_.postMessage(jsonString)
};