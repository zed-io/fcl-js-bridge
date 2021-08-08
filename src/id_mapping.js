"use strict";

class IdMapping {
  constructor() {
    this.intIds = new Map;
  }

  genId() {
    return new Date().getTime() + Math.floor(Math.random() * 1000);
  }

  tryIntifyId(payload) {
    if (!payload.id) {
      payload.id = genId();
      return;
    }
    if (typeof payload.id !== "number") {
      let newId = genId();
      this.intIds.set(newId, payload.id);
      payload.id = newId;
    }
  }

  tryRestoreId(payload) {
    let id = this.tryPopId(payload.id);
    if (id) {
      payload.id = id;
    }
  }

  tryPopId(id) {
    let originId = this.intIds.get(id);
    if (originId) {
      this.intIds.delete(id);
    }
    return originId;
  }
}

module.exports = IdMapping;