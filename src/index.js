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

  show() {
    this.postMessage("show", 888, {});
  }

  hide() {
    this.postMessage("hide", 888, {});
  }

  getConfig = async () => {
    const info = await fcl.config().all()
    this.postMessage("getConfig", 888, info);
  }

  currentUser = async () => {
    const userInfo = await fcl.currentUser().snapshot()
    this.postMessage("currentUser", 888, userInfo);
  }

  getAccount = async (addr) => {
    const account = await fcl.send([fcl.getAccount(addr)])
    const response = await fcl.decode(account)
    this.postMessage("account", 888, response)
  }

  reauth = async () => {
    const userInfo = await fcl.authenticate()
    this.postMessage("reauth", 888, userInfo);
  }

  sendTransaction = async () => {
    const simpleTransaction = `\
    transaction {
      execute {
        log("A transaction happened")
      }
    }
    `

    const isSealed = true;
    const blockResponse = await fcl.send([
      fcl.getBlock(isSealed),
    ])

    const block = await fcl.decode(blockResponse)

    try {
      const { transactionId } = await fcl.send([
        fcl.transaction(simpleTransaction),
        fcl.proposer(fcl.currentUser().authorization),
        fcl.payer(fcl.currentUser().authorization),
        fcl.ref(block.id),
      ])

      const unsub = fcl
        .tx({ transactionId })
        .subscribe(transaction => {
          this.postMessage(transaction)
          if (fcl.tx.isSealed(transaction)) {
            unsub()
          }
        })
    } catch (error) {
      console.error(error);
    }
  }

  scriptOne = async () => {

    const scriptOne = `\
    pub fun main(): Int {
      return 42 + 6
    }
    `
    const response = await fcl.send([
      fcl.script(scriptOne),
    ])

    const result = await fcl.decode(response)
    this.postMessage("scriptOne", 888, result)
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
      fclnative.postMessage(object)
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

var targetNode = document.body;
var observer = new MutationObserver(function () {
  var shouldShow = false;
  for (var key of targetNode.childNodes.values()) {
    if (key.nodeName === 'IFRAME' && key.id === 'FCL_IFRAME') {
      shouldShow = true;
    }
  }
  if (shouldShow) {
    window.fclbridge.show();
  } else {
    window.fclbridge.hide();
  }
});

const config = { childList: true };
observer.observe(targetNode, config);