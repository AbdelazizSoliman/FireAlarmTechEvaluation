var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __esm = (fn, res) => function __init() {
  return fn && (res = (0, fn[__getOwnPropNames(fn)[0]])(fn = 0)), res;
};
var __commonJS = (cb, mod) => function __require() {
  return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
};
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));

// node_modules/@rails/actioncable/src/adapters.js
var adapters_default;
var init_adapters = __esm({
  "node_modules/@rails/actioncable/src/adapters.js"() {
    adapters_default = {
      logger: typeof console !== "undefined" ? console : void 0,
      WebSocket: typeof WebSocket !== "undefined" ? WebSocket : void 0
    };
  }
});

// node_modules/@rails/actioncable/src/logger.js
var logger_default;
var init_logger = __esm({
  "node_modules/@rails/actioncable/src/logger.js"() {
    init_adapters();
    logger_default = {
      log(...messages) {
        if (this.enabled) {
          messages.push(Date.now());
          adapters_default.logger.log("[ActionCable]", ...messages);
        }
      }
    };
  }
});

// node_modules/@rails/actioncable/src/connection_monitor.js
var now, secondsSince, ConnectionMonitor, connection_monitor_default;
var init_connection_monitor = __esm({
  "node_modules/@rails/actioncable/src/connection_monitor.js"() {
    init_logger();
    now = () => (/* @__PURE__ */ new Date()).getTime();
    secondsSince = (time) => (now() - time) / 1e3;
    ConnectionMonitor = class {
      constructor(connection) {
        this.visibilityDidChange = this.visibilityDidChange.bind(this);
        this.connection = connection;
        this.reconnectAttempts = 0;
      }
      start() {
        if (!this.isRunning()) {
          this.startedAt = now();
          delete this.stoppedAt;
          this.startPolling();
          addEventListener("visibilitychange", this.visibilityDidChange);
          logger_default.log(`ConnectionMonitor started. stale threshold = ${this.constructor.staleThreshold} s`);
        }
      }
      stop() {
        if (this.isRunning()) {
          this.stoppedAt = now();
          this.stopPolling();
          removeEventListener("visibilitychange", this.visibilityDidChange);
          logger_default.log("ConnectionMonitor stopped");
        }
      }
      isRunning() {
        return this.startedAt && !this.stoppedAt;
      }
      recordMessage() {
        this.pingedAt = now();
      }
      recordConnect() {
        this.reconnectAttempts = 0;
        delete this.disconnectedAt;
        logger_default.log("ConnectionMonitor recorded connect");
      }
      recordDisconnect() {
        this.disconnectedAt = now();
        logger_default.log("ConnectionMonitor recorded disconnect");
      }
      // Private
      startPolling() {
        this.stopPolling();
        this.poll();
      }
      stopPolling() {
        clearTimeout(this.pollTimeout);
      }
      poll() {
        this.pollTimeout = setTimeout(
          () => {
            this.reconnectIfStale();
            this.poll();
          },
          this.getPollInterval()
        );
      }
      getPollInterval() {
        const { staleThreshold, reconnectionBackoffRate } = this.constructor;
        const backoff = Math.pow(1 + reconnectionBackoffRate, Math.min(this.reconnectAttempts, 10));
        const jitterMax = this.reconnectAttempts === 0 ? 1 : reconnectionBackoffRate;
        const jitter = jitterMax * Math.random();
        return staleThreshold * 1e3 * backoff * (1 + jitter);
      }
      reconnectIfStale() {
        if (this.connectionIsStale()) {
          logger_default.log(`ConnectionMonitor detected stale connection. reconnectAttempts = ${this.reconnectAttempts}, time stale = ${secondsSince(this.refreshedAt)} s, stale threshold = ${this.constructor.staleThreshold} s`);
          this.reconnectAttempts++;
          if (this.disconnectedRecently()) {
            logger_default.log(`ConnectionMonitor skipping reopening recent disconnect. time disconnected = ${secondsSince(this.disconnectedAt)} s`);
          } else {
            logger_default.log("ConnectionMonitor reopening");
            this.connection.reopen();
          }
        }
      }
      get refreshedAt() {
        return this.pingedAt ? this.pingedAt : this.startedAt;
      }
      connectionIsStale() {
        return secondsSince(this.refreshedAt) > this.constructor.staleThreshold;
      }
      disconnectedRecently() {
        return this.disconnectedAt && secondsSince(this.disconnectedAt) < this.constructor.staleThreshold;
      }
      visibilityDidChange() {
        if (document.visibilityState === "visible") {
          setTimeout(
            () => {
              if (this.connectionIsStale() || !this.connection.isOpen()) {
                logger_default.log(`ConnectionMonitor reopening stale connection on visibilitychange. visibilityState = ${document.visibilityState}`);
                this.connection.reopen();
              }
            },
            200
          );
        }
      }
    };
    ConnectionMonitor.staleThreshold = 6;
    ConnectionMonitor.reconnectionBackoffRate = 0.15;
    connection_monitor_default = ConnectionMonitor;
  }
});

// node_modules/@rails/actioncable/src/internal.js
var internal_default;
var init_internal = __esm({
  "node_modules/@rails/actioncable/src/internal.js"() {
    internal_default = {
      "message_types": {
        "welcome": "welcome",
        "disconnect": "disconnect",
        "ping": "ping",
        "confirmation": "confirm_subscription",
        "rejection": "reject_subscription"
      },
      "disconnect_reasons": {
        "unauthorized": "unauthorized",
        "invalid_request": "invalid_request",
        "server_restart": "server_restart",
        "remote": "remote"
      },
      "default_mount_path": "/cable",
      "protocols": [
        "actioncable-v1-json",
        "actioncable-unsupported"
      ]
    };
  }
});

// node_modules/@rails/actioncable/src/connection.js
var message_types, protocols, supportedProtocols, indexOf, Connection, connection_default;
var init_connection = __esm({
  "node_modules/@rails/actioncable/src/connection.js"() {
    init_adapters();
    init_connection_monitor();
    init_internal();
    init_logger();
    ({ message_types, protocols } = internal_default);
    supportedProtocols = protocols.slice(0, protocols.length - 1);
    indexOf = [].indexOf;
    Connection = class {
      constructor(consumer2) {
        this.open = this.open.bind(this);
        this.consumer = consumer2;
        this.subscriptions = this.consumer.subscriptions;
        this.monitor = new connection_monitor_default(this);
        this.disconnected = true;
      }
      send(data) {
        if (this.isOpen()) {
          this.webSocket.send(JSON.stringify(data));
          return true;
        } else {
          return false;
        }
      }
      open() {
        if (this.isActive()) {
          logger_default.log(`Attempted to open WebSocket, but existing socket is ${this.getState()}`);
          return false;
        } else {
          const socketProtocols = [...protocols, ...this.consumer.subprotocols || []];
          logger_default.log(`Opening WebSocket, current state is ${this.getState()}, subprotocols: ${socketProtocols}`);
          if (this.webSocket) {
            this.uninstallEventHandlers();
          }
          this.webSocket = new adapters_default.WebSocket(this.consumer.url, socketProtocols);
          this.installEventHandlers();
          this.monitor.start();
          return true;
        }
      }
      close({ allowReconnect } = { allowReconnect: true }) {
        if (!allowReconnect) {
          this.monitor.stop();
        }
        if (this.isOpen()) {
          return this.webSocket.close();
        }
      }
      reopen() {
        logger_default.log(`Reopening WebSocket, current state is ${this.getState()}`);
        if (this.isActive()) {
          try {
            return this.close();
          } catch (error2) {
            logger_default.log("Failed to reopen WebSocket", error2);
          } finally {
            logger_default.log(`Reopening WebSocket in ${this.constructor.reopenDelay}ms`);
            setTimeout(this.open, this.constructor.reopenDelay);
          }
        } else {
          return this.open();
        }
      }
      getProtocol() {
        if (this.webSocket) {
          return this.webSocket.protocol;
        }
      }
      isOpen() {
        return this.isState("open");
      }
      isActive() {
        return this.isState("open", "connecting");
      }
      triedToReconnect() {
        return this.monitor.reconnectAttempts > 0;
      }
      // Private
      isProtocolSupported() {
        return indexOf.call(supportedProtocols, this.getProtocol()) >= 0;
      }
      isState(...states) {
        return indexOf.call(states, this.getState()) >= 0;
      }
      getState() {
        if (this.webSocket) {
          for (let state in adapters_default.WebSocket) {
            if (adapters_default.WebSocket[state] === this.webSocket.readyState) {
              return state.toLowerCase();
            }
          }
        }
        return null;
      }
      installEventHandlers() {
        for (let eventName in this.events) {
          const handler = this.events[eventName].bind(this);
          this.webSocket[`on${eventName}`] = handler;
        }
      }
      uninstallEventHandlers() {
        for (let eventName in this.events) {
          this.webSocket[`on${eventName}`] = function() {
          };
        }
      }
    };
    Connection.reopenDelay = 500;
    Connection.prototype.events = {
      message(event) {
        if (!this.isProtocolSupported()) {
          return;
        }
        const { identifier, message, reason, reconnect, type } = JSON.parse(event.data);
        this.monitor.recordMessage();
        switch (type) {
          case message_types.welcome:
            if (this.triedToReconnect()) {
              this.reconnectAttempted = true;
            }
            this.monitor.recordConnect();
            return this.subscriptions.reload();
          case message_types.disconnect:
            logger_default.log(`Disconnecting. Reason: ${reason}`);
            return this.close({ allowReconnect: reconnect });
          case message_types.ping:
            return null;
          case message_types.confirmation:
            this.subscriptions.confirmSubscription(identifier);
            if (this.reconnectAttempted) {
              this.reconnectAttempted = false;
              return this.subscriptions.notify(identifier, "connected", { reconnected: true });
            } else {
              return this.subscriptions.notify(identifier, "connected", { reconnected: false });
            }
          case message_types.rejection:
            return this.subscriptions.reject(identifier);
          default:
            return this.subscriptions.notify(identifier, "received", message);
        }
      },
      open() {
        logger_default.log(`WebSocket onopen event, using '${this.getProtocol()}' subprotocol`);
        this.disconnected = false;
        if (!this.isProtocolSupported()) {
          logger_default.log("Protocol is unsupported. Stopping monitor and disconnecting.");
          return this.close({ allowReconnect: false });
        }
      },
      close(event) {
        logger_default.log("WebSocket onclose event");
        if (this.disconnected) {
          return;
        }
        this.disconnected = true;
        this.monitor.recordDisconnect();
        return this.subscriptions.notifyAll("disconnected", { willAttemptReconnect: this.monitor.isRunning() });
      },
      error() {
        logger_default.log("WebSocket onerror event");
      }
    };
    connection_default = Connection;
  }
});

// node_modules/@rails/actioncable/src/subscription.js
var extend, Subscription;
var init_subscription = __esm({
  "node_modules/@rails/actioncable/src/subscription.js"() {
    extend = function(object, properties) {
      if (properties != null) {
        for (let key in properties) {
          const value = properties[key];
          object[key] = value;
        }
      }
      return object;
    };
    Subscription = class {
      constructor(consumer2, params = {}, mixin) {
        this.consumer = consumer2;
        this.identifier = JSON.stringify(params);
        extend(this, mixin);
      }
      // Perform a channel action with the optional data passed as an attribute
      perform(action, data = {}) {
        data.action = action;
        return this.send(data);
      }
      send(data) {
        return this.consumer.send({ command: "message", identifier: this.identifier, data: JSON.stringify(data) });
      }
      unsubscribe() {
        return this.consumer.subscriptions.remove(this);
      }
    };
  }
});

// node_modules/@rails/actioncable/src/subscription_guarantor.js
var SubscriptionGuarantor, subscription_guarantor_default;
var init_subscription_guarantor = __esm({
  "node_modules/@rails/actioncable/src/subscription_guarantor.js"() {
    init_logger();
    SubscriptionGuarantor = class {
      constructor(subscriptions) {
        this.subscriptions = subscriptions;
        this.pendingSubscriptions = [];
      }
      guarantee(subscription) {
        if (this.pendingSubscriptions.indexOf(subscription) == -1) {
          logger_default.log(`SubscriptionGuarantor guaranteeing ${subscription.identifier}`);
          this.pendingSubscriptions.push(subscription);
        } else {
          logger_default.log(`SubscriptionGuarantor already guaranteeing ${subscription.identifier}`);
        }
        this.startGuaranteeing();
      }
      forget(subscription) {
        logger_default.log(`SubscriptionGuarantor forgetting ${subscription.identifier}`);
        this.pendingSubscriptions = this.pendingSubscriptions.filter((s) => s !== subscription);
      }
      startGuaranteeing() {
        this.stopGuaranteeing();
        this.retrySubscribing();
      }
      stopGuaranteeing() {
        clearTimeout(this.retryTimeout);
      }
      retrySubscribing() {
        this.retryTimeout = setTimeout(
          () => {
            if (this.subscriptions && typeof this.subscriptions.subscribe === "function") {
              this.pendingSubscriptions.map((subscription) => {
                logger_default.log(`SubscriptionGuarantor resubscribing ${subscription.identifier}`);
                this.subscriptions.subscribe(subscription);
              });
            }
          },
          500
        );
      }
    };
    subscription_guarantor_default = SubscriptionGuarantor;
  }
});

// node_modules/@rails/actioncable/src/subscriptions.js
var Subscriptions;
var init_subscriptions = __esm({
  "node_modules/@rails/actioncable/src/subscriptions.js"() {
    init_subscription();
    init_subscription_guarantor();
    init_logger();
    Subscriptions = class {
      constructor(consumer2) {
        this.consumer = consumer2;
        this.guarantor = new subscription_guarantor_default(this);
        this.subscriptions = [];
      }
      create(channelName, mixin) {
        const channel = channelName;
        const params = typeof channel === "object" ? channel : { channel };
        const subscription = new Subscription(this.consumer, params, mixin);
        return this.add(subscription);
      }
      // Private
      add(subscription) {
        this.subscriptions.push(subscription);
        this.consumer.ensureActiveConnection();
        this.notify(subscription, "initialized");
        this.subscribe(subscription);
        return subscription;
      }
      remove(subscription) {
        this.forget(subscription);
        if (!this.findAll(subscription.identifier).length) {
          this.sendCommand(subscription, "unsubscribe");
        }
        return subscription;
      }
      reject(identifier) {
        return this.findAll(identifier).map((subscription) => {
          this.forget(subscription);
          this.notify(subscription, "rejected");
          return subscription;
        });
      }
      forget(subscription) {
        this.guarantor.forget(subscription);
        this.subscriptions = this.subscriptions.filter((s) => s !== subscription);
        return subscription;
      }
      findAll(identifier) {
        return this.subscriptions.filter((s) => s.identifier === identifier);
      }
      reload() {
        return this.subscriptions.map((subscription) => this.subscribe(subscription));
      }
      notifyAll(callbackName, ...args) {
        return this.subscriptions.map((subscription) => this.notify(subscription, callbackName, ...args));
      }
      notify(subscription, callbackName, ...args) {
        let subscriptions;
        if (typeof subscription === "string") {
          subscriptions = this.findAll(subscription);
        } else {
          subscriptions = [subscription];
        }
        return subscriptions.map((subscription2) => typeof subscription2[callbackName] === "function" ? subscription2[callbackName](...args) : void 0);
      }
      subscribe(subscription) {
        if (this.sendCommand(subscription, "subscribe")) {
          this.guarantor.guarantee(subscription);
        }
      }
      confirmSubscription(identifier) {
        logger_default.log(`Subscription confirmed ${identifier}`);
        this.findAll(identifier).map((subscription) => this.guarantor.forget(subscription));
      }
      sendCommand(subscription, command) {
        const { identifier } = subscription;
        return this.consumer.send({ command, identifier });
      }
    };
  }
});

// node_modules/@rails/actioncable/src/consumer.js
function createWebSocketURL(url) {
  if (typeof url === "function") {
    url = url();
  }
  if (url && !/^wss?:/i.test(url)) {
    const a = document.createElement("a");
    a.href = url;
    a.href = a.href;
    a.protocol = a.protocol.replace("http", "ws");
    return a.href;
  } else {
    return url;
  }
}
var Consumer;
var init_consumer = __esm({
  "node_modules/@rails/actioncable/src/consumer.js"() {
    init_connection();
    init_subscriptions();
    Consumer = class {
      constructor(url) {
        this._url = url;
        this.subscriptions = new Subscriptions(this);
        this.connection = new connection_default(this);
        this.subprotocols = [];
      }
      get url() {
        return createWebSocketURL(this._url);
      }
      send(data) {
        return this.connection.send(data);
      }
      connect() {
        return this.connection.open();
      }
      disconnect() {
        return this.connection.close({ allowReconnect: false });
      }
      ensureActiveConnection() {
        if (!this.connection.isActive()) {
          return this.connection.open();
        }
      }
      addSubProtocol(subprotocol) {
        this.subprotocols = [...this.subprotocols, subprotocol];
      }
    };
  }
});

// node_modules/@rails/actioncable/src/index.js
var src_exports = {};
__export(src_exports, {
  Connection: () => connection_default,
  ConnectionMonitor: () => connection_monitor_default,
  Consumer: () => Consumer,
  INTERNAL: () => internal_default,
  Subscription: () => Subscription,
  SubscriptionGuarantor: () => subscription_guarantor_default,
  Subscriptions: () => Subscriptions,
  adapters: () => adapters_default,
  createConsumer: () => createConsumer,
  createWebSocketURL: () => createWebSocketURL,
  getConfig: () => getConfig,
  logger: () => logger_default
});
function createConsumer(url = getConfig("url") || internal_default.default_mount_path) {
  return new Consumer(url);
}
function getConfig(name) {
  const element = document.head.querySelector(`meta[name='action-cable-${name}']`);
  if (element) {
    return element.getAttribute("content");
  }
}
var init_src = __esm({
  "node_modules/@rails/actioncable/src/index.js"() {
    init_connection();
    init_connection_monitor();
    init_consumer();
    init_internal();
    init_subscription();
    init_subscriptions();
    init_subscription_guarantor();
    init_adapters();
    init_logger();
  }
});

// node_modules/slim-select/dist/slimselect.js
var require_slimselect = __commonJS({
  "node_modules/slim-select/dist/slimselect.js"(exports, module) {
    (function(global, factory) {
      typeof exports === "object" && typeof module !== "undefined" ? module.exports = factory() : typeof define === "function" && define.amd ? define(factory) : (global = typeof globalThis !== "undefined" ? globalThis : global || self, global.SlimSelect = factory());
    })(exports, function() {
      "use strict";
      class CssClasses {
        constructor(classes) {
          if (!classes) {
            classes = {};
          }
          this.main = classes.main || "ss-main";
          this.placeholder = classes.placeholder || "ss-placeholder";
          this.values = classes.values || "ss-values";
          this.single = classes.single || "ss-single";
          this.max = classes.max || "ss-max";
          this.value = classes.value || "ss-value";
          this.valueText = classes.valueText || "ss-value-text";
          this.valueDelete = classes.valueDelete || "ss-value-delete";
          this.valueOut = classes.valueOut || "ss-value-out";
          this.deselect = classes.deselect || "ss-deselect";
          this.deselectPath = classes.deselectPath || "M10,10 L90,90 M10,90 L90,10";
          this.arrow = classes.arrow || "ss-arrow";
          this.arrowClose = classes.arrowClose || "M10,30 L50,70 L90,30";
          this.arrowOpen = classes.arrowOpen || "M10,70 L50,30 L90,70";
          this.content = classes.content || "ss-content";
          this.openAbove = classes.openAbove || "ss-open-above";
          this.openBelow = classes.openBelow || "ss-open-below";
          this.search = classes.search || "ss-search";
          this.searchHighlighter = classes.searchHighlighter || "ss-search-highlight";
          this.searching = classes.searching || "ss-searching";
          this.addable = classes.addable || "ss-addable";
          this.addablePath = classes.addablePath || "M50,10 L50,90 M10,50 L90,50";
          this.list = classes.list || "ss-list";
          this.optgroup = classes.optgroup || "ss-optgroup";
          this.optgroupLabel = classes.optgroupLabel || "ss-optgroup-label";
          this.optgroupLabelText = classes.optgroupLabelText || "ss-optgroup-label-text";
          this.optgroupActions = classes.optgroupActions || "ss-optgroup-actions";
          this.optgroupSelectAll = classes.optgroupSelectAll || "ss-selectall";
          this.optgroupSelectAllBox = classes.optgroupSelectAllBox || "M60,10 L10,10 L10,90 L90,90 L90,50";
          this.optgroupSelectAllCheck = classes.optgroupSelectAllCheck || "M30,45 L50,70 L90,10";
          this.optgroupClosable = classes.optgroupClosable || "ss-closable";
          this.option = classes.option || "ss-option";
          this.optionDelete = classes.optionDelete || "M10,10 L90,90 M10,90 L90,10";
          this.highlighted = classes.highlighted || "ss-highlighted";
          this.open = classes.open || "ss-open";
          this.close = classes.close || "ss-close";
          this.selected = classes.selected || "ss-selected";
          this.error = classes.error || "ss-error";
          this.disabled = classes.disabled || "ss-disabled";
          this.hide = classes.hide || "ss-hide";
        }
      }
      function generateID() {
        return Math.random().toString(36).substring(2, 10);
      }
      function hasClassInTree(element, className) {
        function hasClass(e, c) {
          if (c && e && e.classList && e.classList.contains(c)) {
            return e;
          }
          if (c && e && e.dataset && e.dataset.id && e.dataset.id === className) {
            return e;
          }
          return null;
        }
        function parentByClass(e, c) {
          if (!e || e === document) {
            return null;
          } else if (hasClass(e, c)) {
            return e;
          } else {
            return parentByClass(e.parentNode, c);
          }
        }
        return hasClass(element, className) || parentByClass(element, className);
      }
      function debounce2(func, wait = 50, immediate = false) {
        let timeout2;
        return function(...args) {
          const context = self;
          const later = () => {
            timeout2 = null;
            if (!immediate) {
              func.apply(context, args);
            }
          };
          const callNow = immediate && !timeout2;
          clearTimeout(timeout2);
          timeout2 = setTimeout(later, wait);
          if (callNow) {
            func.apply(context, args);
          }
        };
      }
      function isEqual(a, b) {
        return JSON.stringify(a) === JSON.stringify(b);
      }
      function kebabCase(str) {
        const result = str.replace(/[A-Z\u00C0-\u00D6\u00D8-\u00DE]/g, (match) => "-" + match.toLowerCase());
        return str[0] === str[0].toUpperCase() ? result.substring(1) : result;
      }
      class Optgroup {
        constructor(optgroup) {
          this.id = !optgroup.id || optgroup.id === "" ? generateID() : optgroup.id;
          this.label = optgroup.label || "";
          this.selectAll = optgroup.selectAll === void 0 ? false : optgroup.selectAll;
          this.selectAllText = optgroup.selectAllText || "Select All";
          this.closable = optgroup.closable || "off";
          this.options = [];
          if (optgroup.options) {
            for (const o of optgroup.options) {
              this.options.push(new Option(o));
            }
          }
        }
      }
      class Option {
        constructor(option) {
          this.id = !option.id || option.id === "" ? generateID() : option.id;
          this.value = option.value === void 0 ? option.text : option.value;
          this.text = option.text || "";
          this.html = option.html || "";
          this.selected = option.selected !== void 0 ? option.selected : false;
          this.display = option.display !== void 0 ? option.display : true;
          this.disabled = option.disabled !== void 0 ? option.disabled : false;
          this.mandatory = option.mandatory !== void 0 ? option.mandatory : false;
          this.placeholder = option.placeholder !== void 0 ? option.placeholder : false;
          this.class = option.class || "";
          this.style = option.style || "";
          this.data = option.data || {};
        }
      }
      class Store {
        constructor(type, data) {
          this.selectType = "single";
          this.data = [];
          this.selectedOrder = [];
          this.selectType = type;
          this.setData(data);
        }
        validateDataArray(data) {
          if (!Array.isArray(data)) {
            return new Error("Data must be an array");
          }
          for (let dataObj of data) {
            if (dataObj instanceof Optgroup || "label" in dataObj) {
              if (!("label" in dataObj)) {
                return new Error("Optgroup must have a label");
              }
              if ("options" in dataObj && dataObj.options) {
                for (let option of dataObj.options) {
                  const validationError = this.validateOption(option);
                  if (validationError) {
                    return validationError;
                  }
                }
              }
            } else if (dataObj instanceof Option || "text" in dataObj) {
              const validationError = this.validateOption(dataObj);
              if (validationError) {
                return validationError;
              }
            } else {
              return new Error("Data object must be a valid optgroup or option");
            }
          }
          return null;
        }
        validateOption(option) {
          if (!("text" in option)) {
            return new Error("Option must have a text");
          }
          return null;
        }
        partialToFullData(data) {
          let dataFinal = [];
          data.forEach((dataObj) => {
            if (dataObj instanceof Optgroup || "label" in dataObj) {
              let optOptions = [];
              if ("options" in dataObj && dataObj.options) {
                dataObj.options.forEach((option) => {
                  optOptions.push(new Option(option));
                });
              }
              if (optOptions.length > 0) {
                dataFinal.push(new Optgroup(dataObj));
              }
            }
            if (dataObj instanceof Option || "text" in dataObj) {
              dataFinal.push(new Option(dataObj));
            }
          });
          return dataFinal;
        }
        setData(data) {
          this.data = this.partialToFullData(data);
          if (this.selectType === "single") {
            this.setSelectedBy("id", this.getSelected());
          }
        }
        getData() {
          return this.filter(null, true);
        }
        getDataOptions() {
          return this.filter(null, false);
        }
        addOption(option, addToStart = false) {
          if (addToStart) {
            let data = [new Option(option)];
            this.setData(data.concat(this.getData()));
          } else {
            this.setData(this.getData().concat(new Option(option)));
          }
        }
        setSelectedBy(selectedType, selectedValues) {
          let firstOption = null;
          let hasSelected = false;
          const selectedObjects = [];
          for (let dataObj of this.data) {
            if (dataObj instanceof Optgroup) {
              for (let option of dataObj.options) {
                if (!firstOption) {
                  firstOption = option;
                }
                option.selected = hasSelected ? false : selectedValues.includes(option[selectedType]);
                if (option.selected) {
                  selectedObjects.push(option);
                  if (this.selectType === "single") {
                    hasSelected = true;
                  }
                }
              }
            }
            if (dataObj instanceof Option) {
              if (!firstOption) {
                firstOption = dataObj;
              }
              dataObj.selected = hasSelected ? false : selectedValues.includes(dataObj[selectedType]);
              if (dataObj.selected) {
                selectedObjects.push(dataObj);
                if (this.selectType === "single") {
                  hasSelected = true;
                }
              }
            }
          }
          if (this.selectType === "single" && firstOption && !hasSelected) {
            firstOption.selected = true;
            selectedObjects.push(firstOption);
          }
          const selectedIds = selectedValues.map((value) => {
            var _a;
            return ((_a = selectedObjects.find((option) => option[selectedType] === value)) === null || _a === void 0 ? void 0 : _a.id) || "";
          });
          this.selectedOrder = selectedIds;
        }
        getSelected() {
          return this.getSelectedOptions().map((option) => option.id);
        }
        getSelectedValues() {
          return this.getSelectedOptions().map((option) => option.value);
        }
        getSelectedOptions() {
          return this.filter((opt) => {
            return opt.selected;
          }, false);
        }
        getOptgroupByID(id) {
          for (let dataObj of this.data) {
            if (dataObj instanceof Optgroup && dataObj.id === id) {
              return dataObj;
            }
          }
          return null;
        }
        getOptionByID(id) {
          let options = this.filter((opt) => {
            return opt.id === id;
          }, false);
          return options.length ? options[0] : null;
        }
        getSelectType() {
          return this.selectType;
        }
        getFirstOption() {
          let option = null;
          for (let dataObj of this.data) {
            if (dataObj instanceof Optgroup) {
              option = dataObj.options[0];
            } else if (dataObj instanceof Option) {
              option = dataObj;
            }
            if (option) {
              break;
            }
          }
          return option;
        }
        search(search, searchFilter) {
          search = search.trim();
          if (search === "") {
            return this.getData();
          }
          return this.filter((opt) => {
            return searchFilter(opt, search);
          }, true);
        }
        filter(filter, includeOptgroup) {
          const dataSearch = [];
          this.data.forEach((dataObj) => {
            if (dataObj instanceof Optgroup) {
              let optOptions = [];
              dataObj.options.forEach((option) => {
                if (!filter || filter(option)) {
                  if (!includeOptgroup) {
                    dataSearch.push(new Option(option));
                  } else {
                    optOptions.push(new Option(option));
                  }
                }
              });
              if (optOptions.length > 0) {
                let optgroup = new Optgroup(dataObj);
                optgroup.options = optOptions;
                dataSearch.push(optgroup);
              }
            }
            if (dataObj instanceof Option) {
              if (!filter || filter(dataObj)) {
                dataSearch.push(new Option(dataObj));
              }
            }
          });
          return dataSearch;
        }
        selectedOrderOptions(options) {
          const newOrder = [];
          this.selectedOrder.forEach((id) => {
            const option = options.find((opt) => opt.id === id);
            if (option) {
              newOrder.push(option);
            }
          });
          options.forEach((option) => {
            let isIn = false;
            newOrder.forEach((selectedOption) => {
              if (option.id === selectedOption.id) {
                isIn = true;
                return;
              }
            });
            if (!isIn) {
              newOrder.push(option);
            }
          });
          return newOrder;
        }
      }
      class Render {
        constructor(settings, classes, store, callbacks) {
          this.store = store;
          this.settings = settings;
          this.classes = classes;
          this.callbacks = callbacks;
          this.main = this.mainDiv();
          this.content = this.contentDiv();
          this.updateClassStyles();
          this.updateAriaAttributes();
          if (this.settings.contentLocation) {
            this.settings.contentLocation.appendChild(this.content.main);
          }
        }
        enable() {
          this.main.main.classList.remove(this.classes.disabled);
          this.content.search.input.disabled = false;
        }
        disable() {
          this.main.main.classList.add(this.classes.disabled);
          this.content.search.input.disabled = true;
        }
        open() {
          this.main.arrow.path.setAttribute("d", this.classes.arrowOpen);
          this.main.main.classList.add(this.settings.openPosition === "up" ? this.classes.openAbove : this.classes.openBelow);
          this.main.main.setAttribute("aria-expanded", "true");
          this.moveContent();
          const selectedOptions = this.store.getSelectedOptions();
          if (selectedOptions.length) {
            const selectedId = selectedOptions[selectedOptions.length - 1].id;
            const selectedOption = this.content.list.querySelector('[data-id="' + selectedId + '"]');
            if (selectedOption) {
              this.ensureElementInView(this.content.list, selectedOption);
            }
          }
        }
        close() {
          this.main.main.classList.remove(this.classes.openAbove);
          this.main.main.classList.remove(this.classes.openBelow);
          this.main.main.setAttribute("aria-expanded", "false");
          this.content.main.classList.remove(this.classes.openAbove);
          this.content.main.classList.remove(this.classes.openBelow);
          this.main.arrow.path.setAttribute("d", this.classes.arrowClose);
        }
        updateClassStyles() {
          this.main.main.className = "";
          this.main.main.removeAttribute("style");
          this.content.main.className = "";
          this.content.main.removeAttribute("style");
          this.main.main.classList.add(this.classes.main);
          this.content.main.classList.add(this.classes.content);
          if (this.settings.style !== "") {
            this.main.main.style.cssText = this.settings.style;
            this.content.main.style.cssText = this.settings.style;
          }
          if (this.settings.class.length) {
            for (const c of this.settings.class) {
              if (c.trim() !== "") {
                this.main.main.classList.add(c.trim());
                this.content.main.classList.add(c.trim());
              }
            }
          }
          if (this.settings.contentPosition === "relative" || this.settings.contentPosition === "fixed") {
            this.content.main.classList.add("ss-" + this.settings.contentPosition);
          }
        }
        updateAriaAttributes() {
          this.main.main.role = "combobox";
          this.main.main.setAttribute("aria-haspopup", "listbox");
          this.main.main.setAttribute("aria-controls", this.content.main.id);
          this.main.main.setAttribute("aria-expanded", "false");
          this.content.main.setAttribute("role", "listbox");
        }
        mainDiv() {
          var _a;
          const main = document.createElement("div");
          main.dataset.id = this.settings.id;
          main.setAttribute("aria-label", this.settings.ariaLabel);
          main.tabIndex = 0;
          main.onkeydown = (e) => {
            switch (e.key) {
              case "ArrowUp":
              case "ArrowDown":
                this.callbacks.open();
                e.key === "ArrowDown" ? this.highlight("down") : this.highlight("up");
                return false;
              case "Tab":
                this.callbacks.close();
                return true;
              case "Enter":
              case " ":
                this.callbacks.open();
                const highlighted = this.content.list.querySelector("." + this.classes.highlighted);
                if (highlighted) {
                  highlighted.click();
                }
                return false;
              case "Escape":
                this.callbacks.close();
                return false;
            }
            if (e.key.length === 1) {
              this.callbacks.open();
            }
            return true;
          };
          main.onclick = (e) => {
            if (this.settings.disabled) {
              return;
            }
            this.settings.isOpen ? this.callbacks.close() : this.callbacks.open();
          };
          const values = document.createElement("div");
          values.classList.add(this.classes.values);
          main.appendChild(values);
          const deselect = document.createElement("div");
          deselect.classList.add(this.classes.deselect);
          const selectedOptions = (_a = this.store) === null || _a === void 0 ? void 0 : _a.getSelectedOptions();
          if (!this.settings.allowDeselect || this.settings.isMultiple && selectedOptions && selectedOptions.length <= 0) {
            deselect.classList.add(this.classes.hide);
          } else {
            deselect.classList.remove(this.classes.hide);
          }
          deselect.onclick = (e) => {
            e.stopPropagation();
            if (this.settings.disabled) {
              return;
            }
            let shouldDelete = true;
            const before = this.store.getSelectedOptions();
            const after = [];
            if (this.callbacks.beforeChange) {
              shouldDelete = this.callbacks.beforeChange(after, before) === true;
            }
            if (shouldDelete) {
              if (this.settings.isMultiple) {
                this.callbacks.setSelected([], false);
                this.updateDeselectAll();
              } else {
                const firstOption = this.store.getFirstOption();
                const id = firstOption ? firstOption.id : "";
                this.callbacks.setSelected(id, false);
              }
              if (this.settings.closeOnSelect) {
                this.callbacks.close();
              }
              if (this.callbacks.afterChange) {
                this.callbacks.afterChange(this.store.getSelectedOptions());
              }
            }
          };
          const deselectSvg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
          deselectSvg.setAttribute("viewBox", "0 0 100 100");
          const deselectPath = document.createElementNS("http://www.w3.org/2000/svg", "path");
          deselectPath.setAttribute("d", this.classes.deselectPath);
          deselectSvg.appendChild(deselectPath);
          deselect.appendChild(deselectSvg);
          main.appendChild(deselect);
          const arrow = document.createElementNS("http://www.w3.org/2000/svg", "svg");
          arrow.classList.add(this.classes.arrow);
          arrow.setAttribute("viewBox", "0 0 100 100");
          const arrowPath = document.createElementNS("http://www.w3.org/2000/svg", "path");
          arrowPath.setAttribute("d", this.classes.arrowClose);
          if (this.settings.alwaysOpen) {
            arrow.classList.add(this.classes.hide);
          }
          arrow.appendChild(arrowPath);
          main.appendChild(arrow);
          return {
            main,
            values,
            deselect: {
              main: deselect,
              svg: deselectSvg,
              path: deselectPath
            },
            arrow: {
              main: arrow,
              path: arrowPath
            }
          };
        }
        mainFocus(eventType) {
          if (eventType !== "click") {
            this.main.main.focus({ preventScroll: true });
          }
        }
        placeholder() {
          const placeholderOption = this.store.filter((o) => o.placeholder, false);
          let placeholderText = this.settings.placeholderText;
          if (placeholderOption.length) {
            if (placeholderOption[0].html !== "") {
              placeholderText = placeholderOption[0].html;
            } else if (placeholderOption[0].text !== "") {
              placeholderText = placeholderOption[0].text;
            }
          }
          const placeholder = document.createElement("div");
          placeholder.classList.add(this.classes.placeholder);
          placeholder.innerHTML = placeholderText;
          return placeholder;
        }
        renderValues() {
          if (!this.settings.isMultiple) {
            this.renderSingleValue();
            return;
          }
          this.renderMultipleValues();
          this.updateDeselectAll();
        }
        renderSingleValue() {
          const selected = this.store.filter((o) => {
            return o.selected && !o.placeholder;
          }, false);
          const selectedSingle = selected.length > 0 ? selected[0] : null;
          if (!selectedSingle) {
            this.main.values.innerHTML = this.placeholder().outerHTML;
          } else {
            const singleValue = document.createElement("div");
            singleValue.classList.add(this.classes.single);
            if (selectedSingle.html) {
              singleValue.innerHTML = selectedSingle.html;
            } else {
              singleValue.innerText = selectedSingle.text;
            }
            this.main.values.innerHTML = singleValue.outerHTML;
          }
          if (!this.settings.allowDeselect || !selected.length) {
            this.main.deselect.main.classList.add(this.classes.hide);
          } else {
            this.main.deselect.main.classList.remove(this.classes.hide);
          }
        }
        renderMultipleValues() {
          let currentNodes = this.main.values.childNodes;
          let selectedOptions = this.store.filter((opt) => {
            return opt.selected && opt.display;
          }, false);
          if (selectedOptions.length === 0) {
            this.main.values.innerHTML = this.placeholder().outerHTML;
            return;
          } else {
            const placeholder = this.main.values.querySelector("." + this.classes.placeholder);
            if (placeholder) {
              placeholder.remove();
            }
          }
          if (selectedOptions.length > this.settings.maxValuesShown) {
            const singleValue = document.createElement("div");
            singleValue.classList.add(this.classes.max);
            singleValue.textContent = this.settings.maxValuesMessage.replace("{number}", selectedOptions.length.toString());
            this.main.values.innerHTML = singleValue.outerHTML;
            return;
          } else {
            const maxValuesMessage = this.main.values.querySelector("." + this.classes.max);
            if (maxValuesMessage) {
              maxValuesMessage.remove();
            }
          }
          if (this.settings.keepOrder) {
            selectedOptions = this.store.selectedOrderOptions(selectedOptions);
          }
          let removeNodes = [];
          for (let i = 0; i < currentNodes.length; i++) {
            const node = currentNodes[i];
            const id = node.getAttribute("data-id");
            if (id) {
              const found = selectedOptions.filter((opt) => {
                return opt.id === id;
              }, false);
              if (!found.length) {
                removeNodes.push(node);
              }
            }
          }
          for (const n of removeNodes) {
            n.classList.add(this.classes.valueOut);
            setTimeout(() => {
              if (this.main.values.hasChildNodes() && this.main.values.contains(n)) {
                this.main.values.removeChild(n);
              }
            }, 100);
          }
          currentNodes = this.main.values.childNodes;
          for (let d = 0; d < selectedOptions.length; d++) {
            let shouldAdd = true;
            for (let i = 0; i < currentNodes.length; i++) {
              if (selectedOptions[d].id === String(currentNodes[i].dataset.id)) {
                shouldAdd = false;
              }
            }
            if (shouldAdd) {
              if (this.settings.keepOrder) {
                this.main.values.appendChild(this.multipleValue(selectedOptions[d]));
              } else {
                if (currentNodes.length === 0) {
                  this.main.values.appendChild(this.multipleValue(selectedOptions[d]));
                } else if (d === 0) {
                  this.main.values.insertBefore(this.multipleValue(selectedOptions[d]), currentNodes[d]);
                } else {
                  currentNodes[d - 1].insertAdjacentElement("afterend", this.multipleValue(selectedOptions[d]));
                }
              }
            }
          }
        }
        multipleValue(option) {
          const value = document.createElement("div");
          value.classList.add(this.classes.value);
          value.dataset.id = option.id;
          const text = document.createElement("div");
          text.classList.add(this.classes.valueText);
          text.textContent = option.text;
          value.appendChild(text);
          if (!option.mandatory) {
            const deleteDiv = document.createElement("div");
            deleteDiv.classList.add(this.classes.valueDelete);
            deleteDiv.onclick = (e) => {
              e.preventDefault();
              e.stopPropagation();
              if (this.settings.disabled) {
                return;
              }
              let shouldDelete = true;
              const before = this.store.getSelectedOptions();
              const after = before.filter((o) => {
                return o.selected && o.id !== option.id;
              }, true);
              if (this.settings.minSelected && after.length < this.settings.minSelected) {
                return;
              }
              if (this.callbacks.beforeChange) {
                shouldDelete = this.callbacks.beforeChange(after, before) === true;
              }
              if (shouldDelete) {
                let selectedIds = [];
                for (const o of after) {
                  if (o instanceof Optgroup) {
                    for (const c of o.options) {
                      selectedIds.push(c.id);
                    }
                  }
                  if (o instanceof Option) {
                    selectedIds.push(o.id);
                  }
                }
                this.callbacks.setSelected(selectedIds, false);
                if (this.settings.closeOnSelect) {
                  this.callbacks.close();
                }
                if (this.callbacks.afterChange) {
                  this.callbacks.afterChange(after);
                }
                this.updateDeselectAll();
              }
            };
            const deleteSvg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
            deleteSvg.setAttribute("viewBox", "0 0 100 100");
            const deletePath = document.createElementNS("http://www.w3.org/2000/svg", "path");
            deletePath.setAttribute("d", this.classes.optionDelete);
            deleteSvg.appendChild(deletePath);
            deleteDiv.appendChild(deleteSvg);
            value.appendChild(deleteDiv);
          }
          return value;
        }
        contentDiv() {
          const main = document.createElement("div");
          main.dataset.id = this.settings.id;
          const search = this.searchDiv();
          main.appendChild(search.main);
          const list = this.listDiv();
          main.appendChild(list);
          return {
            main,
            search,
            list
          };
        }
        moveContent() {
          if (this.settings.contentPosition === "relative") {
            this.moveContentBelow();
            return;
          }
          if (this.settings.openPosition === "down") {
            this.moveContentBelow();
            return;
          } else if (this.settings.openPosition === "up") {
            this.moveContentAbove();
            return;
          }
          if (this.putContent() === "up") {
            this.moveContentAbove();
          } else {
            this.moveContentBelow();
          }
        }
        searchDiv() {
          const main = document.createElement("div");
          const input = document.createElement("input");
          const addable = document.createElement("div");
          main.classList.add(this.classes.search);
          const searchReturn = {
            main,
            input
          };
          if (!this.settings.showSearch) {
            main.classList.add(this.classes.hide);
            input.readOnly = true;
          }
          input.type = "search";
          input.placeholder = this.settings.searchPlaceholder;
          input.tabIndex = -1;
          input.setAttribute("aria-label", this.settings.searchPlaceholder);
          input.setAttribute("autocapitalize", "off");
          input.setAttribute("autocomplete", "off");
          input.setAttribute("autocorrect", "off");
          input.oninput = debounce2((e) => {
            this.callbacks.search(e.target.value);
          }, 100);
          input.onkeydown = (e) => {
            switch (e.key) {
              case "ArrowUp":
              case "ArrowDown":
                e.key === "ArrowDown" ? this.highlight("down") : this.highlight("up");
                return false;
              case "Tab":
                this.callbacks.close();
                return true;
              case "Escape":
                this.callbacks.close();
                return false;
              case " ":
                const highlighted = this.content.list.querySelector("." + this.classes.highlighted);
                if (highlighted) {
                  highlighted.click();
                  return false;
                }
                return true;
              case "Enter":
                if (this.callbacks.addable) {
                  addable.click();
                  return false;
                } else {
                  const highlighted2 = this.content.list.querySelector("." + this.classes.highlighted);
                  if (highlighted2) {
                    highlighted2.click();
                    return false;
                  }
                }
                return true;
            }
            return true;
          };
          main.appendChild(input);
          if (this.callbacks.addable) {
            addable.classList.add(this.classes.addable);
            const plus = document.createElementNS("http://www.w3.org/2000/svg", "svg");
            plus.setAttribute("viewBox", "0 0 100 100");
            const plusPath = document.createElementNS("http://www.w3.org/2000/svg", "path");
            plusPath.setAttribute("d", this.classes.addablePath);
            plus.appendChild(plusPath);
            addable.appendChild(plus);
            addable.onclick = (e) => {
              e.preventDefault();
              e.stopPropagation();
              if (!this.callbacks.addable) {
                return;
              }
              const inputValue = this.content.search.input.value.trim();
              if (inputValue === "") {
                this.content.search.input.focus();
                return;
              }
              const runFinish = (oo) => {
                let newOption = new Option(oo);
                this.callbacks.addOption(newOption);
                if (this.settings.isMultiple) {
                  let ids = this.store.getSelected();
                  ids.push(newOption.id);
                  this.callbacks.setSelected(ids, true);
                } else {
                  this.callbacks.setSelected([newOption.id], true);
                }
                this.callbacks.search("");
                if (this.settings.closeOnSelect) {
                  setTimeout(() => {
                    this.callbacks.close();
                  }, 100);
                }
              };
              const addableValue = this.callbacks.addable(inputValue);
              if (addableValue === false || addableValue === void 0 || addableValue === null) {
                return;
              }
              if (addableValue instanceof Promise) {
                addableValue.then((value) => {
                  if (typeof value === "string") {
                    runFinish({
                      text: value,
                      value
                    });
                  } else if (addableValue instanceof Error) {
                    this.renderError(addableValue.message);
                  } else {
                    runFinish(value);
                  }
                });
              } else if (typeof addableValue === "string") {
                runFinish({
                  text: addableValue,
                  value: addableValue
                });
              } else if (addableValue instanceof Error) {
                this.renderError(addableValue.message);
              } else {
                runFinish(addableValue);
              }
              return;
            };
            main.appendChild(addable);
            searchReturn.addable = {
              main: addable,
              svg: plus,
              path: plusPath
            };
          }
          return searchReturn;
        }
        searchFocus() {
          this.content.search.input.focus();
        }
        getOptions(notPlaceholder = false, notDisabled = false, notHidden = false) {
          let query = "." + this.classes.option;
          if (notPlaceholder) {
            query += ":not(." + this.classes.placeholder + ")";
          }
          if (notDisabled) {
            query += ":not(." + this.classes.disabled + ")";
          }
          if (notHidden) {
            query += ":not(." + this.classes.hide + ")";
          }
          return Array.from(this.content.list.querySelectorAll(query));
        }
        highlight(dir) {
          const options = this.getOptions(true, true, true);
          if (options.length === 0) {
            return;
          }
          if (options.length === 1) {
            if (!options[0].classList.contains(this.classes.highlighted)) {
              options[0].classList.add(this.classes.highlighted);
              return;
            }
          }
          let highlighted = false;
          for (const o of options) {
            if (o.classList.contains(this.classes.highlighted)) {
              highlighted = true;
            }
          }
          if (!highlighted) {
            for (const o of options) {
              if (o.classList.contains(this.classes.selected)) {
                o.classList.add(this.classes.highlighted);
                break;
              }
            }
          }
          for (let i = 0; i < options.length; i++) {
            if (options[i].classList.contains(this.classes.highlighted)) {
              const prevOption = options[i];
              prevOption.classList.remove(this.classes.highlighted);
              const prevParent = prevOption.parentElement;
              if (prevParent && prevParent.classList.contains(this.classes.open)) {
                const optgroupLabel = prevParent.querySelector("." + this.classes.optgroupLabel);
                if (optgroupLabel) {
                  optgroupLabel.click();
                }
              }
              let selectOption = options[dir === "down" ? i + 1 < options.length ? i + 1 : 0 : i - 1 >= 0 ? i - 1 : options.length - 1];
              selectOption.classList.add(this.classes.highlighted);
              this.ensureElementInView(this.content.list, selectOption);
              const selectParent = selectOption.parentElement;
              if (selectParent && selectParent.classList.contains(this.classes.close)) {
                const optgroupLabel = selectParent.querySelector("." + this.classes.optgroupLabel);
                if (optgroupLabel) {
                  optgroupLabel.click();
                }
              }
              return;
            }
          }
          options[dir === "down" ? 0 : options.length - 1].classList.add(this.classes.highlighted);
          this.ensureElementInView(this.content.list, options[dir === "down" ? 0 : options.length - 1]);
        }
        listDiv() {
          const options = document.createElement("div");
          options.classList.add(this.classes.list);
          return options;
        }
        renderError(error2) {
          this.content.list.innerHTML = "";
          const errorDiv = document.createElement("div");
          errorDiv.classList.add(this.classes.error);
          errorDiv.textContent = error2;
          this.content.list.appendChild(errorDiv);
        }
        renderSearching() {
          this.content.list.innerHTML = "";
          const searchingDiv = document.createElement("div");
          searchingDiv.classList.add(this.classes.searching);
          searchingDiv.textContent = this.settings.searchingText;
          this.content.list.appendChild(searchingDiv);
        }
        renderOptions(data) {
          this.content.list.innerHTML = "";
          if (data.length === 0) {
            const noResults = document.createElement("div");
            noResults.classList.add(this.classes.search);
            if (this.callbacks.addable) {
              noResults.innerHTML = this.settings.addableText.replace("{value}", this.content.search.input.value);
            } else {
              noResults.innerHTML = this.settings.searchText;
            }
            this.content.list.appendChild(noResults);
            return;
          }
          if (this.settings.allowDeselect && !this.settings.isMultiple) {
            const placeholderOption = this.store.filter((o) => o.placeholder, false);
            if (!placeholderOption.length) {
              this.store.addOption(new Option({
                text: "",
                value: "",
                selected: false,
                placeholder: true
              }), true);
            }
          }
          for (const d of data) {
            if (d instanceof Optgroup) {
              const optgroupEl = document.createElement("div");
              optgroupEl.classList.add(this.classes.optgroup);
              const optgroupLabel = document.createElement("div");
              optgroupLabel.classList.add(this.classes.optgroupLabel);
              optgroupEl.appendChild(optgroupLabel);
              const optgroupLabelText = document.createElement("div");
              optgroupLabelText.classList.add(this.classes.optgroupLabelText);
              optgroupLabelText.textContent = d.label;
              optgroupLabel.appendChild(optgroupLabelText);
              const optgroupActions = document.createElement("div");
              optgroupActions.classList.add(this.classes.optgroupActions);
              optgroupLabel.appendChild(optgroupActions);
              if (this.settings.isMultiple && d.selectAll) {
                const selectAll = document.createElement("div");
                selectAll.classList.add(this.classes.optgroupSelectAll);
                let allSelected = true;
                for (const o of d.options) {
                  if (!o.selected) {
                    allSelected = false;
                    break;
                  }
                }
                if (allSelected) {
                  selectAll.classList.add(this.classes.selected);
                }
                const selectAllText = document.createElement("span");
                selectAllText.textContent = d.selectAllText;
                selectAll.appendChild(selectAllText);
                const selectAllSvg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
                selectAllSvg.setAttribute("viewBox", "0 0 100 100");
                selectAll.appendChild(selectAllSvg);
                const selectAllBox = document.createElementNS("http://www.w3.org/2000/svg", "path");
                selectAllBox.setAttribute("d", this.classes.optgroupSelectAllBox);
                selectAllSvg.appendChild(selectAllBox);
                const selectAllCheck = document.createElementNS("http://www.w3.org/2000/svg", "path");
                selectAllCheck.setAttribute("d", this.classes.optgroupSelectAllCheck);
                selectAllSvg.appendChild(selectAllCheck);
                selectAll.addEventListener("click", (e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  const currentSelected = this.store.getSelected();
                  if (allSelected) {
                    const newSelected = currentSelected.filter((s) => {
                      for (const o of d.options) {
                        if (s === o.id) {
                          return false;
                        }
                      }
                      return true;
                    });
                    this.callbacks.setSelected(newSelected, true);
                    return;
                  } else {
                    const newSelected = currentSelected.concat(d.options.map((o) => o.id));
                    for (const o of d.options) {
                      if (!this.store.getOptionByID(o.id)) {
                        this.callbacks.addOption(o);
                      }
                    }
                    this.callbacks.setSelected(newSelected, true);
                    return;
                  }
                });
                optgroupActions.appendChild(selectAll);
              }
              if (d.closable !== "off") {
                const optgroupClosable = document.createElement("div");
                optgroupClosable.classList.add(this.classes.optgroupClosable);
                const optgroupClosableSvg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
                optgroupClosableSvg.setAttribute("viewBox", "0 0 100 100");
                optgroupClosableSvg.classList.add(this.classes.arrow);
                optgroupClosable.appendChild(optgroupClosableSvg);
                const optgroupClosableArrow = document.createElementNS("http://www.w3.org/2000/svg", "path");
                optgroupClosableSvg.appendChild(optgroupClosableArrow);
                if (d.options.some((o) => o.selected) || this.content.search.input.value.trim() !== "") {
                  optgroupClosable.classList.add(this.classes.open);
                  optgroupClosableArrow.setAttribute("d", this.classes.arrowOpen);
                } else if (d.closable === "open") {
                  optgroupEl.classList.add(this.classes.open);
                  optgroupClosableArrow.setAttribute("d", this.classes.arrowOpen);
                } else if (d.closable === "close") {
                  optgroupEl.classList.add(this.classes.close);
                  optgroupClosableArrow.setAttribute("d", this.classes.arrowClose);
                }
                optgroupLabel.addEventListener("click", (e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  if (optgroupEl.classList.contains(this.classes.close)) {
                    optgroupEl.classList.remove(this.classes.close);
                    optgroupEl.classList.add(this.classes.open);
                    optgroupClosableArrow.setAttribute("d", this.classes.arrowOpen);
                  } else {
                    optgroupEl.classList.remove(this.classes.open);
                    optgroupEl.classList.add(this.classes.close);
                    optgroupClosableArrow.setAttribute("d", this.classes.arrowClose);
                  }
                });
                optgroupActions.appendChild(optgroupClosable);
              }
              optgroupEl.appendChild(optgroupLabel);
              for (const o of d.options) {
                optgroupEl.appendChild(this.option(o));
              }
              this.content.list.appendChild(optgroupEl);
            }
            if (d instanceof Option) {
              this.content.list.appendChild(this.option(d));
            }
          }
        }
        option(option) {
          if (option.placeholder) {
            const placeholder = document.createElement("div");
            placeholder.classList.add(this.classes.option);
            placeholder.classList.add(this.classes.hide);
            return placeholder;
          }
          const optionEl = document.createElement("div");
          optionEl.dataset.id = option.id;
          optionEl.classList.add(this.classes.option);
          optionEl.setAttribute("role", "option");
          if (option.class) {
            option.class.split(" ").forEach((dataClass) => {
              optionEl.classList.add(dataClass);
            });
          }
          if (option.style) {
            optionEl.style.cssText = option.style;
          }
          if (this.settings.searchHighlight && this.content.search.input.value.trim() !== "") {
            optionEl.innerHTML = this.highlightText(option.html !== "" ? option.html : option.text, this.content.search.input.value, this.classes.searchHighlighter);
          } else if (option.html !== "") {
            optionEl.innerHTML = option.html;
          } else {
            optionEl.textContent = option.text;
          }
          if (this.settings.showOptionTooltips && optionEl.textContent) {
            optionEl.setAttribute("title", optionEl.textContent);
          }
          if (!option.display) {
            optionEl.classList.add(this.classes.hide);
          }
          if (option.disabled) {
            optionEl.classList.add(this.classes.disabled);
          }
          if (option.selected && this.settings.hideSelected) {
            optionEl.classList.add(this.classes.hide);
          }
          if (option.selected) {
            optionEl.classList.add(this.classes.selected);
            optionEl.setAttribute("aria-selected", "true");
            this.main.main.setAttribute("aria-activedescendant", optionEl.id);
          } else {
            optionEl.classList.remove(this.classes.selected);
            optionEl.setAttribute("aria-selected", "false");
          }
          optionEl.addEventListener("click", (e) => {
            e.preventDefault();
            e.stopPropagation();
            const selectedOptions = this.store.getSelected();
            const element = e.currentTarget;
            const elementID = String(element.dataset.id);
            if (option.disabled || option.selected && !this.settings.allowDeselect) {
              return;
            }
            if (this.settings.isMultiple && this.settings.maxSelected <= selectedOptions.length && !option.selected || this.settings.isMultiple && this.settings.minSelected >= selectedOptions.length && option.selected) {
              return;
            }
            let shouldUpdate = false;
            const before = this.store.getSelectedOptions();
            let after = [];
            if (this.settings.isMultiple) {
              if (option.selected) {
                after = before.filter((o) => o.id !== elementID);
              } else {
                after = before.concat(option);
              }
            }
            if (!this.settings.isMultiple) {
              if (option.selected) {
                after = [];
              } else {
                after = [option];
              }
            }
            if (!this.callbacks.beforeChange) {
              shouldUpdate = true;
            }
            if (this.callbacks.beforeChange) {
              if (this.callbacks.beforeChange(after, before) === false) {
                shouldUpdate = false;
              } else {
                shouldUpdate = true;
              }
            }
            if (shouldUpdate) {
              if (!this.store.getOptionByID(elementID)) {
                this.callbacks.addOption(option);
              }
              this.callbacks.setSelected(after.map((o) => o.id), false);
              if (this.settings.closeOnSelect) {
                this.callbacks.close();
              }
              if (this.callbacks.afterChange) {
                this.callbacks.afterChange(after);
              }
            }
          });
          return optionEl;
        }
        destroy() {
          this.main.main.remove();
          this.content.main.remove();
        }
        highlightText(str, search, className) {
          let completedString = str;
          const regex = new RegExp("(?![^<]*>)(" + search.trim() + ")(?![^<]*>[^<>]*</)", "i");
          if (!str.match(regex)) {
            return str;
          }
          const matchStartPosition = str.match(regex).index;
          const matchEndPosition = matchStartPosition + str.match(regex)[0].toString().length;
          const originalTextFoundByRegex = str.substring(matchStartPosition, matchEndPosition);
          completedString = completedString.replace(regex, `<mark class="${className}">${originalTextFoundByRegex}</mark>`);
          return completedString;
        }
        moveContentAbove() {
          const mainHeight = this.main.main.offsetHeight;
          const contentHeight = this.content.main.offsetHeight;
          this.main.main.classList.remove(this.classes.openBelow);
          this.main.main.classList.add(this.classes.openAbove);
          this.content.main.classList.remove(this.classes.openBelow);
          this.content.main.classList.add(this.classes.openAbove);
          const containerRect = this.main.main.getBoundingClientRect();
          this.content.main.style.margin = "-" + (mainHeight + contentHeight - 1) + "px 0px 0px 0px";
          this.content.main.style.top = containerRect.top + containerRect.height + (this.settings.contentPosition === "fixed" ? 0 : window.scrollY) + "px";
          this.content.main.style.left = containerRect.left + (this.settings.contentPosition === "fixed" ? 0 : window.scrollX) + "px";
          this.content.main.style.width = containerRect.width + "px";
        }
        moveContentBelow() {
          this.main.main.classList.remove(this.classes.openAbove);
          this.main.main.classList.add(this.classes.openBelow);
          this.content.main.classList.remove(this.classes.openAbove);
          this.content.main.classList.add(this.classes.openBelow);
          const containerRect = this.main.main.getBoundingClientRect();
          this.content.main.style.margin = "-1px 0px 0px 0px";
          if (this.settings.contentPosition !== "relative") {
            this.content.main.style.top = containerRect.top + containerRect.height + (this.settings.contentPosition === "fixed" ? 0 : window.scrollY) + "px";
            this.content.main.style.left = containerRect.left + (this.settings.contentPosition === "fixed" ? 0 : window.scrollX) + "px";
            this.content.main.style.width = containerRect.width + "px";
          }
        }
        ensureElementInView(container, element) {
          const cTop = container.scrollTop + container.offsetTop;
          const cBottom = cTop + container.clientHeight;
          const eTop = element.offsetTop;
          const eBottom = eTop + element.clientHeight;
          if (eTop < cTop) {
            container.scrollTop -= cTop - eTop;
          } else if (eBottom > cBottom) {
            container.scrollTop += eBottom - cBottom;
          }
        }
        putContent() {
          const mainHeight = this.main.main.offsetHeight;
          const mainRect = this.main.main.getBoundingClientRect();
          const contentHeight = this.content.main.offsetHeight;
          const spaceBelow = window.innerHeight - (mainRect.top + mainHeight);
          if (spaceBelow <= contentHeight) {
            if (mainRect.top > contentHeight) {
              return "up";
            } else {
              return "down";
            }
          }
          return "down";
        }
        updateDeselectAll() {
          if (!this.store || !this.settings) {
            return;
          }
          const selected = this.store.getSelectedOptions();
          const hasSelectedItems = selected && selected.length > 0;
          const isMultiple = this.settings.isMultiple;
          const allowDeselect = this.settings.allowDeselect;
          const deselectButton = this.main.deselect.main;
          const hideClass = this.classes.hide;
          if (allowDeselect && !(isMultiple && !hasSelectedItems)) {
            deselectButton.classList.remove(hideClass);
          } else {
            deselectButton.classList.add(hideClass);
          }
        }
      }
      class Select {
        constructor(select) {
          this.listen = false;
          this.observer = null;
          this.select = select;
          this.valueChange = this.valueChange.bind(this);
          this.select.addEventListener("change", this.valueChange, {
            passive: true
          });
          this.observer = new MutationObserver(this.observeCall.bind(this));
          this.changeListen(true);
        }
        enable() {
          this.select.disabled = false;
        }
        disable() {
          this.select.disabled = true;
        }
        hideUI() {
          this.select.tabIndex = -1;
          this.select.style.display = "none";
          this.select.setAttribute("aria-hidden", "true");
        }
        showUI() {
          this.select.removeAttribute("tabindex");
          this.select.style.display = "";
          this.select.removeAttribute("aria-hidden");
        }
        changeListen(listen) {
          this.listen = listen;
          if (listen) {
            if (this.observer) {
              this.observer.observe(this.select, {
                subtree: true,
                childList: true,
                attributes: true
              });
            }
          }
          if (!listen) {
            if (this.observer) {
              this.observer.disconnect();
            }
          }
        }
        valueChange(ev) {
          if (this.listen && this.onValueChange) {
            this.onValueChange(this.getSelectedOptions());
          }
          return true;
        }
        observeCall(mutations) {
          if (!this.listen) {
            return;
          }
          let classChanged = false;
          let disabledChanged = false;
          let optgroupOptionChanged = false;
          for (const m of mutations) {
            if (m.target === this.select) {
              if (m.attributeName === "disabled") {
                disabledChanged = true;
              }
              if (m.attributeName === "class") {
                classChanged = true;
              }
              if (m.type === "childList") {
                for (const n of m.addedNodes) {
                  if (n.nodeName === "OPTION" && n.value === this.select.value) {
                    this.select.dispatchEvent(new Event("change"));
                    break;
                  }
                }
                optgroupOptionChanged = true;
              }
            }
            if (m.target.nodeName === "OPTGROUP" || m.target.nodeName === "OPTION") {
              optgroupOptionChanged = true;
            }
          }
          if (classChanged && this.onClassChange) {
            this.onClassChange(this.select.className.split(" "));
          }
          if (disabledChanged && this.onDisabledChange) {
            this.changeListen(false);
            this.onDisabledChange(this.select.disabled);
            this.changeListen(true);
          }
          if (optgroupOptionChanged && this.onOptionsChange) {
            this.changeListen(false);
            this.onOptionsChange(this.getData());
            this.changeListen(true);
          }
        }
        getData() {
          let data = [];
          const nodes = this.select.childNodes;
          for (const n of nodes) {
            if (n.nodeName === "OPTGROUP") {
              data.push(this.getDataFromOptgroup(n));
            }
            if (n.nodeName === "OPTION") {
              data.push(this.getDataFromOption(n));
            }
          }
          return data;
        }
        getDataFromOptgroup(optgroup) {
          let data = {
            id: optgroup.id,
            label: optgroup.label,
            selectAll: optgroup.dataset ? optgroup.dataset.selectall === "true" : false,
            selectAllText: optgroup.dataset ? optgroup.dataset.selectalltext : "Select all",
            closable: optgroup.dataset ? optgroup.dataset.closable : "off",
            options: []
          };
          const options = optgroup.childNodes;
          for (const o of options) {
            if (o.nodeName === "OPTION") {
              data.options.push(this.getDataFromOption(o));
            }
          }
          return data;
        }
        getDataFromOption(option) {
          return {
            id: option.id,
            value: option.value,
            text: option.text,
            html: option.dataset && option.dataset.html ? option.dataset.html : "",
            selected: option.selected,
            display: option.style.display !== "none",
            disabled: option.disabled,
            mandatory: option.dataset ? option.dataset.mandatory === "true" : false,
            placeholder: option.dataset.placeholder === "true",
            class: option.className,
            style: option.style.cssText,
            data: option.dataset
          };
        }
        getSelectedOptions() {
          let options = [];
          const opts = this.select.childNodes;
          for (const o of opts) {
            if (o.nodeName === "OPTGROUP") {
              const optgroupOptions = o.childNodes;
              for (const oo of optgroupOptions) {
                if (oo.nodeName === "OPTION") {
                  const option = oo;
                  if (option.selected) {
                    options.push(this.getDataFromOption(option));
                  }
                }
              }
            }
            if (o.nodeName === "OPTION") {
              const option = o;
              if (option.selected) {
                options.push(this.getDataFromOption(option));
              }
            }
          }
          return options;
        }
        getSelectedValues() {
          return this.getSelectedOptions().map((option) => option.value);
        }
        setSelected(ids) {
          this.changeListen(false);
          const options = this.select.childNodes;
          for (const o of options) {
            if (o.nodeName === "OPTGROUP") {
              const optgroup = o;
              const optgroupOptions = optgroup.childNodes;
              for (const oo of optgroupOptions) {
                if (oo.nodeName === "OPTION") {
                  const option = oo;
                  option.selected = ids.includes(option.id);
                }
              }
            }
            if (o.nodeName === "OPTION") {
              const option = o;
              option.selected = ids.includes(option.id);
            }
          }
          this.changeListen(true);
        }
        setSelectedByValue(values) {
          this.changeListen(false);
          const options = this.select.childNodes;
          for (const o of options) {
            if (o.nodeName === "OPTGROUP") {
              const optgroup = o;
              const optgroupOptions = optgroup.childNodes;
              for (const oo of optgroupOptions) {
                if (oo.nodeName === "OPTION") {
                  const option = oo;
                  option.selected = values.includes(option.value);
                }
              }
            }
            if (o.nodeName === "OPTION") {
              const option = o;
              option.selected = values.includes(option.value);
            }
          }
          this.changeListen(true);
        }
        updateSelect(id, style, classes) {
          this.changeListen(false);
          if (id) {
            this.select.dataset.id = id;
          }
          if (style) {
            this.select.style.cssText = style;
          }
          if (classes) {
            this.select.className = "";
            classes.forEach((c) => {
              if (c.trim() !== "") {
                this.select.classList.add(c.trim());
              }
            });
          }
          this.changeListen(true);
        }
        updateOptions(data) {
          this.changeListen(false);
          this.select.innerHTML = "";
          for (const d of data) {
            if (d instanceof Optgroup) {
              this.select.appendChild(this.createOptgroup(d));
            }
            if (d instanceof Option) {
              this.select.appendChild(this.createOption(d));
            }
          }
          this.select.dispatchEvent(new Event("change", { bubbles: true }));
          this.changeListen(true);
        }
        createOptgroup(optgroup) {
          const optgroupEl = document.createElement("optgroup");
          optgroupEl.id = optgroup.id;
          optgroupEl.label = optgroup.label;
          if (optgroup.selectAll) {
            optgroupEl.dataset.selectAll = "true";
          }
          if (optgroup.closable !== "off") {
            optgroupEl.dataset.closable = optgroup.closable;
          }
          if (optgroup.options) {
            for (const o of optgroup.options) {
              optgroupEl.appendChild(this.createOption(o));
            }
          }
          return optgroupEl;
        }
        createOption(info) {
          const optionEl = document.createElement("option");
          optionEl.id = info.id;
          optionEl.value = info.value;
          optionEl.textContent = info.text;
          if (info.html !== "") {
            optionEl.setAttribute("data-html", info.html);
          }
          if (info.selected) {
            optionEl.selected = info.selected;
          }
          if (info.disabled) {
            optionEl.disabled = true;
          }
          if (!info.display) {
            optionEl.style.display = "none";
          }
          if (info.placeholder) {
            optionEl.setAttribute("data-placeholder", "true");
          }
          if (info.mandatory) {
            optionEl.setAttribute("data-mandatory", "true");
          }
          if (info.class) {
            info.class.split(" ").forEach((optionClass) => {
              optionEl.classList.add(optionClass);
            });
          }
          if (info.data && typeof info.data === "object") {
            Object.keys(info.data).forEach((key) => {
              optionEl.setAttribute("data-" + kebabCase(key), info.data[key]);
            });
          }
          return optionEl;
        }
        destroy() {
          this.changeListen(false);
          this.select.removeEventListener("change", this.valueChange);
          if (this.observer) {
            this.observer.disconnect();
            this.observer = null;
          }
          delete this.select.dataset.id;
          this.showUI();
        }
      }
      class Settings {
        constructor(settings) {
          this.id = "";
          this.style = "";
          this.class = [];
          this.isMultiple = false;
          this.isOpen = false;
          this.isFullOpen = false;
          this.intervalMove = null;
          if (!settings) {
            settings = {};
          }
          this.id = "ss-" + generateID();
          this.style = settings.style || "";
          this.class = settings.class || [];
          this.disabled = settings.disabled !== void 0 ? settings.disabled : false;
          this.alwaysOpen = settings.alwaysOpen !== void 0 ? settings.alwaysOpen : false;
          this.showSearch = settings.showSearch !== void 0 ? settings.showSearch : true;
          this.focusSearch = settings.focusSearch !== void 0 ? settings.focusSearch : true;
          this.ariaLabel = settings.ariaLabel || "Combobox";
          this.searchPlaceholder = settings.searchPlaceholder || "Search";
          this.searchText = settings.searchText || "No Results";
          this.searchingText = settings.searchingText || "Searching...";
          this.searchHighlight = settings.searchHighlight !== void 0 ? settings.searchHighlight : false;
          this.closeOnSelect = settings.closeOnSelect !== void 0 ? settings.closeOnSelect : true;
          this.contentLocation = settings.contentLocation || document.body;
          this.contentPosition = settings.contentPosition || "absolute";
          this.openPosition = settings.openPosition || "auto";
          this.placeholderText = settings.placeholderText !== void 0 ? settings.placeholderText : "Select Value";
          this.allowDeselect = settings.allowDeselect !== void 0 ? settings.allowDeselect : false;
          this.hideSelected = settings.hideSelected !== void 0 ? settings.hideSelected : false;
          this.keepOrder = settings.keepOrder !== void 0 ? settings.keepOrder : false;
          this.showOptionTooltips = settings.showOptionTooltips !== void 0 ? settings.showOptionTooltips : false;
          this.minSelected = settings.minSelected || 0;
          this.maxSelected = settings.maxSelected || 1e3;
          this.timeoutDelay = settings.timeoutDelay || 200;
          this.maxValuesShown = settings.maxValuesShown || 20;
          this.maxValuesMessage = settings.maxValuesMessage || "{number} selected";
          this.addableText = settings.addableText || 'Press "Enter" to add {value}';
        }
      }
      class SlimSelect2 {
        constructor(config2) {
          var _a;
          this.events = {
            search: void 0,
            searchFilter: (opt, search) => {
              return opt.text.toLowerCase().indexOf(search.toLowerCase()) !== -1;
            },
            addable: void 0,
            beforeChange: void 0,
            afterChange: void 0,
            beforeOpen: void 0,
            afterOpen: void 0,
            beforeClose: void 0,
            afterClose: void 0
          };
          this.windowResize = debounce2(() => {
            if (!this.settings.isOpen && !this.settings.isFullOpen) {
              return;
            }
            this.render.moveContent();
          });
          this.windowScroll = debounce2(() => {
            if (!this.settings.isOpen && !this.settings.isFullOpen) {
              return;
            }
            this.render.moveContent();
          });
          this.documentClick = (e) => {
            if (!this.settings.isOpen) {
              return;
            }
            if (e.target && !hasClassInTree(e.target, this.settings.id)) {
              this.close(e.type);
            }
          };
          this.windowVisibilityChange = () => {
            if (document.hidden) {
              this.close();
            }
          };
          this.selectEl = typeof config2.select === "string" ? document.querySelector(config2.select) : config2.select;
          if (!this.selectEl) {
            if (config2.events && config2.events.error) {
              config2.events.error(new Error("Could not find select element"));
            }
            return;
          }
          if (this.selectEl.tagName !== "SELECT") {
            if (config2.events && config2.events.error) {
              config2.events.error(new Error("Element isnt of type select"));
            }
            return;
          }
          if (this.selectEl.dataset.ssid) {
            this.destroy();
          }
          this.settings = new Settings(config2.settings);
          this.cssClasses = new CssClasses(config2.cssClasses);
          const debounceEvents = ["afterChange", "beforeOpen", "afterOpen", "beforeClose", "afterClose"];
          for (const key in config2.events) {
            if (!config2.events.hasOwnProperty(key)) {
              continue;
            }
            if (debounceEvents.indexOf(key) !== -1) {
              this.events[key] = debounce2(config2.events[key], 100);
            } else {
              this.events[key] = config2.events[key];
            }
          }
          this.settings.disabled = ((_a = config2.settings) === null || _a === void 0 ? void 0 : _a.disabled) ? config2.settings.disabled : this.selectEl.disabled;
          this.settings.isMultiple = this.selectEl.multiple;
          this.settings.style = this.selectEl.style.cssText;
          this.settings.class = this.selectEl.className.split(" ");
          this.select = new Select(this.selectEl);
          this.select.updateSelect(this.settings.id, this.settings.style, this.settings.class);
          this.select.hideUI();
          this.select.onValueChange = (options) => {
            this.setSelected(options.map((option) => option.id));
          };
          this.select.onClassChange = (classes) => {
            this.settings.class = classes;
            this.render.updateClassStyles();
          };
          this.select.onDisabledChange = (disabled) => {
            if (disabled) {
              this.disable();
            } else {
              this.enable();
            }
          };
          this.select.onOptionsChange = (data) => {
            this.setData(data);
          };
          this.store = new Store(this.settings.isMultiple ? "multiple" : "single", config2.data ? config2.data : this.select.getData());
          if (config2.data) {
            this.select.updateOptions(this.store.getData());
          }
          const renderCallbacks = {
            open: this.open.bind(this),
            close: this.close.bind(this),
            addable: this.events.addable ? this.events.addable : void 0,
            setSelected: this.setSelected.bind(this),
            addOption: this.addOption.bind(this),
            search: this.search.bind(this),
            beforeChange: this.events.beforeChange,
            afterChange: this.events.afterChange
          };
          this.render = new Render(this.settings, this.cssClasses, this.store, renderCallbacks);
          this.render.renderValues();
          this.render.renderOptions(this.store.getData());
          const selectAriaLabel = this.selectEl.getAttribute("aria-label");
          const selectAriaLabelledBy = this.selectEl.getAttribute("aria-labelledby");
          if (selectAriaLabel) {
            this.render.main.main.setAttribute("aria-label", selectAriaLabel);
          } else if (selectAriaLabelledBy) {
            this.render.main.main.setAttribute("aria-labelledby", selectAriaLabelledBy);
          }
          if (this.selectEl.parentNode) {
            this.selectEl.parentNode.insertBefore(this.render.main.main, this.selectEl.nextSibling);
          }
          window.addEventListener("resize", this.windowResize, false);
          if (this.settings.openPosition === "auto") {
            window.addEventListener("scroll", this.windowScroll, false);
          }
          document.addEventListener("visibilitychange", this.windowVisibilityChange);
          if (this.settings.disabled) {
            this.disable();
          }
          if (this.settings.alwaysOpen) {
            this.open();
          }
          this.selectEl.slim = this;
        }
        enable() {
          this.settings.disabled = false;
          this.select.enable();
          this.render.enable();
        }
        disable() {
          this.settings.disabled = true;
          this.select.disable();
          this.render.disable();
        }
        getData() {
          return this.store.getData();
        }
        setData(data) {
          const selected = this.store.getSelected();
          const err = this.store.validateDataArray(data);
          if (err) {
            if (this.events.error) {
              this.events.error(err);
            }
            return;
          }
          this.store.setData(data);
          const dataClean = this.store.getData();
          this.select.updateOptions(dataClean);
          this.render.renderValues();
          this.render.renderOptions(dataClean);
          if (this.events.afterChange && !isEqual(selected, this.store.getSelected())) {
            this.events.afterChange(this.store.getSelectedOptions());
          }
        }
        getSelected() {
          let options = this.store.getSelectedOptions();
          if (this.settings.keepOrder) {
            options = this.store.selectedOrderOptions(options);
          }
          return options.map((option) => option.value);
        }
        setSelected(values, runAfterChange = true) {
          const selected = this.store.getSelected();
          const options = this.store.getDataOptions();
          values = Array.isArray(values) ? values : [values];
          const ids = [];
          for (const value of values) {
            if (options.find((option) => option.id == value)) {
              ids.push(value);
              continue;
            }
            for (const option of options.filter((option2) => option2.value == value)) {
              ids.push(option.id);
            }
          }
          this.store.setSelectedBy("id", ids);
          const data = this.store.getData();
          this.select.updateOptions(data);
          this.render.renderValues();
          if (this.render.content.search.input.value !== "") {
            this.search(this.render.content.search.input.value);
          } else {
            this.render.renderOptions(data);
          }
          if (runAfterChange && this.events.afterChange && !isEqual(selected, this.store.getSelected())) {
            this.events.afterChange(this.store.getSelectedOptions());
          }
        }
        addOption(option) {
          const selected = this.store.getSelected();
          if (!this.store.getDataOptions().some((o) => {
            var _a;
            return o.value === ((_a = option.value) !== null && _a !== void 0 ? _a : option.text);
          })) {
            this.store.addOption(option);
          }
          const data = this.store.getData();
          this.select.updateOptions(data);
          this.render.renderValues();
          this.render.renderOptions(data);
          if (this.events.afterChange && !isEqual(selected, this.store.getSelected())) {
            this.events.afterChange(this.store.getSelectedOptions());
          }
        }
        open() {
          if (this.settings.disabled || this.settings.isOpen) {
            return;
          }
          if (this.events.beforeOpen) {
            this.events.beforeOpen();
          }
          this.render.open();
          if (this.settings.showSearch && this.settings.focusSearch) {
            this.render.searchFocus();
          }
          this.settings.isOpen = true;
          setTimeout(() => {
            if (this.events.afterOpen) {
              this.events.afterOpen();
            }
            if (this.settings.isOpen) {
              this.settings.isFullOpen = true;
            }
            document.addEventListener("click", this.documentClick);
          }, this.settings.timeoutDelay);
          if (this.settings.contentPosition === "absolute") {
            if (this.settings.intervalMove) {
              clearInterval(this.settings.intervalMove);
            }
            this.settings.intervalMove = setInterval(this.render.moveContent.bind(this.render), 500);
          }
        }
        close(eventType = null) {
          if (!this.settings.isOpen || this.settings.alwaysOpen) {
            return;
          }
          if (this.events.beforeClose) {
            this.events.beforeClose();
          }
          this.render.close();
          if (this.render.content.search.input.value !== "") {
            this.search("");
          }
          this.render.mainFocus(eventType);
          this.settings.isOpen = false;
          this.settings.isFullOpen = false;
          setTimeout(() => {
            if (this.events.afterClose) {
              this.events.afterClose();
            }
            document.removeEventListener("click", this.documentClick);
          }, this.settings.timeoutDelay);
          if (this.settings.intervalMove) {
            clearInterval(this.settings.intervalMove);
          }
        }
        search(value) {
          if (this.render.content.search.input.value !== value) {
            this.render.content.search.input.value = value;
          }
          if (!this.events.search) {
            this.render.renderOptions(value === "" ? this.store.getData() : this.store.search(value, this.events.searchFilter));
            return;
          }
          this.render.renderSearching();
          const searchResp = this.events.search(value, this.store.getSelectedOptions());
          if (searchResp instanceof Promise) {
            searchResp.then((data) => {
              this.render.renderOptions(this.store.partialToFullData(data));
            }).catch((err) => {
              this.render.renderError(typeof err === "string" ? err : err.message);
            });
            return;
          } else if (Array.isArray(searchResp)) {
            this.render.renderOptions(this.store.partialToFullData(searchResp));
          } else {
            this.render.renderError("Search event must return a promise or an array of data");
          }
        }
        destroy() {
          document.removeEventListener("click", this.documentClick);
          window.removeEventListener("resize", this.windowResize, false);
          if (this.settings.openPosition === "auto") {
            window.removeEventListener("scroll", this.windowScroll, false);
          }
          document.removeEventListener("visibilitychange", this.windowVisibilityChange);
          this.store.setData([]);
          this.render.destroy();
          this.select.destroy();
        }
      }
      return SlimSelect2;
    });
  }
});

// node_modules/@hotwired/turbo/dist/turbo.es2017-esm.js
var turbo_es2017_esm_exports = {};
__export(turbo_es2017_esm_exports, {
  FetchEnctype: () => FetchEnctype,
  FetchMethod: () => FetchMethod,
  FetchRequest: () => FetchRequest,
  FetchResponse: () => FetchResponse,
  FrameElement: () => FrameElement,
  FrameLoadingStyle: () => FrameLoadingStyle,
  FrameRenderer: () => FrameRenderer,
  PageRenderer: () => PageRenderer,
  PageSnapshot: () => PageSnapshot,
  StreamActions: () => StreamActions,
  StreamElement: () => StreamElement,
  StreamSourceElement: () => StreamSourceElement,
  cache: () => cache,
  clearCache: () => clearCache,
  config: () => config,
  connectStreamSource: () => connectStreamSource,
  disconnectStreamSource: () => disconnectStreamSource,
  fetch: () => fetchWithTurboHeaders,
  fetchEnctypeFromString: () => fetchEnctypeFromString,
  fetchMethodFromString: () => fetchMethodFromString,
  isSafe: () => isSafe,
  navigator: () => navigator$1,
  registerAdapter: () => registerAdapter,
  renderStreamMessage: () => renderStreamMessage,
  session: () => session,
  setConfirmMethod: () => setConfirmMethod,
  setFormMode: () => setFormMode,
  setProgressBarDelay: () => setProgressBarDelay,
  start: () => start,
  visit: () => visit
});
(function(prototype) {
  if (typeof prototype.requestSubmit == "function") return;
  prototype.requestSubmit = function(submitter2) {
    if (submitter2) {
      validateSubmitter(submitter2, this);
      submitter2.click();
    } else {
      submitter2 = document.createElement("input");
      submitter2.type = "submit";
      submitter2.hidden = true;
      this.appendChild(submitter2);
      submitter2.click();
      this.removeChild(submitter2);
    }
  };
  function validateSubmitter(submitter2, form) {
    submitter2 instanceof HTMLElement || raise(TypeError, "parameter 1 is not of type 'HTMLElement'");
    submitter2.type == "submit" || raise(TypeError, "The specified element is not a submit button");
    submitter2.form == form || raise(DOMException, "The specified element is not owned by this form element", "NotFoundError");
  }
  function raise(errorConstructor, message, name) {
    throw new errorConstructor("Failed to execute 'requestSubmit' on 'HTMLFormElement': " + message + ".", name);
  }
})(HTMLFormElement.prototype);
var submittersByForm = /* @__PURE__ */ new WeakMap();
function findSubmitterFromClickTarget(target) {
  const element = target instanceof Element ? target : target instanceof Node ? target.parentElement : null;
  const candidate = element ? element.closest("input, button") : null;
  return candidate?.type == "submit" ? candidate : null;
}
function clickCaptured(event) {
  const submitter2 = findSubmitterFromClickTarget(event.target);
  if (submitter2 && submitter2.form) {
    submittersByForm.set(submitter2.form, submitter2);
  }
}
(function() {
  if ("submitter" in Event.prototype) return;
  let prototype = window.Event.prototype;
  if ("SubmitEvent" in window) {
    const prototypeOfSubmitEvent = window.SubmitEvent.prototype;
    if (/Apple Computer/.test(navigator.vendor) && !("submitter" in prototypeOfSubmitEvent)) {
      prototype = prototypeOfSubmitEvent;
    } else {
      return;
    }
  }
  addEventListener("click", clickCaptured, true);
  Object.defineProperty(prototype, "submitter", {
    get() {
      if (this.type == "submit" && this.target instanceof HTMLFormElement) {
        return submittersByForm.get(this.target);
      }
    }
  });
})();
var FrameLoadingStyle = {
  eager: "eager",
  lazy: "lazy"
};
var FrameElement = class _FrameElement extends HTMLElement {
  static delegateConstructor = void 0;
  loaded = Promise.resolve();
  static get observedAttributes() {
    return ["disabled", "loading", "src"];
  }
  constructor() {
    super();
    this.delegate = new _FrameElement.delegateConstructor(this);
  }
  connectedCallback() {
    this.delegate.connect();
  }
  disconnectedCallback() {
    this.delegate.disconnect();
  }
  reload() {
    return this.delegate.sourceURLReloaded();
  }
  attributeChangedCallback(name) {
    if (name == "loading") {
      this.delegate.loadingStyleChanged();
    } else if (name == "src") {
      this.delegate.sourceURLChanged();
    } else if (name == "disabled") {
      this.delegate.disabledChanged();
    }
  }
  /**
   * Gets the URL to lazily load source HTML from
   */
  get src() {
    return this.getAttribute("src");
  }
  /**
   * Sets the URL to lazily load source HTML from
   */
  set src(value) {
    if (value) {
      this.setAttribute("src", value);
    } else {
      this.removeAttribute("src");
    }
  }
  /**
   * Gets the refresh mode for the frame.
   */
  get refresh() {
    return this.getAttribute("refresh");
  }
  /**
   * Sets the refresh mode for the frame.
   */
  set refresh(value) {
    if (value) {
      this.setAttribute("refresh", value);
    } else {
      this.removeAttribute("refresh");
    }
  }
  get shouldReloadWithMorph() {
    return this.src && this.refresh === "morph";
  }
  /**
   * Determines if the element is loading
   */
  get loading() {
    return frameLoadingStyleFromString(this.getAttribute("loading") || "");
  }
  /**
   * Sets the value of if the element is loading
   */
  set loading(value) {
    if (value) {
      this.setAttribute("loading", value);
    } else {
      this.removeAttribute("loading");
    }
  }
  /**
   * Gets the disabled state of the frame.
   *
   * If disabled, no requests will be intercepted by the frame.
   */
  get disabled() {
    return this.hasAttribute("disabled");
  }
  /**
   * Sets the disabled state of the frame.
   *
   * If disabled, no requests will be intercepted by the frame.
   */
  set disabled(value) {
    if (value) {
      this.setAttribute("disabled", "");
    } else {
      this.removeAttribute("disabled");
    }
  }
  /**
   * Gets the autoscroll state of the frame.
   *
   * If true, the frame will be scrolled into view automatically on update.
   */
  get autoscroll() {
    return this.hasAttribute("autoscroll");
  }
  /**
   * Sets the autoscroll state of the frame.
   *
   * If true, the frame will be scrolled into view automatically on update.
   */
  set autoscroll(value) {
    if (value) {
      this.setAttribute("autoscroll", "");
    } else {
      this.removeAttribute("autoscroll");
    }
  }
  /**
   * Determines if the element has finished loading
   */
  get complete() {
    return !this.delegate.isLoading;
  }
  /**
   * Gets the active state of the frame.
   *
   * If inactive, source changes will not be observed.
   */
  get isActive() {
    return this.ownerDocument === document && !this.isPreview;
  }
  /**
   * Sets the active state of the frame.
   *
   * If inactive, source changes will not be observed.
   */
  get isPreview() {
    return this.ownerDocument?.documentElement?.hasAttribute("data-turbo-preview");
  }
};
function frameLoadingStyleFromString(style) {
  switch (style.toLowerCase()) {
    case "lazy":
      return FrameLoadingStyle.lazy;
    default:
      return FrameLoadingStyle.eager;
  }
}
var drive = {
  enabled: true,
  progressBarDelay: 500,
  unvisitableExtensions: /* @__PURE__ */ new Set(
    [
      ".7z",
      ".aac",
      ".apk",
      ".avi",
      ".bmp",
      ".bz2",
      ".css",
      ".csv",
      ".deb",
      ".dmg",
      ".doc",
      ".docx",
      ".exe",
      ".gif",
      ".gz",
      ".heic",
      ".heif",
      ".ico",
      ".iso",
      ".jpeg",
      ".jpg",
      ".js",
      ".json",
      ".m4a",
      ".mkv",
      ".mov",
      ".mp3",
      ".mp4",
      ".mpeg",
      ".mpg",
      ".msi",
      ".ogg",
      ".ogv",
      ".pdf",
      ".pkg",
      ".png",
      ".ppt",
      ".pptx",
      ".rar",
      ".rtf",
      ".svg",
      ".tar",
      ".tif",
      ".tiff",
      ".txt",
      ".wav",
      ".webm",
      ".webp",
      ".wma",
      ".wmv",
      ".xls",
      ".xlsx",
      ".xml",
      ".zip"
    ]
  )
};
function activateScriptElement(element) {
  if (element.getAttribute("data-turbo-eval") == "false") {
    return element;
  } else {
    const createdScriptElement = document.createElement("script");
    const cspNonce = getCspNonce();
    if (cspNonce) {
      createdScriptElement.nonce = cspNonce;
    }
    createdScriptElement.textContent = element.textContent;
    createdScriptElement.async = false;
    copyElementAttributes(createdScriptElement, element);
    return createdScriptElement;
  }
}
function copyElementAttributes(destinationElement, sourceElement) {
  for (const { name, value } of sourceElement.attributes) {
    destinationElement.setAttribute(name, value);
  }
}
function createDocumentFragment(html) {
  const template = document.createElement("template");
  template.innerHTML = html;
  return template.content;
}
function dispatch(eventName, { target, cancelable, detail } = {}) {
  const event = new CustomEvent(eventName, {
    cancelable,
    bubbles: true,
    composed: true,
    detail
  });
  if (target && target.isConnected) {
    target.dispatchEvent(event);
  } else {
    document.documentElement.dispatchEvent(event);
  }
  return event;
}
function cancelEvent(event) {
  event.preventDefault();
  event.stopImmediatePropagation();
}
function nextRepaint() {
  if (document.visibilityState === "hidden") {
    return nextEventLoopTick();
  } else {
    return nextAnimationFrame();
  }
}
function nextAnimationFrame() {
  return new Promise((resolve) => requestAnimationFrame(() => resolve()));
}
function nextEventLoopTick() {
  return new Promise((resolve) => setTimeout(() => resolve(), 0));
}
function nextMicrotask() {
  return Promise.resolve();
}
function parseHTMLDocument(html = "") {
  return new DOMParser().parseFromString(html, "text/html");
}
function unindent(strings, ...values) {
  const lines = interpolate(strings, values).replace(/^\n/, "").split("\n");
  const match = lines[0].match(/^\s+/);
  const indent = match ? match[0].length : 0;
  return lines.map((line) => line.slice(indent)).join("\n");
}
function interpolate(strings, values) {
  return strings.reduce((result, string, i) => {
    const value = values[i] == void 0 ? "" : values[i];
    return result + string + value;
  }, "");
}
function uuid() {
  return Array.from({ length: 36 }).map((_, i) => {
    if (i == 8 || i == 13 || i == 18 || i == 23) {
      return "-";
    } else if (i == 14) {
      return "4";
    } else if (i == 19) {
      return (Math.floor(Math.random() * 4) + 8).toString(16);
    } else {
      return Math.floor(Math.random() * 15).toString(16);
    }
  }).join("");
}
function getAttribute(attributeName, ...elements) {
  for (const value of elements.map((element) => element?.getAttribute(attributeName))) {
    if (typeof value == "string") return value;
  }
  return null;
}
function hasAttribute(attributeName, ...elements) {
  return elements.some((element) => element && element.hasAttribute(attributeName));
}
function markAsBusy(...elements) {
  for (const element of elements) {
    if (element.localName == "turbo-frame") {
      element.setAttribute("busy", "");
    }
    element.setAttribute("aria-busy", "true");
  }
}
function clearBusyState(...elements) {
  for (const element of elements) {
    if (element.localName == "turbo-frame") {
      element.removeAttribute("busy");
    }
    element.removeAttribute("aria-busy");
  }
}
function waitForLoad(element, timeoutInMilliseconds = 2e3) {
  return new Promise((resolve) => {
    const onComplete = () => {
      element.removeEventListener("error", onComplete);
      element.removeEventListener("load", onComplete);
      resolve();
    };
    element.addEventListener("load", onComplete, { once: true });
    element.addEventListener("error", onComplete, { once: true });
    setTimeout(resolve, timeoutInMilliseconds);
  });
}
function getHistoryMethodForAction(action) {
  switch (action) {
    case "replace":
      return history.replaceState;
    case "advance":
    case "restore":
      return history.pushState;
  }
}
function isAction(action) {
  return action == "advance" || action == "replace" || action == "restore";
}
function getVisitAction(...elements) {
  const action = getAttribute("data-turbo-action", ...elements);
  return isAction(action) ? action : null;
}
function getMetaElement(name) {
  return document.querySelector(`meta[name="${name}"]`);
}
function getMetaContent(name) {
  const element = getMetaElement(name);
  return element && element.content;
}
function getCspNonce() {
  const element = getMetaElement("csp-nonce");
  if (element) {
    const { nonce, content } = element;
    return nonce == "" ? content : nonce;
  }
}
function setMetaContent(name, content) {
  let element = getMetaElement(name);
  if (!element) {
    element = document.createElement("meta");
    element.setAttribute("name", name);
    document.head.appendChild(element);
  }
  element.setAttribute("content", content);
  return element;
}
function findClosestRecursively(element, selector) {
  if (element instanceof Element) {
    return element.closest(selector) || findClosestRecursively(element.assignedSlot || element.getRootNode()?.host, selector);
  }
}
function elementIsFocusable(element) {
  const inertDisabledOrHidden = "[inert], :disabled, [hidden], details:not([open]), dialog:not([open])";
  return !!element && element.closest(inertDisabledOrHidden) == null && typeof element.focus == "function";
}
function queryAutofocusableElement(elementOrDocumentFragment) {
  return Array.from(elementOrDocumentFragment.querySelectorAll("[autofocus]")).find(elementIsFocusable);
}
async function around(callback, reader) {
  const before = reader();
  callback();
  await nextAnimationFrame();
  const after = reader();
  return [before, after];
}
function doesNotTargetIFrame(name) {
  if (name === "_blank") {
    return false;
  } else if (name) {
    for (const element of document.getElementsByName(name)) {
      if (element instanceof HTMLIFrameElement) return false;
    }
    return true;
  } else {
    return true;
  }
}
function findLinkFromClickTarget(target) {
  return findClosestRecursively(target, "a[href]:not([target^=_]):not([download])");
}
function getLocationForLink(link) {
  return expandURL(link.getAttribute("href") || "");
}
function debounce(fn, delay) {
  let timeoutId = null;
  return (...args) => {
    const callback = () => fn.apply(this, args);
    clearTimeout(timeoutId);
    timeoutId = setTimeout(callback, delay);
  };
}
var submitter = {
  "aria-disabled": {
    beforeSubmit: (submitter2) => {
      submitter2.setAttribute("aria-disabled", "true");
      submitter2.addEventListener("click", cancelEvent);
    },
    afterSubmit: (submitter2) => {
      submitter2.removeAttribute("aria-disabled");
      submitter2.removeEventListener("click", cancelEvent);
    }
  },
  "disabled": {
    beforeSubmit: (submitter2) => submitter2.disabled = true,
    afterSubmit: (submitter2) => submitter2.disabled = false
  }
};
var Config = class {
  #submitter = null;
  constructor(config2) {
    Object.assign(this, config2);
  }
  get submitter() {
    return this.#submitter;
  }
  set submitter(value) {
    this.#submitter = submitter[value] || value;
  }
};
var forms = new Config({
  mode: "on",
  submitter: "disabled"
});
var config = {
  drive,
  forms
};
function expandURL(locatable) {
  return new URL(locatable.toString(), document.baseURI);
}
function getAnchor(url) {
  let anchorMatch;
  if (url.hash) {
    return url.hash.slice(1);
  } else if (anchorMatch = url.href.match(/#(.*)$/)) {
    return anchorMatch[1];
  }
}
function getAction$1(form, submitter2) {
  const action = submitter2?.getAttribute("formaction") || form.getAttribute("action") || form.action;
  return expandURL(action);
}
function getExtension(url) {
  return (getLastPathComponent(url).match(/\.[^.]*$/) || [])[0] || "";
}
function isPrefixedBy(baseURL, url) {
  const prefix = getPrefix(url);
  return baseURL.href === expandURL(prefix).href || baseURL.href.startsWith(prefix);
}
function locationIsVisitable(location2, rootLocation) {
  return isPrefixedBy(location2, rootLocation) && !config.drive.unvisitableExtensions.has(getExtension(location2));
}
function getRequestURL(url) {
  const anchor = getAnchor(url);
  return anchor != null ? url.href.slice(0, -(anchor.length + 1)) : url.href;
}
function toCacheKey(url) {
  return getRequestURL(url);
}
function urlsAreEqual(left, right) {
  return expandURL(left).href == expandURL(right).href;
}
function getPathComponents(url) {
  return url.pathname.split("/").slice(1);
}
function getLastPathComponent(url) {
  return getPathComponents(url).slice(-1)[0];
}
function getPrefix(url) {
  return addTrailingSlash(url.origin + url.pathname);
}
function addTrailingSlash(value) {
  return value.endsWith("/") ? value : value + "/";
}
var FetchResponse = class {
  constructor(response) {
    this.response = response;
  }
  get succeeded() {
    return this.response.ok;
  }
  get failed() {
    return !this.succeeded;
  }
  get clientError() {
    return this.statusCode >= 400 && this.statusCode <= 499;
  }
  get serverError() {
    return this.statusCode >= 500 && this.statusCode <= 599;
  }
  get redirected() {
    return this.response.redirected;
  }
  get location() {
    return expandURL(this.response.url);
  }
  get isHTML() {
    return this.contentType && this.contentType.match(/^(?:text\/([^\s;,]+\b)?html|application\/xhtml\+xml)\b/);
  }
  get statusCode() {
    return this.response.status;
  }
  get contentType() {
    return this.header("Content-Type");
  }
  get responseText() {
    return this.response.clone().text();
  }
  get responseHTML() {
    if (this.isHTML) {
      return this.response.clone().text();
    } else {
      return Promise.resolve(void 0);
    }
  }
  header(name) {
    return this.response.headers.get(name);
  }
};
var LimitedSet = class extends Set {
  constructor(maxSize) {
    super();
    this.maxSize = maxSize;
  }
  add(value) {
    if (this.size >= this.maxSize) {
      const iterator = this.values();
      const oldestValue = iterator.next().value;
      this.delete(oldestValue);
    }
    super.add(value);
  }
};
var recentRequests = new LimitedSet(20);
var nativeFetch = window.fetch;
function fetchWithTurboHeaders(url, options = {}) {
  const modifiedHeaders = new Headers(options.headers || {});
  const requestUID = uuid();
  recentRequests.add(requestUID);
  modifiedHeaders.append("X-Turbo-Request-Id", requestUID);
  return nativeFetch(url, {
    ...options,
    headers: modifiedHeaders
  });
}
function fetchMethodFromString(method) {
  switch (method.toLowerCase()) {
    case "get":
      return FetchMethod.get;
    case "post":
      return FetchMethod.post;
    case "put":
      return FetchMethod.put;
    case "patch":
      return FetchMethod.patch;
    case "delete":
      return FetchMethod.delete;
  }
}
var FetchMethod = {
  get: "get",
  post: "post",
  put: "put",
  patch: "patch",
  delete: "delete"
};
function fetchEnctypeFromString(encoding) {
  switch (encoding.toLowerCase()) {
    case FetchEnctype.multipart:
      return FetchEnctype.multipart;
    case FetchEnctype.plain:
      return FetchEnctype.plain;
    default:
      return FetchEnctype.urlEncoded;
  }
}
var FetchEnctype = {
  urlEncoded: "application/x-www-form-urlencoded",
  multipart: "multipart/form-data",
  plain: "text/plain"
};
var FetchRequest = class {
  abortController = new AbortController();
  #resolveRequestPromise = (_value) => {
  };
  constructor(delegate, method, location2, requestBody = new URLSearchParams(), target = null, enctype = FetchEnctype.urlEncoded) {
    const [url, body] = buildResourceAndBody(expandURL(location2), method, requestBody, enctype);
    this.delegate = delegate;
    this.url = url;
    this.target = target;
    this.fetchOptions = {
      credentials: "same-origin",
      redirect: "follow",
      method: method.toUpperCase(),
      headers: { ...this.defaultHeaders },
      body,
      signal: this.abortSignal,
      referrer: this.delegate.referrer?.href
    };
    this.enctype = enctype;
  }
  get method() {
    return this.fetchOptions.method;
  }
  set method(value) {
    const fetchBody = this.isSafe ? this.url.searchParams : this.fetchOptions.body || new FormData();
    const fetchMethod = fetchMethodFromString(value) || FetchMethod.get;
    this.url.search = "";
    const [url, body] = buildResourceAndBody(this.url, fetchMethod, fetchBody, this.enctype);
    this.url = url;
    this.fetchOptions.body = body;
    this.fetchOptions.method = fetchMethod.toUpperCase();
  }
  get headers() {
    return this.fetchOptions.headers;
  }
  set headers(value) {
    this.fetchOptions.headers = value;
  }
  get body() {
    if (this.isSafe) {
      return this.url.searchParams;
    } else {
      return this.fetchOptions.body;
    }
  }
  set body(value) {
    this.fetchOptions.body = value;
  }
  get location() {
    return this.url;
  }
  get params() {
    return this.url.searchParams;
  }
  get entries() {
    return this.body ? Array.from(this.body.entries()) : [];
  }
  cancel() {
    this.abortController.abort();
  }
  async perform() {
    const { fetchOptions } = this;
    this.delegate.prepareRequest(this);
    const event = await this.#allowRequestToBeIntercepted(fetchOptions);
    try {
      this.delegate.requestStarted(this);
      if (event.detail.fetchRequest) {
        this.response = event.detail.fetchRequest.response;
      } else {
        this.response = fetchWithTurboHeaders(this.url.href, fetchOptions);
      }
      const response = await this.response;
      return await this.receive(response);
    } catch (error2) {
      if (error2.name !== "AbortError") {
        if (this.#willDelegateErrorHandling(error2)) {
          this.delegate.requestErrored(this, error2);
        }
        throw error2;
      }
    } finally {
      this.delegate.requestFinished(this);
    }
  }
  async receive(response) {
    const fetchResponse = new FetchResponse(response);
    const event = dispatch("turbo:before-fetch-response", {
      cancelable: true,
      detail: { fetchResponse },
      target: this.target
    });
    if (event.defaultPrevented) {
      this.delegate.requestPreventedHandlingResponse(this, fetchResponse);
    } else if (fetchResponse.succeeded) {
      this.delegate.requestSucceededWithResponse(this, fetchResponse);
    } else {
      this.delegate.requestFailedWithResponse(this, fetchResponse);
    }
    return fetchResponse;
  }
  get defaultHeaders() {
    return {
      Accept: "text/html, application/xhtml+xml"
    };
  }
  get isSafe() {
    return isSafe(this.method);
  }
  get abortSignal() {
    return this.abortController.signal;
  }
  acceptResponseType(mimeType) {
    this.headers["Accept"] = [mimeType, this.headers["Accept"]].join(", ");
  }
  async #allowRequestToBeIntercepted(fetchOptions) {
    const requestInterception = new Promise((resolve) => this.#resolveRequestPromise = resolve);
    const event = dispatch("turbo:before-fetch-request", {
      cancelable: true,
      detail: {
        fetchOptions,
        url: this.url,
        resume: this.#resolveRequestPromise
      },
      target: this.target
    });
    this.url = event.detail.url;
    if (event.defaultPrevented) await requestInterception;
    return event;
  }
  #willDelegateErrorHandling(error2) {
    const event = dispatch("turbo:fetch-request-error", {
      target: this.target,
      cancelable: true,
      detail: { request: this, error: error2 }
    });
    return !event.defaultPrevented;
  }
};
function isSafe(fetchMethod) {
  return fetchMethodFromString(fetchMethod) == FetchMethod.get;
}
function buildResourceAndBody(resource, method, requestBody, enctype) {
  const searchParams = Array.from(requestBody).length > 0 ? new URLSearchParams(entriesExcludingFiles(requestBody)) : resource.searchParams;
  if (isSafe(method)) {
    return [mergeIntoURLSearchParams(resource, searchParams), null];
  } else if (enctype == FetchEnctype.urlEncoded) {
    return [resource, searchParams];
  } else {
    return [resource, requestBody];
  }
}
function entriesExcludingFiles(requestBody) {
  const entries = [];
  for (const [name, value] of requestBody) {
    if (value instanceof File) continue;
    else entries.push([name, value]);
  }
  return entries;
}
function mergeIntoURLSearchParams(url, requestBody) {
  const searchParams = new URLSearchParams(entriesExcludingFiles(requestBody));
  url.search = searchParams.toString();
  return url;
}
var AppearanceObserver = class {
  started = false;
  constructor(delegate, element) {
    this.delegate = delegate;
    this.element = element;
    this.intersectionObserver = new IntersectionObserver(this.intersect);
  }
  start() {
    if (!this.started) {
      this.started = true;
      this.intersectionObserver.observe(this.element);
    }
  }
  stop() {
    if (this.started) {
      this.started = false;
      this.intersectionObserver.unobserve(this.element);
    }
  }
  intersect = (entries) => {
    const lastEntry = entries.slice(-1)[0];
    if (lastEntry?.isIntersecting) {
      this.delegate.elementAppearedInViewport(this.element);
    }
  };
};
var StreamMessage = class {
  static contentType = "text/vnd.turbo-stream.html";
  static wrap(message) {
    if (typeof message == "string") {
      return new this(createDocumentFragment(message));
    } else {
      return message;
    }
  }
  constructor(fragment) {
    this.fragment = importStreamElements(fragment);
  }
};
function importStreamElements(fragment) {
  for (const element of fragment.querySelectorAll("turbo-stream")) {
    const streamElement = document.importNode(element, true);
    for (const inertScriptElement of streamElement.templateElement.content.querySelectorAll("script")) {
      inertScriptElement.replaceWith(activateScriptElement(inertScriptElement));
    }
    element.replaceWith(streamElement);
  }
  return fragment;
}
var PREFETCH_DELAY = 100;
var PrefetchCache = class {
  #prefetchTimeout = null;
  #prefetched = null;
  get(url) {
    if (this.#prefetched && this.#prefetched.url === url && this.#prefetched.expire > Date.now()) {
      return this.#prefetched.request;
    }
  }
  setLater(url, request, ttl) {
    this.clear();
    this.#prefetchTimeout = setTimeout(() => {
      request.perform();
      this.set(url, request, ttl);
      this.#prefetchTimeout = null;
    }, PREFETCH_DELAY);
  }
  set(url, request, ttl) {
    this.#prefetched = { url, request, expire: new Date((/* @__PURE__ */ new Date()).getTime() + ttl) };
  }
  clear() {
    if (this.#prefetchTimeout) clearTimeout(this.#prefetchTimeout);
    this.#prefetched = null;
  }
};
var cacheTtl = 10 * 1e3;
var prefetchCache = new PrefetchCache();
var FormSubmissionState = {
  initialized: "initialized",
  requesting: "requesting",
  waiting: "waiting",
  receiving: "receiving",
  stopping: "stopping",
  stopped: "stopped"
};
var FormSubmission = class _FormSubmission {
  state = FormSubmissionState.initialized;
  static confirmMethod(message) {
    return Promise.resolve(confirm(message));
  }
  constructor(delegate, formElement, submitter2, mustRedirect = false) {
    const method = getMethod(formElement, submitter2);
    const action = getAction(getFormAction(formElement, submitter2), method);
    const body = buildFormData(formElement, submitter2);
    const enctype = getEnctype(formElement, submitter2);
    this.delegate = delegate;
    this.formElement = formElement;
    this.submitter = submitter2;
    this.fetchRequest = new FetchRequest(this, method, action, body, formElement, enctype);
    this.mustRedirect = mustRedirect;
  }
  get method() {
    return this.fetchRequest.method;
  }
  set method(value) {
    this.fetchRequest.method = value;
  }
  get action() {
    return this.fetchRequest.url.toString();
  }
  set action(value) {
    this.fetchRequest.url = expandURL(value);
  }
  get body() {
    return this.fetchRequest.body;
  }
  get enctype() {
    return this.fetchRequest.enctype;
  }
  get isSafe() {
    return this.fetchRequest.isSafe;
  }
  get location() {
    return this.fetchRequest.url;
  }
  // The submission process
  async start() {
    const { initialized, requesting } = FormSubmissionState;
    const confirmationMessage = getAttribute("data-turbo-confirm", this.submitter, this.formElement);
    if (typeof confirmationMessage === "string") {
      const confirmMethod = typeof config.forms.confirm === "function" ? config.forms.confirm : _FormSubmission.confirmMethod;
      const answer = await confirmMethod(confirmationMessage, this.formElement, this.submitter);
      if (!answer) {
        return;
      }
    }
    if (this.state == initialized) {
      this.state = requesting;
      return this.fetchRequest.perform();
    }
  }
  stop() {
    const { stopping, stopped } = FormSubmissionState;
    if (this.state != stopping && this.state != stopped) {
      this.state = stopping;
      this.fetchRequest.cancel();
      return true;
    }
  }
  // Fetch request delegate
  prepareRequest(request) {
    if (!request.isSafe) {
      const token = getCookieValue(getMetaContent("csrf-param")) || getMetaContent("csrf-token");
      if (token) {
        request.headers["X-CSRF-Token"] = token;
      }
    }
    if (this.requestAcceptsTurboStreamResponse(request)) {
      request.acceptResponseType(StreamMessage.contentType);
    }
  }
  requestStarted(_request) {
    this.state = FormSubmissionState.waiting;
    if (this.submitter) config.forms.submitter.beforeSubmit(this.submitter);
    this.setSubmitsWith();
    markAsBusy(this.formElement);
    dispatch("turbo:submit-start", {
      target: this.formElement,
      detail: { formSubmission: this }
    });
    this.delegate.formSubmissionStarted(this);
  }
  requestPreventedHandlingResponse(request, response) {
    prefetchCache.clear();
    this.result = { success: response.succeeded, fetchResponse: response };
  }
  requestSucceededWithResponse(request, response) {
    if (response.clientError || response.serverError) {
      this.delegate.formSubmissionFailedWithResponse(this, response);
      return;
    }
    prefetchCache.clear();
    if (this.requestMustRedirect(request) && responseSucceededWithoutRedirect(response)) {
      const error2 = new Error("Form responses must redirect to another location");
      this.delegate.formSubmissionErrored(this, error2);
    } else {
      this.state = FormSubmissionState.receiving;
      this.result = { success: true, fetchResponse: response };
      this.delegate.formSubmissionSucceededWithResponse(this, response);
    }
  }
  requestFailedWithResponse(request, response) {
    this.result = { success: false, fetchResponse: response };
    this.delegate.formSubmissionFailedWithResponse(this, response);
  }
  requestErrored(request, error2) {
    this.result = { success: false, error: error2 };
    this.delegate.formSubmissionErrored(this, error2);
  }
  requestFinished(_request) {
    this.state = FormSubmissionState.stopped;
    if (this.submitter) config.forms.submitter.afterSubmit(this.submitter);
    this.resetSubmitterText();
    clearBusyState(this.formElement);
    dispatch("turbo:submit-end", {
      target: this.formElement,
      detail: { formSubmission: this, ...this.result }
    });
    this.delegate.formSubmissionFinished(this);
  }
  // Private
  setSubmitsWith() {
    if (!this.submitter || !this.submitsWith) return;
    if (this.submitter.matches("button")) {
      this.originalSubmitText = this.submitter.innerHTML;
      this.submitter.innerHTML = this.submitsWith;
    } else if (this.submitter.matches("input")) {
      const input = this.submitter;
      this.originalSubmitText = input.value;
      input.value = this.submitsWith;
    }
  }
  resetSubmitterText() {
    if (!this.submitter || !this.originalSubmitText) return;
    if (this.submitter.matches("button")) {
      this.submitter.innerHTML = this.originalSubmitText;
    } else if (this.submitter.matches("input")) {
      const input = this.submitter;
      input.value = this.originalSubmitText;
    }
  }
  requestMustRedirect(request) {
    return !request.isSafe && this.mustRedirect;
  }
  requestAcceptsTurboStreamResponse(request) {
    return !request.isSafe || hasAttribute("data-turbo-stream", this.submitter, this.formElement);
  }
  get submitsWith() {
    return this.submitter?.getAttribute("data-turbo-submits-with");
  }
};
function buildFormData(formElement, submitter2) {
  const formData = new FormData(formElement);
  const name = submitter2?.getAttribute("name");
  const value = submitter2?.getAttribute("value");
  if (name) {
    formData.append(name, value || "");
  }
  return formData;
}
function getCookieValue(cookieName) {
  if (cookieName != null) {
    const cookies = document.cookie ? document.cookie.split("; ") : [];
    const cookie = cookies.find((cookie2) => cookie2.startsWith(cookieName));
    if (cookie) {
      const value = cookie.split("=").slice(1).join("=");
      return value ? decodeURIComponent(value) : void 0;
    }
  }
}
function responseSucceededWithoutRedirect(response) {
  return response.statusCode == 200 && !response.redirected;
}
function getFormAction(formElement, submitter2) {
  const formElementAction = typeof formElement.action === "string" ? formElement.action : null;
  if (submitter2?.hasAttribute("formaction")) {
    return submitter2.getAttribute("formaction") || "";
  } else {
    return formElement.getAttribute("action") || formElementAction || "";
  }
}
function getAction(formAction, fetchMethod) {
  const action = expandURL(formAction);
  if (isSafe(fetchMethod)) {
    action.search = "";
  }
  return action;
}
function getMethod(formElement, submitter2) {
  const method = submitter2?.getAttribute("formmethod") || formElement.getAttribute("method") || "";
  return fetchMethodFromString(method.toLowerCase()) || FetchMethod.get;
}
function getEnctype(formElement, submitter2) {
  return fetchEnctypeFromString(submitter2?.getAttribute("formenctype") || formElement.enctype);
}
var Snapshot = class {
  constructor(element) {
    this.element = element;
  }
  get activeElement() {
    return this.element.ownerDocument.activeElement;
  }
  get children() {
    return [...this.element.children];
  }
  hasAnchor(anchor) {
    return this.getElementForAnchor(anchor) != null;
  }
  getElementForAnchor(anchor) {
    return anchor ? this.element.querySelector(`[id='${anchor}'], a[name='${anchor}']`) : null;
  }
  get isConnected() {
    return this.element.isConnected;
  }
  get firstAutofocusableElement() {
    return queryAutofocusableElement(this.element);
  }
  get permanentElements() {
    return queryPermanentElementsAll(this.element);
  }
  getPermanentElementById(id) {
    return getPermanentElementById(this.element, id);
  }
  getPermanentElementMapForSnapshot(snapshot) {
    const permanentElementMap = {};
    for (const currentPermanentElement of this.permanentElements) {
      const { id } = currentPermanentElement;
      const newPermanentElement = snapshot.getPermanentElementById(id);
      if (newPermanentElement) {
        permanentElementMap[id] = [currentPermanentElement, newPermanentElement];
      }
    }
    return permanentElementMap;
  }
};
function getPermanentElementById(node, id) {
  return node.querySelector(`#${id}[data-turbo-permanent]`);
}
function queryPermanentElementsAll(node) {
  return node.querySelectorAll("[id][data-turbo-permanent]");
}
var FormSubmitObserver = class {
  started = false;
  constructor(delegate, eventTarget) {
    this.delegate = delegate;
    this.eventTarget = eventTarget;
  }
  start() {
    if (!this.started) {
      this.eventTarget.addEventListener("submit", this.submitCaptured, true);
      this.started = true;
    }
  }
  stop() {
    if (this.started) {
      this.eventTarget.removeEventListener("submit", this.submitCaptured, true);
      this.started = false;
    }
  }
  submitCaptured = () => {
    this.eventTarget.removeEventListener("submit", this.submitBubbled, false);
    this.eventTarget.addEventListener("submit", this.submitBubbled, false);
  };
  submitBubbled = (event) => {
    if (!event.defaultPrevented) {
      const form = event.target instanceof HTMLFormElement ? event.target : void 0;
      const submitter2 = event.submitter || void 0;
      if (form && submissionDoesNotDismissDialog(form, submitter2) && submissionDoesNotTargetIFrame(form, submitter2) && this.delegate.willSubmitForm(form, submitter2)) {
        event.preventDefault();
        event.stopImmediatePropagation();
        this.delegate.formSubmitted(form, submitter2);
      }
    }
  };
};
function submissionDoesNotDismissDialog(form, submitter2) {
  const method = submitter2?.getAttribute("formmethod") || form.getAttribute("method");
  return method != "dialog";
}
function submissionDoesNotTargetIFrame(form, submitter2) {
  const target = submitter2?.getAttribute("formtarget") || form.getAttribute("target");
  return doesNotTargetIFrame(target);
}
var View = class {
  #resolveRenderPromise = (_value) => {
  };
  #resolveInterceptionPromise = (_value) => {
  };
  constructor(delegate, element) {
    this.delegate = delegate;
    this.element = element;
  }
  // Scrolling
  scrollToAnchor(anchor) {
    const element = this.snapshot.getElementForAnchor(anchor);
    if (element) {
      this.scrollToElement(element);
      this.focusElement(element);
    } else {
      this.scrollToPosition({ x: 0, y: 0 });
    }
  }
  scrollToAnchorFromLocation(location2) {
    this.scrollToAnchor(getAnchor(location2));
  }
  scrollToElement(element) {
    element.scrollIntoView();
  }
  focusElement(element) {
    if (element instanceof HTMLElement) {
      if (element.hasAttribute("tabindex")) {
        element.focus();
      } else {
        element.setAttribute("tabindex", "-1");
        element.focus();
        element.removeAttribute("tabindex");
      }
    }
  }
  scrollToPosition({ x, y }) {
    this.scrollRoot.scrollTo(x, y);
  }
  scrollToTop() {
    this.scrollToPosition({ x: 0, y: 0 });
  }
  get scrollRoot() {
    return window;
  }
  // Rendering
  async render(renderer) {
    const { isPreview, shouldRender, willRender, newSnapshot: snapshot } = renderer;
    const shouldInvalidate = willRender;
    if (shouldRender) {
      try {
        this.renderPromise = new Promise((resolve) => this.#resolveRenderPromise = resolve);
        this.renderer = renderer;
        await this.prepareToRenderSnapshot(renderer);
        const renderInterception = new Promise((resolve) => this.#resolveInterceptionPromise = resolve);
        const options = { resume: this.#resolveInterceptionPromise, render: this.renderer.renderElement, renderMethod: this.renderer.renderMethod };
        const immediateRender = this.delegate.allowsImmediateRender(snapshot, options);
        if (!immediateRender) await renderInterception;
        await this.renderSnapshot(renderer);
        this.delegate.viewRenderedSnapshot(snapshot, isPreview, this.renderer.renderMethod);
        this.delegate.preloadOnLoadLinksForView(this.element);
        this.finishRenderingSnapshot(renderer);
      } finally {
        delete this.renderer;
        this.#resolveRenderPromise(void 0);
        delete this.renderPromise;
      }
    } else if (shouldInvalidate) {
      this.invalidate(renderer.reloadReason);
    }
  }
  invalidate(reason) {
    this.delegate.viewInvalidated(reason);
  }
  async prepareToRenderSnapshot(renderer) {
    this.markAsPreview(renderer.isPreview);
    await renderer.prepareToRender();
  }
  markAsPreview(isPreview) {
    if (isPreview) {
      this.element.setAttribute("data-turbo-preview", "");
    } else {
      this.element.removeAttribute("data-turbo-preview");
    }
  }
  markVisitDirection(direction) {
    this.element.setAttribute("data-turbo-visit-direction", direction);
  }
  unmarkVisitDirection() {
    this.element.removeAttribute("data-turbo-visit-direction");
  }
  async renderSnapshot(renderer) {
    await renderer.render();
  }
  finishRenderingSnapshot(renderer) {
    renderer.finishRendering();
  }
};
var FrameView = class extends View {
  missing() {
    this.element.innerHTML = `<strong class="turbo-frame-error">Content missing</strong>`;
  }
  get snapshot() {
    return new Snapshot(this.element);
  }
};
var LinkInterceptor = class {
  constructor(delegate, element) {
    this.delegate = delegate;
    this.element = element;
  }
  start() {
    this.element.addEventListener("click", this.clickBubbled);
    document.addEventListener("turbo:click", this.linkClicked);
    document.addEventListener("turbo:before-visit", this.willVisit);
  }
  stop() {
    this.element.removeEventListener("click", this.clickBubbled);
    document.removeEventListener("turbo:click", this.linkClicked);
    document.removeEventListener("turbo:before-visit", this.willVisit);
  }
  clickBubbled = (event) => {
    if (this.clickEventIsSignificant(event)) {
      this.clickEvent = event;
    } else {
      delete this.clickEvent;
    }
  };
  linkClicked = (event) => {
    if (this.clickEvent && this.clickEventIsSignificant(event)) {
      if (this.delegate.shouldInterceptLinkClick(event.target, event.detail.url, event.detail.originalEvent)) {
        this.clickEvent.preventDefault();
        event.preventDefault();
        this.delegate.linkClickIntercepted(event.target, event.detail.url, event.detail.originalEvent);
      }
    }
    delete this.clickEvent;
  };
  willVisit = (_event) => {
    delete this.clickEvent;
  };
  clickEventIsSignificant(event) {
    const target = event.composed ? event.target?.parentElement : event.target;
    const element = findLinkFromClickTarget(target) || target;
    return element instanceof Element && element.closest("turbo-frame, html") == this.element;
  }
};
var LinkClickObserver = class {
  started = false;
  constructor(delegate, eventTarget) {
    this.delegate = delegate;
    this.eventTarget = eventTarget;
  }
  start() {
    if (!this.started) {
      this.eventTarget.addEventListener("click", this.clickCaptured, true);
      this.started = true;
    }
  }
  stop() {
    if (this.started) {
      this.eventTarget.removeEventListener("click", this.clickCaptured, true);
      this.started = false;
    }
  }
  clickCaptured = () => {
    this.eventTarget.removeEventListener("click", this.clickBubbled, false);
    this.eventTarget.addEventListener("click", this.clickBubbled, false);
  };
  clickBubbled = (event) => {
    if (event instanceof MouseEvent && this.clickEventIsSignificant(event)) {
      const target = event.composedPath && event.composedPath()[0] || event.target;
      const link = findLinkFromClickTarget(target);
      if (link && doesNotTargetIFrame(link.target)) {
        const location2 = getLocationForLink(link);
        if (this.delegate.willFollowLinkToLocation(link, location2, event)) {
          event.preventDefault();
          this.delegate.followedLinkToLocation(link, location2);
        }
      }
    }
  };
  clickEventIsSignificant(event) {
    return !(event.target && event.target.isContentEditable || event.defaultPrevented || event.which > 1 || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey);
  }
};
var FormLinkClickObserver = class {
  constructor(delegate, element) {
    this.delegate = delegate;
    this.linkInterceptor = new LinkClickObserver(this, element);
  }
  start() {
    this.linkInterceptor.start();
  }
  stop() {
    this.linkInterceptor.stop();
  }
  // Link hover observer delegate
  canPrefetchRequestToLocation(link, location2) {
    return false;
  }
  prefetchAndCacheRequestToLocation(link, location2) {
    return;
  }
  // Link click observer delegate
  willFollowLinkToLocation(link, location2, originalEvent) {
    return this.delegate.willSubmitFormLinkToLocation(link, location2, originalEvent) && (link.hasAttribute("data-turbo-method") || link.hasAttribute("data-turbo-stream"));
  }
  followedLinkToLocation(link, location2) {
    const form = document.createElement("form");
    const type = "hidden";
    for (const [name, value] of location2.searchParams) {
      form.append(Object.assign(document.createElement("input"), { type, name, value }));
    }
    const action = Object.assign(location2, { search: "" });
    form.setAttribute("data-turbo", "true");
    form.setAttribute("action", action.href);
    form.setAttribute("hidden", "");
    const method = link.getAttribute("data-turbo-method");
    if (method) form.setAttribute("method", method);
    const turboFrame = link.getAttribute("data-turbo-frame");
    if (turboFrame) form.setAttribute("data-turbo-frame", turboFrame);
    const turboAction = getVisitAction(link);
    if (turboAction) form.setAttribute("data-turbo-action", turboAction);
    const turboConfirm = link.getAttribute("data-turbo-confirm");
    if (turboConfirm) form.setAttribute("data-turbo-confirm", turboConfirm);
    const turboStream = link.hasAttribute("data-turbo-stream");
    if (turboStream) form.setAttribute("data-turbo-stream", "");
    this.delegate.submittedFormLinkToLocation(link, location2, form);
    document.body.appendChild(form);
    form.addEventListener("turbo:submit-end", () => form.remove(), { once: true });
    requestAnimationFrame(() => form.requestSubmit());
  }
};
var Bardo = class {
  static async preservingPermanentElements(delegate, permanentElementMap, callback) {
    const bardo = new this(delegate, permanentElementMap);
    bardo.enter();
    await callback();
    bardo.leave();
  }
  constructor(delegate, permanentElementMap) {
    this.delegate = delegate;
    this.permanentElementMap = permanentElementMap;
  }
  enter() {
    for (const id in this.permanentElementMap) {
      const [currentPermanentElement, newPermanentElement] = this.permanentElementMap[id];
      this.delegate.enteringBardo(currentPermanentElement, newPermanentElement);
      this.replaceNewPermanentElementWithPlaceholder(newPermanentElement);
    }
  }
  leave() {
    for (const id in this.permanentElementMap) {
      const [currentPermanentElement] = this.permanentElementMap[id];
      this.replaceCurrentPermanentElementWithClone(currentPermanentElement);
      this.replacePlaceholderWithPermanentElement(currentPermanentElement);
      this.delegate.leavingBardo(currentPermanentElement);
    }
  }
  replaceNewPermanentElementWithPlaceholder(permanentElement) {
    const placeholder = createPlaceholderForPermanentElement(permanentElement);
    permanentElement.replaceWith(placeholder);
  }
  replaceCurrentPermanentElementWithClone(permanentElement) {
    const clone = permanentElement.cloneNode(true);
    permanentElement.replaceWith(clone);
  }
  replacePlaceholderWithPermanentElement(permanentElement) {
    const placeholder = this.getPlaceholderById(permanentElement.id);
    placeholder?.replaceWith(permanentElement);
  }
  getPlaceholderById(id) {
    return this.placeholders.find((element) => element.content == id);
  }
  get placeholders() {
    return [...document.querySelectorAll("meta[name=turbo-permanent-placeholder][content]")];
  }
};
function createPlaceholderForPermanentElement(permanentElement) {
  const element = document.createElement("meta");
  element.setAttribute("name", "turbo-permanent-placeholder");
  element.setAttribute("content", permanentElement.id);
  return element;
}
var Renderer = class {
  #activeElement = null;
  static renderElement(currentElement, newElement) {
  }
  constructor(currentSnapshot, newSnapshot, isPreview, willRender = true) {
    this.currentSnapshot = currentSnapshot;
    this.newSnapshot = newSnapshot;
    this.isPreview = isPreview;
    this.willRender = willRender;
    this.renderElement = this.constructor.renderElement;
    this.promise = new Promise((resolve, reject) => this.resolvingFunctions = { resolve, reject });
  }
  get shouldRender() {
    return true;
  }
  get shouldAutofocus() {
    return true;
  }
  get reloadReason() {
    return;
  }
  prepareToRender() {
    return;
  }
  render() {
  }
  finishRendering() {
    if (this.resolvingFunctions) {
      this.resolvingFunctions.resolve();
      delete this.resolvingFunctions;
    }
  }
  async preservingPermanentElements(callback) {
    await Bardo.preservingPermanentElements(this, this.permanentElementMap, callback);
  }
  focusFirstAutofocusableElement() {
    if (this.shouldAutofocus) {
      const element = this.connectedSnapshot.firstAutofocusableElement;
      if (element) {
        element.focus();
      }
    }
  }
  // Bardo delegate
  enteringBardo(currentPermanentElement) {
    if (this.#activeElement) return;
    if (currentPermanentElement.contains(this.currentSnapshot.activeElement)) {
      this.#activeElement = this.currentSnapshot.activeElement;
    }
  }
  leavingBardo(currentPermanentElement) {
    if (currentPermanentElement.contains(this.#activeElement) && this.#activeElement instanceof HTMLElement) {
      this.#activeElement.focus();
      this.#activeElement = null;
    }
  }
  get connectedSnapshot() {
    return this.newSnapshot.isConnected ? this.newSnapshot : this.currentSnapshot;
  }
  get currentElement() {
    return this.currentSnapshot.element;
  }
  get newElement() {
    return this.newSnapshot.element;
  }
  get permanentElementMap() {
    return this.currentSnapshot.getPermanentElementMapForSnapshot(this.newSnapshot);
  }
  get renderMethod() {
    return "replace";
  }
};
var FrameRenderer = class extends Renderer {
  static renderElement(currentElement, newElement) {
    const destinationRange = document.createRange();
    destinationRange.selectNodeContents(currentElement);
    destinationRange.deleteContents();
    const frameElement = newElement;
    const sourceRange = frameElement.ownerDocument?.createRange();
    if (sourceRange) {
      sourceRange.selectNodeContents(frameElement);
      currentElement.appendChild(sourceRange.extractContents());
    }
  }
  constructor(delegate, currentSnapshot, newSnapshot, renderElement, isPreview, willRender = true) {
    super(currentSnapshot, newSnapshot, renderElement, isPreview, willRender);
    this.delegate = delegate;
  }
  get shouldRender() {
    return true;
  }
  async render() {
    await nextRepaint();
    this.preservingPermanentElements(() => {
      this.loadFrameElement();
    });
    this.scrollFrameIntoView();
    await nextRepaint();
    this.focusFirstAutofocusableElement();
    await nextRepaint();
    this.activateScriptElements();
  }
  loadFrameElement() {
    this.delegate.willRenderFrame(this.currentElement, this.newElement);
    this.renderElement(this.currentElement, this.newElement);
  }
  scrollFrameIntoView() {
    if (this.currentElement.autoscroll || this.newElement.autoscroll) {
      const element = this.currentElement.firstElementChild;
      const block = readScrollLogicalPosition(this.currentElement.getAttribute("data-autoscroll-block"), "end");
      const behavior = readScrollBehavior(this.currentElement.getAttribute("data-autoscroll-behavior"), "auto");
      if (element) {
        element.scrollIntoView({ block, behavior });
        return true;
      }
    }
    return false;
  }
  activateScriptElements() {
    for (const inertScriptElement of this.newScriptElements) {
      const activatedScriptElement = activateScriptElement(inertScriptElement);
      inertScriptElement.replaceWith(activatedScriptElement);
    }
  }
  get newScriptElements() {
    return this.currentElement.querySelectorAll("script");
  }
};
function readScrollLogicalPosition(value, defaultValue) {
  if (value == "end" || value == "start" || value == "center" || value == "nearest") {
    return value;
  } else {
    return defaultValue;
  }
}
function readScrollBehavior(value, defaultValue) {
  if (value == "auto" || value == "smooth") {
    return value;
  } else {
    return defaultValue;
  }
}
var Idiomorph = /* @__PURE__ */ function() {
  let EMPTY_SET = /* @__PURE__ */ new Set();
  let defaults = {
    morphStyle: "outerHTML",
    callbacks: {
      beforeNodeAdded: noOp,
      afterNodeAdded: noOp,
      beforeNodeMorphed: noOp,
      afterNodeMorphed: noOp,
      beforeNodeRemoved: noOp,
      afterNodeRemoved: noOp,
      beforeAttributeUpdated: noOp
    },
    head: {
      style: "merge",
      shouldPreserve: function(elt) {
        return elt.getAttribute("im-preserve") === "true";
      },
      shouldReAppend: function(elt) {
        return elt.getAttribute("im-re-append") === "true";
      },
      shouldRemove: noOp,
      afterHeadMorphed: noOp
    }
  };
  function morph(oldNode, newContent, config2 = {}) {
    if (oldNode instanceof Document) {
      oldNode = oldNode.documentElement;
    }
    if (typeof newContent === "string") {
      newContent = parseContent(newContent);
    }
    let normalizedContent = normalizeContent(newContent);
    let ctx = createMorphContext(oldNode, normalizedContent, config2);
    return morphNormalizedContent(oldNode, normalizedContent, ctx);
  }
  function morphNormalizedContent(oldNode, normalizedNewContent, ctx) {
    if (ctx.head.block) {
      let oldHead = oldNode.querySelector("head");
      let newHead = normalizedNewContent.querySelector("head");
      if (oldHead && newHead) {
        let promises = handleHeadElement(newHead, oldHead, ctx);
        Promise.all(promises).then(function() {
          morphNormalizedContent(oldNode, normalizedNewContent, Object.assign(ctx, {
            head: {
              block: false,
              ignore: true
            }
          }));
        });
        return;
      }
    }
    if (ctx.morphStyle === "innerHTML") {
      morphChildren2(normalizedNewContent, oldNode, ctx);
      return oldNode.children;
    } else if (ctx.morphStyle === "outerHTML" || ctx.morphStyle == null) {
      let bestMatch = findBestNodeMatch(normalizedNewContent, oldNode, ctx);
      let previousSibling = bestMatch?.previousSibling;
      let nextSibling = bestMatch?.nextSibling;
      let morphedNode = morphOldNodeTo(oldNode, bestMatch, ctx);
      if (bestMatch) {
        return insertSiblings(previousSibling, morphedNode, nextSibling);
      } else {
        return [];
      }
    } else {
      throw "Do not understand how to morph style " + ctx.morphStyle;
    }
  }
  function ignoreValueOfActiveElement(possibleActiveElement, ctx) {
    return ctx.ignoreActiveValue && possibleActiveElement === document.activeElement && possibleActiveElement !== document.body;
  }
  function morphOldNodeTo(oldNode, newContent, ctx) {
    if (ctx.ignoreActive && oldNode === document.activeElement) ;
    else if (newContent == null) {
      if (ctx.callbacks.beforeNodeRemoved(oldNode) === false) return oldNode;
      oldNode.remove();
      ctx.callbacks.afterNodeRemoved(oldNode);
      return null;
    } else if (!isSoftMatch(oldNode, newContent)) {
      if (ctx.callbacks.beforeNodeRemoved(oldNode) === false) return oldNode;
      if (ctx.callbacks.beforeNodeAdded(newContent) === false) return oldNode;
      oldNode.parentElement.replaceChild(newContent, oldNode);
      ctx.callbacks.afterNodeAdded(newContent);
      ctx.callbacks.afterNodeRemoved(oldNode);
      return newContent;
    } else {
      if (ctx.callbacks.beforeNodeMorphed(oldNode, newContent) === false) return oldNode;
      if (oldNode instanceof HTMLHeadElement && ctx.head.ignore) ;
      else if (oldNode instanceof HTMLHeadElement && ctx.head.style !== "morph") {
        handleHeadElement(newContent, oldNode, ctx);
      } else {
        syncNodeFrom(newContent, oldNode, ctx);
        if (!ignoreValueOfActiveElement(oldNode, ctx)) {
          morphChildren2(newContent, oldNode, ctx);
        }
      }
      ctx.callbacks.afterNodeMorphed(oldNode, newContent);
      return oldNode;
    }
  }
  function morphChildren2(newParent, oldParent, ctx) {
    let nextNewChild = newParent.firstChild;
    let insertionPoint = oldParent.firstChild;
    let newChild;
    while (nextNewChild) {
      newChild = nextNewChild;
      nextNewChild = newChild.nextSibling;
      if (insertionPoint == null) {
        if (ctx.callbacks.beforeNodeAdded(newChild) === false) return;
        oldParent.appendChild(newChild);
        ctx.callbacks.afterNodeAdded(newChild);
        removeIdsFromConsideration(ctx, newChild);
        continue;
      }
      if (isIdSetMatch(newChild, insertionPoint, ctx)) {
        morphOldNodeTo(insertionPoint, newChild, ctx);
        insertionPoint = insertionPoint.nextSibling;
        removeIdsFromConsideration(ctx, newChild);
        continue;
      }
      let idSetMatch = findIdSetMatch(newParent, oldParent, newChild, insertionPoint, ctx);
      if (idSetMatch) {
        insertionPoint = removeNodesBetween(insertionPoint, idSetMatch, ctx);
        morphOldNodeTo(idSetMatch, newChild, ctx);
        removeIdsFromConsideration(ctx, newChild);
        continue;
      }
      let softMatch = findSoftMatch(newParent, oldParent, newChild, insertionPoint, ctx);
      if (softMatch) {
        insertionPoint = removeNodesBetween(insertionPoint, softMatch, ctx);
        morphOldNodeTo(softMatch, newChild, ctx);
        removeIdsFromConsideration(ctx, newChild);
        continue;
      }
      if (ctx.callbacks.beforeNodeAdded(newChild) === false) return;
      oldParent.insertBefore(newChild, insertionPoint);
      ctx.callbacks.afterNodeAdded(newChild);
      removeIdsFromConsideration(ctx, newChild);
    }
    while (insertionPoint !== null) {
      let tempNode = insertionPoint;
      insertionPoint = insertionPoint.nextSibling;
      removeNode(tempNode, ctx);
    }
  }
  function ignoreAttribute(attr, to, updateType, ctx) {
    if (attr === "value" && ctx.ignoreActiveValue && to === document.activeElement) {
      return true;
    }
    return ctx.callbacks.beforeAttributeUpdated(attr, to, updateType) === false;
  }
  function syncNodeFrom(from, to, ctx) {
    let type = from.nodeType;
    if (type === 1) {
      const fromAttributes = from.attributes;
      const toAttributes = to.attributes;
      for (const fromAttribute of fromAttributes) {
        if (ignoreAttribute(fromAttribute.name, to, "update", ctx)) {
          continue;
        }
        if (to.getAttribute(fromAttribute.name) !== fromAttribute.value) {
          to.setAttribute(fromAttribute.name, fromAttribute.value);
        }
      }
      for (let i = toAttributes.length - 1; 0 <= i; i--) {
        const toAttribute = toAttributes[i];
        if (ignoreAttribute(toAttribute.name, to, "remove", ctx)) {
          continue;
        }
        if (!from.hasAttribute(toAttribute.name)) {
          to.removeAttribute(toAttribute.name);
        }
      }
    }
    if (type === 8 || type === 3) {
      if (to.nodeValue !== from.nodeValue) {
        to.nodeValue = from.nodeValue;
      }
    }
    if (!ignoreValueOfActiveElement(to, ctx)) {
      syncInputValue(from, to, ctx);
    }
  }
  function syncBooleanAttribute(from, to, attributeName, ctx) {
    if (from[attributeName] !== to[attributeName]) {
      let ignoreUpdate = ignoreAttribute(attributeName, to, "update", ctx);
      if (!ignoreUpdate) {
        to[attributeName] = from[attributeName];
      }
      if (from[attributeName]) {
        if (!ignoreUpdate) {
          to.setAttribute(attributeName, from[attributeName]);
        }
      } else {
        if (!ignoreAttribute(attributeName, to, "remove", ctx)) {
          to.removeAttribute(attributeName);
        }
      }
    }
  }
  function syncInputValue(from, to, ctx) {
    if (from instanceof HTMLInputElement && to instanceof HTMLInputElement && from.type !== "file") {
      let fromValue = from.value;
      let toValue = to.value;
      syncBooleanAttribute(from, to, "checked", ctx);
      syncBooleanAttribute(from, to, "disabled", ctx);
      if (!from.hasAttribute("value")) {
        if (!ignoreAttribute("value", to, "remove", ctx)) {
          to.value = "";
          to.removeAttribute("value");
        }
      } else if (fromValue !== toValue) {
        if (!ignoreAttribute("value", to, "update", ctx)) {
          to.setAttribute("value", fromValue);
          to.value = fromValue;
        }
      }
    } else if (from instanceof HTMLOptionElement) {
      syncBooleanAttribute(from, to, "selected", ctx);
    } else if (from instanceof HTMLTextAreaElement && to instanceof HTMLTextAreaElement) {
      let fromValue = from.value;
      let toValue = to.value;
      if (ignoreAttribute("value", to, "update", ctx)) {
        return;
      }
      if (fromValue !== toValue) {
        to.value = fromValue;
      }
      if (to.firstChild && to.firstChild.nodeValue !== fromValue) {
        to.firstChild.nodeValue = fromValue;
      }
    }
  }
  function handleHeadElement(newHeadTag, currentHead, ctx) {
    let added = [];
    let removed = [];
    let preserved = [];
    let nodesToAppend = [];
    let headMergeStyle = ctx.head.style;
    let srcToNewHeadNodes = /* @__PURE__ */ new Map();
    for (const newHeadChild of newHeadTag.children) {
      srcToNewHeadNodes.set(newHeadChild.outerHTML, newHeadChild);
    }
    for (const currentHeadElt of currentHead.children) {
      let inNewContent = srcToNewHeadNodes.has(currentHeadElt.outerHTML);
      let isReAppended = ctx.head.shouldReAppend(currentHeadElt);
      let isPreserved = ctx.head.shouldPreserve(currentHeadElt);
      if (inNewContent || isPreserved) {
        if (isReAppended) {
          removed.push(currentHeadElt);
        } else {
          srcToNewHeadNodes.delete(currentHeadElt.outerHTML);
          preserved.push(currentHeadElt);
        }
      } else {
        if (headMergeStyle === "append") {
          if (isReAppended) {
            removed.push(currentHeadElt);
            nodesToAppend.push(currentHeadElt);
          }
        } else {
          if (ctx.head.shouldRemove(currentHeadElt) !== false) {
            removed.push(currentHeadElt);
          }
        }
      }
    }
    nodesToAppend.push(...srcToNewHeadNodes.values());
    let promises = [];
    for (const newNode of nodesToAppend) {
      let newElt = document.createRange().createContextualFragment(newNode.outerHTML).firstChild;
      if (ctx.callbacks.beforeNodeAdded(newElt) !== false) {
        if (newElt.href || newElt.src) {
          let resolve = null;
          let promise = new Promise(function(_resolve) {
            resolve = _resolve;
          });
          newElt.addEventListener("load", function() {
            resolve();
          });
          promises.push(promise);
        }
        currentHead.appendChild(newElt);
        ctx.callbacks.afterNodeAdded(newElt);
        added.push(newElt);
      }
    }
    for (const removedElement of removed) {
      if (ctx.callbacks.beforeNodeRemoved(removedElement) !== false) {
        currentHead.removeChild(removedElement);
        ctx.callbacks.afterNodeRemoved(removedElement);
      }
    }
    ctx.head.afterHeadMorphed(currentHead, { added, kept: preserved, removed });
    return promises;
  }
  function noOp() {
  }
  function mergeDefaults(config2) {
    let finalConfig = {};
    Object.assign(finalConfig, defaults);
    Object.assign(finalConfig, config2);
    finalConfig.callbacks = {};
    Object.assign(finalConfig.callbacks, defaults.callbacks);
    Object.assign(finalConfig.callbacks, config2.callbacks);
    finalConfig.head = {};
    Object.assign(finalConfig.head, defaults.head);
    Object.assign(finalConfig.head, config2.head);
    return finalConfig;
  }
  function createMorphContext(oldNode, newContent, config2) {
    config2 = mergeDefaults(config2);
    return {
      target: oldNode,
      newContent,
      config: config2,
      morphStyle: config2.morphStyle,
      ignoreActive: config2.ignoreActive,
      ignoreActiveValue: config2.ignoreActiveValue,
      idMap: createIdMap(oldNode, newContent),
      deadIds: /* @__PURE__ */ new Set(),
      callbacks: config2.callbacks,
      head: config2.head
    };
  }
  function isIdSetMatch(node1, node2, ctx) {
    if (node1 == null || node2 == null) {
      return false;
    }
    if (node1.nodeType === node2.nodeType && node1.tagName === node2.tagName) {
      if (node1.id !== "" && node1.id === node2.id) {
        return true;
      } else {
        return getIdIntersectionCount(ctx, node1, node2) > 0;
      }
    }
    return false;
  }
  function isSoftMatch(node1, node2) {
    if (node1 == null || node2 == null) {
      return false;
    }
    return node1.nodeType === node2.nodeType && node1.tagName === node2.tagName;
  }
  function removeNodesBetween(startInclusive, endExclusive, ctx) {
    while (startInclusive !== endExclusive) {
      let tempNode = startInclusive;
      startInclusive = startInclusive.nextSibling;
      removeNode(tempNode, ctx);
    }
    removeIdsFromConsideration(ctx, endExclusive);
    return endExclusive.nextSibling;
  }
  function findIdSetMatch(newContent, oldParent, newChild, insertionPoint, ctx) {
    let newChildPotentialIdCount = getIdIntersectionCount(ctx, newChild, oldParent);
    let potentialMatch = null;
    if (newChildPotentialIdCount > 0) {
      let potentialMatch2 = insertionPoint;
      let otherMatchCount = 0;
      while (potentialMatch2 != null) {
        if (isIdSetMatch(newChild, potentialMatch2, ctx)) {
          return potentialMatch2;
        }
        otherMatchCount += getIdIntersectionCount(ctx, potentialMatch2, newContent);
        if (otherMatchCount > newChildPotentialIdCount) {
          return null;
        }
        potentialMatch2 = potentialMatch2.nextSibling;
      }
    }
    return potentialMatch;
  }
  function findSoftMatch(newContent, oldParent, newChild, insertionPoint, ctx) {
    let potentialSoftMatch = insertionPoint;
    let nextSibling = newChild.nextSibling;
    let siblingSoftMatchCount = 0;
    while (potentialSoftMatch != null) {
      if (getIdIntersectionCount(ctx, potentialSoftMatch, newContent) > 0) {
        return null;
      }
      if (isSoftMatch(newChild, potentialSoftMatch)) {
        return potentialSoftMatch;
      }
      if (isSoftMatch(nextSibling, potentialSoftMatch)) {
        siblingSoftMatchCount++;
        nextSibling = nextSibling.nextSibling;
        if (siblingSoftMatchCount >= 2) {
          return null;
        }
      }
      potentialSoftMatch = potentialSoftMatch.nextSibling;
    }
    return potentialSoftMatch;
  }
  function parseContent(newContent) {
    let parser = new DOMParser();
    let contentWithSvgsRemoved = newContent.replace(/<svg(\s[^>]*>|>)([\s\S]*?)<\/svg>/gim, "");
    if (contentWithSvgsRemoved.match(/<\/html>/) || contentWithSvgsRemoved.match(/<\/head>/) || contentWithSvgsRemoved.match(/<\/body>/)) {
      let content = parser.parseFromString(newContent, "text/html");
      if (contentWithSvgsRemoved.match(/<\/html>/)) {
        content.generatedByIdiomorph = true;
        return content;
      } else {
        let htmlElement = content.firstChild;
        if (htmlElement) {
          htmlElement.generatedByIdiomorph = true;
          return htmlElement;
        } else {
          return null;
        }
      }
    } else {
      let responseDoc = parser.parseFromString("<body><template>" + newContent + "</template></body>", "text/html");
      let content = responseDoc.body.querySelector("template").content;
      content.generatedByIdiomorph = true;
      return content;
    }
  }
  function normalizeContent(newContent) {
    if (newContent == null) {
      const dummyParent = document.createElement("div");
      return dummyParent;
    } else if (newContent.generatedByIdiomorph) {
      return newContent;
    } else if (newContent instanceof Node) {
      const dummyParent = document.createElement("div");
      dummyParent.append(newContent);
      return dummyParent;
    } else {
      const dummyParent = document.createElement("div");
      for (const elt of [...newContent]) {
        dummyParent.append(elt);
      }
      return dummyParent;
    }
  }
  function insertSiblings(previousSibling, morphedNode, nextSibling) {
    let stack = [];
    let added = [];
    while (previousSibling != null) {
      stack.push(previousSibling);
      previousSibling = previousSibling.previousSibling;
    }
    while (stack.length > 0) {
      let node = stack.pop();
      added.push(node);
      morphedNode.parentElement.insertBefore(node, morphedNode);
    }
    added.push(morphedNode);
    while (nextSibling != null) {
      stack.push(nextSibling);
      added.push(nextSibling);
      nextSibling = nextSibling.nextSibling;
    }
    while (stack.length > 0) {
      morphedNode.parentElement.insertBefore(stack.pop(), morphedNode.nextSibling);
    }
    return added;
  }
  function findBestNodeMatch(newContent, oldNode, ctx) {
    let currentElement;
    currentElement = newContent.firstChild;
    let bestElement = currentElement;
    let score = 0;
    while (currentElement) {
      let newScore = scoreElement(currentElement, oldNode, ctx);
      if (newScore > score) {
        bestElement = currentElement;
        score = newScore;
      }
      currentElement = currentElement.nextSibling;
    }
    return bestElement;
  }
  function scoreElement(node1, node2, ctx) {
    if (isSoftMatch(node1, node2)) {
      return 0.5 + getIdIntersectionCount(ctx, node1, node2);
    }
    return 0;
  }
  function removeNode(tempNode, ctx) {
    removeIdsFromConsideration(ctx, tempNode);
    if (ctx.callbacks.beforeNodeRemoved(tempNode) === false) return;
    tempNode.remove();
    ctx.callbacks.afterNodeRemoved(tempNode);
  }
  function isIdInConsideration(ctx, id) {
    return !ctx.deadIds.has(id);
  }
  function idIsWithinNode(ctx, id, targetNode) {
    let idSet = ctx.idMap.get(targetNode) || EMPTY_SET;
    return idSet.has(id);
  }
  function removeIdsFromConsideration(ctx, node) {
    let idSet = ctx.idMap.get(node) || EMPTY_SET;
    for (const id of idSet) {
      ctx.deadIds.add(id);
    }
  }
  function getIdIntersectionCount(ctx, node1, node2) {
    let sourceSet = ctx.idMap.get(node1) || EMPTY_SET;
    let matchCount = 0;
    for (const id of sourceSet) {
      if (isIdInConsideration(ctx, id) && idIsWithinNode(ctx, id, node2)) {
        ++matchCount;
      }
    }
    return matchCount;
  }
  function populateIdMapForNode(node, idMap) {
    let nodeParent = node.parentElement;
    let idElements = node.querySelectorAll("[id]");
    for (const elt of idElements) {
      let current = elt;
      while (current !== nodeParent && current != null) {
        let idSet = idMap.get(current);
        if (idSet == null) {
          idSet = /* @__PURE__ */ new Set();
          idMap.set(current, idSet);
        }
        idSet.add(elt.id);
        current = current.parentElement;
      }
    }
  }
  function createIdMap(oldContent, newContent) {
    let idMap = /* @__PURE__ */ new Map();
    populateIdMapForNode(oldContent, idMap);
    populateIdMapForNode(newContent, idMap);
    return idMap;
  }
  return {
    morph,
    defaults
  };
}();
function morphElements(currentElement, newElement, { callbacks, ...options } = {}) {
  Idiomorph.morph(currentElement, newElement, {
    ...options,
    callbacks: new DefaultIdiomorphCallbacks(callbacks)
  });
}
function morphChildren(currentElement, newElement) {
  morphElements(currentElement, newElement.children, {
    morphStyle: "innerHTML"
  });
}
var DefaultIdiomorphCallbacks = class {
  #beforeNodeMorphed;
  constructor({ beforeNodeMorphed } = {}) {
    this.#beforeNodeMorphed = beforeNodeMorphed || (() => true);
  }
  beforeNodeAdded = (node) => {
    return !(node.id && node.hasAttribute("data-turbo-permanent") && document.getElementById(node.id));
  };
  beforeNodeMorphed = (currentElement, newElement) => {
    if (currentElement instanceof Element) {
      if (!currentElement.hasAttribute("data-turbo-permanent") && this.#beforeNodeMorphed(currentElement, newElement)) {
        const event = dispatch("turbo:before-morph-element", {
          cancelable: true,
          target: currentElement,
          detail: { currentElement, newElement }
        });
        return !event.defaultPrevented;
      } else {
        return false;
      }
    }
  };
  beforeAttributeUpdated = (attributeName, target, mutationType) => {
    const event = dispatch("turbo:before-morph-attribute", {
      cancelable: true,
      target,
      detail: { attributeName, mutationType }
    });
    return !event.defaultPrevented;
  };
  beforeNodeRemoved = (node) => {
    return this.beforeNodeMorphed(node);
  };
  afterNodeMorphed = (currentElement, newElement) => {
    if (currentElement instanceof Element) {
      dispatch("turbo:morph-element", {
        target: currentElement,
        detail: { currentElement, newElement }
      });
    }
  };
};
var MorphingFrameRenderer = class extends FrameRenderer {
  static renderElement(currentElement, newElement) {
    dispatch("turbo:before-frame-morph", {
      target: currentElement,
      detail: { currentElement, newElement }
    });
    morphChildren(currentElement, newElement);
  }
  async preservingPermanentElements(callback) {
    return await callback();
  }
};
var ProgressBar = class _ProgressBar {
  static animationDuration = 300;
  /*ms*/
  static get defaultCSS() {
    return unindent`
      .turbo-progress-bar {
        position: fixed;
        display: block;
        top: 0;
        left: 0;
        height: 3px;
        background: #0076ff;
        z-index: 2147483647;
        transition:
          width ${_ProgressBar.animationDuration}ms ease-out,
          opacity ${_ProgressBar.animationDuration / 2}ms ${_ProgressBar.animationDuration / 2}ms ease-in;
        transform: translate3d(0, 0, 0);
      }
    `;
  }
  hiding = false;
  value = 0;
  visible = false;
  constructor() {
    this.stylesheetElement = this.createStylesheetElement();
    this.progressElement = this.createProgressElement();
    this.installStylesheetElement();
    this.setValue(0);
  }
  show() {
    if (!this.visible) {
      this.visible = true;
      this.installProgressElement();
      this.startTrickling();
    }
  }
  hide() {
    if (this.visible && !this.hiding) {
      this.hiding = true;
      this.fadeProgressElement(() => {
        this.uninstallProgressElement();
        this.stopTrickling();
        this.visible = false;
        this.hiding = false;
      });
    }
  }
  setValue(value) {
    this.value = value;
    this.refresh();
  }
  // Private
  installStylesheetElement() {
    document.head.insertBefore(this.stylesheetElement, document.head.firstChild);
  }
  installProgressElement() {
    this.progressElement.style.width = "0";
    this.progressElement.style.opacity = "1";
    document.documentElement.insertBefore(this.progressElement, document.body);
    this.refresh();
  }
  fadeProgressElement(callback) {
    this.progressElement.style.opacity = "0";
    setTimeout(callback, _ProgressBar.animationDuration * 1.5);
  }
  uninstallProgressElement() {
    if (this.progressElement.parentNode) {
      document.documentElement.removeChild(this.progressElement);
    }
  }
  startTrickling() {
    if (!this.trickleInterval) {
      this.trickleInterval = window.setInterval(this.trickle, _ProgressBar.animationDuration);
    }
  }
  stopTrickling() {
    window.clearInterval(this.trickleInterval);
    delete this.trickleInterval;
  }
  trickle = () => {
    this.setValue(this.value + Math.random() / 100);
  };
  refresh() {
    requestAnimationFrame(() => {
      this.progressElement.style.width = `${10 + this.value * 90}%`;
    });
  }
  createStylesheetElement() {
    const element = document.createElement("style");
    element.type = "text/css";
    element.textContent = _ProgressBar.defaultCSS;
    const cspNonce = getCspNonce();
    if (cspNonce) {
      element.nonce = cspNonce;
    }
    return element;
  }
  createProgressElement() {
    const element = document.createElement("div");
    element.className = "turbo-progress-bar";
    return element;
  }
};
var HeadSnapshot = class extends Snapshot {
  detailsByOuterHTML = this.children.filter((element) => !elementIsNoscript(element)).map((element) => elementWithoutNonce(element)).reduce((result, element) => {
    const { outerHTML } = element;
    const details = outerHTML in result ? result[outerHTML] : {
      type: elementType(element),
      tracked: elementIsTracked(element),
      elements: []
    };
    return {
      ...result,
      [outerHTML]: {
        ...details,
        elements: [...details.elements, element]
      }
    };
  }, {});
  get trackedElementSignature() {
    return Object.keys(this.detailsByOuterHTML).filter((outerHTML) => this.detailsByOuterHTML[outerHTML].tracked).join("");
  }
  getScriptElementsNotInSnapshot(snapshot) {
    return this.getElementsMatchingTypeNotInSnapshot("script", snapshot);
  }
  getStylesheetElementsNotInSnapshot(snapshot) {
    return this.getElementsMatchingTypeNotInSnapshot("stylesheet", snapshot);
  }
  getElementsMatchingTypeNotInSnapshot(matchedType, snapshot) {
    return Object.keys(this.detailsByOuterHTML).filter((outerHTML) => !(outerHTML in snapshot.detailsByOuterHTML)).map((outerHTML) => this.detailsByOuterHTML[outerHTML]).filter(({ type }) => type == matchedType).map(({ elements: [element] }) => element);
  }
  get provisionalElements() {
    return Object.keys(this.detailsByOuterHTML).reduce((result, outerHTML) => {
      const { type, tracked, elements } = this.detailsByOuterHTML[outerHTML];
      if (type == null && !tracked) {
        return [...result, ...elements];
      } else if (elements.length > 1) {
        return [...result, ...elements.slice(1)];
      } else {
        return result;
      }
    }, []);
  }
  getMetaValue(name) {
    const element = this.findMetaElementByName(name);
    return element ? element.getAttribute("content") : null;
  }
  findMetaElementByName(name) {
    return Object.keys(this.detailsByOuterHTML).reduce((result, outerHTML) => {
      const {
        elements: [element]
      } = this.detailsByOuterHTML[outerHTML];
      return elementIsMetaElementWithName(element, name) ? element : result;
    }, void 0 | void 0);
  }
};
function elementType(element) {
  if (elementIsScript(element)) {
    return "script";
  } else if (elementIsStylesheet(element)) {
    return "stylesheet";
  }
}
function elementIsTracked(element) {
  return element.getAttribute("data-turbo-track") == "reload";
}
function elementIsScript(element) {
  const tagName = element.localName;
  return tagName == "script";
}
function elementIsNoscript(element) {
  const tagName = element.localName;
  return tagName == "noscript";
}
function elementIsStylesheet(element) {
  const tagName = element.localName;
  return tagName == "style" || tagName == "link" && element.getAttribute("rel") == "stylesheet";
}
function elementIsMetaElementWithName(element, name) {
  const tagName = element.localName;
  return tagName == "meta" && element.getAttribute("name") == name;
}
function elementWithoutNonce(element) {
  if (element.hasAttribute("nonce")) {
    element.setAttribute("nonce", "");
  }
  return element;
}
var PageSnapshot = class _PageSnapshot extends Snapshot {
  static fromHTMLString(html = "") {
    return this.fromDocument(parseHTMLDocument(html));
  }
  static fromElement(element) {
    return this.fromDocument(element.ownerDocument);
  }
  static fromDocument({ documentElement, body, head }) {
    return new this(documentElement, body, new HeadSnapshot(head));
  }
  constructor(documentElement, body, headSnapshot) {
    super(body);
    this.documentElement = documentElement;
    this.headSnapshot = headSnapshot;
  }
  clone() {
    const clonedElement = this.element.cloneNode(true);
    const selectElements = this.element.querySelectorAll("select");
    const clonedSelectElements = clonedElement.querySelectorAll("select");
    for (const [index, source] of selectElements.entries()) {
      const clone = clonedSelectElements[index];
      for (const option of clone.selectedOptions) option.selected = false;
      for (const option of source.selectedOptions) clone.options[option.index].selected = true;
    }
    for (const clonedPasswordInput of clonedElement.querySelectorAll('input[type="password"]')) {
      clonedPasswordInput.value = "";
    }
    return new _PageSnapshot(this.documentElement, clonedElement, this.headSnapshot);
  }
  get lang() {
    return this.documentElement.getAttribute("lang");
  }
  get headElement() {
    return this.headSnapshot.element;
  }
  get rootLocation() {
    const root = this.getSetting("root") ?? "/";
    return expandURL(root);
  }
  get cacheControlValue() {
    return this.getSetting("cache-control");
  }
  get isPreviewable() {
    return this.cacheControlValue != "no-preview";
  }
  get isCacheable() {
    return this.cacheControlValue != "no-cache";
  }
  get isVisitable() {
    return this.getSetting("visit-control") != "reload";
  }
  get prefersViewTransitions() {
    return this.headSnapshot.getMetaValue("view-transition") === "same-origin";
  }
  get shouldMorphPage() {
    return this.getSetting("refresh-method") === "morph";
  }
  get shouldPreserveScrollPosition() {
    return this.getSetting("refresh-scroll") === "preserve";
  }
  // Private
  getSetting(name) {
    return this.headSnapshot.getMetaValue(`turbo-${name}`);
  }
};
var ViewTransitioner = class {
  #viewTransitionStarted = false;
  #lastOperation = Promise.resolve();
  renderChange(useViewTransition, render) {
    if (useViewTransition && this.viewTransitionsAvailable && !this.#viewTransitionStarted) {
      this.#viewTransitionStarted = true;
      this.#lastOperation = this.#lastOperation.then(async () => {
        await document.startViewTransition(render).finished;
      });
    } else {
      this.#lastOperation = this.#lastOperation.then(render);
    }
    return this.#lastOperation;
  }
  get viewTransitionsAvailable() {
    return document.startViewTransition;
  }
};
var defaultOptions = {
  action: "advance",
  historyChanged: false,
  visitCachedSnapshot: () => {
  },
  willRender: true,
  updateHistory: true,
  shouldCacheSnapshot: true,
  acceptsStreamResponse: false
};
var TimingMetric = {
  visitStart: "visitStart",
  requestStart: "requestStart",
  requestEnd: "requestEnd",
  visitEnd: "visitEnd"
};
var VisitState = {
  initialized: "initialized",
  started: "started",
  canceled: "canceled",
  failed: "failed",
  completed: "completed"
};
var SystemStatusCode = {
  networkFailure: 0,
  timeoutFailure: -1,
  contentTypeMismatch: -2
};
var Direction = {
  advance: "forward",
  restore: "back",
  replace: "none"
};
var Visit = class {
  identifier = uuid();
  // Required by turbo-ios
  timingMetrics = {};
  followedRedirect = false;
  historyChanged = false;
  scrolled = false;
  shouldCacheSnapshot = true;
  acceptsStreamResponse = false;
  snapshotCached = false;
  state = VisitState.initialized;
  viewTransitioner = new ViewTransitioner();
  constructor(delegate, location2, restorationIdentifier, options = {}) {
    this.delegate = delegate;
    this.location = location2;
    this.restorationIdentifier = restorationIdentifier || uuid();
    const {
      action,
      historyChanged,
      referrer,
      snapshot,
      snapshotHTML,
      response,
      visitCachedSnapshot,
      willRender,
      updateHistory,
      shouldCacheSnapshot,
      acceptsStreamResponse,
      direction
    } = {
      ...defaultOptions,
      ...options
    };
    this.action = action;
    this.historyChanged = historyChanged;
    this.referrer = referrer;
    this.snapshot = snapshot;
    this.snapshotHTML = snapshotHTML;
    this.response = response;
    this.isSamePage = this.delegate.locationWithActionIsSamePage(this.location, this.action);
    this.isPageRefresh = this.view.isPageRefresh(this);
    this.visitCachedSnapshot = visitCachedSnapshot;
    this.willRender = willRender;
    this.updateHistory = updateHistory;
    this.scrolled = !willRender;
    this.shouldCacheSnapshot = shouldCacheSnapshot;
    this.acceptsStreamResponse = acceptsStreamResponse;
    this.direction = direction || Direction[action];
  }
  get adapter() {
    return this.delegate.adapter;
  }
  get view() {
    return this.delegate.view;
  }
  get history() {
    return this.delegate.history;
  }
  get restorationData() {
    return this.history.getRestorationDataForIdentifier(this.restorationIdentifier);
  }
  get silent() {
    return this.isSamePage;
  }
  start() {
    if (this.state == VisitState.initialized) {
      this.recordTimingMetric(TimingMetric.visitStart);
      this.state = VisitState.started;
      this.adapter.visitStarted(this);
      this.delegate.visitStarted(this);
    }
  }
  cancel() {
    if (this.state == VisitState.started) {
      if (this.request) {
        this.request.cancel();
      }
      this.cancelRender();
      this.state = VisitState.canceled;
    }
  }
  complete() {
    if (this.state == VisitState.started) {
      this.recordTimingMetric(TimingMetric.visitEnd);
      this.adapter.visitCompleted(this);
      this.state = VisitState.completed;
      this.followRedirect();
      if (!this.followedRedirect) {
        this.delegate.visitCompleted(this);
      }
    }
  }
  fail() {
    if (this.state == VisitState.started) {
      this.state = VisitState.failed;
      this.adapter.visitFailed(this);
      this.delegate.visitCompleted(this);
    }
  }
  changeHistory() {
    if (!this.historyChanged && this.updateHistory) {
      const actionForHistory = this.location.href === this.referrer?.href ? "replace" : this.action;
      const method = getHistoryMethodForAction(actionForHistory);
      this.history.update(method, this.location, this.restorationIdentifier);
      this.historyChanged = true;
    }
  }
  issueRequest() {
    if (this.hasPreloadedResponse()) {
      this.simulateRequest();
    } else if (this.shouldIssueRequest() && !this.request) {
      this.request = new FetchRequest(this, FetchMethod.get, this.location);
      this.request.perform();
    }
  }
  simulateRequest() {
    if (this.response) {
      this.startRequest();
      this.recordResponse();
      this.finishRequest();
    }
  }
  startRequest() {
    this.recordTimingMetric(TimingMetric.requestStart);
    this.adapter.visitRequestStarted(this);
  }
  recordResponse(response = this.response) {
    this.response = response;
    if (response) {
      const { statusCode } = response;
      if (isSuccessful(statusCode)) {
        this.adapter.visitRequestCompleted(this);
      } else {
        this.adapter.visitRequestFailedWithStatusCode(this, statusCode);
      }
    }
  }
  finishRequest() {
    this.recordTimingMetric(TimingMetric.requestEnd);
    this.adapter.visitRequestFinished(this);
  }
  loadResponse() {
    if (this.response) {
      const { statusCode, responseHTML } = this.response;
      this.render(async () => {
        if (this.shouldCacheSnapshot) this.cacheSnapshot();
        if (this.view.renderPromise) await this.view.renderPromise;
        if (isSuccessful(statusCode) && responseHTML != null) {
          const snapshot = PageSnapshot.fromHTMLString(responseHTML);
          await this.renderPageSnapshot(snapshot, false);
          this.adapter.visitRendered(this);
          this.complete();
        } else {
          await this.view.renderError(PageSnapshot.fromHTMLString(responseHTML), this);
          this.adapter.visitRendered(this);
          this.fail();
        }
      });
    }
  }
  getCachedSnapshot() {
    const snapshot = this.view.getCachedSnapshotForLocation(this.location) || this.getPreloadedSnapshot();
    if (snapshot && (!getAnchor(this.location) || snapshot.hasAnchor(getAnchor(this.location)))) {
      if (this.action == "restore" || snapshot.isPreviewable) {
        return snapshot;
      }
    }
  }
  getPreloadedSnapshot() {
    if (this.snapshotHTML) {
      return PageSnapshot.fromHTMLString(this.snapshotHTML);
    }
  }
  hasCachedSnapshot() {
    return this.getCachedSnapshot() != null;
  }
  loadCachedSnapshot() {
    const snapshot = this.getCachedSnapshot();
    if (snapshot) {
      const isPreview = this.shouldIssueRequest();
      this.render(async () => {
        this.cacheSnapshot();
        if (this.isSamePage || this.isPageRefresh) {
          this.adapter.visitRendered(this);
        } else {
          if (this.view.renderPromise) await this.view.renderPromise;
          await this.renderPageSnapshot(snapshot, isPreview);
          this.adapter.visitRendered(this);
          if (!isPreview) {
            this.complete();
          }
        }
      });
    }
  }
  followRedirect() {
    if (this.redirectedToLocation && !this.followedRedirect && this.response?.redirected) {
      this.adapter.visitProposedToLocation(this.redirectedToLocation, {
        action: "replace",
        response: this.response,
        shouldCacheSnapshot: false,
        willRender: false
      });
      this.followedRedirect = true;
    }
  }
  goToSamePageAnchor() {
    if (this.isSamePage) {
      this.render(async () => {
        this.cacheSnapshot();
        this.performScroll();
        this.changeHistory();
        this.adapter.visitRendered(this);
      });
    }
  }
  // Fetch request delegate
  prepareRequest(request) {
    if (this.acceptsStreamResponse) {
      request.acceptResponseType(StreamMessage.contentType);
    }
  }
  requestStarted() {
    this.startRequest();
  }
  requestPreventedHandlingResponse(_request, _response) {
  }
  async requestSucceededWithResponse(request, response) {
    const responseHTML = await response.responseHTML;
    const { redirected, statusCode } = response;
    if (responseHTML == void 0) {
      this.recordResponse({
        statusCode: SystemStatusCode.contentTypeMismatch,
        redirected
      });
    } else {
      this.redirectedToLocation = response.redirected ? response.location : void 0;
      this.recordResponse({ statusCode, responseHTML, redirected });
    }
  }
  async requestFailedWithResponse(request, response) {
    const responseHTML = await response.responseHTML;
    const { redirected, statusCode } = response;
    if (responseHTML == void 0) {
      this.recordResponse({
        statusCode: SystemStatusCode.contentTypeMismatch,
        redirected
      });
    } else {
      this.recordResponse({ statusCode, responseHTML, redirected });
    }
  }
  requestErrored(_request, _error) {
    this.recordResponse({
      statusCode: SystemStatusCode.networkFailure,
      redirected: false
    });
  }
  requestFinished() {
    this.finishRequest();
  }
  // Scrolling
  performScroll() {
    if (!this.scrolled && !this.view.forceReloaded && !this.view.shouldPreserveScrollPosition(this)) {
      if (this.action == "restore") {
        this.scrollToRestoredPosition() || this.scrollToAnchor() || this.view.scrollToTop();
      } else {
        this.scrollToAnchor() || this.view.scrollToTop();
      }
      if (this.isSamePage) {
        this.delegate.visitScrolledToSamePageLocation(this.view.lastRenderedLocation, this.location);
      }
      this.scrolled = true;
    }
  }
  scrollToRestoredPosition() {
    const { scrollPosition } = this.restorationData;
    if (scrollPosition) {
      this.view.scrollToPosition(scrollPosition);
      return true;
    }
  }
  scrollToAnchor() {
    const anchor = getAnchor(this.location);
    if (anchor != null) {
      this.view.scrollToAnchor(anchor);
      return true;
    }
  }
  // Instrumentation
  recordTimingMetric(metric) {
    this.timingMetrics[metric] = (/* @__PURE__ */ new Date()).getTime();
  }
  getTimingMetrics() {
    return { ...this.timingMetrics };
  }
  // Private
  getHistoryMethodForAction(action) {
    switch (action) {
      case "replace":
        return history.replaceState;
      case "advance":
      case "restore":
        return history.pushState;
    }
  }
  hasPreloadedResponse() {
    return typeof this.response == "object";
  }
  shouldIssueRequest() {
    if (this.isSamePage) {
      return false;
    } else if (this.action == "restore") {
      return !this.hasCachedSnapshot();
    } else {
      return this.willRender;
    }
  }
  cacheSnapshot() {
    if (!this.snapshotCached) {
      this.view.cacheSnapshot(this.snapshot).then((snapshot) => snapshot && this.visitCachedSnapshot(snapshot));
      this.snapshotCached = true;
    }
  }
  async render(callback) {
    this.cancelRender();
    await new Promise((resolve) => {
      this.frame = document.visibilityState === "hidden" ? setTimeout(() => resolve(), 0) : requestAnimationFrame(() => resolve());
    });
    await callback();
    delete this.frame;
  }
  async renderPageSnapshot(snapshot, isPreview) {
    await this.viewTransitioner.renderChange(this.view.shouldTransitionTo(snapshot), async () => {
      await this.view.renderPage(snapshot, isPreview, this.willRender, this);
      this.performScroll();
    });
  }
  cancelRender() {
    if (this.frame) {
      cancelAnimationFrame(this.frame);
      delete this.frame;
    }
  }
};
function isSuccessful(statusCode) {
  return statusCode >= 200 && statusCode < 300;
}
var BrowserAdapter = class {
  progressBar = new ProgressBar();
  constructor(session2) {
    this.session = session2;
  }
  visitProposedToLocation(location2, options) {
    if (locationIsVisitable(location2, this.navigator.rootLocation)) {
      this.navigator.startVisit(location2, options?.restorationIdentifier || uuid(), options);
    } else {
      window.location.href = location2.toString();
    }
  }
  visitStarted(visit2) {
    this.location = visit2.location;
    visit2.loadCachedSnapshot();
    visit2.issueRequest();
    visit2.goToSamePageAnchor();
  }
  visitRequestStarted(visit2) {
    this.progressBar.setValue(0);
    if (visit2.hasCachedSnapshot() || visit2.action != "restore") {
      this.showVisitProgressBarAfterDelay();
    } else {
      this.showProgressBar();
    }
  }
  visitRequestCompleted(visit2) {
    visit2.loadResponse();
  }
  visitRequestFailedWithStatusCode(visit2, statusCode) {
    switch (statusCode) {
      case SystemStatusCode.networkFailure:
      case SystemStatusCode.timeoutFailure:
      case SystemStatusCode.contentTypeMismatch:
        return this.reload({
          reason: "request_failed",
          context: {
            statusCode
          }
        });
      default:
        return visit2.loadResponse();
    }
  }
  visitRequestFinished(_visit) {
  }
  visitCompleted(_visit) {
    this.progressBar.setValue(1);
    this.hideVisitProgressBar();
  }
  pageInvalidated(reason) {
    this.reload(reason);
  }
  visitFailed(_visit) {
    this.progressBar.setValue(1);
    this.hideVisitProgressBar();
  }
  visitRendered(_visit) {
  }
  // Form Submission Delegate
  formSubmissionStarted(_formSubmission) {
    this.progressBar.setValue(0);
    this.showFormProgressBarAfterDelay();
  }
  formSubmissionFinished(_formSubmission) {
    this.progressBar.setValue(1);
    this.hideFormProgressBar();
  }
  // Private
  showVisitProgressBarAfterDelay() {
    this.visitProgressBarTimeout = window.setTimeout(this.showProgressBar, this.session.progressBarDelay);
  }
  hideVisitProgressBar() {
    this.progressBar.hide();
    if (this.visitProgressBarTimeout != null) {
      window.clearTimeout(this.visitProgressBarTimeout);
      delete this.visitProgressBarTimeout;
    }
  }
  showFormProgressBarAfterDelay() {
    if (this.formProgressBarTimeout == null) {
      this.formProgressBarTimeout = window.setTimeout(this.showProgressBar, this.session.progressBarDelay);
    }
  }
  hideFormProgressBar() {
    this.progressBar.hide();
    if (this.formProgressBarTimeout != null) {
      window.clearTimeout(this.formProgressBarTimeout);
      delete this.formProgressBarTimeout;
    }
  }
  showProgressBar = () => {
    this.progressBar.show();
  };
  reload(reason) {
    dispatch("turbo:reload", { detail: reason });
    window.location.href = this.location?.toString() || window.location.href;
  }
  get navigator() {
    return this.session.navigator;
  }
};
var CacheObserver = class {
  selector = "[data-turbo-temporary]";
  deprecatedSelector = "[data-turbo-cache=false]";
  started = false;
  start() {
    if (!this.started) {
      this.started = true;
      addEventListener("turbo:before-cache", this.removeTemporaryElements, false);
    }
  }
  stop() {
    if (this.started) {
      this.started = false;
      removeEventListener("turbo:before-cache", this.removeTemporaryElements, false);
    }
  }
  removeTemporaryElements = (_event) => {
    for (const element of this.temporaryElements) {
      element.remove();
    }
  };
  get temporaryElements() {
    return [...document.querySelectorAll(this.selector), ...this.temporaryElementsWithDeprecation];
  }
  get temporaryElementsWithDeprecation() {
    const elements = document.querySelectorAll(this.deprecatedSelector);
    if (elements.length) {
      console.warn(
        `The ${this.deprecatedSelector} selector is deprecated and will be removed in a future version. Use ${this.selector} instead.`
      );
    }
    return [...elements];
  }
};
var FrameRedirector = class {
  constructor(session2, element) {
    this.session = session2;
    this.element = element;
    this.linkInterceptor = new LinkInterceptor(this, element);
    this.formSubmitObserver = new FormSubmitObserver(this, element);
  }
  start() {
    this.linkInterceptor.start();
    this.formSubmitObserver.start();
  }
  stop() {
    this.linkInterceptor.stop();
    this.formSubmitObserver.stop();
  }
  // Link interceptor delegate
  shouldInterceptLinkClick(element, _location, _event) {
    return this.#shouldRedirect(element);
  }
  linkClickIntercepted(element, url, event) {
    const frame = this.#findFrameElement(element);
    if (frame) {
      frame.delegate.linkClickIntercepted(element, url, event);
    }
  }
  // Form submit observer delegate
  willSubmitForm(element, submitter2) {
    return element.closest("turbo-frame") == null && this.#shouldSubmit(element, submitter2) && this.#shouldRedirect(element, submitter2);
  }
  formSubmitted(element, submitter2) {
    const frame = this.#findFrameElement(element, submitter2);
    if (frame) {
      frame.delegate.formSubmitted(element, submitter2);
    }
  }
  #shouldSubmit(form, submitter2) {
    const action = getAction$1(form, submitter2);
    const meta = this.element.ownerDocument.querySelector(`meta[name="turbo-root"]`);
    const rootLocation = expandURL(meta?.content ?? "/");
    return this.#shouldRedirect(form, submitter2) && locationIsVisitable(action, rootLocation);
  }
  #shouldRedirect(element, submitter2) {
    const isNavigatable = element instanceof HTMLFormElement ? this.session.submissionIsNavigatable(element, submitter2) : this.session.elementIsNavigatable(element);
    if (isNavigatable) {
      const frame = this.#findFrameElement(element, submitter2);
      return frame ? frame != element.closest("turbo-frame") : false;
    } else {
      return false;
    }
  }
  #findFrameElement(element, submitter2) {
    const id = submitter2?.getAttribute("data-turbo-frame") || element.getAttribute("data-turbo-frame");
    if (id && id != "_top") {
      const frame = this.element.querySelector(`#${id}:not([disabled])`);
      if (frame instanceof FrameElement) {
        return frame;
      }
    }
  }
};
var History = class {
  location;
  restorationIdentifier = uuid();
  restorationData = {};
  started = false;
  pageLoaded = false;
  currentIndex = 0;
  constructor(delegate) {
    this.delegate = delegate;
  }
  start() {
    if (!this.started) {
      addEventListener("popstate", this.onPopState, false);
      addEventListener("load", this.onPageLoad, false);
      this.currentIndex = history.state?.turbo?.restorationIndex || 0;
      this.started = true;
      this.replace(new URL(window.location.href));
    }
  }
  stop() {
    if (this.started) {
      removeEventListener("popstate", this.onPopState, false);
      removeEventListener("load", this.onPageLoad, false);
      this.started = false;
    }
  }
  push(location2, restorationIdentifier) {
    this.update(history.pushState, location2, restorationIdentifier);
  }
  replace(location2, restorationIdentifier) {
    this.update(history.replaceState, location2, restorationIdentifier);
  }
  update(method, location2, restorationIdentifier = uuid()) {
    if (method === history.pushState) ++this.currentIndex;
    const state = { turbo: { restorationIdentifier, restorationIndex: this.currentIndex } };
    method.call(history, state, "", location2.href);
    this.location = location2;
    this.restorationIdentifier = restorationIdentifier;
  }
  // Restoration data
  getRestorationDataForIdentifier(restorationIdentifier) {
    return this.restorationData[restorationIdentifier] || {};
  }
  updateRestorationData(additionalData) {
    const { restorationIdentifier } = this;
    const restorationData = this.restorationData[restorationIdentifier];
    this.restorationData[restorationIdentifier] = {
      ...restorationData,
      ...additionalData
    };
  }
  // Scroll restoration
  assumeControlOfScrollRestoration() {
    if (!this.previousScrollRestoration) {
      this.previousScrollRestoration = history.scrollRestoration ?? "auto";
      history.scrollRestoration = "manual";
    }
  }
  relinquishControlOfScrollRestoration() {
    if (this.previousScrollRestoration) {
      history.scrollRestoration = this.previousScrollRestoration;
      delete this.previousScrollRestoration;
    }
  }
  // Event handlers
  onPopState = (event) => {
    if (this.shouldHandlePopState()) {
      const { turbo } = event.state || {};
      if (turbo) {
        this.location = new URL(window.location.href);
        const { restorationIdentifier, restorationIndex } = turbo;
        this.restorationIdentifier = restorationIdentifier;
        const direction = restorationIndex > this.currentIndex ? "forward" : "back";
        this.delegate.historyPoppedToLocationWithRestorationIdentifierAndDirection(this.location, restorationIdentifier, direction);
        this.currentIndex = restorationIndex;
      }
    }
  };
  onPageLoad = async (_event) => {
    await nextMicrotask();
    this.pageLoaded = true;
  };
  // Private
  shouldHandlePopState() {
    return this.pageIsLoaded();
  }
  pageIsLoaded() {
    return this.pageLoaded || document.readyState == "complete";
  }
};
var LinkPrefetchObserver = class {
  started = false;
  #prefetchedLink = null;
  constructor(delegate, eventTarget) {
    this.delegate = delegate;
    this.eventTarget = eventTarget;
  }
  start() {
    if (this.started) return;
    if (this.eventTarget.readyState === "loading") {
      this.eventTarget.addEventListener("DOMContentLoaded", this.#enable, { once: true });
    } else {
      this.#enable();
    }
  }
  stop() {
    if (!this.started) return;
    this.eventTarget.removeEventListener("mouseenter", this.#tryToPrefetchRequest, {
      capture: true,
      passive: true
    });
    this.eventTarget.removeEventListener("mouseleave", this.#cancelRequestIfObsolete, {
      capture: true,
      passive: true
    });
    this.eventTarget.removeEventListener("turbo:before-fetch-request", this.#tryToUsePrefetchedRequest, true);
    this.started = false;
  }
  #enable = () => {
    this.eventTarget.addEventListener("mouseenter", this.#tryToPrefetchRequest, {
      capture: true,
      passive: true
    });
    this.eventTarget.addEventListener("mouseleave", this.#cancelRequestIfObsolete, {
      capture: true,
      passive: true
    });
    this.eventTarget.addEventListener("turbo:before-fetch-request", this.#tryToUsePrefetchedRequest, true);
    this.started = true;
  };
  #tryToPrefetchRequest = (event) => {
    if (getMetaContent("turbo-prefetch") === "false") return;
    const target = event.target;
    const isLink = target.matches && target.matches("a[href]:not([target^=_]):not([download])");
    if (isLink && this.#isPrefetchable(target)) {
      const link = target;
      const location2 = getLocationForLink(link);
      if (this.delegate.canPrefetchRequestToLocation(link, location2)) {
        this.#prefetchedLink = link;
        const fetchRequest = new FetchRequest(
          this,
          FetchMethod.get,
          location2,
          new URLSearchParams(),
          target
        );
        prefetchCache.setLater(location2.toString(), fetchRequest, this.#cacheTtl);
      }
    }
  };
  #cancelRequestIfObsolete = (event) => {
    if (event.target === this.#prefetchedLink) this.#cancelPrefetchRequest();
  };
  #cancelPrefetchRequest = () => {
    prefetchCache.clear();
    this.#prefetchedLink = null;
  };
  #tryToUsePrefetchedRequest = (event) => {
    if (event.target.tagName !== "FORM" && event.detail.fetchOptions.method === "GET") {
      const cached = prefetchCache.get(event.detail.url.toString());
      if (cached) {
        event.detail.fetchRequest = cached;
      }
      prefetchCache.clear();
    }
  };
  prepareRequest(request) {
    const link = request.target;
    request.headers["X-Sec-Purpose"] = "prefetch";
    const turboFrame = link.closest("turbo-frame");
    const turboFrameTarget = link.getAttribute("data-turbo-frame") || turboFrame?.getAttribute("target") || turboFrame?.id;
    if (turboFrameTarget && turboFrameTarget !== "_top") {
      request.headers["Turbo-Frame"] = turboFrameTarget;
    }
  }
  // Fetch request interface
  requestSucceededWithResponse() {
  }
  requestStarted(fetchRequest) {
  }
  requestErrored(fetchRequest) {
  }
  requestFinished(fetchRequest) {
  }
  requestPreventedHandlingResponse(fetchRequest, fetchResponse) {
  }
  requestFailedWithResponse(fetchRequest, fetchResponse) {
  }
  get #cacheTtl() {
    return Number(getMetaContent("turbo-prefetch-cache-time")) || cacheTtl;
  }
  #isPrefetchable(link) {
    const href = link.getAttribute("href");
    if (!href) return false;
    if (unfetchableLink(link)) return false;
    if (linkToTheSamePage(link)) return false;
    if (linkOptsOut(link)) return false;
    if (nonSafeLink(link)) return false;
    if (eventPrevented(link)) return false;
    return true;
  }
};
var unfetchableLink = (link) => {
  return link.origin !== document.location.origin || !["http:", "https:"].includes(link.protocol) || link.hasAttribute("target");
};
var linkToTheSamePage = (link) => {
  return link.pathname + link.search === document.location.pathname + document.location.search || link.href.startsWith("#");
};
var linkOptsOut = (link) => {
  if (link.getAttribute("data-turbo-prefetch") === "false") return true;
  if (link.getAttribute("data-turbo") === "false") return true;
  const turboPrefetchParent = findClosestRecursively(link, "[data-turbo-prefetch]");
  if (turboPrefetchParent && turboPrefetchParent.getAttribute("data-turbo-prefetch") === "false") return true;
  return false;
};
var nonSafeLink = (link) => {
  const turboMethod = link.getAttribute("data-turbo-method");
  if (turboMethod && turboMethod.toLowerCase() !== "get") return true;
  if (isUJS(link)) return true;
  if (link.hasAttribute("data-turbo-confirm")) return true;
  if (link.hasAttribute("data-turbo-stream")) return true;
  return false;
};
var isUJS = (link) => {
  return link.hasAttribute("data-remote") || link.hasAttribute("data-behavior") || link.hasAttribute("data-confirm") || link.hasAttribute("data-method");
};
var eventPrevented = (link) => {
  const event = dispatch("turbo:before-prefetch", { target: link, cancelable: true });
  return event.defaultPrevented;
};
var Navigator = class {
  constructor(delegate) {
    this.delegate = delegate;
  }
  proposeVisit(location2, options = {}) {
    if (this.delegate.allowsVisitingLocationWithAction(location2, options.action)) {
      this.delegate.visitProposedToLocation(location2, options);
    }
  }
  startVisit(locatable, restorationIdentifier, options = {}) {
    this.stop();
    this.currentVisit = new Visit(this, expandURL(locatable), restorationIdentifier, {
      referrer: this.location,
      ...options
    });
    this.currentVisit.start();
  }
  submitForm(form, submitter2) {
    this.stop();
    this.formSubmission = new FormSubmission(this, form, submitter2, true);
    this.formSubmission.start();
  }
  stop() {
    if (this.formSubmission) {
      this.formSubmission.stop();
      delete this.formSubmission;
    }
    if (this.currentVisit) {
      this.currentVisit.cancel();
      delete this.currentVisit;
    }
  }
  get adapter() {
    return this.delegate.adapter;
  }
  get view() {
    return this.delegate.view;
  }
  get rootLocation() {
    return this.view.snapshot.rootLocation;
  }
  get history() {
    return this.delegate.history;
  }
  // Form submission delegate
  formSubmissionStarted(formSubmission) {
    if (typeof this.adapter.formSubmissionStarted === "function") {
      this.adapter.formSubmissionStarted(formSubmission);
    }
  }
  async formSubmissionSucceededWithResponse(formSubmission, fetchResponse) {
    if (formSubmission == this.formSubmission) {
      const responseHTML = await fetchResponse.responseHTML;
      if (responseHTML) {
        const shouldCacheSnapshot = formSubmission.isSafe;
        if (!shouldCacheSnapshot) {
          this.view.clearSnapshotCache();
        }
        const { statusCode, redirected } = fetchResponse;
        const action = this.#getActionForFormSubmission(formSubmission, fetchResponse);
        const visitOptions = {
          action,
          shouldCacheSnapshot,
          response: { statusCode, responseHTML, redirected }
        };
        this.proposeVisit(fetchResponse.location, visitOptions);
      }
    }
  }
  async formSubmissionFailedWithResponse(formSubmission, fetchResponse) {
    const responseHTML = await fetchResponse.responseHTML;
    if (responseHTML) {
      const snapshot = PageSnapshot.fromHTMLString(responseHTML);
      if (fetchResponse.serverError) {
        await this.view.renderError(snapshot, this.currentVisit);
      } else {
        await this.view.renderPage(snapshot, false, true, this.currentVisit);
      }
      if (!snapshot.shouldPreserveScrollPosition) {
        this.view.scrollToTop();
      }
      this.view.clearSnapshotCache();
    }
  }
  formSubmissionErrored(formSubmission, error2) {
    console.error(error2);
  }
  formSubmissionFinished(formSubmission) {
    if (typeof this.adapter.formSubmissionFinished === "function") {
      this.adapter.formSubmissionFinished(formSubmission);
    }
  }
  // Visit delegate
  visitStarted(visit2) {
    this.delegate.visitStarted(visit2);
  }
  visitCompleted(visit2) {
    this.delegate.visitCompleted(visit2);
    delete this.currentVisit;
  }
  locationWithActionIsSamePage(location2, action) {
    const anchor = getAnchor(location2);
    const currentAnchor = getAnchor(this.view.lastRenderedLocation);
    const isRestorationToTop = action === "restore" && typeof anchor === "undefined";
    return action !== "replace" && getRequestURL(location2) === getRequestURL(this.view.lastRenderedLocation) && (isRestorationToTop || anchor != null && anchor !== currentAnchor);
  }
  visitScrolledToSamePageLocation(oldURL, newURL) {
    this.delegate.visitScrolledToSamePageLocation(oldURL, newURL);
  }
  // Visits
  get location() {
    return this.history.location;
  }
  get restorationIdentifier() {
    return this.history.restorationIdentifier;
  }
  #getActionForFormSubmission(formSubmission, fetchResponse) {
    const { submitter: submitter2, formElement } = formSubmission;
    return getVisitAction(submitter2, formElement) || this.#getDefaultAction(fetchResponse);
  }
  #getDefaultAction(fetchResponse) {
    const sameLocationRedirect = fetchResponse.redirected && fetchResponse.location.href === this.location?.href;
    return sameLocationRedirect ? "replace" : "advance";
  }
};
var PageStage = {
  initial: 0,
  loading: 1,
  interactive: 2,
  complete: 3
};
var PageObserver = class {
  stage = PageStage.initial;
  started = false;
  constructor(delegate) {
    this.delegate = delegate;
  }
  start() {
    if (!this.started) {
      if (this.stage == PageStage.initial) {
        this.stage = PageStage.loading;
      }
      document.addEventListener("readystatechange", this.interpretReadyState, false);
      addEventListener("pagehide", this.pageWillUnload, false);
      this.started = true;
    }
  }
  stop() {
    if (this.started) {
      document.removeEventListener("readystatechange", this.interpretReadyState, false);
      removeEventListener("pagehide", this.pageWillUnload, false);
      this.started = false;
    }
  }
  interpretReadyState = () => {
    const { readyState } = this;
    if (readyState == "interactive") {
      this.pageIsInteractive();
    } else if (readyState == "complete") {
      this.pageIsComplete();
    }
  };
  pageIsInteractive() {
    if (this.stage == PageStage.loading) {
      this.stage = PageStage.interactive;
      this.delegate.pageBecameInteractive();
    }
  }
  pageIsComplete() {
    this.pageIsInteractive();
    if (this.stage == PageStage.interactive) {
      this.stage = PageStage.complete;
      this.delegate.pageLoaded();
    }
  }
  pageWillUnload = () => {
    this.delegate.pageWillUnload();
  };
  get readyState() {
    return document.readyState;
  }
};
var ScrollObserver = class {
  started = false;
  constructor(delegate) {
    this.delegate = delegate;
  }
  start() {
    if (!this.started) {
      addEventListener("scroll", this.onScroll, false);
      this.onScroll();
      this.started = true;
    }
  }
  stop() {
    if (this.started) {
      removeEventListener("scroll", this.onScroll, false);
      this.started = false;
    }
  }
  onScroll = () => {
    this.updatePosition({ x: window.pageXOffset, y: window.pageYOffset });
  };
  // Private
  updatePosition(position) {
    this.delegate.scrollPositionChanged(position);
  }
};
var StreamMessageRenderer = class {
  render({ fragment }) {
    Bardo.preservingPermanentElements(this, getPermanentElementMapForFragment(fragment), () => {
      withAutofocusFromFragment(fragment, () => {
        withPreservedFocus(() => {
          document.documentElement.appendChild(fragment);
        });
      });
    });
  }
  // Bardo delegate
  enteringBardo(currentPermanentElement, newPermanentElement) {
    newPermanentElement.replaceWith(currentPermanentElement.cloneNode(true));
  }
  leavingBardo() {
  }
};
function getPermanentElementMapForFragment(fragment) {
  const permanentElementsInDocument = queryPermanentElementsAll(document.documentElement);
  const permanentElementMap = {};
  for (const permanentElementInDocument of permanentElementsInDocument) {
    const { id } = permanentElementInDocument;
    for (const streamElement of fragment.querySelectorAll("turbo-stream")) {
      const elementInStream = getPermanentElementById(streamElement.templateElement.content, id);
      if (elementInStream) {
        permanentElementMap[id] = [permanentElementInDocument, elementInStream];
      }
    }
  }
  return permanentElementMap;
}
async function withAutofocusFromFragment(fragment, callback) {
  const generatedID = `turbo-stream-autofocus-${uuid()}`;
  const turboStreams = fragment.querySelectorAll("turbo-stream");
  const elementWithAutofocus = firstAutofocusableElementInStreams(turboStreams);
  let willAutofocusId = null;
  if (elementWithAutofocus) {
    if (elementWithAutofocus.id) {
      willAutofocusId = elementWithAutofocus.id;
    } else {
      willAutofocusId = generatedID;
    }
    elementWithAutofocus.id = willAutofocusId;
  }
  callback();
  await nextRepaint();
  const hasNoActiveElement = document.activeElement == null || document.activeElement == document.body;
  if (hasNoActiveElement && willAutofocusId) {
    const elementToAutofocus = document.getElementById(willAutofocusId);
    if (elementIsFocusable(elementToAutofocus)) {
      elementToAutofocus.focus();
    }
    if (elementToAutofocus && elementToAutofocus.id == generatedID) {
      elementToAutofocus.removeAttribute("id");
    }
  }
}
async function withPreservedFocus(callback) {
  const [activeElementBeforeRender, activeElementAfterRender] = await around(callback, () => document.activeElement);
  const restoreFocusTo = activeElementBeforeRender && activeElementBeforeRender.id;
  if (restoreFocusTo) {
    const elementToFocus = document.getElementById(restoreFocusTo);
    if (elementIsFocusable(elementToFocus) && elementToFocus != activeElementAfterRender) {
      elementToFocus.focus();
    }
  }
}
function firstAutofocusableElementInStreams(nodeListOfStreamElements) {
  for (const streamElement of nodeListOfStreamElements) {
    const elementWithAutofocus = queryAutofocusableElement(streamElement.templateElement.content);
    if (elementWithAutofocus) return elementWithAutofocus;
  }
  return null;
}
var StreamObserver = class {
  sources = /* @__PURE__ */ new Set();
  #started = false;
  constructor(delegate) {
    this.delegate = delegate;
  }
  start() {
    if (!this.#started) {
      this.#started = true;
      addEventListener("turbo:before-fetch-response", this.inspectFetchResponse, false);
    }
  }
  stop() {
    if (this.#started) {
      this.#started = false;
      removeEventListener("turbo:before-fetch-response", this.inspectFetchResponse, false);
    }
  }
  connectStreamSource(source) {
    if (!this.streamSourceIsConnected(source)) {
      this.sources.add(source);
      source.addEventListener("message", this.receiveMessageEvent, false);
    }
  }
  disconnectStreamSource(source) {
    if (this.streamSourceIsConnected(source)) {
      this.sources.delete(source);
      source.removeEventListener("message", this.receiveMessageEvent, false);
    }
  }
  streamSourceIsConnected(source) {
    return this.sources.has(source);
  }
  inspectFetchResponse = (event) => {
    const response = fetchResponseFromEvent(event);
    if (response && fetchResponseIsStream(response)) {
      event.preventDefault();
      this.receiveMessageResponse(response);
    }
  };
  receiveMessageEvent = (event) => {
    if (this.#started && typeof event.data == "string") {
      this.receiveMessageHTML(event.data);
    }
  };
  async receiveMessageResponse(response) {
    const html = await response.responseHTML;
    if (html) {
      this.receiveMessageHTML(html);
    }
  }
  receiveMessageHTML(html) {
    this.delegate.receivedMessageFromStream(StreamMessage.wrap(html));
  }
};
function fetchResponseFromEvent(event) {
  const fetchResponse = event.detail?.fetchResponse;
  if (fetchResponse instanceof FetchResponse) {
    return fetchResponse;
  }
}
function fetchResponseIsStream(response) {
  const contentType = response.contentType ?? "";
  return contentType.startsWith(StreamMessage.contentType);
}
var ErrorRenderer = class extends Renderer {
  static renderElement(currentElement, newElement) {
    const { documentElement, body } = document;
    documentElement.replaceChild(newElement, body);
  }
  async render() {
    this.replaceHeadAndBody();
    this.activateScriptElements();
  }
  replaceHeadAndBody() {
    const { documentElement, head } = document;
    documentElement.replaceChild(this.newHead, head);
    this.renderElement(this.currentElement, this.newElement);
  }
  activateScriptElements() {
    for (const replaceableElement of this.scriptElements) {
      const parentNode = replaceableElement.parentNode;
      if (parentNode) {
        const element = activateScriptElement(replaceableElement);
        parentNode.replaceChild(element, replaceableElement);
      }
    }
  }
  get newHead() {
    return this.newSnapshot.headSnapshot.element;
  }
  get scriptElements() {
    return document.documentElement.querySelectorAll("script");
  }
};
var PageRenderer = class extends Renderer {
  static renderElement(currentElement, newElement) {
    if (document.body && newElement instanceof HTMLBodyElement) {
      document.body.replaceWith(newElement);
    } else {
      document.documentElement.appendChild(newElement);
    }
  }
  get shouldRender() {
    return this.newSnapshot.isVisitable && this.trackedElementsAreIdentical;
  }
  get reloadReason() {
    if (!this.newSnapshot.isVisitable) {
      return {
        reason: "turbo_visit_control_is_reload"
      };
    }
    if (!this.trackedElementsAreIdentical) {
      return {
        reason: "tracked_element_mismatch"
      };
    }
  }
  async prepareToRender() {
    this.#setLanguage();
    await this.mergeHead();
  }
  async render() {
    if (this.willRender) {
      await this.replaceBody();
    }
  }
  finishRendering() {
    super.finishRendering();
    if (!this.isPreview) {
      this.focusFirstAutofocusableElement();
    }
  }
  get currentHeadSnapshot() {
    return this.currentSnapshot.headSnapshot;
  }
  get newHeadSnapshot() {
    return this.newSnapshot.headSnapshot;
  }
  get newElement() {
    return this.newSnapshot.element;
  }
  #setLanguage() {
    const { documentElement } = this.currentSnapshot;
    const { lang } = this.newSnapshot;
    if (lang) {
      documentElement.setAttribute("lang", lang);
    } else {
      documentElement.removeAttribute("lang");
    }
  }
  async mergeHead() {
    const mergedHeadElements = this.mergeProvisionalElements();
    const newStylesheetElements = this.copyNewHeadStylesheetElements();
    this.copyNewHeadScriptElements();
    await mergedHeadElements;
    await newStylesheetElements;
    if (this.willRender) {
      this.removeUnusedDynamicStylesheetElements();
    }
  }
  async replaceBody() {
    await this.preservingPermanentElements(async () => {
      this.activateNewBody();
      await this.assignNewBody();
    });
  }
  get trackedElementsAreIdentical() {
    return this.currentHeadSnapshot.trackedElementSignature == this.newHeadSnapshot.trackedElementSignature;
  }
  async copyNewHeadStylesheetElements() {
    const loadingElements = [];
    for (const element of this.newHeadStylesheetElements) {
      loadingElements.push(waitForLoad(element));
      document.head.appendChild(element);
    }
    await Promise.all(loadingElements);
  }
  copyNewHeadScriptElements() {
    for (const element of this.newHeadScriptElements) {
      document.head.appendChild(activateScriptElement(element));
    }
  }
  removeUnusedDynamicStylesheetElements() {
    for (const element of this.unusedDynamicStylesheetElements) {
      document.head.removeChild(element);
    }
  }
  async mergeProvisionalElements() {
    const newHeadElements = [...this.newHeadProvisionalElements];
    for (const element of this.currentHeadProvisionalElements) {
      if (!this.isCurrentElementInElementList(element, newHeadElements)) {
        document.head.removeChild(element);
      }
    }
    for (const element of newHeadElements) {
      document.head.appendChild(element);
    }
  }
  isCurrentElementInElementList(element, elementList) {
    for (const [index, newElement] of elementList.entries()) {
      if (element.tagName == "TITLE") {
        if (newElement.tagName != "TITLE") {
          continue;
        }
        if (element.innerHTML == newElement.innerHTML) {
          elementList.splice(index, 1);
          return true;
        }
      }
      if (newElement.isEqualNode(element)) {
        elementList.splice(index, 1);
        return true;
      }
    }
    return false;
  }
  removeCurrentHeadProvisionalElements() {
    for (const element of this.currentHeadProvisionalElements) {
      document.head.removeChild(element);
    }
  }
  copyNewHeadProvisionalElements() {
    for (const element of this.newHeadProvisionalElements) {
      document.head.appendChild(element);
    }
  }
  activateNewBody() {
    document.adoptNode(this.newElement);
    this.activateNewBodyScriptElements();
  }
  activateNewBodyScriptElements() {
    for (const inertScriptElement of this.newBodyScriptElements) {
      const activatedScriptElement = activateScriptElement(inertScriptElement);
      inertScriptElement.replaceWith(activatedScriptElement);
    }
  }
  async assignNewBody() {
    await this.renderElement(this.currentElement, this.newElement);
  }
  get unusedDynamicStylesheetElements() {
    return this.oldHeadStylesheetElements.filter((element) => {
      return element.getAttribute("data-turbo-track") === "dynamic";
    });
  }
  get oldHeadStylesheetElements() {
    return this.currentHeadSnapshot.getStylesheetElementsNotInSnapshot(this.newHeadSnapshot);
  }
  get newHeadStylesheetElements() {
    return this.newHeadSnapshot.getStylesheetElementsNotInSnapshot(this.currentHeadSnapshot);
  }
  get newHeadScriptElements() {
    return this.newHeadSnapshot.getScriptElementsNotInSnapshot(this.currentHeadSnapshot);
  }
  get currentHeadProvisionalElements() {
    return this.currentHeadSnapshot.provisionalElements;
  }
  get newHeadProvisionalElements() {
    return this.newHeadSnapshot.provisionalElements;
  }
  get newBodyScriptElements() {
    return this.newElement.querySelectorAll("script");
  }
};
var MorphingPageRenderer = class extends PageRenderer {
  static renderElement(currentElement, newElement) {
    morphElements(currentElement, newElement, {
      callbacks: {
        beforeNodeMorphed: (element) => !canRefreshFrame(element)
      }
    });
    for (const frame of currentElement.querySelectorAll("turbo-frame")) {
      if (canRefreshFrame(frame)) frame.reload();
    }
    dispatch("turbo:morph", { detail: { currentElement, newElement } });
  }
  async preservingPermanentElements(callback) {
    return await callback();
  }
  get renderMethod() {
    return "morph";
  }
  get shouldAutofocus() {
    return false;
  }
};
function canRefreshFrame(frame) {
  return frame instanceof FrameElement && frame.src && frame.refresh === "morph" && !frame.closest("[data-turbo-permanent]");
}
var SnapshotCache = class {
  keys = [];
  snapshots = {};
  constructor(size) {
    this.size = size;
  }
  has(location2) {
    return toCacheKey(location2) in this.snapshots;
  }
  get(location2) {
    if (this.has(location2)) {
      const snapshot = this.read(location2);
      this.touch(location2);
      return snapshot;
    }
  }
  put(location2, snapshot) {
    this.write(location2, snapshot);
    this.touch(location2);
    return snapshot;
  }
  clear() {
    this.snapshots = {};
  }
  // Private
  read(location2) {
    return this.snapshots[toCacheKey(location2)];
  }
  write(location2, snapshot) {
    this.snapshots[toCacheKey(location2)] = snapshot;
  }
  touch(location2) {
    const key = toCacheKey(location2);
    const index = this.keys.indexOf(key);
    if (index > -1) this.keys.splice(index, 1);
    this.keys.unshift(key);
    this.trim();
  }
  trim() {
    for (const key of this.keys.splice(this.size)) {
      delete this.snapshots[key];
    }
  }
};
var PageView = class extends View {
  snapshotCache = new SnapshotCache(10);
  lastRenderedLocation = new URL(location.href);
  forceReloaded = false;
  shouldTransitionTo(newSnapshot) {
    return this.snapshot.prefersViewTransitions && newSnapshot.prefersViewTransitions;
  }
  renderPage(snapshot, isPreview = false, willRender = true, visit2) {
    const shouldMorphPage = this.isPageRefresh(visit2) && this.snapshot.shouldMorphPage;
    const rendererClass = shouldMorphPage ? MorphingPageRenderer : PageRenderer;
    const renderer = new rendererClass(this.snapshot, snapshot, isPreview, willRender);
    if (!renderer.shouldRender) {
      this.forceReloaded = true;
    } else {
      visit2?.changeHistory();
    }
    return this.render(renderer);
  }
  renderError(snapshot, visit2) {
    visit2?.changeHistory();
    const renderer = new ErrorRenderer(this.snapshot, snapshot, false);
    return this.render(renderer);
  }
  clearSnapshotCache() {
    this.snapshotCache.clear();
  }
  async cacheSnapshot(snapshot = this.snapshot) {
    if (snapshot.isCacheable) {
      this.delegate.viewWillCacheSnapshot();
      const { lastRenderedLocation: location2 } = this;
      await nextEventLoopTick();
      const cachedSnapshot = snapshot.clone();
      this.snapshotCache.put(location2, cachedSnapshot);
      return cachedSnapshot;
    }
  }
  getCachedSnapshotForLocation(location2) {
    return this.snapshotCache.get(location2);
  }
  isPageRefresh(visit2) {
    return !visit2 || this.lastRenderedLocation.pathname === visit2.location.pathname && visit2.action === "replace";
  }
  shouldPreserveScrollPosition(visit2) {
    return this.isPageRefresh(visit2) && this.snapshot.shouldPreserveScrollPosition;
  }
  get snapshot() {
    return PageSnapshot.fromElement(this.element);
  }
};
var Preloader = class {
  selector = "a[data-turbo-preload]";
  constructor(delegate, snapshotCache) {
    this.delegate = delegate;
    this.snapshotCache = snapshotCache;
  }
  start() {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", this.#preloadAll);
    } else {
      this.preloadOnLoadLinksForView(document.body);
    }
  }
  stop() {
    document.removeEventListener("DOMContentLoaded", this.#preloadAll);
  }
  preloadOnLoadLinksForView(element) {
    for (const link of element.querySelectorAll(this.selector)) {
      if (this.delegate.shouldPreloadLink(link)) {
        this.preloadURL(link);
      }
    }
  }
  async preloadURL(link) {
    const location2 = new URL(link.href);
    if (this.snapshotCache.has(location2)) {
      return;
    }
    const fetchRequest = new FetchRequest(this, FetchMethod.get, location2, new URLSearchParams(), link);
    await fetchRequest.perform();
  }
  // Fetch request delegate
  prepareRequest(fetchRequest) {
    fetchRequest.headers["X-Sec-Purpose"] = "prefetch";
  }
  async requestSucceededWithResponse(fetchRequest, fetchResponse) {
    try {
      const responseHTML = await fetchResponse.responseHTML;
      const snapshot = PageSnapshot.fromHTMLString(responseHTML);
      this.snapshotCache.put(fetchRequest.url, snapshot);
    } catch (_) {
    }
  }
  requestStarted(fetchRequest) {
  }
  requestErrored(fetchRequest) {
  }
  requestFinished(fetchRequest) {
  }
  requestPreventedHandlingResponse(fetchRequest, fetchResponse) {
  }
  requestFailedWithResponse(fetchRequest, fetchResponse) {
  }
  #preloadAll = () => {
    this.preloadOnLoadLinksForView(document.body);
  };
};
var Cache = class {
  constructor(session2) {
    this.session = session2;
  }
  clear() {
    this.session.clearCache();
  }
  resetCacheControl() {
    this.#setCacheControl("");
  }
  exemptPageFromCache() {
    this.#setCacheControl("no-cache");
  }
  exemptPageFromPreview() {
    this.#setCacheControl("no-preview");
  }
  #setCacheControl(value) {
    setMetaContent("turbo-cache-control", value);
  }
};
var Session = class {
  navigator = new Navigator(this);
  history = new History(this);
  view = new PageView(this, document.documentElement);
  adapter = new BrowserAdapter(this);
  pageObserver = new PageObserver(this);
  cacheObserver = new CacheObserver();
  linkPrefetchObserver = new LinkPrefetchObserver(this, document);
  linkClickObserver = new LinkClickObserver(this, window);
  formSubmitObserver = new FormSubmitObserver(this, document);
  scrollObserver = new ScrollObserver(this);
  streamObserver = new StreamObserver(this);
  formLinkClickObserver = new FormLinkClickObserver(this, document.documentElement);
  frameRedirector = new FrameRedirector(this, document.documentElement);
  streamMessageRenderer = new StreamMessageRenderer();
  cache = new Cache(this);
  enabled = true;
  started = false;
  #pageRefreshDebouncePeriod = 150;
  constructor(recentRequests2) {
    this.recentRequests = recentRequests2;
    this.preloader = new Preloader(this, this.view.snapshotCache);
    this.debouncedRefresh = this.refresh;
    this.pageRefreshDebouncePeriod = this.pageRefreshDebouncePeriod;
  }
  start() {
    if (!this.started) {
      this.pageObserver.start();
      this.cacheObserver.start();
      this.linkPrefetchObserver.start();
      this.formLinkClickObserver.start();
      this.linkClickObserver.start();
      this.formSubmitObserver.start();
      this.scrollObserver.start();
      this.streamObserver.start();
      this.frameRedirector.start();
      this.history.start();
      this.preloader.start();
      this.started = true;
      this.enabled = true;
    }
  }
  disable() {
    this.enabled = false;
  }
  stop() {
    if (this.started) {
      this.pageObserver.stop();
      this.cacheObserver.stop();
      this.linkPrefetchObserver.stop();
      this.formLinkClickObserver.stop();
      this.linkClickObserver.stop();
      this.formSubmitObserver.stop();
      this.scrollObserver.stop();
      this.streamObserver.stop();
      this.frameRedirector.stop();
      this.history.stop();
      this.preloader.stop();
      this.started = false;
    }
  }
  registerAdapter(adapter) {
    this.adapter = adapter;
  }
  visit(location2, options = {}) {
    const frameElement = options.frame ? document.getElementById(options.frame) : null;
    if (frameElement instanceof FrameElement) {
      const action = options.action || getVisitAction(frameElement);
      frameElement.delegate.proposeVisitIfNavigatedWithAction(frameElement, action);
      frameElement.src = location2.toString();
    } else {
      this.navigator.proposeVisit(expandURL(location2), options);
    }
  }
  refresh(url, requestId) {
    const isRecentRequest = requestId && this.recentRequests.has(requestId);
    if (!isRecentRequest && !this.navigator.currentVisit) {
      this.visit(url, { action: "replace", shouldCacheSnapshot: false });
    }
  }
  connectStreamSource(source) {
    this.streamObserver.connectStreamSource(source);
  }
  disconnectStreamSource(source) {
    this.streamObserver.disconnectStreamSource(source);
  }
  renderStreamMessage(message) {
    this.streamMessageRenderer.render(StreamMessage.wrap(message));
  }
  clearCache() {
    this.view.clearSnapshotCache();
  }
  setProgressBarDelay(delay) {
    console.warn(
      "Please replace `session.setProgressBarDelay(delay)` with `session.progressBarDelay = delay`. The function is deprecated and will be removed in a future version of Turbo.`"
    );
    this.progressBarDelay = delay;
  }
  set progressBarDelay(delay) {
    config.drive.progressBarDelay = delay;
  }
  get progressBarDelay() {
    return config.drive.progressBarDelay;
  }
  set drive(value) {
    config.drive.enabled = value;
  }
  get drive() {
    return config.drive.enabled;
  }
  set formMode(value) {
    config.forms.mode = value;
  }
  get formMode() {
    return config.forms.mode;
  }
  get location() {
    return this.history.location;
  }
  get restorationIdentifier() {
    return this.history.restorationIdentifier;
  }
  get pageRefreshDebouncePeriod() {
    return this.#pageRefreshDebouncePeriod;
  }
  set pageRefreshDebouncePeriod(value) {
    this.refresh = debounce(this.debouncedRefresh.bind(this), value);
    this.#pageRefreshDebouncePeriod = value;
  }
  // Preloader delegate
  shouldPreloadLink(element) {
    const isUnsafe = element.hasAttribute("data-turbo-method");
    const isStream = element.hasAttribute("data-turbo-stream");
    const frameTarget = element.getAttribute("data-turbo-frame");
    const frame = frameTarget == "_top" ? null : document.getElementById(frameTarget) || findClosestRecursively(element, "turbo-frame:not([disabled])");
    if (isUnsafe || isStream || frame instanceof FrameElement) {
      return false;
    } else {
      const location2 = new URL(element.href);
      return this.elementIsNavigatable(element) && locationIsVisitable(location2, this.snapshot.rootLocation);
    }
  }
  // History delegate
  historyPoppedToLocationWithRestorationIdentifierAndDirection(location2, restorationIdentifier, direction) {
    if (this.enabled) {
      this.navigator.startVisit(location2, restorationIdentifier, {
        action: "restore",
        historyChanged: true,
        direction
      });
    } else {
      this.adapter.pageInvalidated({
        reason: "turbo_disabled"
      });
    }
  }
  // Scroll observer delegate
  scrollPositionChanged(position) {
    this.history.updateRestorationData({ scrollPosition: position });
  }
  // Form click observer delegate
  willSubmitFormLinkToLocation(link, location2) {
    return this.elementIsNavigatable(link) && locationIsVisitable(location2, this.snapshot.rootLocation);
  }
  submittedFormLinkToLocation() {
  }
  // Link hover observer delegate
  canPrefetchRequestToLocation(link, location2) {
    return this.elementIsNavigatable(link) && locationIsVisitable(location2, this.snapshot.rootLocation);
  }
  // Link click observer delegate
  willFollowLinkToLocation(link, location2, event) {
    return this.elementIsNavigatable(link) && locationIsVisitable(location2, this.snapshot.rootLocation) && this.applicationAllowsFollowingLinkToLocation(link, location2, event);
  }
  followedLinkToLocation(link, location2) {
    const action = this.getActionForLink(link);
    const acceptsStreamResponse = link.hasAttribute("data-turbo-stream");
    this.visit(location2.href, { action, acceptsStreamResponse });
  }
  // Navigator delegate
  allowsVisitingLocationWithAction(location2, action) {
    return this.locationWithActionIsSamePage(location2, action) || this.applicationAllowsVisitingLocation(location2);
  }
  visitProposedToLocation(location2, options) {
    extendURLWithDeprecatedProperties(location2);
    this.adapter.visitProposedToLocation(location2, options);
  }
  // Visit delegate
  visitStarted(visit2) {
    if (!visit2.acceptsStreamResponse) {
      markAsBusy(document.documentElement);
      this.view.markVisitDirection(visit2.direction);
    }
    extendURLWithDeprecatedProperties(visit2.location);
    if (!visit2.silent) {
      this.notifyApplicationAfterVisitingLocation(visit2.location, visit2.action);
    }
  }
  visitCompleted(visit2) {
    this.view.unmarkVisitDirection();
    clearBusyState(document.documentElement);
    this.notifyApplicationAfterPageLoad(visit2.getTimingMetrics());
  }
  locationWithActionIsSamePage(location2, action) {
    return this.navigator.locationWithActionIsSamePage(location2, action);
  }
  visitScrolledToSamePageLocation(oldURL, newURL) {
    this.notifyApplicationAfterVisitingSamePageLocation(oldURL, newURL);
  }
  // Form submit observer delegate
  willSubmitForm(form, submitter2) {
    const action = getAction$1(form, submitter2);
    return this.submissionIsNavigatable(form, submitter2) && locationIsVisitable(expandURL(action), this.snapshot.rootLocation);
  }
  formSubmitted(form, submitter2) {
    this.navigator.submitForm(form, submitter2);
  }
  // Page observer delegate
  pageBecameInteractive() {
    this.view.lastRenderedLocation = this.location;
    this.notifyApplicationAfterPageLoad();
  }
  pageLoaded() {
    this.history.assumeControlOfScrollRestoration();
  }
  pageWillUnload() {
    this.history.relinquishControlOfScrollRestoration();
  }
  // Stream observer delegate
  receivedMessageFromStream(message) {
    this.renderStreamMessage(message);
  }
  // Page view delegate
  viewWillCacheSnapshot() {
    if (!this.navigator.currentVisit?.silent) {
      this.notifyApplicationBeforeCachingSnapshot();
    }
  }
  allowsImmediateRender({ element }, options) {
    const event = this.notifyApplicationBeforeRender(element, options);
    const {
      defaultPrevented,
      detail: { render }
    } = event;
    if (this.view.renderer && render) {
      this.view.renderer.renderElement = render;
    }
    return !defaultPrevented;
  }
  viewRenderedSnapshot(_snapshot, _isPreview, renderMethod) {
    this.view.lastRenderedLocation = this.history.location;
    this.notifyApplicationAfterRender(renderMethod);
  }
  preloadOnLoadLinksForView(element) {
    this.preloader.preloadOnLoadLinksForView(element);
  }
  viewInvalidated(reason) {
    this.adapter.pageInvalidated(reason);
  }
  // Frame element
  frameLoaded(frame) {
    this.notifyApplicationAfterFrameLoad(frame);
  }
  frameRendered(fetchResponse, frame) {
    this.notifyApplicationAfterFrameRender(fetchResponse, frame);
  }
  // Application events
  applicationAllowsFollowingLinkToLocation(link, location2, ev) {
    const event = this.notifyApplicationAfterClickingLinkToLocation(link, location2, ev);
    return !event.defaultPrevented;
  }
  applicationAllowsVisitingLocation(location2) {
    const event = this.notifyApplicationBeforeVisitingLocation(location2);
    return !event.defaultPrevented;
  }
  notifyApplicationAfterClickingLinkToLocation(link, location2, event) {
    return dispatch("turbo:click", {
      target: link,
      detail: { url: location2.href, originalEvent: event },
      cancelable: true
    });
  }
  notifyApplicationBeforeVisitingLocation(location2) {
    return dispatch("turbo:before-visit", {
      detail: { url: location2.href },
      cancelable: true
    });
  }
  notifyApplicationAfterVisitingLocation(location2, action) {
    return dispatch("turbo:visit", { detail: { url: location2.href, action } });
  }
  notifyApplicationBeforeCachingSnapshot() {
    return dispatch("turbo:before-cache");
  }
  notifyApplicationBeforeRender(newBody, options) {
    return dispatch("turbo:before-render", {
      detail: { newBody, ...options },
      cancelable: true
    });
  }
  notifyApplicationAfterRender(renderMethod) {
    return dispatch("turbo:render", { detail: { renderMethod } });
  }
  notifyApplicationAfterPageLoad(timing = {}) {
    return dispatch("turbo:load", {
      detail: { url: this.location.href, timing }
    });
  }
  notifyApplicationAfterVisitingSamePageLocation(oldURL, newURL) {
    dispatchEvent(
      new HashChangeEvent("hashchange", {
        oldURL: oldURL.toString(),
        newURL: newURL.toString()
      })
    );
  }
  notifyApplicationAfterFrameLoad(frame) {
    return dispatch("turbo:frame-load", { target: frame });
  }
  notifyApplicationAfterFrameRender(fetchResponse, frame) {
    return dispatch("turbo:frame-render", {
      detail: { fetchResponse },
      target: frame,
      cancelable: true
    });
  }
  // Helpers
  submissionIsNavigatable(form, submitter2) {
    if (config.forms.mode == "off") {
      return false;
    } else {
      const submitterIsNavigatable = submitter2 ? this.elementIsNavigatable(submitter2) : true;
      if (config.forms.mode == "optin") {
        return submitterIsNavigatable && form.closest('[data-turbo="true"]') != null;
      } else {
        return submitterIsNavigatable && this.elementIsNavigatable(form);
      }
    }
  }
  elementIsNavigatable(element) {
    const container = findClosestRecursively(element, "[data-turbo]");
    const withinFrame = findClosestRecursively(element, "turbo-frame");
    if (config.drive.enabled || withinFrame) {
      if (container) {
        return container.getAttribute("data-turbo") != "false";
      } else {
        return true;
      }
    } else {
      if (container) {
        return container.getAttribute("data-turbo") == "true";
      } else {
        return false;
      }
    }
  }
  // Private
  getActionForLink(link) {
    return getVisitAction(link) || "advance";
  }
  get snapshot() {
    return this.view.snapshot;
  }
};
function extendURLWithDeprecatedProperties(url) {
  Object.defineProperties(url, deprecatedLocationPropertyDescriptors);
}
var deprecatedLocationPropertyDescriptors = {
  absoluteURL: {
    get() {
      return this.toString();
    }
  }
};
var session = new Session(recentRequests);
var { cache, navigator: navigator$1 } = session;
function start() {
  session.start();
}
function registerAdapter(adapter) {
  session.registerAdapter(adapter);
}
function visit(location2, options) {
  session.visit(location2, options);
}
function connectStreamSource(source) {
  session.connectStreamSource(source);
}
function disconnectStreamSource(source) {
  session.disconnectStreamSource(source);
}
function renderStreamMessage(message) {
  session.renderStreamMessage(message);
}
function clearCache() {
  console.warn(
    "Please replace `Turbo.clearCache()` with `Turbo.cache.clear()`. The top-level function is deprecated and will be removed in a future version of Turbo.`"
  );
  session.clearCache();
}
function setProgressBarDelay(delay) {
  console.warn(
    "Please replace `Turbo.setProgressBarDelay(delay)` with `Turbo.config.drive.progressBarDelay = delay`. The top-level function is deprecated and will be removed in a future version of Turbo.`"
  );
  config.drive.progressBarDelay = delay;
}
function setConfirmMethod(confirmMethod) {
  console.warn(
    "Please replace `Turbo.setConfirmMethod(confirmMethod)` with `Turbo.config.forms.confirm = confirmMethod`. The top-level function is deprecated and will be removed in a future version of Turbo.`"
  );
  config.forms.confirm = confirmMethod;
}
function setFormMode(mode) {
  console.warn(
    "Please replace `Turbo.setFormMode(mode)` with `Turbo.config.forms.mode = mode`. The top-level function is deprecated and will be removed in a future version of Turbo.`"
  );
  config.forms.mode = mode;
}
var Turbo = /* @__PURE__ */ Object.freeze({
  __proto__: null,
  navigator: navigator$1,
  session,
  cache,
  PageRenderer,
  PageSnapshot,
  FrameRenderer,
  fetch: fetchWithTurboHeaders,
  config,
  start,
  registerAdapter,
  visit,
  connectStreamSource,
  disconnectStreamSource,
  renderStreamMessage,
  clearCache,
  setProgressBarDelay,
  setConfirmMethod,
  setFormMode
});
var TurboFrameMissingError = class extends Error {
};
var FrameController = class {
  fetchResponseLoaded = (_fetchResponse) => Promise.resolve();
  #currentFetchRequest = null;
  #resolveVisitPromise = () => {
  };
  #connected = false;
  #hasBeenLoaded = false;
  #ignoredAttributes = /* @__PURE__ */ new Set();
  #shouldMorphFrame = false;
  action = null;
  constructor(element) {
    this.element = element;
    this.view = new FrameView(this, this.element);
    this.appearanceObserver = new AppearanceObserver(this, this.element);
    this.formLinkClickObserver = new FormLinkClickObserver(this, this.element);
    this.linkInterceptor = new LinkInterceptor(this, this.element);
    this.restorationIdentifier = uuid();
    this.formSubmitObserver = new FormSubmitObserver(this, this.element);
  }
  // Frame delegate
  connect() {
    if (!this.#connected) {
      this.#connected = true;
      if (this.loadingStyle == FrameLoadingStyle.lazy) {
        this.appearanceObserver.start();
      } else {
        this.#loadSourceURL();
      }
      this.formLinkClickObserver.start();
      this.linkInterceptor.start();
      this.formSubmitObserver.start();
    }
  }
  disconnect() {
    if (this.#connected) {
      this.#connected = false;
      this.appearanceObserver.stop();
      this.formLinkClickObserver.stop();
      this.linkInterceptor.stop();
      this.formSubmitObserver.stop();
    }
  }
  disabledChanged() {
    if (this.loadingStyle == FrameLoadingStyle.eager) {
      this.#loadSourceURL();
    }
  }
  sourceURLChanged() {
    if (this.#isIgnoringChangesTo("src")) return;
    if (this.element.isConnected) {
      this.complete = false;
    }
    if (this.loadingStyle == FrameLoadingStyle.eager || this.#hasBeenLoaded) {
      this.#loadSourceURL();
    }
  }
  sourceURLReloaded() {
    const { refresh, src } = this.element;
    this.#shouldMorphFrame = src && refresh === "morph";
    this.element.removeAttribute("complete");
    this.element.src = null;
    this.element.src = src;
    return this.element.loaded;
  }
  loadingStyleChanged() {
    if (this.loadingStyle == FrameLoadingStyle.lazy) {
      this.appearanceObserver.start();
    } else {
      this.appearanceObserver.stop();
      this.#loadSourceURL();
    }
  }
  async #loadSourceURL() {
    if (this.enabled && this.isActive && !this.complete && this.sourceURL) {
      this.element.loaded = this.#visit(expandURL(this.sourceURL));
      this.appearanceObserver.stop();
      await this.element.loaded;
      this.#hasBeenLoaded = true;
    }
  }
  async loadResponse(fetchResponse) {
    if (fetchResponse.redirected || fetchResponse.succeeded && fetchResponse.isHTML) {
      this.sourceURL = fetchResponse.response.url;
    }
    try {
      const html = await fetchResponse.responseHTML;
      if (html) {
        const document2 = parseHTMLDocument(html);
        const pageSnapshot = PageSnapshot.fromDocument(document2);
        if (pageSnapshot.isVisitable) {
          await this.#loadFrameResponse(fetchResponse, document2);
        } else {
          await this.#handleUnvisitableFrameResponse(fetchResponse);
        }
      }
    } finally {
      this.#shouldMorphFrame = false;
      this.fetchResponseLoaded = () => Promise.resolve();
    }
  }
  // Appearance observer delegate
  elementAppearedInViewport(element) {
    this.proposeVisitIfNavigatedWithAction(element, getVisitAction(element));
    this.#loadSourceURL();
  }
  // Form link click observer delegate
  willSubmitFormLinkToLocation(link) {
    return this.#shouldInterceptNavigation(link);
  }
  submittedFormLinkToLocation(link, _location, form) {
    const frame = this.#findFrameElement(link);
    if (frame) form.setAttribute("data-turbo-frame", frame.id);
  }
  // Link interceptor delegate
  shouldInterceptLinkClick(element, _location, _event) {
    return this.#shouldInterceptNavigation(element);
  }
  linkClickIntercepted(element, location2) {
    this.#navigateFrame(element, location2);
  }
  // Form submit observer delegate
  willSubmitForm(element, submitter2) {
    return element.closest("turbo-frame") == this.element && this.#shouldInterceptNavigation(element, submitter2);
  }
  formSubmitted(element, submitter2) {
    if (this.formSubmission) {
      this.formSubmission.stop();
    }
    this.formSubmission = new FormSubmission(this, element, submitter2);
    const { fetchRequest } = this.formSubmission;
    this.prepareRequest(fetchRequest);
    this.formSubmission.start();
  }
  // Fetch request delegate
  prepareRequest(request) {
    request.headers["Turbo-Frame"] = this.id;
    if (this.currentNavigationElement?.hasAttribute("data-turbo-stream")) {
      request.acceptResponseType(StreamMessage.contentType);
    }
  }
  requestStarted(_request) {
    markAsBusy(this.element);
  }
  requestPreventedHandlingResponse(_request, _response) {
    this.#resolveVisitPromise();
  }
  async requestSucceededWithResponse(request, response) {
    await this.loadResponse(response);
    this.#resolveVisitPromise();
  }
  async requestFailedWithResponse(request, response) {
    await this.loadResponse(response);
    this.#resolveVisitPromise();
  }
  requestErrored(request, error2) {
    console.error(error2);
    this.#resolveVisitPromise();
  }
  requestFinished(_request) {
    clearBusyState(this.element);
  }
  // Form submission delegate
  formSubmissionStarted({ formElement }) {
    markAsBusy(formElement, this.#findFrameElement(formElement));
  }
  formSubmissionSucceededWithResponse(formSubmission, response) {
    const frame = this.#findFrameElement(formSubmission.formElement, formSubmission.submitter);
    frame.delegate.proposeVisitIfNavigatedWithAction(frame, getVisitAction(formSubmission.submitter, formSubmission.formElement, frame));
    frame.delegate.loadResponse(response);
    if (!formSubmission.isSafe) {
      session.clearCache();
    }
  }
  formSubmissionFailedWithResponse(formSubmission, fetchResponse) {
    this.element.delegate.loadResponse(fetchResponse);
    session.clearCache();
  }
  formSubmissionErrored(formSubmission, error2) {
    console.error(error2);
  }
  formSubmissionFinished({ formElement }) {
    clearBusyState(formElement, this.#findFrameElement(formElement));
  }
  // View delegate
  allowsImmediateRender({ element: newFrame }, options) {
    const event = dispatch("turbo:before-frame-render", {
      target: this.element,
      detail: { newFrame, ...options },
      cancelable: true
    });
    const {
      defaultPrevented,
      detail: { render }
    } = event;
    if (this.view.renderer && render) {
      this.view.renderer.renderElement = render;
    }
    return !defaultPrevented;
  }
  viewRenderedSnapshot(_snapshot, _isPreview, _renderMethod) {
  }
  preloadOnLoadLinksForView(element) {
    session.preloadOnLoadLinksForView(element);
  }
  viewInvalidated() {
  }
  // Frame renderer delegate
  willRenderFrame(currentElement, _newElement) {
    this.previousFrameElement = currentElement.cloneNode(true);
  }
  visitCachedSnapshot = ({ element }) => {
    const frame = element.querySelector("#" + this.element.id);
    if (frame && this.previousFrameElement) {
      frame.replaceChildren(...this.previousFrameElement.children);
    }
    delete this.previousFrameElement;
  };
  // Private
  async #loadFrameResponse(fetchResponse, document2) {
    const newFrameElement = await this.extractForeignFrameElement(document2.body);
    const rendererClass = this.#shouldMorphFrame ? MorphingFrameRenderer : FrameRenderer;
    if (newFrameElement) {
      const snapshot = new Snapshot(newFrameElement);
      const renderer = new rendererClass(this, this.view.snapshot, snapshot, false, false);
      if (this.view.renderPromise) await this.view.renderPromise;
      this.changeHistory();
      await this.view.render(renderer);
      this.complete = true;
      session.frameRendered(fetchResponse, this.element);
      session.frameLoaded(this.element);
      await this.fetchResponseLoaded(fetchResponse);
    } else if (this.#willHandleFrameMissingFromResponse(fetchResponse)) {
      this.#handleFrameMissingFromResponse(fetchResponse);
    }
  }
  async #visit(url) {
    const request = new FetchRequest(this, FetchMethod.get, url, new URLSearchParams(), this.element);
    this.#currentFetchRequest?.cancel();
    this.#currentFetchRequest = request;
    return new Promise((resolve) => {
      this.#resolveVisitPromise = () => {
        this.#resolveVisitPromise = () => {
        };
        this.#currentFetchRequest = null;
        resolve();
      };
      request.perform();
    });
  }
  #navigateFrame(element, url, submitter2) {
    const frame = this.#findFrameElement(element, submitter2);
    frame.delegate.proposeVisitIfNavigatedWithAction(frame, getVisitAction(submitter2, element, frame));
    this.#withCurrentNavigationElement(element, () => {
      frame.src = url;
    });
  }
  proposeVisitIfNavigatedWithAction(frame, action = null) {
    this.action = action;
    if (this.action) {
      const pageSnapshot = PageSnapshot.fromElement(frame).clone();
      const { visitCachedSnapshot } = frame.delegate;
      frame.delegate.fetchResponseLoaded = async (fetchResponse) => {
        if (frame.src) {
          const { statusCode, redirected } = fetchResponse;
          const responseHTML = await fetchResponse.responseHTML;
          const response = { statusCode, redirected, responseHTML };
          const options = {
            response,
            visitCachedSnapshot,
            willRender: false,
            updateHistory: false,
            restorationIdentifier: this.restorationIdentifier,
            snapshot: pageSnapshot
          };
          if (this.action) options.action = this.action;
          session.visit(frame.src, options);
        }
      };
    }
  }
  changeHistory() {
    if (this.action) {
      const method = getHistoryMethodForAction(this.action);
      session.history.update(method, expandURL(this.element.src || ""), this.restorationIdentifier);
    }
  }
  async #handleUnvisitableFrameResponse(fetchResponse) {
    console.warn(
      `The response (${fetchResponse.statusCode}) from <turbo-frame id="${this.element.id}"> is performing a full page visit due to turbo-visit-control.`
    );
    await this.#visitResponse(fetchResponse.response);
  }
  #willHandleFrameMissingFromResponse(fetchResponse) {
    this.element.setAttribute("complete", "");
    const response = fetchResponse.response;
    const visit2 = async (url, options) => {
      if (url instanceof Response) {
        this.#visitResponse(url);
      } else {
        session.visit(url, options);
      }
    };
    const event = dispatch("turbo:frame-missing", {
      target: this.element,
      detail: { response, visit: visit2 },
      cancelable: true
    });
    return !event.defaultPrevented;
  }
  #handleFrameMissingFromResponse(fetchResponse) {
    this.view.missing();
    this.#throwFrameMissingError(fetchResponse);
  }
  #throwFrameMissingError(fetchResponse) {
    const message = `The response (${fetchResponse.statusCode}) did not contain the expected <turbo-frame id="${this.element.id}"> and will be ignored. To perform a full page visit instead, set turbo-visit-control to reload.`;
    throw new TurboFrameMissingError(message);
  }
  async #visitResponse(response) {
    const wrapped = new FetchResponse(response);
    const responseHTML = await wrapped.responseHTML;
    const { location: location2, redirected, statusCode } = wrapped;
    return session.visit(location2, { response: { redirected, statusCode, responseHTML } });
  }
  #findFrameElement(element, submitter2) {
    const id = getAttribute("data-turbo-frame", submitter2, element) || this.element.getAttribute("target");
    return getFrameElementById(id) ?? this.element;
  }
  async extractForeignFrameElement(container) {
    let element;
    const id = CSS.escape(this.id);
    try {
      element = activateElement(container.querySelector(`turbo-frame#${id}`), this.sourceURL);
      if (element) {
        return element;
      }
      element = activateElement(container.querySelector(`turbo-frame[src][recurse~=${id}]`), this.sourceURL);
      if (element) {
        await element.loaded;
        return await this.extractForeignFrameElement(element);
      }
    } catch (error2) {
      console.error(error2);
      return new FrameElement();
    }
    return null;
  }
  #formActionIsVisitable(form, submitter2) {
    const action = getAction$1(form, submitter2);
    return locationIsVisitable(expandURL(action), this.rootLocation);
  }
  #shouldInterceptNavigation(element, submitter2) {
    const id = getAttribute("data-turbo-frame", submitter2, element) || this.element.getAttribute("target");
    if (element instanceof HTMLFormElement && !this.#formActionIsVisitable(element, submitter2)) {
      return false;
    }
    if (!this.enabled || id == "_top") {
      return false;
    }
    if (id) {
      const frameElement = getFrameElementById(id);
      if (frameElement) {
        return !frameElement.disabled;
      }
    }
    if (!session.elementIsNavigatable(element)) {
      return false;
    }
    if (submitter2 && !session.elementIsNavigatable(submitter2)) {
      return false;
    }
    return true;
  }
  // Computed properties
  get id() {
    return this.element.id;
  }
  get enabled() {
    return !this.element.disabled;
  }
  get sourceURL() {
    if (this.element.src) {
      return this.element.src;
    }
  }
  set sourceURL(sourceURL) {
    this.#ignoringChangesToAttribute("src", () => {
      this.element.src = sourceURL ?? null;
    });
  }
  get loadingStyle() {
    return this.element.loading;
  }
  get isLoading() {
    return this.formSubmission !== void 0 || this.#resolveVisitPromise() !== void 0;
  }
  get complete() {
    return this.element.hasAttribute("complete");
  }
  set complete(value) {
    if (value) {
      this.element.setAttribute("complete", "");
    } else {
      this.element.removeAttribute("complete");
    }
  }
  get isActive() {
    return this.element.isActive && this.#connected;
  }
  get rootLocation() {
    const meta = this.element.ownerDocument.querySelector(`meta[name="turbo-root"]`);
    const root = meta?.content ?? "/";
    return expandURL(root);
  }
  #isIgnoringChangesTo(attributeName) {
    return this.#ignoredAttributes.has(attributeName);
  }
  #ignoringChangesToAttribute(attributeName, callback) {
    this.#ignoredAttributes.add(attributeName);
    callback();
    this.#ignoredAttributes.delete(attributeName);
  }
  #withCurrentNavigationElement(element, callback) {
    this.currentNavigationElement = element;
    callback();
    delete this.currentNavigationElement;
  }
};
function getFrameElementById(id) {
  if (id != null) {
    const element = document.getElementById(id);
    if (element instanceof FrameElement) {
      return element;
    }
  }
}
function activateElement(element, currentURL) {
  if (element) {
    const src = element.getAttribute("src");
    if (src != null && currentURL != null && urlsAreEqual(src, currentURL)) {
      throw new Error(`Matching <turbo-frame id="${element.id}"> element has a source URL which references itself`);
    }
    if (element.ownerDocument !== document) {
      element = document.importNode(element, true);
    }
    if (element instanceof FrameElement) {
      element.connectedCallback();
      element.disconnectedCallback();
      return element;
    }
  }
}
var StreamActions = {
  after() {
    this.targetElements.forEach((e) => e.parentElement?.insertBefore(this.templateContent, e.nextSibling));
  },
  append() {
    this.removeDuplicateTargetChildren();
    this.targetElements.forEach((e) => e.append(this.templateContent));
  },
  before() {
    this.targetElements.forEach((e) => e.parentElement?.insertBefore(this.templateContent, e));
  },
  prepend() {
    this.removeDuplicateTargetChildren();
    this.targetElements.forEach((e) => e.prepend(this.templateContent));
  },
  remove() {
    this.targetElements.forEach((e) => e.remove());
  },
  replace() {
    const method = this.getAttribute("method");
    this.targetElements.forEach((targetElement) => {
      if (method === "morph") {
        morphElements(targetElement, this.templateContent);
      } else {
        targetElement.replaceWith(this.templateContent);
      }
    });
  },
  update() {
    const method = this.getAttribute("method");
    this.targetElements.forEach((targetElement) => {
      if (method === "morph") {
        morphChildren(targetElement, this.templateContent);
      } else {
        targetElement.innerHTML = "";
        targetElement.append(this.templateContent);
      }
    });
  },
  refresh() {
    session.refresh(this.baseURI, this.requestId);
  }
};
var StreamElement = class _StreamElement extends HTMLElement {
  static async renderElement(newElement) {
    await newElement.performAction();
  }
  async connectedCallback() {
    try {
      await this.render();
    } catch (error2) {
      console.error(error2);
    } finally {
      this.disconnect();
    }
  }
  async render() {
    return this.renderPromise ??= (async () => {
      const event = this.beforeRenderEvent;
      if (this.dispatchEvent(event)) {
        await nextRepaint();
        await event.detail.render(this);
      }
    })();
  }
  disconnect() {
    try {
      this.remove();
    } catch {
    }
  }
  /**
   * Removes duplicate children (by ID)
   */
  removeDuplicateTargetChildren() {
    this.duplicateChildren.forEach((c) => c.remove());
  }
  /**
   * Gets the list of duplicate children (i.e. those with the same ID)
   */
  get duplicateChildren() {
    const existingChildren = this.targetElements.flatMap((e) => [...e.children]).filter((c) => !!c.id);
    const newChildrenIds = [...this.templateContent?.children || []].filter((c) => !!c.id).map((c) => c.id);
    return existingChildren.filter((c) => newChildrenIds.includes(c.id));
  }
  /**
   * Gets the action function to be performed.
   */
  get performAction() {
    if (this.action) {
      const actionFunction = StreamActions[this.action];
      if (actionFunction) {
        return actionFunction;
      }
      this.#raise("unknown action");
    }
    this.#raise("action attribute is missing");
  }
  /**
   * Gets the target elements which the template will be rendered to.
   */
  get targetElements() {
    if (this.target) {
      return this.targetElementsById;
    } else if (this.targets) {
      return this.targetElementsByQuery;
    } else {
      this.#raise("target or targets attribute is missing");
    }
  }
  /**
   * Gets the contents of the main `<template>`.
   */
  get templateContent() {
    return this.templateElement.content.cloneNode(true);
  }
  /**
   * Gets the main `<template>` used for rendering
   */
  get templateElement() {
    if (this.firstElementChild === null) {
      const template = this.ownerDocument.createElement("template");
      this.appendChild(template);
      return template;
    } else if (this.firstElementChild instanceof HTMLTemplateElement) {
      return this.firstElementChild;
    }
    this.#raise("first child element must be a <template> element");
  }
  /**
   * Gets the current action.
   */
  get action() {
    return this.getAttribute("action");
  }
  /**
   * Gets the current target (an element ID) to which the result will
   * be rendered.
   */
  get target() {
    return this.getAttribute("target");
  }
  /**
   * Gets the current "targets" selector (a CSS selector)
   */
  get targets() {
    return this.getAttribute("targets");
  }
  /**
   * Reads the request-id attribute
   */
  get requestId() {
    return this.getAttribute("request-id");
  }
  #raise(message) {
    throw new Error(`${this.description}: ${message}`);
  }
  get description() {
    return (this.outerHTML.match(/<[^>]+>/) ?? [])[0] ?? "<turbo-stream>";
  }
  get beforeRenderEvent() {
    return new CustomEvent("turbo:before-stream-render", {
      bubbles: true,
      cancelable: true,
      detail: { newStream: this, render: _StreamElement.renderElement }
    });
  }
  get targetElementsById() {
    const element = this.ownerDocument?.getElementById(this.target);
    if (element !== null) {
      return [element];
    } else {
      return [];
    }
  }
  get targetElementsByQuery() {
    const elements = this.ownerDocument?.querySelectorAll(this.targets);
    if (elements.length !== 0) {
      return Array.prototype.slice.call(elements);
    } else {
      return [];
    }
  }
};
var StreamSourceElement = class extends HTMLElement {
  streamSource = null;
  connectedCallback() {
    this.streamSource = this.src.match(/^ws{1,2}:/) ? new WebSocket(this.src) : new EventSource(this.src);
    connectStreamSource(this.streamSource);
  }
  disconnectedCallback() {
    if (this.streamSource) {
      this.streamSource.close();
      disconnectStreamSource(this.streamSource);
    }
  }
  get src() {
    return this.getAttribute("src") || "";
  }
};
FrameElement.delegateConstructor = FrameController;
if (customElements.get("turbo-frame") === void 0) {
  customElements.define("turbo-frame", FrameElement);
}
if (customElements.get("turbo-stream") === void 0) {
  customElements.define("turbo-stream", StreamElement);
}
if (customElements.get("turbo-stream-source") === void 0) {
  customElements.define("turbo-stream-source", StreamSourceElement);
}
(() => {
  let element = document.currentScript;
  if (!element) return;
  if (element.hasAttribute("data-turbo-suppress-warning")) return;
  element = element.parentElement;
  while (element) {
    if (element == document.body) {
      return console.warn(
        unindent`
        You are loading Turbo from a <script> element inside the <body> element. This is probably not what you meant to do!

        Load your application’s JavaScript bundle inside the <head> element instead. <script> elements in <body> are evaluated with each page change.

        For more information, see: https://turbo.hotwired.dev/handbook/building#working-with-script-elements

        ——
        Suppress this warning by adding a "data-turbo-suppress-warning" attribute to: %s
      `,
        element.outerHTML
      );
    }
    element = element.parentElement;
  }
})();
window.Turbo = { ...Turbo, StreamActions };
start();

// node_modules/@hotwired/turbo-rails/app/javascript/turbo/cable.js
var consumer;
async function getConsumer() {
  return consumer || setConsumer(createConsumer2().then(setConsumer));
}
function setConsumer(newConsumer) {
  return consumer = newConsumer;
}
async function createConsumer2() {
  const { createConsumer: createConsumer3 } = await Promise.resolve().then(() => (init_src(), src_exports));
  return createConsumer3();
}
async function subscribeTo(channel, mixin) {
  const { subscriptions } = await getConsumer();
  return subscriptions.create(channel, mixin);
}

// node_modules/@hotwired/turbo-rails/app/javascript/turbo/snakeize.js
function walk(obj) {
  if (!obj || typeof obj !== "object") return obj;
  if (obj instanceof Date || obj instanceof RegExp) return obj;
  if (Array.isArray(obj)) return obj.map(walk);
  return Object.keys(obj).reduce(function(acc, key) {
    var camel = key[0].toLowerCase() + key.slice(1).replace(/([A-Z]+)/g, function(m, x) {
      return "_" + x.toLowerCase();
    });
    acc[camel] = walk(obj[key]);
    return acc;
  }, {});
}

// node_modules/@hotwired/turbo-rails/app/javascript/turbo/cable_stream_source_element.js
var TurboCableStreamSourceElement = class extends HTMLElement {
  static observedAttributes = ["channel", "signed-stream-name"];
  async connectedCallback() {
    connectStreamSource(this);
    this.subscription = await subscribeTo(this.channel, {
      received: this.dispatchMessageEvent.bind(this),
      connected: this.subscriptionConnected.bind(this),
      disconnected: this.subscriptionDisconnected.bind(this)
    });
  }
  disconnectedCallback() {
    disconnectStreamSource(this);
    if (this.subscription) this.subscription.unsubscribe();
    this.subscriptionDisconnected();
  }
  attributeChangedCallback() {
    if (this.subscription) {
      this.disconnectedCallback();
      this.connectedCallback();
    }
  }
  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data });
    return this.dispatchEvent(event);
  }
  subscriptionConnected() {
    this.setAttribute("connected", "");
  }
  subscriptionDisconnected() {
    this.removeAttribute("connected");
  }
  get channel() {
    const channel = this.getAttribute("channel");
    const signed_stream_name = this.getAttribute("signed-stream-name");
    return { channel, signed_stream_name, ...walk({ ...this.dataset }) };
  }
};
if (customElements.get("turbo-cable-stream-source") === void 0) {
  customElements.define("turbo-cable-stream-source", TurboCableStreamSourceElement);
}

// node_modules/@hotwired/turbo-rails/app/javascript/turbo/fetch_requests.js
function encodeMethodIntoRequestBody(event) {
  if (event.target instanceof HTMLFormElement) {
    const { target: form, detail: { fetchOptions } } = event;
    form.addEventListener("turbo:submit-start", ({ detail: { formSubmission: { submitter: submitter2 } } }) => {
      const body = isBodyInit(fetchOptions.body) ? fetchOptions.body : new URLSearchParams();
      const method = determineFetchMethod(submitter2, body, form);
      if (!/get/i.test(method)) {
        if (/post/i.test(method)) {
          body.delete("_method");
        } else {
          body.set("_method", method);
        }
        fetchOptions.method = "post";
      }
    }, { once: true });
  }
}
function determineFetchMethod(submitter2, body, form) {
  const formMethod = determineFormMethod(submitter2);
  const overrideMethod = body.get("_method");
  const method = form.getAttribute("method") || "get";
  if (typeof formMethod == "string") {
    return formMethod;
  } else if (typeof overrideMethod == "string") {
    return overrideMethod;
  } else {
    return method;
  }
}
function determineFormMethod(submitter2) {
  if (submitter2 instanceof HTMLButtonElement || submitter2 instanceof HTMLInputElement) {
    if (submitter2.name === "_method") {
      return submitter2.value;
    } else if (submitter2.hasAttribute("formmethod")) {
      return submitter2.formMethod;
    } else {
      return null;
    }
  } else {
    return null;
  }
}
function isBodyInit(body) {
  return body instanceof FormData || body instanceof URLSearchParams;
}

// node_modules/@hotwired/turbo-rails/app/javascript/turbo/index.js
window.Turbo = turbo_es2017_esm_exports;
addEventListener("turbo:before-fetch-request", encodeMethodIntoRequestBody);

// node_modules/@hotwired/stimulus/dist/stimulus.js
var EventListener = class {
  constructor(eventTarget, eventName, eventOptions) {
    this.eventTarget = eventTarget;
    this.eventName = eventName;
    this.eventOptions = eventOptions;
    this.unorderedBindings = /* @__PURE__ */ new Set();
  }
  connect() {
    this.eventTarget.addEventListener(this.eventName, this, this.eventOptions);
  }
  disconnect() {
    this.eventTarget.removeEventListener(this.eventName, this, this.eventOptions);
  }
  bindingConnected(binding) {
    this.unorderedBindings.add(binding);
  }
  bindingDisconnected(binding) {
    this.unorderedBindings.delete(binding);
  }
  handleEvent(event) {
    const extendedEvent2 = extendEvent(event);
    for (const binding of this.bindings) {
      if (extendedEvent2.immediatePropagationStopped) {
        break;
      } else {
        binding.handleEvent(extendedEvent2);
      }
    }
  }
  hasBindings() {
    return this.unorderedBindings.size > 0;
  }
  get bindings() {
    return Array.from(this.unorderedBindings).sort((left, right) => {
      const leftIndex = left.index, rightIndex = right.index;
      return leftIndex < rightIndex ? -1 : leftIndex > rightIndex ? 1 : 0;
    });
  }
};
function extendEvent(event) {
  if ("immediatePropagationStopped" in event) {
    return event;
  } else {
    const { stopImmediatePropagation } = event;
    return Object.assign(event, {
      immediatePropagationStopped: false,
      stopImmediatePropagation() {
        this.immediatePropagationStopped = true;
        stopImmediatePropagation.call(this);
      }
    });
  }
}
var Dispatcher = class {
  constructor(application2) {
    this.application = application2;
    this.eventListenerMaps = /* @__PURE__ */ new Map();
    this.started = false;
  }
  start() {
    if (!this.started) {
      this.started = true;
      this.eventListeners.forEach((eventListener) => eventListener.connect());
    }
  }
  stop() {
    if (this.started) {
      this.started = false;
      this.eventListeners.forEach((eventListener) => eventListener.disconnect());
    }
  }
  get eventListeners() {
    return Array.from(this.eventListenerMaps.values()).reduce((listeners, map) => listeners.concat(Array.from(map.values())), []);
  }
  bindingConnected(binding) {
    this.fetchEventListenerForBinding(binding).bindingConnected(binding);
  }
  bindingDisconnected(binding, clearEventListeners = false) {
    this.fetchEventListenerForBinding(binding).bindingDisconnected(binding);
    if (clearEventListeners)
      this.clearEventListenersForBinding(binding);
  }
  handleError(error2, message, detail = {}) {
    this.application.handleError(error2, `Error ${message}`, detail);
  }
  clearEventListenersForBinding(binding) {
    const eventListener = this.fetchEventListenerForBinding(binding);
    if (!eventListener.hasBindings()) {
      eventListener.disconnect();
      this.removeMappedEventListenerFor(binding);
    }
  }
  removeMappedEventListenerFor(binding) {
    const { eventTarget, eventName, eventOptions } = binding;
    const eventListenerMap = this.fetchEventListenerMapForEventTarget(eventTarget);
    const cacheKey = this.cacheKey(eventName, eventOptions);
    eventListenerMap.delete(cacheKey);
    if (eventListenerMap.size == 0)
      this.eventListenerMaps.delete(eventTarget);
  }
  fetchEventListenerForBinding(binding) {
    const { eventTarget, eventName, eventOptions } = binding;
    return this.fetchEventListener(eventTarget, eventName, eventOptions);
  }
  fetchEventListener(eventTarget, eventName, eventOptions) {
    const eventListenerMap = this.fetchEventListenerMapForEventTarget(eventTarget);
    const cacheKey = this.cacheKey(eventName, eventOptions);
    let eventListener = eventListenerMap.get(cacheKey);
    if (!eventListener) {
      eventListener = this.createEventListener(eventTarget, eventName, eventOptions);
      eventListenerMap.set(cacheKey, eventListener);
    }
    return eventListener;
  }
  createEventListener(eventTarget, eventName, eventOptions) {
    const eventListener = new EventListener(eventTarget, eventName, eventOptions);
    if (this.started) {
      eventListener.connect();
    }
    return eventListener;
  }
  fetchEventListenerMapForEventTarget(eventTarget) {
    let eventListenerMap = this.eventListenerMaps.get(eventTarget);
    if (!eventListenerMap) {
      eventListenerMap = /* @__PURE__ */ new Map();
      this.eventListenerMaps.set(eventTarget, eventListenerMap);
    }
    return eventListenerMap;
  }
  cacheKey(eventName, eventOptions) {
    const parts = [eventName];
    Object.keys(eventOptions).sort().forEach((key) => {
      parts.push(`${eventOptions[key] ? "" : "!"}${key}`);
    });
    return parts.join(":");
  }
};
var defaultActionDescriptorFilters = {
  stop({ event, value }) {
    if (value)
      event.stopPropagation();
    return true;
  },
  prevent({ event, value }) {
    if (value)
      event.preventDefault();
    return true;
  },
  self({ event, value, element }) {
    if (value) {
      return element === event.target;
    } else {
      return true;
    }
  }
};
var descriptorPattern = /^(?:(?:([^.]+?)\+)?(.+?)(?:\.(.+?))?(?:@(window|document))?->)?(.+?)(?:#([^:]+?))(?::(.+))?$/;
function parseActionDescriptorString(descriptorString) {
  const source = descriptorString.trim();
  const matches = source.match(descriptorPattern) || [];
  let eventName = matches[2];
  let keyFilter = matches[3];
  if (keyFilter && !["keydown", "keyup", "keypress"].includes(eventName)) {
    eventName += `.${keyFilter}`;
    keyFilter = "";
  }
  return {
    eventTarget: parseEventTarget(matches[4]),
    eventName,
    eventOptions: matches[7] ? parseEventOptions(matches[7]) : {},
    identifier: matches[5],
    methodName: matches[6],
    keyFilter: matches[1] || keyFilter
  };
}
function parseEventTarget(eventTargetName) {
  if (eventTargetName == "window") {
    return window;
  } else if (eventTargetName == "document") {
    return document;
  }
}
function parseEventOptions(eventOptions) {
  return eventOptions.split(":").reduce((options, token) => Object.assign(options, { [token.replace(/^!/, "")]: !/^!/.test(token) }), {});
}
function stringifyEventTarget(eventTarget) {
  if (eventTarget == window) {
    return "window";
  } else if (eventTarget == document) {
    return "document";
  }
}
function camelize(value) {
  return value.replace(/(?:[_-])([a-z0-9])/g, (_, char) => char.toUpperCase());
}
function namespaceCamelize(value) {
  return camelize(value.replace(/--/g, "-").replace(/__/g, "_"));
}
function capitalize(value) {
  return value.charAt(0).toUpperCase() + value.slice(1);
}
function dasherize(value) {
  return value.replace(/([A-Z])/g, (_, char) => `-${char.toLowerCase()}`);
}
function tokenize(value) {
  return value.match(/[^\s]+/g) || [];
}
function isSomething(object) {
  return object !== null && object !== void 0;
}
function hasProperty(object, property) {
  return Object.prototype.hasOwnProperty.call(object, property);
}
var allModifiers = ["meta", "ctrl", "alt", "shift"];
var Action = class {
  constructor(element, index, descriptor, schema) {
    this.element = element;
    this.index = index;
    this.eventTarget = descriptor.eventTarget || element;
    this.eventName = descriptor.eventName || getDefaultEventNameForElement(element) || error("missing event name");
    this.eventOptions = descriptor.eventOptions || {};
    this.identifier = descriptor.identifier || error("missing identifier");
    this.methodName = descriptor.methodName || error("missing method name");
    this.keyFilter = descriptor.keyFilter || "";
    this.schema = schema;
  }
  static forToken(token, schema) {
    return new this(token.element, token.index, parseActionDescriptorString(token.content), schema);
  }
  toString() {
    const eventFilter = this.keyFilter ? `.${this.keyFilter}` : "";
    const eventTarget = this.eventTargetName ? `@${this.eventTargetName}` : "";
    return `${this.eventName}${eventFilter}${eventTarget}->${this.identifier}#${this.methodName}`;
  }
  shouldIgnoreKeyboardEvent(event) {
    if (!this.keyFilter) {
      return false;
    }
    const filters = this.keyFilter.split("+");
    if (this.keyFilterDissatisfied(event, filters)) {
      return true;
    }
    const standardFilter = filters.filter((key) => !allModifiers.includes(key))[0];
    if (!standardFilter) {
      return false;
    }
    if (!hasProperty(this.keyMappings, standardFilter)) {
      error(`contains unknown key filter: ${this.keyFilter}`);
    }
    return this.keyMappings[standardFilter].toLowerCase() !== event.key.toLowerCase();
  }
  shouldIgnoreMouseEvent(event) {
    if (!this.keyFilter) {
      return false;
    }
    const filters = [this.keyFilter];
    if (this.keyFilterDissatisfied(event, filters)) {
      return true;
    }
    return false;
  }
  get params() {
    const params = {};
    const pattern = new RegExp(`^data-${this.identifier}-(.+)-param$`, "i");
    for (const { name, value } of Array.from(this.element.attributes)) {
      const match = name.match(pattern);
      const key = match && match[1];
      if (key) {
        params[camelize(key)] = typecast(value);
      }
    }
    return params;
  }
  get eventTargetName() {
    return stringifyEventTarget(this.eventTarget);
  }
  get keyMappings() {
    return this.schema.keyMappings;
  }
  keyFilterDissatisfied(event, filters) {
    const [meta, ctrl, alt, shift] = allModifiers.map((modifier) => filters.includes(modifier));
    return event.metaKey !== meta || event.ctrlKey !== ctrl || event.altKey !== alt || event.shiftKey !== shift;
  }
};
var defaultEventNames = {
  a: () => "click",
  button: () => "click",
  form: () => "submit",
  details: () => "toggle",
  input: (e) => e.getAttribute("type") == "submit" ? "click" : "input",
  select: () => "change",
  textarea: () => "input"
};
function getDefaultEventNameForElement(element) {
  const tagName = element.tagName.toLowerCase();
  if (tagName in defaultEventNames) {
    return defaultEventNames[tagName](element);
  }
}
function error(message) {
  throw new Error(message);
}
function typecast(value) {
  try {
    return JSON.parse(value);
  } catch (o_O) {
    return value;
  }
}
var Binding = class {
  constructor(context, action) {
    this.context = context;
    this.action = action;
  }
  get index() {
    return this.action.index;
  }
  get eventTarget() {
    return this.action.eventTarget;
  }
  get eventOptions() {
    return this.action.eventOptions;
  }
  get identifier() {
    return this.context.identifier;
  }
  handleEvent(event) {
    const actionEvent = this.prepareActionEvent(event);
    if (this.willBeInvokedByEvent(event) && this.applyEventModifiers(actionEvent)) {
      this.invokeWithEvent(actionEvent);
    }
  }
  get eventName() {
    return this.action.eventName;
  }
  get method() {
    const method = this.controller[this.methodName];
    if (typeof method == "function") {
      return method;
    }
    throw new Error(`Action "${this.action}" references undefined method "${this.methodName}"`);
  }
  applyEventModifiers(event) {
    const { element } = this.action;
    const { actionDescriptorFilters } = this.context.application;
    const { controller } = this.context;
    let passes = true;
    for (const [name, value] of Object.entries(this.eventOptions)) {
      if (name in actionDescriptorFilters) {
        const filter = actionDescriptorFilters[name];
        passes = passes && filter({ name, value, event, element, controller });
      } else {
        continue;
      }
    }
    return passes;
  }
  prepareActionEvent(event) {
    return Object.assign(event, { params: this.action.params });
  }
  invokeWithEvent(event) {
    const { target, currentTarget } = event;
    try {
      this.method.call(this.controller, event);
      this.context.logDebugActivity(this.methodName, { event, target, currentTarget, action: this.methodName });
    } catch (error2) {
      const { identifier, controller, element, index } = this;
      const detail = { identifier, controller, element, index, event };
      this.context.handleError(error2, `invoking action "${this.action}"`, detail);
    }
  }
  willBeInvokedByEvent(event) {
    const eventTarget = event.target;
    if (event instanceof KeyboardEvent && this.action.shouldIgnoreKeyboardEvent(event)) {
      return false;
    }
    if (event instanceof MouseEvent && this.action.shouldIgnoreMouseEvent(event)) {
      return false;
    }
    if (this.element === eventTarget) {
      return true;
    } else if (eventTarget instanceof Element && this.element.contains(eventTarget)) {
      return this.scope.containsElement(eventTarget);
    } else {
      return this.scope.containsElement(this.action.element);
    }
  }
  get controller() {
    return this.context.controller;
  }
  get methodName() {
    return this.action.methodName;
  }
  get element() {
    return this.scope.element;
  }
  get scope() {
    return this.context.scope;
  }
};
var ElementObserver = class {
  constructor(element, delegate) {
    this.mutationObserverInit = { attributes: true, childList: true, subtree: true };
    this.element = element;
    this.started = false;
    this.delegate = delegate;
    this.elements = /* @__PURE__ */ new Set();
    this.mutationObserver = new MutationObserver((mutations) => this.processMutations(mutations));
  }
  start() {
    if (!this.started) {
      this.started = true;
      this.mutationObserver.observe(this.element, this.mutationObserverInit);
      this.refresh();
    }
  }
  pause(callback) {
    if (this.started) {
      this.mutationObserver.disconnect();
      this.started = false;
    }
    callback();
    if (!this.started) {
      this.mutationObserver.observe(this.element, this.mutationObserverInit);
      this.started = true;
    }
  }
  stop() {
    if (this.started) {
      this.mutationObserver.takeRecords();
      this.mutationObserver.disconnect();
      this.started = false;
    }
  }
  refresh() {
    if (this.started) {
      const matches = new Set(this.matchElementsInTree());
      for (const element of Array.from(this.elements)) {
        if (!matches.has(element)) {
          this.removeElement(element);
        }
      }
      for (const element of Array.from(matches)) {
        this.addElement(element);
      }
    }
  }
  processMutations(mutations) {
    if (this.started) {
      for (const mutation of mutations) {
        this.processMutation(mutation);
      }
    }
  }
  processMutation(mutation) {
    if (mutation.type == "attributes") {
      this.processAttributeChange(mutation.target, mutation.attributeName);
    } else if (mutation.type == "childList") {
      this.processRemovedNodes(mutation.removedNodes);
      this.processAddedNodes(mutation.addedNodes);
    }
  }
  processAttributeChange(element, attributeName) {
    if (this.elements.has(element)) {
      if (this.delegate.elementAttributeChanged && this.matchElement(element)) {
        this.delegate.elementAttributeChanged(element, attributeName);
      } else {
        this.removeElement(element);
      }
    } else if (this.matchElement(element)) {
      this.addElement(element);
    }
  }
  processRemovedNodes(nodes) {
    for (const node of Array.from(nodes)) {
      const element = this.elementFromNode(node);
      if (element) {
        this.processTree(element, this.removeElement);
      }
    }
  }
  processAddedNodes(nodes) {
    for (const node of Array.from(nodes)) {
      const element = this.elementFromNode(node);
      if (element && this.elementIsActive(element)) {
        this.processTree(element, this.addElement);
      }
    }
  }
  matchElement(element) {
    return this.delegate.matchElement(element);
  }
  matchElementsInTree(tree = this.element) {
    return this.delegate.matchElementsInTree(tree);
  }
  processTree(tree, processor) {
    for (const element of this.matchElementsInTree(tree)) {
      processor.call(this, element);
    }
  }
  elementFromNode(node) {
    if (node.nodeType == Node.ELEMENT_NODE) {
      return node;
    }
  }
  elementIsActive(element) {
    if (element.isConnected != this.element.isConnected) {
      return false;
    } else {
      return this.element.contains(element);
    }
  }
  addElement(element) {
    if (!this.elements.has(element)) {
      if (this.elementIsActive(element)) {
        this.elements.add(element);
        if (this.delegate.elementMatched) {
          this.delegate.elementMatched(element);
        }
      }
    }
  }
  removeElement(element) {
    if (this.elements.has(element)) {
      this.elements.delete(element);
      if (this.delegate.elementUnmatched) {
        this.delegate.elementUnmatched(element);
      }
    }
  }
};
var AttributeObserver = class {
  constructor(element, attributeName, delegate) {
    this.attributeName = attributeName;
    this.delegate = delegate;
    this.elementObserver = new ElementObserver(element, this);
  }
  get element() {
    return this.elementObserver.element;
  }
  get selector() {
    return `[${this.attributeName}]`;
  }
  start() {
    this.elementObserver.start();
  }
  pause(callback) {
    this.elementObserver.pause(callback);
  }
  stop() {
    this.elementObserver.stop();
  }
  refresh() {
    this.elementObserver.refresh();
  }
  get started() {
    return this.elementObserver.started;
  }
  matchElement(element) {
    return element.hasAttribute(this.attributeName);
  }
  matchElementsInTree(tree) {
    const match = this.matchElement(tree) ? [tree] : [];
    const matches = Array.from(tree.querySelectorAll(this.selector));
    return match.concat(matches);
  }
  elementMatched(element) {
    if (this.delegate.elementMatchedAttribute) {
      this.delegate.elementMatchedAttribute(element, this.attributeName);
    }
  }
  elementUnmatched(element) {
    if (this.delegate.elementUnmatchedAttribute) {
      this.delegate.elementUnmatchedAttribute(element, this.attributeName);
    }
  }
  elementAttributeChanged(element, attributeName) {
    if (this.delegate.elementAttributeValueChanged && this.attributeName == attributeName) {
      this.delegate.elementAttributeValueChanged(element, attributeName);
    }
  }
};
function add(map, key, value) {
  fetch2(map, key).add(value);
}
function del(map, key, value) {
  fetch2(map, key).delete(value);
  prune(map, key);
}
function fetch2(map, key) {
  let values = map.get(key);
  if (!values) {
    values = /* @__PURE__ */ new Set();
    map.set(key, values);
  }
  return values;
}
function prune(map, key) {
  const values = map.get(key);
  if (values != null && values.size == 0) {
    map.delete(key);
  }
}
var Multimap = class {
  constructor() {
    this.valuesByKey = /* @__PURE__ */ new Map();
  }
  get keys() {
    return Array.from(this.valuesByKey.keys());
  }
  get values() {
    const sets = Array.from(this.valuesByKey.values());
    return sets.reduce((values, set) => values.concat(Array.from(set)), []);
  }
  get size() {
    const sets = Array.from(this.valuesByKey.values());
    return sets.reduce((size, set) => size + set.size, 0);
  }
  add(key, value) {
    add(this.valuesByKey, key, value);
  }
  delete(key, value) {
    del(this.valuesByKey, key, value);
  }
  has(key, value) {
    const values = this.valuesByKey.get(key);
    return values != null && values.has(value);
  }
  hasKey(key) {
    return this.valuesByKey.has(key);
  }
  hasValue(value) {
    const sets = Array.from(this.valuesByKey.values());
    return sets.some((set) => set.has(value));
  }
  getValuesForKey(key) {
    const values = this.valuesByKey.get(key);
    return values ? Array.from(values) : [];
  }
  getKeysForValue(value) {
    return Array.from(this.valuesByKey).filter(([_key, values]) => values.has(value)).map(([key, _values]) => key);
  }
};
var SelectorObserver = class {
  constructor(element, selector, delegate, details) {
    this._selector = selector;
    this.details = details;
    this.elementObserver = new ElementObserver(element, this);
    this.delegate = delegate;
    this.matchesByElement = new Multimap();
  }
  get started() {
    return this.elementObserver.started;
  }
  get selector() {
    return this._selector;
  }
  set selector(selector) {
    this._selector = selector;
    this.refresh();
  }
  start() {
    this.elementObserver.start();
  }
  pause(callback) {
    this.elementObserver.pause(callback);
  }
  stop() {
    this.elementObserver.stop();
  }
  refresh() {
    this.elementObserver.refresh();
  }
  get element() {
    return this.elementObserver.element;
  }
  matchElement(element) {
    const { selector } = this;
    if (selector) {
      const matches = element.matches(selector);
      if (this.delegate.selectorMatchElement) {
        return matches && this.delegate.selectorMatchElement(element, this.details);
      }
      return matches;
    } else {
      return false;
    }
  }
  matchElementsInTree(tree) {
    const { selector } = this;
    if (selector) {
      const match = this.matchElement(tree) ? [tree] : [];
      const matches = Array.from(tree.querySelectorAll(selector)).filter((match2) => this.matchElement(match2));
      return match.concat(matches);
    } else {
      return [];
    }
  }
  elementMatched(element) {
    const { selector } = this;
    if (selector) {
      this.selectorMatched(element, selector);
    }
  }
  elementUnmatched(element) {
    const selectors = this.matchesByElement.getKeysForValue(element);
    for (const selector of selectors) {
      this.selectorUnmatched(element, selector);
    }
  }
  elementAttributeChanged(element, _attributeName) {
    const { selector } = this;
    if (selector) {
      const matches = this.matchElement(element);
      const matchedBefore = this.matchesByElement.has(selector, element);
      if (matches && !matchedBefore) {
        this.selectorMatched(element, selector);
      } else if (!matches && matchedBefore) {
        this.selectorUnmatched(element, selector);
      }
    }
  }
  selectorMatched(element, selector) {
    this.delegate.selectorMatched(element, selector, this.details);
    this.matchesByElement.add(selector, element);
  }
  selectorUnmatched(element, selector) {
    this.delegate.selectorUnmatched(element, selector, this.details);
    this.matchesByElement.delete(selector, element);
  }
};
var StringMapObserver = class {
  constructor(element, delegate) {
    this.element = element;
    this.delegate = delegate;
    this.started = false;
    this.stringMap = /* @__PURE__ */ new Map();
    this.mutationObserver = new MutationObserver((mutations) => this.processMutations(mutations));
  }
  start() {
    if (!this.started) {
      this.started = true;
      this.mutationObserver.observe(this.element, { attributes: true, attributeOldValue: true });
      this.refresh();
    }
  }
  stop() {
    if (this.started) {
      this.mutationObserver.takeRecords();
      this.mutationObserver.disconnect();
      this.started = false;
    }
  }
  refresh() {
    if (this.started) {
      for (const attributeName of this.knownAttributeNames) {
        this.refreshAttribute(attributeName, null);
      }
    }
  }
  processMutations(mutations) {
    if (this.started) {
      for (const mutation of mutations) {
        this.processMutation(mutation);
      }
    }
  }
  processMutation(mutation) {
    const attributeName = mutation.attributeName;
    if (attributeName) {
      this.refreshAttribute(attributeName, mutation.oldValue);
    }
  }
  refreshAttribute(attributeName, oldValue) {
    const key = this.delegate.getStringMapKeyForAttribute(attributeName);
    if (key != null) {
      if (!this.stringMap.has(attributeName)) {
        this.stringMapKeyAdded(key, attributeName);
      }
      const value = this.element.getAttribute(attributeName);
      if (this.stringMap.get(attributeName) != value) {
        this.stringMapValueChanged(value, key, oldValue);
      }
      if (value == null) {
        const oldValue2 = this.stringMap.get(attributeName);
        this.stringMap.delete(attributeName);
        if (oldValue2)
          this.stringMapKeyRemoved(key, attributeName, oldValue2);
      } else {
        this.stringMap.set(attributeName, value);
      }
    }
  }
  stringMapKeyAdded(key, attributeName) {
    if (this.delegate.stringMapKeyAdded) {
      this.delegate.stringMapKeyAdded(key, attributeName);
    }
  }
  stringMapValueChanged(value, key, oldValue) {
    if (this.delegate.stringMapValueChanged) {
      this.delegate.stringMapValueChanged(value, key, oldValue);
    }
  }
  stringMapKeyRemoved(key, attributeName, oldValue) {
    if (this.delegate.stringMapKeyRemoved) {
      this.delegate.stringMapKeyRemoved(key, attributeName, oldValue);
    }
  }
  get knownAttributeNames() {
    return Array.from(new Set(this.currentAttributeNames.concat(this.recordedAttributeNames)));
  }
  get currentAttributeNames() {
    return Array.from(this.element.attributes).map((attribute) => attribute.name);
  }
  get recordedAttributeNames() {
    return Array.from(this.stringMap.keys());
  }
};
var TokenListObserver = class {
  constructor(element, attributeName, delegate) {
    this.attributeObserver = new AttributeObserver(element, attributeName, this);
    this.delegate = delegate;
    this.tokensByElement = new Multimap();
  }
  get started() {
    return this.attributeObserver.started;
  }
  start() {
    this.attributeObserver.start();
  }
  pause(callback) {
    this.attributeObserver.pause(callback);
  }
  stop() {
    this.attributeObserver.stop();
  }
  refresh() {
    this.attributeObserver.refresh();
  }
  get element() {
    return this.attributeObserver.element;
  }
  get attributeName() {
    return this.attributeObserver.attributeName;
  }
  elementMatchedAttribute(element) {
    this.tokensMatched(this.readTokensForElement(element));
  }
  elementAttributeValueChanged(element) {
    const [unmatchedTokens, matchedTokens] = this.refreshTokensForElement(element);
    this.tokensUnmatched(unmatchedTokens);
    this.tokensMatched(matchedTokens);
  }
  elementUnmatchedAttribute(element) {
    this.tokensUnmatched(this.tokensByElement.getValuesForKey(element));
  }
  tokensMatched(tokens) {
    tokens.forEach((token) => this.tokenMatched(token));
  }
  tokensUnmatched(tokens) {
    tokens.forEach((token) => this.tokenUnmatched(token));
  }
  tokenMatched(token) {
    this.delegate.tokenMatched(token);
    this.tokensByElement.add(token.element, token);
  }
  tokenUnmatched(token) {
    this.delegate.tokenUnmatched(token);
    this.tokensByElement.delete(token.element, token);
  }
  refreshTokensForElement(element) {
    const previousTokens = this.tokensByElement.getValuesForKey(element);
    const currentTokens = this.readTokensForElement(element);
    const firstDifferingIndex = zip(previousTokens, currentTokens).findIndex(([previousToken, currentToken]) => !tokensAreEqual(previousToken, currentToken));
    if (firstDifferingIndex == -1) {
      return [[], []];
    } else {
      return [previousTokens.slice(firstDifferingIndex), currentTokens.slice(firstDifferingIndex)];
    }
  }
  readTokensForElement(element) {
    const attributeName = this.attributeName;
    const tokenString = element.getAttribute(attributeName) || "";
    return parseTokenString(tokenString, element, attributeName);
  }
};
function parseTokenString(tokenString, element, attributeName) {
  return tokenString.trim().split(/\s+/).filter((content) => content.length).map((content, index) => ({ element, attributeName, content, index }));
}
function zip(left, right) {
  const length = Math.max(left.length, right.length);
  return Array.from({ length }, (_, index) => [left[index], right[index]]);
}
function tokensAreEqual(left, right) {
  return left && right && left.index == right.index && left.content == right.content;
}
var ValueListObserver = class {
  constructor(element, attributeName, delegate) {
    this.tokenListObserver = new TokenListObserver(element, attributeName, this);
    this.delegate = delegate;
    this.parseResultsByToken = /* @__PURE__ */ new WeakMap();
    this.valuesByTokenByElement = /* @__PURE__ */ new WeakMap();
  }
  get started() {
    return this.tokenListObserver.started;
  }
  start() {
    this.tokenListObserver.start();
  }
  stop() {
    this.tokenListObserver.stop();
  }
  refresh() {
    this.tokenListObserver.refresh();
  }
  get element() {
    return this.tokenListObserver.element;
  }
  get attributeName() {
    return this.tokenListObserver.attributeName;
  }
  tokenMatched(token) {
    const { element } = token;
    const { value } = this.fetchParseResultForToken(token);
    if (value) {
      this.fetchValuesByTokenForElement(element).set(token, value);
      this.delegate.elementMatchedValue(element, value);
    }
  }
  tokenUnmatched(token) {
    const { element } = token;
    const { value } = this.fetchParseResultForToken(token);
    if (value) {
      this.fetchValuesByTokenForElement(element).delete(token);
      this.delegate.elementUnmatchedValue(element, value);
    }
  }
  fetchParseResultForToken(token) {
    let parseResult = this.parseResultsByToken.get(token);
    if (!parseResult) {
      parseResult = this.parseToken(token);
      this.parseResultsByToken.set(token, parseResult);
    }
    return parseResult;
  }
  fetchValuesByTokenForElement(element) {
    let valuesByToken = this.valuesByTokenByElement.get(element);
    if (!valuesByToken) {
      valuesByToken = /* @__PURE__ */ new Map();
      this.valuesByTokenByElement.set(element, valuesByToken);
    }
    return valuesByToken;
  }
  parseToken(token) {
    try {
      const value = this.delegate.parseValueForToken(token);
      return { value };
    } catch (error2) {
      return { error: error2 };
    }
  }
};
var BindingObserver = class {
  constructor(context, delegate) {
    this.context = context;
    this.delegate = delegate;
    this.bindingsByAction = /* @__PURE__ */ new Map();
  }
  start() {
    if (!this.valueListObserver) {
      this.valueListObserver = new ValueListObserver(this.element, this.actionAttribute, this);
      this.valueListObserver.start();
    }
  }
  stop() {
    if (this.valueListObserver) {
      this.valueListObserver.stop();
      delete this.valueListObserver;
      this.disconnectAllActions();
    }
  }
  get element() {
    return this.context.element;
  }
  get identifier() {
    return this.context.identifier;
  }
  get actionAttribute() {
    return this.schema.actionAttribute;
  }
  get schema() {
    return this.context.schema;
  }
  get bindings() {
    return Array.from(this.bindingsByAction.values());
  }
  connectAction(action) {
    const binding = new Binding(this.context, action);
    this.bindingsByAction.set(action, binding);
    this.delegate.bindingConnected(binding);
  }
  disconnectAction(action) {
    const binding = this.bindingsByAction.get(action);
    if (binding) {
      this.bindingsByAction.delete(action);
      this.delegate.bindingDisconnected(binding);
    }
  }
  disconnectAllActions() {
    this.bindings.forEach((binding) => this.delegate.bindingDisconnected(binding, true));
    this.bindingsByAction.clear();
  }
  parseValueForToken(token) {
    const action = Action.forToken(token, this.schema);
    if (action.identifier == this.identifier) {
      return action;
    }
  }
  elementMatchedValue(element, action) {
    this.connectAction(action);
  }
  elementUnmatchedValue(element, action) {
    this.disconnectAction(action);
  }
};
var ValueObserver = class {
  constructor(context, receiver) {
    this.context = context;
    this.receiver = receiver;
    this.stringMapObserver = new StringMapObserver(this.element, this);
    this.valueDescriptorMap = this.controller.valueDescriptorMap;
  }
  start() {
    this.stringMapObserver.start();
    this.invokeChangedCallbacksForDefaultValues();
  }
  stop() {
    this.stringMapObserver.stop();
  }
  get element() {
    return this.context.element;
  }
  get controller() {
    return this.context.controller;
  }
  getStringMapKeyForAttribute(attributeName) {
    if (attributeName in this.valueDescriptorMap) {
      return this.valueDescriptorMap[attributeName].name;
    }
  }
  stringMapKeyAdded(key, attributeName) {
    const descriptor = this.valueDescriptorMap[attributeName];
    if (!this.hasValue(key)) {
      this.invokeChangedCallback(key, descriptor.writer(this.receiver[key]), descriptor.writer(descriptor.defaultValue));
    }
  }
  stringMapValueChanged(value, name, oldValue) {
    const descriptor = this.valueDescriptorNameMap[name];
    if (value === null)
      return;
    if (oldValue === null) {
      oldValue = descriptor.writer(descriptor.defaultValue);
    }
    this.invokeChangedCallback(name, value, oldValue);
  }
  stringMapKeyRemoved(key, attributeName, oldValue) {
    const descriptor = this.valueDescriptorNameMap[key];
    if (this.hasValue(key)) {
      this.invokeChangedCallback(key, descriptor.writer(this.receiver[key]), oldValue);
    } else {
      this.invokeChangedCallback(key, descriptor.writer(descriptor.defaultValue), oldValue);
    }
  }
  invokeChangedCallbacksForDefaultValues() {
    for (const { key, name, defaultValue, writer } of this.valueDescriptors) {
      if (defaultValue != void 0 && !this.controller.data.has(key)) {
        this.invokeChangedCallback(name, writer(defaultValue), void 0);
      }
    }
  }
  invokeChangedCallback(name, rawValue, rawOldValue) {
    const changedMethodName = `${name}Changed`;
    const changedMethod = this.receiver[changedMethodName];
    if (typeof changedMethod == "function") {
      const descriptor = this.valueDescriptorNameMap[name];
      try {
        const value = descriptor.reader(rawValue);
        let oldValue = rawOldValue;
        if (rawOldValue) {
          oldValue = descriptor.reader(rawOldValue);
        }
        changedMethod.call(this.receiver, value, oldValue);
      } catch (error2) {
        if (error2 instanceof TypeError) {
          error2.message = `Stimulus Value "${this.context.identifier}.${descriptor.name}" - ${error2.message}`;
        }
        throw error2;
      }
    }
  }
  get valueDescriptors() {
    const { valueDescriptorMap } = this;
    return Object.keys(valueDescriptorMap).map((key) => valueDescriptorMap[key]);
  }
  get valueDescriptorNameMap() {
    const descriptors = {};
    Object.keys(this.valueDescriptorMap).forEach((key) => {
      const descriptor = this.valueDescriptorMap[key];
      descriptors[descriptor.name] = descriptor;
    });
    return descriptors;
  }
  hasValue(attributeName) {
    const descriptor = this.valueDescriptorNameMap[attributeName];
    const hasMethodName = `has${capitalize(descriptor.name)}`;
    return this.receiver[hasMethodName];
  }
};
var TargetObserver = class {
  constructor(context, delegate) {
    this.context = context;
    this.delegate = delegate;
    this.targetsByName = new Multimap();
  }
  start() {
    if (!this.tokenListObserver) {
      this.tokenListObserver = new TokenListObserver(this.element, this.attributeName, this);
      this.tokenListObserver.start();
    }
  }
  stop() {
    if (this.tokenListObserver) {
      this.disconnectAllTargets();
      this.tokenListObserver.stop();
      delete this.tokenListObserver;
    }
  }
  tokenMatched({ element, content: name }) {
    if (this.scope.containsElement(element)) {
      this.connectTarget(element, name);
    }
  }
  tokenUnmatched({ element, content: name }) {
    this.disconnectTarget(element, name);
  }
  connectTarget(element, name) {
    var _a;
    if (!this.targetsByName.has(name, element)) {
      this.targetsByName.add(name, element);
      (_a = this.tokenListObserver) === null || _a === void 0 ? void 0 : _a.pause(() => this.delegate.targetConnected(element, name));
    }
  }
  disconnectTarget(element, name) {
    var _a;
    if (this.targetsByName.has(name, element)) {
      this.targetsByName.delete(name, element);
      (_a = this.tokenListObserver) === null || _a === void 0 ? void 0 : _a.pause(() => this.delegate.targetDisconnected(element, name));
    }
  }
  disconnectAllTargets() {
    for (const name of this.targetsByName.keys) {
      for (const element of this.targetsByName.getValuesForKey(name)) {
        this.disconnectTarget(element, name);
      }
    }
  }
  get attributeName() {
    return `data-${this.context.identifier}-target`;
  }
  get element() {
    return this.context.element;
  }
  get scope() {
    return this.context.scope;
  }
};
function readInheritableStaticArrayValues(constructor, propertyName) {
  const ancestors = getAncestorsForConstructor(constructor);
  return Array.from(ancestors.reduce((values, constructor2) => {
    getOwnStaticArrayValues(constructor2, propertyName).forEach((name) => values.add(name));
    return values;
  }, /* @__PURE__ */ new Set()));
}
function readInheritableStaticObjectPairs(constructor, propertyName) {
  const ancestors = getAncestorsForConstructor(constructor);
  return ancestors.reduce((pairs, constructor2) => {
    pairs.push(...getOwnStaticObjectPairs(constructor2, propertyName));
    return pairs;
  }, []);
}
function getAncestorsForConstructor(constructor) {
  const ancestors = [];
  while (constructor) {
    ancestors.push(constructor);
    constructor = Object.getPrototypeOf(constructor);
  }
  return ancestors.reverse();
}
function getOwnStaticArrayValues(constructor, propertyName) {
  const definition = constructor[propertyName];
  return Array.isArray(definition) ? definition : [];
}
function getOwnStaticObjectPairs(constructor, propertyName) {
  const definition = constructor[propertyName];
  return definition ? Object.keys(definition).map((key) => [key, definition[key]]) : [];
}
var OutletObserver = class {
  constructor(context, delegate) {
    this.started = false;
    this.context = context;
    this.delegate = delegate;
    this.outletsByName = new Multimap();
    this.outletElementsByName = new Multimap();
    this.selectorObserverMap = /* @__PURE__ */ new Map();
    this.attributeObserverMap = /* @__PURE__ */ new Map();
  }
  start() {
    if (!this.started) {
      this.outletDefinitions.forEach((outletName) => {
        this.setupSelectorObserverForOutlet(outletName);
        this.setupAttributeObserverForOutlet(outletName);
      });
      this.started = true;
      this.dependentContexts.forEach((context) => context.refresh());
    }
  }
  refresh() {
    this.selectorObserverMap.forEach((observer) => observer.refresh());
    this.attributeObserverMap.forEach((observer) => observer.refresh());
  }
  stop() {
    if (this.started) {
      this.started = false;
      this.disconnectAllOutlets();
      this.stopSelectorObservers();
      this.stopAttributeObservers();
    }
  }
  stopSelectorObservers() {
    if (this.selectorObserverMap.size > 0) {
      this.selectorObserverMap.forEach((observer) => observer.stop());
      this.selectorObserverMap.clear();
    }
  }
  stopAttributeObservers() {
    if (this.attributeObserverMap.size > 0) {
      this.attributeObserverMap.forEach((observer) => observer.stop());
      this.attributeObserverMap.clear();
    }
  }
  selectorMatched(element, _selector, { outletName }) {
    const outlet = this.getOutlet(element, outletName);
    if (outlet) {
      this.connectOutlet(outlet, element, outletName);
    }
  }
  selectorUnmatched(element, _selector, { outletName }) {
    const outlet = this.getOutletFromMap(element, outletName);
    if (outlet) {
      this.disconnectOutlet(outlet, element, outletName);
    }
  }
  selectorMatchElement(element, { outletName }) {
    const selector = this.selector(outletName);
    const hasOutlet = this.hasOutlet(element, outletName);
    const hasOutletController = element.matches(`[${this.schema.controllerAttribute}~=${outletName}]`);
    if (selector) {
      return hasOutlet && hasOutletController && element.matches(selector);
    } else {
      return false;
    }
  }
  elementMatchedAttribute(_element, attributeName) {
    const outletName = this.getOutletNameFromOutletAttributeName(attributeName);
    if (outletName) {
      this.updateSelectorObserverForOutlet(outletName);
    }
  }
  elementAttributeValueChanged(_element, attributeName) {
    const outletName = this.getOutletNameFromOutletAttributeName(attributeName);
    if (outletName) {
      this.updateSelectorObserverForOutlet(outletName);
    }
  }
  elementUnmatchedAttribute(_element, attributeName) {
    const outletName = this.getOutletNameFromOutletAttributeName(attributeName);
    if (outletName) {
      this.updateSelectorObserverForOutlet(outletName);
    }
  }
  connectOutlet(outlet, element, outletName) {
    var _a;
    if (!this.outletElementsByName.has(outletName, element)) {
      this.outletsByName.add(outletName, outlet);
      this.outletElementsByName.add(outletName, element);
      (_a = this.selectorObserverMap.get(outletName)) === null || _a === void 0 ? void 0 : _a.pause(() => this.delegate.outletConnected(outlet, element, outletName));
    }
  }
  disconnectOutlet(outlet, element, outletName) {
    var _a;
    if (this.outletElementsByName.has(outletName, element)) {
      this.outletsByName.delete(outletName, outlet);
      this.outletElementsByName.delete(outletName, element);
      (_a = this.selectorObserverMap.get(outletName)) === null || _a === void 0 ? void 0 : _a.pause(() => this.delegate.outletDisconnected(outlet, element, outletName));
    }
  }
  disconnectAllOutlets() {
    for (const outletName of this.outletElementsByName.keys) {
      for (const element of this.outletElementsByName.getValuesForKey(outletName)) {
        for (const outlet of this.outletsByName.getValuesForKey(outletName)) {
          this.disconnectOutlet(outlet, element, outletName);
        }
      }
    }
  }
  updateSelectorObserverForOutlet(outletName) {
    const observer = this.selectorObserverMap.get(outletName);
    if (observer) {
      observer.selector = this.selector(outletName);
    }
  }
  setupSelectorObserverForOutlet(outletName) {
    const selector = this.selector(outletName);
    const selectorObserver = new SelectorObserver(document.body, selector, this, { outletName });
    this.selectorObserverMap.set(outletName, selectorObserver);
    selectorObserver.start();
  }
  setupAttributeObserverForOutlet(outletName) {
    const attributeName = this.attributeNameForOutletName(outletName);
    const attributeObserver = new AttributeObserver(this.scope.element, attributeName, this);
    this.attributeObserverMap.set(outletName, attributeObserver);
    attributeObserver.start();
  }
  selector(outletName) {
    return this.scope.outlets.getSelectorForOutletName(outletName);
  }
  attributeNameForOutletName(outletName) {
    return this.scope.schema.outletAttributeForScope(this.identifier, outletName);
  }
  getOutletNameFromOutletAttributeName(attributeName) {
    return this.outletDefinitions.find((outletName) => this.attributeNameForOutletName(outletName) === attributeName);
  }
  get outletDependencies() {
    const dependencies = new Multimap();
    this.router.modules.forEach((module) => {
      const constructor = module.definition.controllerConstructor;
      const outlets = readInheritableStaticArrayValues(constructor, "outlets");
      outlets.forEach((outlet) => dependencies.add(outlet, module.identifier));
    });
    return dependencies;
  }
  get outletDefinitions() {
    return this.outletDependencies.getKeysForValue(this.identifier);
  }
  get dependentControllerIdentifiers() {
    return this.outletDependencies.getValuesForKey(this.identifier);
  }
  get dependentContexts() {
    const identifiers = this.dependentControllerIdentifiers;
    return this.router.contexts.filter((context) => identifiers.includes(context.identifier));
  }
  hasOutlet(element, outletName) {
    return !!this.getOutlet(element, outletName) || !!this.getOutletFromMap(element, outletName);
  }
  getOutlet(element, outletName) {
    return this.application.getControllerForElementAndIdentifier(element, outletName);
  }
  getOutletFromMap(element, outletName) {
    return this.outletsByName.getValuesForKey(outletName).find((outlet) => outlet.element === element);
  }
  get scope() {
    return this.context.scope;
  }
  get schema() {
    return this.context.schema;
  }
  get identifier() {
    return this.context.identifier;
  }
  get application() {
    return this.context.application;
  }
  get router() {
    return this.application.router;
  }
};
var Context = class {
  constructor(module, scope) {
    this.logDebugActivity = (functionName, detail = {}) => {
      const { identifier, controller, element } = this;
      detail = Object.assign({ identifier, controller, element }, detail);
      this.application.logDebugActivity(this.identifier, functionName, detail);
    };
    this.module = module;
    this.scope = scope;
    this.controller = new module.controllerConstructor(this);
    this.bindingObserver = new BindingObserver(this, this.dispatcher);
    this.valueObserver = new ValueObserver(this, this.controller);
    this.targetObserver = new TargetObserver(this, this);
    this.outletObserver = new OutletObserver(this, this);
    try {
      this.controller.initialize();
      this.logDebugActivity("initialize");
    } catch (error2) {
      this.handleError(error2, "initializing controller");
    }
  }
  connect() {
    this.bindingObserver.start();
    this.valueObserver.start();
    this.targetObserver.start();
    this.outletObserver.start();
    try {
      this.controller.connect();
      this.logDebugActivity("connect");
    } catch (error2) {
      this.handleError(error2, "connecting controller");
    }
  }
  refresh() {
    this.outletObserver.refresh();
  }
  disconnect() {
    try {
      this.controller.disconnect();
      this.logDebugActivity("disconnect");
    } catch (error2) {
      this.handleError(error2, "disconnecting controller");
    }
    this.outletObserver.stop();
    this.targetObserver.stop();
    this.valueObserver.stop();
    this.bindingObserver.stop();
  }
  get application() {
    return this.module.application;
  }
  get identifier() {
    return this.module.identifier;
  }
  get schema() {
    return this.application.schema;
  }
  get dispatcher() {
    return this.application.dispatcher;
  }
  get element() {
    return this.scope.element;
  }
  get parentElement() {
    return this.element.parentElement;
  }
  handleError(error2, message, detail = {}) {
    const { identifier, controller, element } = this;
    detail = Object.assign({ identifier, controller, element }, detail);
    this.application.handleError(error2, `Error ${message}`, detail);
  }
  targetConnected(element, name) {
    this.invokeControllerMethod(`${name}TargetConnected`, element);
  }
  targetDisconnected(element, name) {
    this.invokeControllerMethod(`${name}TargetDisconnected`, element);
  }
  outletConnected(outlet, element, name) {
    this.invokeControllerMethod(`${namespaceCamelize(name)}OutletConnected`, outlet, element);
  }
  outletDisconnected(outlet, element, name) {
    this.invokeControllerMethod(`${namespaceCamelize(name)}OutletDisconnected`, outlet, element);
  }
  invokeControllerMethod(methodName, ...args) {
    const controller = this.controller;
    if (typeof controller[methodName] == "function") {
      controller[methodName](...args);
    }
  }
};
function bless(constructor) {
  return shadow(constructor, getBlessedProperties(constructor));
}
function shadow(constructor, properties) {
  const shadowConstructor = extend2(constructor);
  const shadowProperties = getShadowProperties(constructor.prototype, properties);
  Object.defineProperties(shadowConstructor.prototype, shadowProperties);
  return shadowConstructor;
}
function getBlessedProperties(constructor) {
  const blessings = readInheritableStaticArrayValues(constructor, "blessings");
  return blessings.reduce((blessedProperties, blessing) => {
    const properties = blessing(constructor);
    for (const key in properties) {
      const descriptor = blessedProperties[key] || {};
      blessedProperties[key] = Object.assign(descriptor, properties[key]);
    }
    return blessedProperties;
  }, {});
}
function getShadowProperties(prototype, properties) {
  return getOwnKeys(properties).reduce((shadowProperties, key) => {
    const descriptor = getShadowedDescriptor(prototype, properties, key);
    if (descriptor) {
      Object.assign(shadowProperties, { [key]: descriptor });
    }
    return shadowProperties;
  }, {});
}
function getShadowedDescriptor(prototype, properties, key) {
  const shadowingDescriptor = Object.getOwnPropertyDescriptor(prototype, key);
  const shadowedByValue = shadowingDescriptor && "value" in shadowingDescriptor;
  if (!shadowedByValue) {
    const descriptor = Object.getOwnPropertyDescriptor(properties, key).value;
    if (shadowingDescriptor) {
      descriptor.get = shadowingDescriptor.get || descriptor.get;
      descriptor.set = shadowingDescriptor.set || descriptor.set;
    }
    return descriptor;
  }
}
var getOwnKeys = (() => {
  if (typeof Object.getOwnPropertySymbols == "function") {
    return (object) => [...Object.getOwnPropertyNames(object), ...Object.getOwnPropertySymbols(object)];
  } else {
    return Object.getOwnPropertyNames;
  }
})();
var extend2 = (() => {
  function extendWithReflect(constructor) {
    function extended() {
      return Reflect.construct(constructor, arguments, new.target);
    }
    extended.prototype = Object.create(constructor.prototype, {
      constructor: { value: extended }
    });
    Reflect.setPrototypeOf(extended, constructor);
    return extended;
  }
  function testReflectExtension() {
    const a = function() {
      this.a.call(this);
    };
    const b = extendWithReflect(a);
    b.prototype.a = function() {
    };
    return new b();
  }
  try {
    testReflectExtension();
    return extendWithReflect;
  } catch (error2) {
    return (constructor) => class extended extends constructor {
    };
  }
})();
function blessDefinition(definition) {
  return {
    identifier: definition.identifier,
    controllerConstructor: bless(definition.controllerConstructor)
  };
}
var Module = class {
  constructor(application2, definition) {
    this.application = application2;
    this.definition = blessDefinition(definition);
    this.contextsByScope = /* @__PURE__ */ new WeakMap();
    this.connectedContexts = /* @__PURE__ */ new Set();
  }
  get identifier() {
    return this.definition.identifier;
  }
  get controllerConstructor() {
    return this.definition.controllerConstructor;
  }
  get contexts() {
    return Array.from(this.connectedContexts);
  }
  connectContextForScope(scope) {
    const context = this.fetchContextForScope(scope);
    this.connectedContexts.add(context);
    context.connect();
  }
  disconnectContextForScope(scope) {
    const context = this.contextsByScope.get(scope);
    if (context) {
      this.connectedContexts.delete(context);
      context.disconnect();
    }
  }
  fetchContextForScope(scope) {
    let context = this.contextsByScope.get(scope);
    if (!context) {
      context = new Context(this, scope);
      this.contextsByScope.set(scope, context);
    }
    return context;
  }
};
var ClassMap = class {
  constructor(scope) {
    this.scope = scope;
  }
  has(name) {
    return this.data.has(this.getDataKey(name));
  }
  get(name) {
    return this.getAll(name)[0];
  }
  getAll(name) {
    const tokenString = this.data.get(this.getDataKey(name)) || "";
    return tokenize(tokenString);
  }
  getAttributeName(name) {
    return this.data.getAttributeNameForKey(this.getDataKey(name));
  }
  getDataKey(name) {
    return `${name}-class`;
  }
  get data() {
    return this.scope.data;
  }
};
var DataMap = class {
  constructor(scope) {
    this.scope = scope;
  }
  get element() {
    return this.scope.element;
  }
  get identifier() {
    return this.scope.identifier;
  }
  get(key) {
    const name = this.getAttributeNameForKey(key);
    return this.element.getAttribute(name);
  }
  set(key, value) {
    const name = this.getAttributeNameForKey(key);
    this.element.setAttribute(name, value);
    return this.get(key);
  }
  has(key) {
    const name = this.getAttributeNameForKey(key);
    return this.element.hasAttribute(name);
  }
  delete(key) {
    if (this.has(key)) {
      const name = this.getAttributeNameForKey(key);
      this.element.removeAttribute(name);
      return true;
    } else {
      return false;
    }
  }
  getAttributeNameForKey(key) {
    return `data-${this.identifier}-${dasherize(key)}`;
  }
};
var Guide = class {
  constructor(logger) {
    this.warnedKeysByObject = /* @__PURE__ */ new WeakMap();
    this.logger = logger;
  }
  warn(object, key, message) {
    let warnedKeys = this.warnedKeysByObject.get(object);
    if (!warnedKeys) {
      warnedKeys = /* @__PURE__ */ new Set();
      this.warnedKeysByObject.set(object, warnedKeys);
    }
    if (!warnedKeys.has(key)) {
      warnedKeys.add(key);
      this.logger.warn(message, object);
    }
  }
};
function attributeValueContainsToken(attributeName, token) {
  return `[${attributeName}~="${token}"]`;
}
var TargetSet = class {
  constructor(scope) {
    this.scope = scope;
  }
  get element() {
    return this.scope.element;
  }
  get identifier() {
    return this.scope.identifier;
  }
  get schema() {
    return this.scope.schema;
  }
  has(targetName) {
    return this.find(targetName) != null;
  }
  find(...targetNames) {
    return targetNames.reduce((target, targetName) => target || this.findTarget(targetName) || this.findLegacyTarget(targetName), void 0);
  }
  findAll(...targetNames) {
    return targetNames.reduce((targets, targetName) => [
      ...targets,
      ...this.findAllTargets(targetName),
      ...this.findAllLegacyTargets(targetName)
    ], []);
  }
  findTarget(targetName) {
    const selector = this.getSelectorForTargetName(targetName);
    return this.scope.findElement(selector);
  }
  findAllTargets(targetName) {
    const selector = this.getSelectorForTargetName(targetName);
    return this.scope.findAllElements(selector);
  }
  getSelectorForTargetName(targetName) {
    const attributeName = this.schema.targetAttributeForScope(this.identifier);
    return attributeValueContainsToken(attributeName, targetName);
  }
  findLegacyTarget(targetName) {
    const selector = this.getLegacySelectorForTargetName(targetName);
    return this.deprecate(this.scope.findElement(selector), targetName);
  }
  findAllLegacyTargets(targetName) {
    const selector = this.getLegacySelectorForTargetName(targetName);
    return this.scope.findAllElements(selector).map((element) => this.deprecate(element, targetName));
  }
  getLegacySelectorForTargetName(targetName) {
    const targetDescriptor = `${this.identifier}.${targetName}`;
    return attributeValueContainsToken(this.schema.targetAttribute, targetDescriptor);
  }
  deprecate(element, targetName) {
    if (element) {
      const { identifier } = this;
      const attributeName = this.schema.targetAttribute;
      const revisedAttributeName = this.schema.targetAttributeForScope(identifier);
      this.guide.warn(element, `target:${targetName}`, `Please replace ${attributeName}="${identifier}.${targetName}" with ${revisedAttributeName}="${targetName}". The ${attributeName} attribute is deprecated and will be removed in a future version of Stimulus.`);
    }
    return element;
  }
  get guide() {
    return this.scope.guide;
  }
};
var OutletSet = class {
  constructor(scope, controllerElement) {
    this.scope = scope;
    this.controllerElement = controllerElement;
  }
  get element() {
    return this.scope.element;
  }
  get identifier() {
    return this.scope.identifier;
  }
  get schema() {
    return this.scope.schema;
  }
  has(outletName) {
    return this.find(outletName) != null;
  }
  find(...outletNames) {
    return outletNames.reduce((outlet, outletName) => outlet || this.findOutlet(outletName), void 0);
  }
  findAll(...outletNames) {
    return outletNames.reduce((outlets, outletName) => [...outlets, ...this.findAllOutlets(outletName)], []);
  }
  getSelectorForOutletName(outletName) {
    const attributeName = this.schema.outletAttributeForScope(this.identifier, outletName);
    return this.controllerElement.getAttribute(attributeName);
  }
  findOutlet(outletName) {
    const selector = this.getSelectorForOutletName(outletName);
    if (selector)
      return this.findElement(selector, outletName);
  }
  findAllOutlets(outletName) {
    const selector = this.getSelectorForOutletName(outletName);
    return selector ? this.findAllElements(selector, outletName) : [];
  }
  findElement(selector, outletName) {
    const elements = this.scope.queryElements(selector);
    return elements.filter((element) => this.matchesElement(element, selector, outletName))[0];
  }
  findAllElements(selector, outletName) {
    const elements = this.scope.queryElements(selector);
    return elements.filter((element) => this.matchesElement(element, selector, outletName));
  }
  matchesElement(element, selector, outletName) {
    const controllerAttribute = element.getAttribute(this.scope.schema.controllerAttribute) || "";
    return element.matches(selector) && controllerAttribute.split(" ").includes(outletName);
  }
};
var Scope = class _Scope {
  constructor(schema, element, identifier, logger) {
    this.targets = new TargetSet(this);
    this.classes = new ClassMap(this);
    this.data = new DataMap(this);
    this.containsElement = (element2) => {
      return element2.closest(this.controllerSelector) === this.element;
    };
    this.schema = schema;
    this.element = element;
    this.identifier = identifier;
    this.guide = new Guide(logger);
    this.outlets = new OutletSet(this.documentScope, element);
  }
  findElement(selector) {
    return this.element.matches(selector) ? this.element : this.queryElements(selector).find(this.containsElement);
  }
  findAllElements(selector) {
    return [
      ...this.element.matches(selector) ? [this.element] : [],
      ...this.queryElements(selector).filter(this.containsElement)
    ];
  }
  queryElements(selector) {
    return Array.from(this.element.querySelectorAll(selector));
  }
  get controllerSelector() {
    return attributeValueContainsToken(this.schema.controllerAttribute, this.identifier);
  }
  get isDocumentScope() {
    return this.element === document.documentElement;
  }
  get documentScope() {
    return this.isDocumentScope ? this : new _Scope(this.schema, document.documentElement, this.identifier, this.guide.logger);
  }
};
var ScopeObserver = class {
  constructor(element, schema, delegate) {
    this.element = element;
    this.schema = schema;
    this.delegate = delegate;
    this.valueListObserver = new ValueListObserver(this.element, this.controllerAttribute, this);
    this.scopesByIdentifierByElement = /* @__PURE__ */ new WeakMap();
    this.scopeReferenceCounts = /* @__PURE__ */ new WeakMap();
  }
  start() {
    this.valueListObserver.start();
  }
  stop() {
    this.valueListObserver.stop();
  }
  get controllerAttribute() {
    return this.schema.controllerAttribute;
  }
  parseValueForToken(token) {
    const { element, content: identifier } = token;
    return this.parseValueForElementAndIdentifier(element, identifier);
  }
  parseValueForElementAndIdentifier(element, identifier) {
    const scopesByIdentifier = this.fetchScopesByIdentifierForElement(element);
    let scope = scopesByIdentifier.get(identifier);
    if (!scope) {
      scope = this.delegate.createScopeForElementAndIdentifier(element, identifier);
      scopesByIdentifier.set(identifier, scope);
    }
    return scope;
  }
  elementMatchedValue(element, value) {
    const referenceCount = (this.scopeReferenceCounts.get(value) || 0) + 1;
    this.scopeReferenceCounts.set(value, referenceCount);
    if (referenceCount == 1) {
      this.delegate.scopeConnected(value);
    }
  }
  elementUnmatchedValue(element, value) {
    const referenceCount = this.scopeReferenceCounts.get(value);
    if (referenceCount) {
      this.scopeReferenceCounts.set(value, referenceCount - 1);
      if (referenceCount == 1) {
        this.delegate.scopeDisconnected(value);
      }
    }
  }
  fetchScopesByIdentifierForElement(element) {
    let scopesByIdentifier = this.scopesByIdentifierByElement.get(element);
    if (!scopesByIdentifier) {
      scopesByIdentifier = /* @__PURE__ */ new Map();
      this.scopesByIdentifierByElement.set(element, scopesByIdentifier);
    }
    return scopesByIdentifier;
  }
};
var Router = class {
  constructor(application2) {
    this.application = application2;
    this.scopeObserver = new ScopeObserver(this.element, this.schema, this);
    this.scopesByIdentifier = new Multimap();
    this.modulesByIdentifier = /* @__PURE__ */ new Map();
  }
  get element() {
    return this.application.element;
  }
  get schema() {
    return this.application.schema;
  }
  get logger() {
    return this.application.logger;
  }
  get controllerAttribute() {
    return this.schema.controllerAttribute;
  }
  get modules() {
    return Array.from(this.modulesByIdentifier.values());
  }
  get contexts() {
    return this.modules.reduce((contexts, module) => contexts.concat(module.contexts), []);
  }
  start() {
    this.scopeObserver.start();
  }
  stop() {
    this.scopeObserver.stop();
  }
  loadDefinition(definition) {
    this.unloadIdentifier(definition.identifier);
    const module = new Module(this.application, definition);
    this.connectModule(module);
    const afterLoad = definition.controllerConstructor.afterLoad;
    if (afterLoad) {
      afterLoad.call(definition.controllerConstructor, definition.identifier, this.application);
    }
  }
  unloadIdentifier(identifier) {
    const module = this.modulesByIdentifier.get(identifier);
    if (module) {
      this.disconnectModule(module);
    }
  }
  getContextForElementAndIdentifier(element, identifier) {
    const module = this.modulesByIdentifier.get(identifier);
    if (module) {
      return module.contexts.find((context) => context.element == element);
    }
  }
  proposeToConnectScopeForElementAndIdentifier(element, identifier) {
    const scope = this.scopeObserver.parseValueForElementAndIdentifier(element, identifier);
    if (scope) {
      this.scopeObserver.elementMatchedValue(scope.element, scope);
    } else {
      console.error(`Couldn't find or create scope for identifier: "${identifier}" and element:`, element);
    }
  }
  handleError(error2, message, detail) {
    this.application.handleError(error2, message, detail);
  }
  createScopeForElementAndIdentifier(element, identifier) {
    return new Scope(this.schema, element, identifier, this.logger);
  }
  scopeConnected(scope) {
    this.scopesByIdentifier.add(scope.identifier, scope);
    const module = this.modulesByIdentifier.get(scope.identifier);
    if (module) {
      module.connectContextForScope(scope);
    }
  }
  scopeDisconnected(scope) {
    this.scopesByIdentifier.delete(scope.identifier, scope);
    const module = this.modulesByIdentifier.get(scope.identifier);
    if (module) {
      module.disconnectContextForScope(scope);
    }
  }
  connectModule(module) {
    this.modulesByIdentifier.set(module.identifier, module);
    const scopes = this.scopesByIdentifier.getValuesForKey(module.identifier);
    scopes.forEach((scope) => module.connectContextForScope(scope));
  }
  disconnectModule(module) {
    this.modulesByIdentifier.delete(module.identifier);
    const scopes = this.scopesByIdentifier.getValuesForKey(module.identifier);
    scopes.forEach((scope) => module.disconnectContextForScope(scope));
  }
};
var defaultSchema = {
  controllerAttribute: "data-controller",
  actionAttribute: "data-action",
  targetAttribute: "data-target",
  targetAttributeForScope: (identifier) => `data-${identifier}-target`,
  outletAttributeForScope: (identifier, outlet) => `data-${identifier}-${outlet}-outlet`,
  keyMappings: Object.assign(Object.assign({ enter: "Enter", tab: "Tab", esc: "Escape", space: " ", up: "ArrowUp", down: "ArrowDown", left: "ArrowLeft", right: "ArrowRight", home: "Home", end: "End", page_up: "PageUp", page_down: "PageDown" }, objectFromEntries("abcdefghijklmnopqrstuvwxyz".split("").map((c) => [c, c]))), objectFromEntries("0123456789".split("").map((n) => [n, n])))
};
function objectFromEntries(array) {
  return array.reduce((memo, [k, v]) => Object.assign(Object.assign({}, memo), { [k]: v }), {});
}
var Application = class {
  constructor(element = document.documentElement, schema = defaultSchema) {
    this.logger = console;
    this.debug = false;
    this.logDebugActivity = (identifier, functionName, detail = {}) => {
      if (this.debug) {
        this.logFormattedMessage(identifier, functionName, detail);
      }
    };
    this.element = element;
    this.schema = schema;
    this.dispatcher = new Dispatcher(this);
    this.router = new Router(this);
    this.actionDescriptorFilters = Object.assign({}, defaultActionDescriptorFilters);
  }
  static start(element, schema) {
    const application2 = new this(element, schema);
    application2.start();
    return application2;
  }
  async start() {
    await domReady();
    this.logDebugActivity("application", "starting");
    this.dispatcher.start();
    this.router.start();
    this.logDebugActivity("application", "start");
  }
  stop() {
    this.logDebugActivity("application", "stopping");
    this.dispatcher.stop();
    this.router.stop();
    this.logDebugActivity("application", "stop");
  }
  register(identifier, controllerConstructor) {
    this.load({ identifier, controllerConstructor });
  }
  registerActionOption(name, filter) {
    this.actionDescriptorFilters[name] = filter;
  }
  load(head, ...rest) {
    const definitions = Array.isArray(head) ? head : [head, ...rest];
    definitions.forEach((definition) => {
      if (definition.controllerConstructor.shouldLoad) {
        this.router.loadDefinition(definition);
      }
    });
  }
  unload(head, ...rest) {
    const identifiers = Array.isArray(head) ? head : [head, ...rest];
    identifiers.forEach((identifier) => this.router.unloadIdentifier(identifier));
  }
  get controllers() {
    return this.router.contexts.map((context) => context.controller);
  }
  getControllerForElementAndIdentifier(element, identifier) {
    const context = this.router.getContextForElementAndIdentifier(element, identifier);
    return context ? context.controller : null;
  }
  handleError(error2, message, detail) {
    var _a;
    this.logger.error(`%s

%o

%o`, message, error2, detail);
    (_a = window.onerror) === null || _a === void 0 ? void 0 : _a.call(window, message, "", 0, 0, error2);
  }
  logFormattedMessage(identifier, functionName, detail = {}) {
    detail = Object.assign({ application: this }, detail);
    this.logger.groupCollapsed(`${identifier} #${functionName}`);
    this.logger.log("details:", Object.assign({}, detail));
    this.logger.groupEnd();
  }
};
function domReady() {
  return new Promise((resolve) => {
    if (document.readyState == "loading") {
      document.addEventListener("DOMContentLoaded", () => resolve());
    } else {
      resolve();
    }
  });
}
function ClassPropertiesBlessing(constructor) {
  const classes = readInheritableStaticArrayValues(constructor, "classes");
  return classes.reduce((properties, classDefinition) => {
    return Object.assign(properties, propertiesForClassDefinition(classDefinition));
  }, {});
}
function propertiesForClassDefinition(key) {
  return {
    [`${key}Class`]: {
      get() {
        const { classes } = this;
        if (classes.has(key)) {
          return classes.get(key);
        } else {
          const attribute = classes.getAttributeName(key);
          throw new Error(`Missing attribute "${attribute}"`);
        }
      }
    },
    [`${key}Classes`]: {
      get() {
        return this.classes.getAll(key);
      }
    },
    [`has${capitalize(key)}Class`]: {
      get() {
        return this.classes.has(key);
      }
    }
  };
}
function OutletPropertiesBlessing(constructor) {
  const outlets = readInheritableStaticArrayValues(constructor, "outlets");
  return outlets.reduce((properties, outletDefinition) => {
    return Object.assign(properties, propertiesForOutletDefinition(outletDefinition));
  }, {});
}
function getOutletController(controller, element, identifier) {
  return controller.application.getControllerForElementAndIdentifier(element, identifier);
}
function getControllerAndEnsureConnectedScope(controller, element, outletName) {
  let outletController = getOutletController(controller, element, outletName);
  if (outletController)
    return outletController;
  controller.application.router.proposeToConnectScopeForElementAndIdentifier(element, outletName);
  outletController = getOutletController(controller, element, outletName);
  if (outletController)
    return outletController;
}
function propertiesForOutletDefinition(name) {
  const camelizedName = namespaceCamelize(name);
  return {
    [`${camelizedName}Outlet`]: {
      get() {
        const outletElement = this.outlets.find(name);
        const selector = this.outlets.getSelectorForOutletName(name);
        if (outletElement) {
          const outletController = getControllerAndEnsureConnectedScope(this, outletElement, name);
          if (outletController)
            return outletController;
          throw new Error(`The provided outlet element is missing an outlet controller "${name}" instance for host controller "${this.identifier}"`);
        }
        throw new Error(`Missing outlet element "${name}" for host controller "${this.identifier}". Stimulus couldn't find a matching outlet element using selector "${selector}".`);
      }
    },
    [`${camelizedName}Outlets`]: {
      get() {
        const outlets = this.outlets.findAll(name);
        if (outlets.length > 0) {
          return outlets.map((outletElement) => {
            const outletController = getControllerAndEnsureConnectedScope(this, outletElement, name);
            if (outletController)
              return outletController;
            console.warn(`The provided outlet element is missing an outlet controller "${name}" instance for host controller "${this.identifier}"`, outletElement);
          }).filter((controller) => controller);
        }
        return [];
      }
    },
    [`${camelizedName}OutletElement`]: {
      get() {
        const outletElement = this.outlets.find(name);
        const selector = this.outlets.getSelectorForOutletName(name);
        if (outletElement) {
          return outletElement;
        } else {
          throw new Error(`Missing outlet element "${name}" for host controller "${this.identifier}". Stimulus couldn't find a matching outlet element using selector "${selector}".`);
        }
      }
    },
    [`${camelizedName}OutletElements`]: {
      get() {
        return this.outlets.findAll(name);
      }
    },
    [`has${capitalize(camelizedName)}Outlet`]: {
      get() {
        return this.outlets.has(name);
      }
    }
  };
}
function TargetPropertiesBlessing(constructor) {
  const targets = readInheritableStaticArrayValues(constructor, "targets");
  return targets.reduce((properties, targetDefinition) => {
    return Object.assign(properties, propertiesForTargetDefinition(targetDefinition));
  }, {});
}
function propertiesForTargetDefinition(name) {
  return {
    [`${name}Target`]: {
      get() {
        const target = this.targets.find(name);
        if (target) {
          return target;
        } else {
          throw new Error(`Missing target element "${name}" for "${this.identifier}" controller`);
        }
      }
    },
    [`${name}Targets`]: {
      get() {
        return this.targets.findAll(name);
      }
    },
    [`has${capitalize(name)}Target`]: {
      get() {
        return this.targets.has(name);
      }
    }
  };
}
function ValuePropertiesBlessing(constructor) {
  const valueDefinitionPairs = readInheritableStaticObjectPairs(constructor, "values");
  const propertyDescriptorMap = {
    valueDescriptorMap: {
      get() {
        return valueDefinitionPairs.reduce((result, valueDefinitionPair) => {
          const valueDescriptor = parseValueDefinitionPair(valueDefinitionPair, this.identifier);
          const attributeName = this.data.getAttributeNameForKey(valueDescriptor.key);
          return Object.assign(result, { [attributeName]: valueDescriptor });
        }, {});
      }
    }
  };
  return valueDefinitionPairs.reduce((properties, valueDefinitionPair) => {
    return Object.assign(properties, propertiesForValueDefinitionPair(valueDefinitionPair));
  }, propertyDescriptorMap);
}
function propertiesForValueDefinitionPair(valueDefinitionPair, controller) {
  const definition = parseValueDefinitionPair(valueDefinitionPair, controller);
  const { key, name, reader: read, writer: write } = definition;
  return {
    [name]: {
      get() {
        const value = this.data.get(key);
        if (value !== null) {
          return read(value);
        } else {
          return definition.defaultValue;
        }
      },
      set(value) {
        if (value === void 0) {
          this.data.delete(key);
        } else {
          this.data.set(key, write(value));
        }
      }
    },
    [`has${capitalize(name)}`]: {
      get() {
        return this.data.has(key) || definition.hasCustomDefaultValue;
      }
    }
  };
}
function parseValueDefinitionPair([token, typeDefinition], controller) {
  return valueDescriptorForTokenAndTypeDefinition({
    controller,
    token,
    typeDefinition
  });
}
function parseValueTypeConstant(constant) {
  switch (constant) {
    case Array:
      return "array";
    case Boolean:
      return "boolean";
    case Number:
      return "number";
    case Object:
      return "object";
    case String:
      return "string";
  }
}
function parseValueTypeDefault(defaultValue) {
  switch (typeof defaultValue) {
    case "boolean":
      return "boolean";
    case "number":
      return "number";
    case "string":
      return "string";
  }
  if (Array.isArray(defaultValue))
    return "array";
  if (Object.prototype.toString.call(defaultValue) === "[object Object]")
    return "object";
}
function parseValueTypeObject(payload) {
  const { controller, token, typeObject } = payload;
  const hasType = isSomething(typeObject.type);
  const hasDefault = isSomething(typeObject.default);
  const fullObject = hasType && hasDefault;
  const onlyType = hasType && !hasDefault;
  const onlyDefault = !hasType && hasDefault;
  const typeFromObject = parseValueTypeConstant(typeObject.type);
  const typeFromDefaultValue = parseValueTypeDefault(payload.typeObject.default);
  if (onlyType)
    return typeFromObject;
  if (onlyDefault)
    return typeFromDefaultValue;
  if (typeFromObject !== typeFromDefaultValue) {
    const propertyPath = controller ? `${controller}.${token}` : token;
    throw new Error(`The specified default value for the Stimulus Value "${propertyPath}" must match the defined type "${typeFromObject}". The provided default value of "${typeObject.default}" is of type "${typeFromDefaultValue}".`);
  }
  if (fullObject)
    return typeFromObject;
}
function parseValueTypeDefinition(payload) {
  const { controller, token, typeDefinition } = payload;
  const typeObject = { controller, token, typeObject: typeDefinition };
  const typeFromObject = parseValueTypeObject(typeObject);
  const typeFromDefaultValue = parseValueTypeDefault(typeDefinition);
  const typeFromConstant = parseValueTypeConstant(typeDefinition);
  const type = typeFromObject || typeFromDefaultValue || typeFromConstant;
  if (type)
    return type;
  const propertyPath = controller ? `${controller}.${typeDefinition}` : token;
  throw new Error(`Unknown value type "${propertyPath}" for "${token}" value`);
}
function defaultValueForDefinition(typeDefinition) {
  const constant = parseValueTypeConstant(typeDefinition);
  if (constant)
    return defaultValuesByType[constant];
  const hasDefault = hasProperty(typeDefinition, "default");
  const hasType = hasProperty(typeDefinition, "type");
  const typeObject = typeDefinition;
  if (hasDefault)
    return typeObject.default;
  if (hasType) {
    const { type } = typeObject;
    const constantFromType = parseValueTypeConstant(type);
    if (constantFromType)
      return defaultValuesByType[constantFromType];
  }
  return typeDefinition;
}
function valueDescriptorForTokenAndTypeDefinition(payload) {
  const { token, typeDefinition } = payload;
  const key = `${dasherize(token)}-value`;
  const type = parseValueTypeDefinition(payload);
  return {
    type,
    key,
    name: camelize(key),
    get defaultValue() {
      return defaultValueForDefinition(typeDefinition);
    },
    get hasCustomDefaultValue() {
      return parseValueTypeDefault(typeDefinition) !== void 0;
    },
    reader: readers[type],
    writer: writers[type] || writers.default
  };
}
var defaultValuesByType = {
  get array() {
    return [];
  },
  boolean: false,
  number: 0,
  get object() {
    return {};
  },
  string: ""
};
var readers = {
  array(value) {
    const array = JSON.parse(value);
    if (!Array.isArray(array)) {
      throw new TypeError(`expected value of type "array" but instead got value "${value}" of type "${parseValueTypeDefault(array)}"`);
    }
    return array;
  },
  boolean(value) {
    return !(value == "0" || String(value).toLowerCase() == "false");
  },
  number(value) {
    return Number(value.replace(/_/g, ""));
  },
  object(value) {
    const object = JSON.parse(value);
    if (object === null || typeof object != "object" || Array.isArray(object)) {
      throw new TypeError(`expected value of type "object" but instead got value "${value}" of type "${parseValueTypeDefault(object)}"`);
    }
    return object;
  },
  string(value) {
    return value;
  }
};
var writers = {
  default: writeString,
  array: writeJSON,
  object: writeJSON
};
function writeJSON(value) {
  return JSON.stringify(value);
}
function writeString(value) {
  return `${value}`;
}
var Controller = class {
  constructor(context) {
    this.context = context;
  }
  static get shouldLoad() {
    return true;
  }
  static afterLoad(_identifier, _application) {
    return;
  }
  get application() {
    return this.context.application;
  }
  get scope() {
    return this.context.scope;
  }
  get element() {
    return this.scope.element;
  }
  get identifier() {
    return this.scope.identifier;
  }
  get targets() {
    return this.scope.targets;
  }
  get outlets() {
    return this.scope.outlets;
  }
  get classes() {
    return this.scope.classes;
  }
  get data() {
    return this.scope.data;
  }
  initialize() {
  }
  connect() {
  }
  disconnect() {
  }
  dispatch(eventName, { target = this.element, detail = {}, prefix = this.identifier, bubbles = true, cancelable = true } = {}) {
    const type = prefix ? `${prefix}:${eventName}` : eventName;
    const event = new CustomEvent(type, { detail, bubbles, cancelable });
    target.dispatchEvent(event);
    return event;
  }
};
Controller.blessings = [
  ClassPropertiesBlessing,
  TargetPropertiesBlessing,
  ValuePropertiesBlessing,
  OutletPropertiesBlessing
];
Controller.targets = [];
Controller.outlets = [];
Controller.values = {};

// app/javascript/controllers/application.js
var application = Application.start();
application.debug = false;
window.Stimulus = application;

// node_modules/stimulus/dist/stimulus.js
function camelize2(value) {
  return value.replace(/(?:[_-])([a-z0-9])/g, (_, char) => char.toUpperCase());
}
function namespaceCamelize2(value) {
  return camelize2(value.replace(/--/g, "-").replace(/__/g, "_"));
}
function capitalize2(value) {
  return value.charAt(0).toUpperCase() + value.slice(1);
}
function dasherize2(value) {
  return value.replace(/([A-Z])/g, (_, char) => `-${char.toLowerCase()}`);
}
function isSomething2(object) {
  return object !== null && object !== void 0;
}
function hasProperty2(object, property) {
  return Object.prototype.hasOwnProperty.call(object, property);
}
function readInheritableStaticArrayValues2(constructor, propertyName) {
  const ancestors = getAncestorsForConstructor2(constructor);
  return Array.from(ancestors.reduce((values, constructor2) => {
    getOwnStaticArrayValues2(constructor2, propertyName).forEach((name) => values.add(name));
    return values;
  }, /* @__PURE__ */ new Set()));
}
function readInheritableStaticObjectPairs2(constructor, propertyName) {
  const ancestors = getAncestorsForConstructor2(constructor);
  return ancestors.reduce((pairs, constructor2) => {
    pairs.push(...getOwnStaticObjectPairs2(constructor2, propertyName));
    return pairs;
  }, []);
}
function getAncestorsForConstructor2(constructor) {
  const ancestors = [];
  while (constructor) {
    ancestors.push(constructor);
    constructor = Object.getPrototypeOf(constructor);
  }
  return ancestors.reverse();
}
function getOwnStaticArrayValues2(constructor, propertyName) {
  const definition = constructor[propertyName];
  return Array.isArray(definition) ? definition : [];
}
function getOwnStaticObjectPairs2(constructor, propertyName) {
  const definition = constructor[propertyName];
  return definition ? Object.keys(definition).map((key) => [key, definition[key]]) : [];
}
var getOwnKeys2 = (() => {
  if (typeof Object.getOwnPropertySymbols == "function") {
    return (object) => [...Object.getOwnPropertyNames(object), ...Object.getOwnPropertySymbols(object)];
  } else {
    return Object.getOwnPropertyNames;
  }
})();
var extend3 = (() => {
  function extendWithReflect(constructor) {
    function extended() {
      return Reflect.construct(constructor, arguments, new.target);
    }
    extended.prototype = Object.create(constructor.prototype, {
      constructor: { value: extended }
    });
    Reflect.setPrototypeOf(extended, constructor);
    return extended;
  }
  function testReflectExtension() {
    const a = function() {
      this.a.call(this);
    };
    const b = extendWithReflect(a);
    b.prototype.a = function() {
    };
    return new b();
  }
  try {
    testReflectExtension();
    return extendWithReflect;
  } catch (error2) {
    return (constructor) => class extended extends constructor {
    };
  }
})();
var defaultSchema2 = {
  controllerAttribute: "data-controller",
  actionAttribute: "data-action",
  targetAttribute: "data-target",
  targetAttributeForScope: (identifier) => `data-${identifier}-target`,
  outletAttributeForScope: (identifier, outlet) => `data-${identifier}-${outlet}-outlet`,
  keyMappings: Object.assign(Object.assign({ enter: "Enter", tab: "Tab", esc: "Escape", space: " ", up: "ArrowUp", down: "ArrowDown", left: "ArrowLeft", right: "ArrowRight", home: "Home", end: "End", page_up: "PageUp", page_down: "PageDown" }, objectFromEntries2("abcdefghijklmnopqrstuvwxyz".split("").map((c) => [c, c]))), objectFromEntries2("0123456789".split("").map((n) => [n, n])))
};
function objectFromEntries2(array) {
  return array.reduce((memo, [k, v]) => Object.assign(Object.assign({}, memo), { [k]: v }), {});
}
function ClassPropertiesBlessing2(constructor) {
  const classes = readInheritableStaticArrayValues2(constructor, "classes");
  return classes.reduce((properties, classDefinition) => {
    return Object.assign(properties, propertiesForClassDefinition2(classDefinition));
  }, {});
}
function propertiesForClassDefinition2(key) {
  return {
    [`${key}Class`]: {
      get() {
        const { classes } = this;
        if (classes.has(key)) {
          return classes.get(key);
        } else {
          const attribute = classes.getAttributeName(key);
          throw new Error(`Missing attribute "${attribute}"`);
        }
      }
    },
    [`${key}Classes`]: {
      get() {
        return this.classes.getAll(key);
      }
    },
    [`has${capitalize2(key)}Class`]: {
      get() {
        return this.classes.has(key);
      }
    }
  };
}
function OutletPropertiesBlessing2(constructor) {
  const outlets = readInheritableStaticArrayValues2(constructor, "outlets");
  return outlets.reduce((properties, outletDefinition) => {
    return Object.assign(properties, propertiesForOutletDefinition2(outletDefinition));
  }, {});
}
function getOutletController2(controller, element, identifier) {
  return controller.application.getControllerForElementAndIdentifier(element, identifier);
}
function getControllerAndEnsureConnectedScope2(controller, element, outletName) {
  let outletController = getOutletController2(controller, element, outletName);
  if (outletController)
    return outletController;
  controller.application.router.proposeToConnectScopeForElementAndIdentifier(element, outletName);
  outletController = getOutletController2(controller, element, outletName);
  if (outletController)
    return outletController;
}
function propertiesForOutletDefinition2(name) {
  const camelizedName = namespaceCamelize2(name);
  return {
    [`${camelizedName}Outlet`]: {
      get() {
        const outletElement = this.outlets.find(name);
        const selector = this.outlets.getSelectorForOutletName(name);
        if (outletElement) {
          const outletController = getControllerAndEnsureConnectedScope2(this, outletElement, name);
          if (outletController)
            return outletController;
          throw new Error(`The provided outlet element is missing an outlet controller "${name}" instance for host controller "${this.identifier}"`);
        }
        throw new Error(`Missing outlet element "${name}" for host controller "${this.identifier}". Stimulus couldn't find a matching outlet element using selector "${selector}".`);
      }
    },
    [`${camelizedName}Outlets`]: {
      get() {
        const outlets = this.outlets.findAll(name);
        if (outlets.length > 0) {
          return outlets.map((outletElement) => {
            const outletController = getControllerAndEnsureConnectedScope2(this, outletElement, name);
            if (outletController)
              return outletController;
            console.warn(`The provided outlet element is missing an outlet controller "${name}" instance for host controller "${this.identifier}"`, outletElement);
          }).filter((controller) => controller);
        }
        return [];
      }
    },
    [`${camelizedName}OutletElement`]: {
      get() {
        const outletElement = this.outlets.find(name);
        const selector = this.outlets.getSelectorForOutletName(name);
        if (outletElement) {
          return outletElement;
        } else {
          throw new Error(`Missing outlet element "${name}" for host controller "${this.identifier}". Stimulus couldn't find a matching outlet element using selector "${selector}".`);
        }
      }
    },
    [`${camelizedName}OutletElements`]: {
      get() {
        return this.outlets.findAll(name);
      }
    },
    [`has${capitalize2(camelizedName)}Outlet`]: {
      get() {
        return this.outlets.has(name);
      }
    }
  };
}
function TargetPropertiesBlessing2(constructor) {
  const targets = readInheritableStaticArrayValues2(constructor, "targets");
  return targets.reduce((properties, targetDefinition) => {
    return Object.assign(properties, propertiesForTargetDefinition2(targetDefinition));
  }, {});
}
function propertiesForTargetDefinition2(name) {
  return {
    [`${name}Target`]: {
      get() {
        const target = this.targets.find(name);
        if (target) {
          return target;
        } else {
          throw new Error(`Missing target element "${name}" for "${this.identifier}" controller`);
        }
      }
    },
    [`${name}Targets`]: {
      get() {
        return this.targets.findAll(name);
      }
    },
    [`has${capitalize2(name)}Target`]: {
      get() {
        return this.targets.has(name);
      }
    }
  };
}
function ValuePropertiesBlessing2(constructor) {
  const valueDefinitionPairs = readInheritableStaticObjectPairs2(constructor, "values");
  const propertyDescriptorMap = {
    valueDescriptorMap: {
      get() {
        return valueDefinitionPairs.reduce((result, valueDefinitionPair) => {
          const valueDescriptor = parseValueDefinitionPair2(valueDefinitionPair, this.identifier);
          const attributeName = this.data.getAttributeNameForKey(valueDescriptor.key);
          return Object.assign(result, { [attributeName]: valueDescriptor });
        }, {});
      }
    }
  };
  return valueDefinitionPairs.reduce((properties, valueDefinitionPair) => {
    return Object.assign(properties, propertiesForValueDefinitionPair2(valueDefinitionPair));
  }, propertyDescriptorMap);
}
function propertiesForValueDefinitionPair2(valueDefinitionPair, controller) {
  const definition = parseValueDefinitionPair2(valueDefinitionPair, controller);
  const { key, name, reader: read, writer: write } = definition;
  return {
    [name]: {
      get() {
        const value = this.data.get(key);
        if (value !== null) {
          return read(value);
        } else {
          return definition.defaultValue;
        }
      },
      set(value) {
        if (value === void 0) {
          this.data.delete(key);
        } else {
          this.data.set(key, write(value));
        }
      }
    },
    [`has${capitalize2(name)}`]: {
      get() {
        return this.data.has(key) || definition.hasCustomDefaultValue;
      }
    }
  };
}
function parseValueDefinitionPair2([token, typeDefinition], controller) {
  return valueDescriptorForTokenAndTypeDefinition2({
    controller,
    token,
    typeDefinition
  });
}
function parseValueTypeConstant2(constant) {
  switch (constant) {
    case Array:
      return "array";
    case Boolean:
      return "boolean";
    case Number:
      return "number";
    case Object:
      return "object";
    case String:
      return "string";
  }
}
function parseValueTypeDefault2(defaultValue) {
  switch (typeof defaultValue) {
    case "boolean":
      return "boolean";
    case "number":
      return "number";
    case "string":
      return "string";
  }
  if (Array.isArray(defaultValue))
    return "array";
  if (Object.prototype.toString.call(defaultValue) === "[object Object]")
    return "object";
}
function parseValueTypeObject2(payload) {
  const { controller, token, typeObject } = payload;
  const hasType = isSomething2(typeObject.type);
  const hasDefault = isSomething2(typeObject.default);
  const fullObject = hasType && hasDefault;
  const onlyType = hasType && !hasDefault;
  const onlyDefault = !hasType && hasDefault;
  const typeFromObject = parseValueTypeConstant2(typeObject.type);
  const typeFromDefaultValue = parseValueTypeDefault2(payload.typeObject.default);
  if (onlyType)
    return typeFromObject;
  if (onlyDefault)
    return typeFromDefaultValue;
  if (typeFromObject !== typeFromDefaultValue) {
    const propertyPath = controller ? `${controller}.${token}` : token;
    throw new Error(`The specified default value for the Stimulus Value "${propertyPath}" must match the defined type "${typeFromObject}". The provided default value of "${typeObject.default}" is of type "${typeFromDefaultValue}".`);
  }
  if (fullObject)
    return typeFromObject;
}
function parseValueTypeDefinition2(payload) {
  const { controller, token, typeDefinition } = payload;
  const typeObject = { controller, token, typeObject: typeDefinition };
  const typeFromObject = parseValueTypeObject2(typeObject);
  const typeFromDefaultValue = parseValueTypeDefault2(typeDefinition);
  const typeFromConstant = parseValueTypeConstant2(typeDefinition);
  const type = typeFromObject || typeFromDefaultValue || typeFromConstant;
  if (type)
    return type;
  const propertyPath = controller ? `${controller}.${typeDefinition}` : token;
  throw new Error(`Unknown value type "${propertyPath}" for "${token}" value`);
}
function defaultValueForDefinition2(typeDefinition) {
  const constant = parseValueTypeConstant2(typeDefinition);
  if (constant)
    return defaultValuesByType2[constant];
  const hasDefault = hasProperty2(typeDefinition, "default");
  const hasType = hasProperty2(typeDefinition, "type");
  const typeObject = typeDefinition;
  if (hasDefault)
    return typeObject.default;
  if (hasType) {
    const { type } = typeObject;
    const constantFromType = parseValueTypeConstant2(type);
    if (constantFromType)
      return defaultValuesByType2[constantFromType];
  }
  return typeDefinition;
}
function valueDescriptorForTokenAndTypeDefinition2(payload) {
  const { token, typeDefinition } = payload;
  const key = `${dasherize2(token)}-value`;
  const type = parseValueTypeDefinition2(payload);
  return {
    type,
    key,
    name: camelize2(key),
    get defaultValue() {
      return defaultValueForDefinition2(typeDefinition);
    },
    get hasCustomDefaultValue() {
      return parseValueTypeDefault2(typeDefinition) !== void 0;
    },
    reader: readers2[type],
    writer: writers2[type] || writers2.default
  };
}
var defaultValuesByType2 = {
  get array() {
    return [];
  },
  boolean: false,
  number: 0,
  get object() {
    return {};
  },
  string: ""
};
var readers2 = {
  array(value) {
    const array = JSON.parse(value);
    if (!Array.isArray(array)) {
      throw new TypeError(`expected value of type "array" but instead got value "${value}" of type "${parseValueTypeDefault2(array)}"`);
    }
    return array;
  },
  boolean(value) {
    return !(value == "0" || String(value).toLowerCase() == "false");
  },
  number(value) {
    return Number(value.replace(/_/g, ""));
  },
  object(value) {
    const object = JSON.parse(value);
    if (object === null || typeof object != "object" || Array.isArray(object)) {
      throw new TypeError(`expected value of type "object" but instead got value "${value}" of type "${parseValueTypeDefault2(object)}"`);
    }
    return object;
  },
  string(value) {
    return value;
  }
};
var writers2 = {
  default: writeString2,
  array: writeJSON2,
  object: writeJSON2
};
function writeJSON2(value) {
  return JSON.stringify(value);
}
function writeString2(value) {
  return `${value}`;
}
var Controller2 = class {
  constructor(context) {
    this.context = context;
  }
  static get shouldLoad() {
    return true;
  }
  static afterLoad(_identifier, _application) {
    return;
  }
  get application() {
    return this.context.application;
  }
  get scope() {
    return this.context.scope;
  }
  get element() {
    return this.scope.element;
  }
  get identifier() {
    return this.scope.identifier;
  }
  get targets() {
    return this.scope.targets;
  }
  get outlets() {
    return this.scope.outlets;
  }
  get classes() {
    return this.scope.classes;
  }
  get data() {
    return this.scope.data;
  }
  initialize() {
  }
  connect() {
  }
  disconnect() {
  }
  dispatch(eventName, { target = this.element, detail = {}, prefix = this.identifier, bubbles = true, cancelable = true } = {}) {
    const type = prefix ? `${prefix}:${eventName}` : eventName;
    const event = new CustomEvent(type, { detail, bubbles, cancelable });
    target.dispatchEvent(event);
    return event;
  }
};
Controller2.blessings = [
  ClassPropertiesBlessing2,
  TargetPropertiesBlessing2,
  ValuePropertiesBlessing2,
  OutletPropertiesBlessing2
];
Controller2.targets = [];
Controller2.outlets = [];
Controller2.values = {};

// app/javascript/controllers/alerts_controller.js
var alerts_controller_default = class extends Controller2 {
  static targets = ["alert"];
  connect() {
    this.autoHide();
  }
  autoHide() {
    setTimeout(() => {
      this.alertTargets.forEach((alert) => {
        alert.style.display = "none";
      });
    }, 3e3);
  }
  hide(event) {
    event.target.closest(".alert").style.display = "none";
  }
};

// app/javascript/controllers/dropdown_controller.js
var dropdown_controller_default = class extends Controller2 {
  static targets = ["menu"];
  connect() {
    this.isOpen = false;
  }
  toggle() {
    this.isOpen = !this.isOpen;
    this.menuTarget.classList.toggle("hidden", !this.isOpen);
  }
};

// app/javascript/controllers/hello_controller.js
var hello_controller_default = class extends Controller {
  connect() {
    this.element.textContent = "Hello World!";
  }
};

// app/javascript/controllers/modal_controller.js
var modal_controller_default = class extends Controller2 {
  static targets = ["modal"];
  connect() {
  }
  close(event) {
    if (event && event.currentTarget.tagName === "BUTTON") {
      this.modalTarget.remove();
    }
  }
};

// app/javascript/controllers/multiselect_controller.js
var import_slim_select = __toESM(require_slimselect());
var multiselect_controller_default = class extends Controller {
  static targets = ["rows", "selectedContainerList"];
  connect() {
    this.selectedIds = [];
    this.initializeSelectedIds();
    this.initializeSlimSelect();
  }
  initializeSelectedIds() {
    const existingIds = document.getElementById("disposal_container_ids").value.split(",");
    this.selectedIds = existingIds.filter((id) => id);
  }
  initializeSlimSelect() {
    this.slimSelect = new import_slim_select.default({
      select: "#container-multiselect",
      showSearch: true,
      settings: {
        allowDeselect: true
      },
      onChange: (info) => {
        this.addRow(info);
      }
    });
    this.element.querySelector("#container-multiselect").addEventListener("change", this.addRow.bind(this));
  }
  addRow(info) {
    const containerId = info.value;
    const containerName = info.text;
    if (containerId && !this.selectedIds.includes(containerId)) {
      const tag = document.createElement("div");
      tag.classList.add(
        "flex",
        "items-center",
        "bg-red-100",
        "border",
        "border-red-200",
        "text-red-600",
        "px-2",
        "py-1",
        "rounded-full",
        "mr-1",
        "mb-1"
      );
      tag.setAttribute("data-multiselect-id", containerId);
      tag.innerHTML = `
        ${containerName}
        <button type="button" class="ml-2 text-red-600" data-action="multiselect#removeTag" data-multiselect-id="${containerId}">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 9.293l3.293-3.293a1 1 0 011.414 0l.086.086a1 1 0 010 1.414L11.414 10l3.293 3.293a1 1 0 01.086 1.32l-.086.086a1 1 0 01-1.414 0L10 11.414l-3.293 3.293a1 1 0 01-1.32.086l-.086-.086a1 1 0 010-1.414L8.586 10 5.293 6.707a1 1 0 01-.086-1.32l.086-.086a1 1 0 011.414 0L10 8.586z" clip-rule="evenodd" />
          </svg>
        </button>
      `;
      this.selectedContainerListTarget.appendChild(tag);
      const row = document.createElement("div");
      row.classList.add(
        "bg-gray-100",
        "border",
        "rounded",
        "p-4",
        "flex",
        "items-center",
        "space-x-4",
        "mt-2"
      );
      row.setAttribute("data-multiselect-id", containerId);
      row.innerHTML = `
        <span class="text-red-600">${containerName}</span>
        <label class="flex items-center">
          MXI Cost: $
          <input type="number" name="disposal_cost[disposal_containers_attributes][${containerId}][mxi_cost]" class="ml-2 border rounded py-1 px-2" required>
        </label>
        <label class="flex items-center">
          Client Charge: $
          <input type="number" name="disposal_cost[disposal_containers_attributes][${containerId}][client_charge]" class="ml-2 border rounded py-1 px-2" required>
        </label>
        <input type="hidden" name="disposal_cost[disposal_containers_attributes][${containerId}][name]" value="${containerName}">
        <input type="hidden" name="disposal_cost[disposal_containers_attributes][${containerId}][_destroy]" value="false">
      `;
      this.rowsTarget.appendChild(row);
      this.selectedIds.push(containerId);
      document.getElementById("disposal_container_ids").value = this.selectedIds.join(",");
      this.slimSelect.set("");
    }
  }
  removeTag(event) {
    const containerId = event.currentTarget.getAttribute("data-multiselect-id");
    const tag = this.selectedContainerListTarget.querySelector(
      `[data-multiselect-id="${containerId}"]`
    );
    if (tag) {
      tag.remove();
    }
    const row = this.rowsTarget.querySelector(
      `[data-multiselect-id="${containerId}"]`
    );
    if (row) {
      row.remove();
    }
    this.selectedIds = this.selectedIds.filter((id) => id !== containerId);
    document.getElementById("disposal_container_ids").value = this.selectedIds.join(",");
  }
};

// node_modules/stimulus-rails-nested-form/dist/stimulus-rails-nested-form.mjs
var r = class extends Controller {
  add(t) {
    t.preventDefault();
    const e = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, (/* @__PURE__ */ new Date()).getTime().toString());
    this.targetTarget.insertAdjacentHTML("beforebegin", e);
  }
  remove(t) {
    t.preventDefault();
    const e = t.target.closest(this.wrapperSelectorValue);
    if (e.dataset.newRecord === "true")
      e.remove();
    else {
      e.style.display = "none";
      const a = e.querySelector("input[name*='_destroy']");
      a.value = "1";
    }
  }
};
r.targets = ["target", "template"];
r.values = {
  wrapperSelector: {
    type: String,
    default: ".nested-form-wrapper"
  }
};

// app/javascript/controllers/nested_form_controller.js
var nested_form_controller_default = class extends r {
  connect() {
    super.connect();
  }
};

// app/javascript/controllers/phone_format_controller.js
var phone_format_controller_default = class extends Controller2 {
  static targets = ["input"];
  connect() {
    this.inputTarget.addEventListener(
      "input",
      this.formatPhoneNumber.bind(this)
    );
  }
  formatPhoneNumber(event) {
    let input = event.target.value.replace(/\D/g, "");
    if (input.length > 10) {
      input = input.substring(0, 10);
    }
    let formatted = "";
    if (input.length > 0) {
      formatted += `+1 `;
    }
    if (input.length > 0) {
      formatted += `(${input.substring(0, 3)}`;
    }
    if (input.length >= 4) {
      formatted += `) ${input.substring(3, 6)}`;
    }
    if (input.length >= 7) {
      formatted += `-${input.substring(6, 10)}`;
    }
    this.inputTarget.value = formatted;
  }
};

// app/javascript/controllers/searchable_dropdown_controller.js
var searchable_dropdown_controller_default = class extends Controller {
  static targets = ["input", "list", "option"];
  connect() {
    this.inputTarget.addEventListener("input", this.filterOptions.bind(this));
  }
  filterOptions() {
    const query = this.inputTarget.value.toLowerCase();
    if (query === "") {
      this.hideList();
    } else {
      this.showList();
      this.optionTargets.forEach((option) => {
        const text = option.textContent.toLowerCase();
        option.style.display = text.includes(query) ? "block" : "none";
      });
    }
  }
  showList() {
    this.listTarget.style.display = "block";
  }
  hideList() {
    this.listTarget.style.display = "none";
  }
};

// node_modules/tom-select/dist/esm/contrib/microevent.js
function forEvents(events, callback) {
  events.split(/\s+/).forEach((event) => {
    callback(event);
  });
}
var MicroEvent = class {
  constructor() {
    this._events = {};
  }
  on(events, fct) {
    forEvents(events, (event) => {
      const event_array = this._events[event] || [];
      event_array.push(fct);
      this._events[event] = event_array;
    });
  }
  off(events, fct) {
    var n = arguments.length;
    if (n === 0) {
      this._events = {};
      return;
    }
    forEvents(events, (event) => {
      if (n === 1) {
        delete this._events[event];
        return;
      }
      const event_array = this._events[event];
      if (event_array === void 0)
        return;
      event_array.splice(event_array.indexOf(fct), 1);
      this._events[event] = event_array;
    });
  }
  trigger(events, ...args) {
    var self2 = this;
    forEvents(events, (event) => {
      const event_array = self2._events[event];
      if (event_array === void 0)
        return;
      event_array.forEach((fct) => {
        fct.apply(self2, args);
      });
    });
  }
};

// node_modules/tom-select/dist/esm/contrib/microplugin.js
function MicroPlugin(Interface) {
  Interface.plugins = {};
  return class extends Interface {
    constructor() {
      super(...arguments);
      this.plugins = {
        names: [],
        settings: {},
        requested: {},
        loaded: {}
      };
    }
    /**
     * Registers a plugin.
     *
     * @param {function} fn
     */
    static define(name, fn) {
      Interface.plugins[name] = {
        "name": name,
        "fn": fn
      };
    }
    /**
     * Initializes the listed plugins (with options).
     * Acceptable formats:
     *
     * List (without options):
     *   ['a', 'b', 'c']
     *
     * List (with options):
     *   [{'name': 'a', options: {}}, {'name': 'b', options: {}}]
     *
     * Hash (with options):
     *   {'a': { ... }, 'b': { ... }, 'c': { ... }}
     *
     * @param {array|object} plugins
     */
    initializePlugins(plugins) {
      var key, name;
      const self2 = this;
      const queue = [];
      if (Array.isArray(plugins)) {
        plugins.forEach((plugin15) => {
          if (typeof plugin15 === "string") {
            queue.push(plugin15);
          } else {
            self2.plugins.settings[plugin15.name] = plugin15.options;
            queue.push(plugin15.name);
          }
        });
      } else if (plugins) {
        for (key in plugins) {
          if (plugins.hasOwnProperty(key)) {
            self2.plugins.settings[key] = plugins[key];
            queue.push(key);
          }
        }
      }
      while (name = queue.shift()) {
        self2.require(name);
      }
    }
    loadPlugin(name) {
      var self2 = this;
      var plugins = self2.plugins;
      var plugin15 = Interface.plugins[name];
      if (!Interface.plugins.hasOwnProperty(name)) {
        throw new Error('Unable to find "' + name + '" plugin');
      }
      plugins.requested[name] = true;
      plugins.loaded[name] = plugin15.fn.apply(self2, [self2.plugins.settings[name] || {}]);
      plugins.names.push(name);
    }
    /**
     * Initializes a plugin.
     *
     */
    require(name) {
      var self2 = this;
      var plugins = self2.plugins;
      if (!self2.plugins.loaded.hasOwnProperty(name)) {
        if (plugins.requested[name]) {
          throw new Error('Plugin has circular dependency ("' + name + '")');
        }
        self2.loadPlugin(name);
      }
      return plugins.loaded[name];
    }
  };
}

// node_modules/@orchidjs/unicode-variants/dist/esm/regex.js
var arrayToPattern = (chars) => {
  chars = chars.filter(Boolean);
  if (chars.length < 2) {
    return chars[0] || "";
  }
  return maxValueLength(chars) == 1 ? "[" + chars.join("") + "]" : "(?:" + chars.join("|") + ")";
};
var sequencePattern = (array) => {
  if (!hasDuplicates(array)) {
    return array.join("");
  }
  let pattern = "";
  let prev_char_count = 0;
  const prev_pattern = () => {
    if (prev_char_count > 1) {
      pattern += "{" + prev_char_count + "}";
    }
  };
  array.forEach((char, i) => {
    if (char === array[i - 1]) {
      prev_char_count++;
      return;
    }
    prev_pattern();
    pattern += char;
    prev_char_count = 1;
  });
  prev_pattern();
  return pattern;
};
var setToPattern = (chars) => {
  let array = Array.from(chars);
  return arrayToPattern(array);
};
var hasDuplicates = (array) => {
  return new Set(array).size !== array.length;
};
var escape_regex = (str) => {
  return (str + "").replace(/([\$\(\)\*\+\.\?\[\]\^\{\|\}\\])/gu, "\\$1");
};
var maxValueLength = (array) => {
  return array.reduce((longest, value) => Math.max(longest, unicodeLength(value)), 0);
};
var unicodeLength = (str) => {
  return Array.from(str).length;
};

// node_modules/@orchidjs/unicode-variants/dist/esm/strings.js
var allSubstrings = (input) => {
  if (input.length === 1)
    return [[input]];
  let result = [];
  const start2 = input.substring(1);
  const suba = allSubstrings(start2);
  suba.forEach(function(subresult) {
    let tmp = subresult.slice(0);
    tmp[0] = input.charAt(0) + tmp[0];
    result.push(tmp);
    tmp = subresult.slice(0);
    tmp.unshift(input.charAt(0));
    result.push(tmp);
  });
  return result;
};

// node_modules/@orchidjs/unicode-variants/dist/esm/index.js
var code_points = [[0, 65535]];
var accent_pat = "[\u0300-\u036F\xB7\u02BE\u02BC]";
var unicode_map;
var multi_char_reg;
var max_char_length = 3;
var latin_convert = {};
var latin_condensed = {
  "/": "\u2044\u2215",
  "0": "\u07C0",
  "a": "\u2C65\u0250\u0251",
  "aa": "\uA733",
  "ae": "\xE6\u01FD\u01E3",
  "ao": "\uA735",
  "au": "\uA737",
  "av": "\uA739\uA73B",
  "ay": "\uA73D",
  "b": "\u0180\u0253\u0183",
  "c": "\uA73F\u0188\u023C\u2184",
  "d": "\u0111\u0257\u0256\u1D05\u018C\uABB7\u0501\u0266",
  "e": "\u025B\u01DD\u1D07\u0247",
  "f": "\uA77C\u0192",
  "g": "\u01E5\u0260\uA7A1\u1D79\uA77F\u0262",
  "h": "\u0127\u2C68\u2C76\u0265",
  "i": "\u0268\u0131",
  "j": "\u0249\u0237",
  "k": "\u0199\u2C6A\uA741\uA743\uA745\uA7A3",
  "l": "\u0142\u019A\u026B\u2C61\uA749\uA747\uA781\u026D",
  "m": "\u0271\u026F\u03FB",
  "n": "\uA7A5\u019E\u0272\uA791\u1D0E\u043B\u0509",
  "o": "\xF8\u01FF\u0254\u0275\uA74B\uA74D\u1D11",
  "oe": "\u0153",
  "oi": "\u01A3",
  "oo": "\uA74F",
  "ou": "\u0223",
  "p": "\u01A5\u1D7D\uA751\uA753\uA755\u03C1",
  "q": "\uA757\uA759\u024B",
  "r": "\u024D\u027D\uA75B\uA7A7\uA783",
  "s": "\xDF\u023F\uA7A9\uA785\u0282",
  "t": "\u0167\u01AD\u0288\u2C66\uA787",
  "th": "\xFE",
  "tz": "\uA729",
  "u": "\u0289",
  "v": "\u028B\uA75F\u028C",
  "vy": "\uA761",
  "w": "\u2C73",
  "y": "\u01B4\u024F\u1EFF",
  "z": "\u01B6\u0225\u0240\u2C6C\uA763",
  "hv": "\u0195"
};
for (let latin in latin_condensed) {
  let unicode = latin_condensed[latin] || "";
  for (let i = 0; i < unicode.length; i++) {
    let char = unicode.substring(i, i + 1);
    latin_convert[char] = latin;
  }
}
var convert_pat = new RegExp(Object.keys(latin_convert).join("|") + "|" + accent_pat, "gu");
var initialize = (_code_points) => {
  if (unicode_map !== void 0)
    return;
  unicode_map = generateMap(_code_points || code_points);
};
var normalize = (str, form = "NFKD") => str.normalize(form);
var asciifold = (str) => {
  return Array.from(str).reduce(
    /**
     * @param {string} result
     * @param {string} char
     */
    (result, char) => {
      return result + _asciifold(char);
    },
    ""
  );
};
var _asciifold = (str) => {
  str = normalize(str).toLowerCase().replace(convert_pat, (char) => {
    return latin_convert[char] || "";
  });
  return normalize(str, "NFC");
};
function* generator(code_points2) {
  for (const [code_point_min, code_point_max] of code_points2) {
    for (let i = code_point_min; i <= code_point_max; i++) {
      let composed = String.fromCharCode(i);
      let folded = asciifold(composed);
      if (folded == composed.toLowerCase()) {
        continue;
      }
      if (folded.length > max_char_length) {
        continue;
      }
      if (folded.length == 0) {
        continue;
      }
      yield { folded, composed, code_point: i };
    }
  }
}
var generateSets = (code_points2) => {
  const unicode_sets = {};
  const addMatching = (folded, to_add) => {
    const folded_set = unicode_sets[folded] || /* @__PURE__ */ new Set();
    const patt = new RegExp("^" + setToPattern(folded_set) + "$", "iu");
    if (to_add.match(patt)) {
      return;
    }
    folded_set.add(escape_regex(to_add));
    unicode_sets[folded] = folded_set;
  };
  for (let value of generator(code_points2)) {
    addMatching(value.folded, value.folded);
    addMatching(value.folded, value.composed);
  }
  return unicode_sets;
};
var generateMap = (code_points2) => {
  const unicode_sets = generateSets(code_points2);
  const unicode_map2 = {};
  let multi_char = [];
  for (let folded in unicode_sets) {
    let set = unicode_sets[folded];
    if (set) {
      unicode_map2[folded] = setToPattern(set);
    }
    if (folded.length > 1) {
      multi_char.push(escape_regex(folded));
    }
  }
  multi_char.sort((a, b) => b.length - a.length);
  const multi_char_patt = arrayToPattern(multi_char);
  multi_char_reg = new RegExp("^" + multi_char_patt, "u");
  return unicode_map2;
};
var mapSequence = (strings, min_replacement = 1) => {
  let chars_replaced = 0;
  strings = strings.map((str) => {
    if (unicode_map[str]) {
      chars_replaced += str.length;
    }
    return unicode_map[str] || str;
  });
  if (chars_replaced >= min_replacement) {
    return sequencePattern(strings);
  }
  return "";
};
var substringsToPattern = (str, min_replacement = 1) => {
  min_replacement = Math.max(min_replacement, str.length - 1);
  return arrayToPattern(allSubstrings(str).map((sub_pat) => {
    return mapSequence(sub_pat, min_replacement);
  }));
};
var sequencesToPattern = (sequences, all = true) => {
  let min_replacement = sequences.length > 1 ? 1 : 0;
  return arrayToPattern(sequences.map((sequence) => {
    let seq = [];
    const len = all ? sequence.length() : sequence.length() - 1;
    for (let j = 0; j < len; j++) {
      seq.push(substringsToPattern(sequence.substrs[j] || "", min_replacement));
    }
    return sequencePattern(seq);
  }));
};
var inSequences = (needle_seq, sequences) => {
  for (const seq of sequences) {
    if (seq.start != needle_seq.start || seq.end != needle_seq.end) {
      continue;
    }
    if (seq.substrs.join("") !== needle_seq.substrs.join("")) {
      continue;
    }
    let needle_parts = needle_seq.parts;
    const filter = (part) => {
      for (const needle_part of needle_parts) {
        if (needle_part.start === part.start && needle_part.substr === part.substr) {
          return false;
        }
        if (part.length == 1 || needle_part.length == 1) {
          continue;
        }
        if (part.start < needle_part.start && part.end > needle_part.start) {
          return true;
        }
        if (needle_part.start < part.start && needle_part.end > part.start) {
          return true;
        }
      }
      return false;
    };
    let filtered = seq.parts.filter(filter);
    if (filtered.length > 0) {
      continue;
    }
    return true;
  }
  return false;
};
var Sequence = class _Sequence {
  parts;
  substrs;
  start;
  end;
  constructor() {
    this.parts = [];
    this.substrs = [];
    this.start = 0;
    this.end = 0;
  }
  add(part) {
    if (part) {
      this.parts.push(part);
      this.substrs.push(part.substr);
      this.start = Math.min(part.start, this.start);
      this.end = Math.max(part.end, this.end);
    }
  }
  last() {
    return this.parts[this.parts.length - 1];
  }
  length() {
    return this.parts.length;
  }
  clone(position, last_piece) {
    let clone = new _Sequence();
    let parts = JSON.parse(JSON.stringify(this.parts));
    let last_part = parts.pop();
    for (const part of parts) {
      clone.add(part);
    }
    let last_substr = last_piece.substr.substring(0, position - last_part.start);
    let clone_last_len = last_substr.length;
    clone.add({ start: last_part.start, end: last_part.start + clone_last_len, length: clone_last_len, substr: last_substr });
    return clone;
  }
};
var getPattern = (str) => {
  initialize();
  str = asciifold(str);
  let pattern = "";
  let sequences = [new Sequence()];
  for (let i = 0; i < str.length; i++) {
    let substr = str.substring(i);
    let match = substr.match(multi_char_reg);
    const char = str.substring(i, i + 1);
    const match_str = match ? match[0] : null;
    let overlapping = [];
    let added_types = /* @__PURE__ */ new Set();
    for (const sequence of sequences) {
      const last_piece = sequence.last();
      if (!last_piece || last_piece.length == 1 || last_piece.end <= i) {
        if (match_str) {
          const len = match_str.length;
          sequence.add({ start: i, end: i + len, length: len, substr: match_str });
          added_types.add("1");
        } else {
          sequence.add({ start: i, end: i + 1, length: 1, substr: char });
          added_types.add("2");
        }
      } else if (match_str) {
        let clone = sequence.clone(i, last_piece);
        const len = match_str.length;
        clone.add({ start: i, end: i + len, length: len, substr: match_str });
        overlapping.push(clone);
      } else {
        added_types.add("3");
      }
    }
    if (overlapping.length > 0) {
      overlapping = overlapping.sort((a, b) => {
        return a.length() - b.length();
      });
      for (let clone of overlapping) {
        if (inSequences(clone, sequences)) {
          continue;
        }
        sequences.push(clone);
      }
      continue;
    }
    if (i > 0 && added_types.size == 1 && !added_types.has("3")) {
      pattern += sequencesToPattern(sequences, false);
      let new_seq = new Sequence();
      const old_seq = sequences[0];
      if (old_seq) {
        new_seq.add(old_seq.last());
      }
      sequences = [new_seq];
    }
  }
  pattern += sequencesToPattern(sequences, true);
  return pattern;
};

// node_modules/@orchidjs/sifter/dist/esm/utils.js
var getAttr = (obj, name) => {
  if (!obj)
    return;
  return obj[name];
};
var getAttrNesting = (obj, name) => {
  if (!obj)
    return;
  var part, names = name.split(".");
  while ((part = names.shift()) && (obj = obj[part]))
    ;
  return obj;
};
var scoreValue = (value, token, weight) => {
  var score, pos;
  if (!value)
    return 0;
  value = value + "";
  if (token.regex == null)
    return 0;
  pos = value.search(token.regex);
  if (pos === -1)
    return 0;
  score = token.string.length / value.length;
  if (pos === 0)
    score += 0.5;
  return score * weight;
};
var propToArray = (obj, key) => {
  var value = obj[key];
  if (typeof value == "function")
    return value;
  if (value && !Array.isArray(value)) {
    obj[key] = [value];
  }
};
var iterate = (object, callback) => {
  if (Array.isArray(object)) {
    object.forEach(callback);
  } else {
    for (var key in object) {
      if (object.hasOwnProperty(key)) {
        callback(object[key], key);
      }
    }
  }
};
var cmp = (a, b) => {
  if (typeof a === "number" && typeof b === "number") {
    return a > b ? 1 : a < b ? -1 : 0;
  }
  a = asciifold(a + "").toLowerCase();
  b = asciifold(b + "").toLowerCase();
  if (a > b)
    return 1;
  if (b > a)
    return -1;
  return 0;
};

// node_modules/@orchidjs/sifter/dist/esm/sifter.js
var Sifter = class {
  items;
  // []|{};
  settings;
  /**
   * Textually searches arrays and hashes of objects
   * by property (or multiple properties). Designed
   * specifically for autocomplete.
   *
   */
  constructor(items, settings) {
    this.items = items;
    this.settings = settings || { diacritics: true };
  }
  /**
   * Splits a search string into an array of individual
   * regexps to be used to match results.
   *
   */
  tokenize(query, respect_word_boundaries, weights) {
    if (!query || !query.length)
      return [];
    const tokens = [];
    const words = query.split(/\s+/);
    var field_regex;
    if (weights) {
      field_regex = new RegExp("^(" + Object.keys(weights).map(escape_regex).join("|") + "):(.*)$");
    }
    words.forEach((word) => {
      let field_match;
      let field = null;
      let regex = null;
      if (field_regex && (field_match = word.match(field_regex))) {
        field = field_match[1];
        word = field_match[2];
      }
      if (word.length > 0) {
        if (this.settings.diacritics) {
          regex = getPattern(word) || null;
        } else {
          regex = escape_regex(word);
        }
        if (regex && respect_word_boundaries)
          regex = "\\b" + regex;
      }
      tokens.push({
        string: word,
        regex: regex ? new RegExp(regex, "iu") : null,
        field
      });
    });
    return tokens;
  }
  /**
   * Returns a function to be used to score individual results.
   *
   * Good matches will have a higher score than poor matches.
   * If an item is not a match, 0 will be returned by the function.
   *
   * @returns {T.ScoreFn}
   */
  getScoreFunction(query, options) {
    var search = this.prepareSearch(query, options);
    return this._getScoreFunction(search);
  }
  /**
   * @returns {T.ScoreFn}
   *
   */
  _getScoreFunction(search) {
    const tokens = search.tokens, token_count = tokens.length;
    if (!token_count) {
      return function() {
        return 0;
      };
    }
    const fields = search.options.fields, weights = search.weights, field_count = fields.length, getAttrFn = search.getAttrFn;
    if (!field_count) {
      return function() {
        return 1;
      };
    }
    const scoreObject = function() {
      if (field_count === 1) {
        return function(token, data) {
          const field = fields[0].field;
          return scoreValue(getAttrFn(data, field), token, weights[field] || 1);
        };
      }
      return function(token, data) {
        var sum = 0;
        if (token.field) {
          const value = getAttrFn(data, token.field);
          if (!token.regex && value) {
            sum += 1 / field_count;
          } else {
            sum += scoreValue(value, token, 1);
          }
        } else {
          iterate(weights, (weight, field) => {
            sum += scoreValue(getAttrFn(data, field), token, weight);
          });
        }
        return sum / field_count;
      };
    }();
    if (token_count === 1) {
      return function(data) {
        return scoreObject(tokens[0], data);
      };
    }
    if (search.options.conjunction === "and") {
      return function(data) {
        var score, sum = 0;
        for (let token of tokens) {
          score = scoreObject(token, data);
          if (score <= 0)
            return 0;
          sum += score;
        }
        return sum / token_count;
      };
    } else {
      return function(data) {
        var sum = 0;
        iterate(tokens, (token) => {
          sum += scoreObject(token, data);
        });
        return sum / token_count;
      };
    }
  }
  /**
   * Returns a function that can be used to compare two
   * results, for sorting purposes. If no sorting should
   * be performed, `null` will be returned.
   *
   * @return function(a,b)
   */
  getSortFunction(query, options) {
    var search = this.prepareSearch(query, options);
    return this._getSortFunction(search);
  }
  _getSortFunction(search) {
    var implicit_score, sort_flds = [];
    const self2 = this, options = search.options, sort = !search.query && options.sort_empty ? options.sort_empty : options.sort;
    if (typeof sort == "function") {
      return sort.bind(this);
    }
    const get_field = function(name, result) {
      if (name === "$score")
        return result.score;
      return search.getAttrFn(self2.items[result.id], name);
    };
    if (sort) {
      for (let s of sort) {
        if (search.query || s.field !== "$score") {
          sort_flds.push(s);
        }
      }
    }
    if (search.query) {
      implicit_score = true;
      for (let fld of sort_flds) {
        if (fld.field === "$score") {
          implicit_score = false;
          break;
        }
      }
      if (implicit_score) {
        sort_flds.unshift({ field: "$score", direction: "desc" });
      }
    } else {
      sort_flds = sort_flds.filter((fld) => fld.field !== "$score");
    }
    const sort_flds_count = sort_flds.length;
    if (!sort_flds_count) {
      return null;
    }
    return function(a, b) {
      var result, field;
      for (let sort_fld of sort_flds) {
        field = sort_fld.field;
        let multiplier = sort_fld.direction === "desc" ? -1 : 1;
        result = multiplier * cmp(get_field(field, a), get_field(field, b));
        if (result)
          return result;
      }
      return 0;
    };
  }
  /**
   * Parses a search query and returns an object
   * with tokens and fields ready to be populated
   * with results.
   *
   */
  prepareSearch(query, optsUser) {
    const weights = {};
    var options = Object.assign({}, optsUser);
    propToArray(options, "sort");
    propToArray(options, "sort_empty");
    if (options.fields) {
      propToArray(options, "fields");
      const fields = [];
      options.fields.forEach((field) => {
        if (typeof field == "string") {
          field = { field, weight: 1 };
        }
        fields.push(field);
        weights[field.field] = "weight" in field ? field.weight : 1;
      });
      options.fields = fields;
    }
    return {
      options,
      query: query.toLowerCase().trim(),
      tokens: this.tokenize(query, options.respect_word_boundaries, weights),
      total: 0,
      items: [],
      weights,
      getAttrFn: options.nesting ? getAttrNesting : getAttr
    };
  }
  /**
   * Searches through all items and returns a sorted array of matches.
   *
   */
  search(query, options) {
    var self2 = this, score, search;
    search = this.prepareSearch(query, options);
    options = search.options;
    query = search.query;
    const fn_score = options.score || self2._getScoreFunction(search);
    if (query.length) {
      iterate(self2.items, (item, id) => {
        score = fn_score(item);
        if (options.filter === false || score > 0) {
          search.items.push({ "score": score, "id": id });
        }
      });
    } else {
      iterate(self2.items, (_, id) => {
        search.items.push({ "score": 1, "id": id });
      });
    }
    const fn_sort = self2._getSortFunction(search);
    if (fn_sort)
      search.items.sort(fn_sort);
    search.total = search.items.length;
    if (typeof options.limit === "number") {
      search.items = search.items.slice(0, options.limit);
    }
    return search;
  }
};

// node_modules/tom-select/dist/esm/utils.js
var hash_key = (value) => {
  if (typeof value === "undefined" || value === null)
    return null;
  return get_hash(value);
};
var get_hash = (value) => {
  if (typeof value === "boolean")
    return value ? "1" : "0";
  return value + "";
};
var escape_html = (str) => {
  return (str + "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
};
var timeout = (fn, timeout2) => {
  if (timeout2 > 0) {
    return window.setTimeout(fn, timeout2);
  }
  fn.call(null);
  return null;
};
var loadDebounce = (fn, delay) => {
  var timeout2;
  return function(value, callback) {
    var self2 = this;
    if (timeout2) {
      self2.loading = Math.max(self2.loading - 1, 0);
      clearTimeout(timeout2);
    }
    timeout2 = setTimeout(function() {
      timeout2 = null;
      self2.loadedSearches[value] = true;
      fn.call(self2, value, callback);
    }, delay);
  };
};
var debounce_events = (self2, types, fn) => {
  var type;
  var trigger = self2.trigger;
  var event_args = {};
  self2.trigger = function() {
    var type2 = arguments[0];
    if (types.indexOf(type2) !== -1) {
      event_args[type2] = arguments;
    } else {
      return trigger.apply(self2, arguments);
    }
  };
  fn.apply(self2, []);
  self2.trigger = trigger;
  for (type of types) {
    if (type in event_args) {
      trigger.apply(self2, event_args[type]);
    }
  }
};
var getSelection = (input) => {
  return {
    start: input.selectionStart || 0,
    length: (input.selectionEnd || 0) - (input.selectionStart || 0)
  };
};
var preventDefault = (evt, stop = false) => {
  if (evt) {
    evt.preventDefault();
    if (stop) {
      evt.stopPropagation();
    }
  }
};
var addEvent = (target, type, callback, options) => {
  target.addEventListener(type, callback, options);
};
var isKeyDown = (key_name, evt) => {
  if (!evt) {
    return false;
  }
  if (!evt[key_name]) {
    return false;
  }
  var count = (evt.altKey ? 1 : 0) + (evt.ctrlKey ? 1 : 0) + (evt.shiftKey ? 1 : 0) + (evt.metaKey ? 1 : 0);
  if (count === 1) {
    return true;
  }
  return false;
};
var getId = (el, id) => {
  const existing_id = el.getAttribute("id");
  if (existing_id) {
    return existing_id;
  }
  el.setAttribute("id", id);
  return id;
};
var addSlashes = (str) => {
  return str.replace(/[\\"']/g, "\\$&");
};
var append = (parent, node) => {
  if (node)
    parent.append(node);
};
var iterate2 = (object, callback) => {
  if (Array.isArray(object)) {
    object.forEach(callback);
  } else {
    for (var key in object) {
      if (object.hasOwnProperty(key)) {
        callback(object[key], key);
      }
    }
  }
};

// node_modules/tom-select/dist/esm/vanilla.js
var getDom = (query) => {
  if (query.jquery) {
    return query[0];
  }
  if (query instanceof HTMLElement) {
    return query;
  }
  if (isHtmlString(query)) {
    var tpl = document.createElement("template");
    tpl.innerHTML = query.trim();
    return tpl.content.firstChild;
  }
  return document.querySelector(query);
};
var isHtmlString = (arg) => {
  if (typeof arg === "string" && arg.indexOf("<") > -1) {
    return true;
  }
  return false;
};
var escapeQuery = (query) => {
  return query.replace(/['"\\]/g, "\\$&");
};
var triggerEvent = (dom_el, event_name) => {
  var event = document.createEvent("HTMLEvents");
  event.initEvent(event_name, true, false);
  dom_el.dispatchEvent(event);
};
var applyCSS = (dom_el, css) => {
  Object.assign(dom_el.style, css);
};
var addClasses = (elmts, ...classes) => {
  var norm_classes = classesArray(classes);
  elmts = castAsArray(elmts);
  elmts.map((el) => {
    norm_classes.map((cls) => {
      el.classList.add(cls);
    });
  });
};
var removeClasses = (elmts, ...classes) => {
  var norm_classes = classesArray(classes);
  elmts = castAsArray(elmts);
  elmts.map((el) => {
    norm_classes.map((cls) => {
      el.classList.remove(cls);
    });
  });
};
var classesArray = (args) => {
  var classes = [];
  iterate2(args, (_classes) => {
    if (typeof _classes === "string") {
      _classes = _classes.trim().split(/[\t\n\f\r\s]/);
    }
    if (Array.isArray(_classes)) {
      classes = classes.concat(_classes);
    }
  });
  return classes.filter(Boolean);
};
var castAsArray = (arg) => {
  if (!Array.isArray(arg)) {
    arg = [arg];
  }
  return arg;
};
var parentMatch = (target, selector, wrapper) => {
  if (wrapper && !wrapper.contains(target)) {
    return;
  }
  while (target && target.matches) {
    if (target.matches(selector)) {
      return target;
    }
    target = target.parentNode;
  }
};
var getTail = (list, direction = 0) => {
  if (direction > 0) {
    return list[list.length - 1];
  }
  return list[0];
};
var isEmptyObject = (obj) => {
  return Object.keys(obj).length === 0;
};
var nodeIndex = (el, amongst) => {
  if (!el)
    return -1;
  amongst = amongst || el.nodeName;
  var i = 0;
  while (el = el.previousElementSibling) {
    if (el.matches(amongst)) {
      i++;
    }
  }
  return i;
};
var setAttr = (el, attrs) => {
  iterate2(attrs, (val, attr) => {
    if (val == null) {
      el.removeAttribute(attr);
    } else {
      el.setAttribute(attr, "" + val);
    }
  });
};
var replaceNode = (existing, replacement) => {
  if (existing.parentNode)
    existing.parentNode.replaceChild(replacement, existing);
};

// node_modules/tom-select/dist/esm/contrib/highlight.js
var highlight = (element, regex) => {
  if (regex === null)
    return;
  if (typeof regex === "string") {
    if (!regex.length)
      return;
    regex = new RegExp(regex, "i");
  }
  const highlightText = (node) => {
    var match = node.data.match(regex);
    if (match && node.data.length > 0) {
      var spannode = document.createElement("span");
      spannode.className = "highlight";
      var middlebit = node.splitText(match.index);
      middlebit.splitText(match[0].length);
      var middleclone = middlebit.cloneNode(true);
      spannode.appendChild(middleclone);
      replaceNode(middlebit, spannode);
      return 1;
    }
    return 0;
  };
  const highlightChildren = (node) => {
    if (node.nodeType === 1 && node.childNodes && !/(script|style)/i.test(node.tagName) && (node.className !== "highlight" || node.tagName !== "SPAN")) {
      Array.from(node.childNodes).forEach((element2) => {
        highlightRecursive(element2);
      });
    }
  };
  const highlightRecursive = (node) => {
    if (node.nodeType === 3) {
      return highlightText(node);
    }
    highlightChildren(node);
    return 0;
  };
  highlightRecursive(element);
};
var removeHighlight = (el) => {
  var elements = el.querySelectorAll("span.highlight");
  Array.prototype.forEach.call(elements, function(el2) {
    var parent = el2.parentNode;
    parent.replaceChild(el2.firstChild, el2);
    parent.normalize();
  });
};

// node_modules/tom-select/dist/esm/constants.js
var KEY_A = 65;
var KEY_RETURN = 13;
var KEY_ESC = 27;
var KEY_LEFT = 37;
var KEY_UP = 38;
var KEY_RIGHT = 39;
var KEY_DOWN = 40;
var KEY_BACKSPACE = 8;
var KEY_DELETE = 46;
var KEY_TAB = 9;
var IS_MAC = typeof navigator === "undefined" ? false : /Mac/.test(navigator.userAgent);
var KEY_SHORTCUT = IS_MAC ? "metaKey" : "ctrlKey";

// node_modules/tom-select/dist/esm/defaults.js
var defaults_default = {
  options: [],
  optgroups: [],
  plugins: [],
  delimiter: ",",
  splitOn: null,
  // regexp or string for splitting up values from a paste command
  persist: true,
  diacritics: true,
  create: null,
  createOnBlur: false,
  createFilter: null,
  highlight: true,
  openOnFocus: true,
  shouldOpen: null,
  maxOptions: 50,
  maxItems: null,
  hideSelected: null,
  duplicates: false,
  addPrecedence: false,
  selectOnTab: false,
  preload: null,
  allowEmptyOption: false,
  //closeAfterSelect: false,
  refreshThrottle: 300,
  loadThrottle: 300,
  loadingClass: "loading",
  dataAttr: null,
  //'data-data',
  optgroupField: "optgroup",
  valueField: "value",
  labelField: "text",
  disabledField: "disabled",
  optgroupLabelField: "label",
  optgroupValueField: "value",
  lockOptgroupOrder: false,
  sortField: "$order",
  searchField: ["text"],
  searchConjunction: "and",
  mode: null,
  wrapperClass: "ts-wrapper",
  controlClass: "ts-control",
  dropdownClass: "ts-dropdown",
  dropdownContentClass: "ts-dropdown-content",
  itemClass: "item",
  optionClass: "option",
  dropdownParent: null,
  controlInput: '<input type="text" autocomplete="off" size="1" />',
  copyClassesToDropdown: false,
  placeholder: null,
  hidePlaceholder: null,
  shouldLoad: function(query) {
    return query.length > 0;
  },
  /*
  load                 : null, // function(query, callback) { ... }
  score                : null, // function(search) { ... }
  onInitialize         : null, // function() { ... }
  onChange             : null, // function(value) { ... }
  onItemAdd            : null, // function(value, $item) { ... }
  onItemRemove         : null, // function(value) { ... }
  onClear              : null, // function() { ... }
  onOptionAdd          : null, // function(value, data) { ... }
  onOptionRemove       : null, // function(value) { ... }
  onOptionClear        : null, // function() { ... }
  onOptionGroupAdd     : null, // function(id, data) { ... }
  onOptionGroupRemove  : null, // function(id) { ... }
  onOptionGroupClear   : null, // function() { ... }
  onDropdownOpen       : null, // function(dropdown) { ... }
  onDropdownClose      : null, // function(dropdown) { ... }
  onType               : null, // function(str) { ... }
  onDelete             : null, // function(values) { ... }
  */
  render: {
    /*
    item: null,
    optgroup: null,
    optgroup_header: null,
    option: null,
    option_create: null
    */
  }
};

// node_modules/tom-select/dist/esm/getSettings.js
function getSettings(input, settings_user) {
  var settings = Object.assign({}, defaults_default, settings_user);
  var attr_data = settings.dataAttr;
  var field_label = settings.labelField;
  var field_value = settings.valueField;
  var field_disabled = settings.disabledField;
  var field_optgroup = settings.optgroupField;
  var field_optgroup_label = settings.optgroupLabelField;
  var field_optgroup_value = settings.optgroupValueField;
  var tag_name = input.tagName.toLowerCase();
  var placeholder = input.getAttribute("placeholder") || input.getAttribute("data-placeholder");
  if (!placeholder && !settings.allowEmptyOption) {
    let option = input.querySelector('option[value=""]');
    if (option) {
      placeholder = option.textContent;
    }
  }
  var settings_element = {
    placeholder,
    options: [],
    optgroups: [],
    items: [],
    maxItems: null
  };
  var init_select = () => {
    var tagName;
    var options = settings_element.options;
    var optionsMap = {};
    var group_count = 1;
    let $order = 0;
    var readData = (el) => {
      var data = Object.assign({}, el.dataset);
      var json = attr_data && data[attr_data];
      if (typeof json === "string" && json.length) {
        data = Object.assign(data, JSON.parse(json));
      }
      return data;
    };
    var addOption = (option, group) => {
      var value = hash_key(option.value);
      if (value == null)
        return;
      if (!value && !settings.allowEmptyOption)
        return;
      if (optionsMap.hasOwnProperty(value)) {
        if (group) {
          var arr = optionsMap[value][field_optgroup];
          if (!arr) {
            optionsMap[value][field_optgroup] = group;
          } else if (!Array.isArray(arr)) {
            optionsMap[value][field_optgroup] = [arr, group];
          } else {
            arr.push(group);
          }
        }
      } else {
        var option_data = readData(option);
        option_data[field_label] = option_data[field_label] || option.textContent;
        option_data[field_value] = option_data[field_value] || value;
        option_data[field_disabled] = option_data[field_disabled] || option.disabled;
        option_data[field_optgroup] = option_data[field_optgroup] || group;
        option_data.$option = option;
        option_data.$order = option_data.$order || ++$order;
        optionsMap[value] = option_data;
        options.push(option_data);
      }
      if (option.selected) {
        settings_element.items.push(value);
      }
    };
    var addGroup = (optgroup) => {
      var id, optgroup_data;
      optgroup_data = readData(optgroup);
      optgroup_data[field_optgroup_label] = optgroup_data[field_optgroup_label] || optgroup.getAttribute("label") || "";
      optgroup_data[field_optgroup_value] = optgroup_data[field_optgroup_value] || group_count++;
      optgroup_data[field_disabled] = optgroup_data[field_disabled] || optgroup.disabled;
      optgroup_data.$order = optgroup_data.$order || ++$order;
      settings_element.optgroups.push(optgroup_data);
      id = optgroup_data[field_optgroup_value];
      iterate2(optgroup.children, (option) => {
        addOption(option, id);
      });
    };
    settings_element.maxItems = input.hasAttribute("multiple") ? null : 1;
    iterate2(input.children, (child) => {
      tagName = child.tagName.toLowerCase();
      if (tagName === "optgroup") {
        addGroup(child);
      } else if (tagName === "option") {
        addOption(child);
      }
    });
  };
  var init_textbox = () => {
    const data_raw = input.getAttribute(attr_data);
    if (!data_raw) {
      var value = input.value.trim() || "";
      if (!settings.allowEmptyOption && !value.length)
        return;
      const values = value.split(settings.delimiter);
      iterate2(values, (value2) => {
        const option = {};
        option[field_label] = value2;
        option[field_value] = value2;
        settings_element.options.push(option);
      });
      settings_element.items = values;
    } else {
      settings_element.options = JSON.parse(data_raw);
      iterate2(settings_element.options, (opt) => {
        settings_element.items.push(opt[field_value]);
      });
    }
  };
  if (tag_name === "select") {
    init_select();
  } else {
    init_textbox();
  }
  return Object.assign({}, defaults_default, settings_element, settings_user);
}

// node_modules/tom-select/dist/esm/tom-select.js
var instance_i = 0;
var TomSelect = class extends MicroPlugin(MicroEvent) {
  constructor(input_arg, user_settings) {
    super();
    this.order = 0;
    this.isOpen = false;
    this.isDisabled = false;
    this.isReadOnly = false;
    this.isInvalid = false;
    this.isValid = true;
    this.isLocked = false;
    this.isFocused = false;
    this.isInputHidden = false;
    this.isSetup = false;
    this.ignoreFocus = false;
    this.ignoreHover = false;
    this.hasOptions = false;
    this.lastValue = "";
    this.caretPos = 0;
    this.loading = 0;
    this.loadedSearches = {};
    this.activeOption = null;
    this.activeItems = [];
    this.optgroups = {};
    this.options = {};
    this.userOptions = {};
    this.items = [];
    this.refreshTimeout = null;
    instance_i++;
    var dir;
    var input = getDom(input_arg);
    if (input.tomselect) {
      throw new Error("Tom Select already initialized on this element");
    }
    input.tomselect = this;
    var computedStyle = window.getComputedStyle && window.getComputedStyle(input, null);
    dir = computedStyle.getPropertyValue("direction");
    const settings = getSettings(input, user_settings);
    this.settings = settings;
    this.input = input;
    this.tabIndex = input.tabIndex || 0;
    this.is_select_tag = input.tagName.toLowerCase() === "select";
    this.rtl = /rtl/i.test(dir);
    this.inputId = getId(input, "tomselect-" + instance_i);
    this.isRequired = input.required;
    this.sifter = new Sifter(this.options, { diacritics: settings.diacritics });
    settings.mode = settings.mode || (settings.maxItems === 1 ? "single" : "multi");
    if (typeof settings.hideSelected !== "boolean") {
      settings.hideSelected = settings.mode === "multi";
    }
    if (typeof settings.hidePlaceholder !== "boolean") {
      settings.hidePlaceholder = settings.mode !== "multi";
    }
    var filter = settings.createFilter;
    if (typeof filter !== "function") {
      if (typeof filter === "string") {
        filter = new RegExp(filter);
      }
      if (filter instanceof RegExp) {
        settings.createFilter = (input2) => filter.test(input2);
      } else {
        settings.createFilter = (value) => {
          return this.settings.duplicates || !this.options[value];
        };
      }
    }
    this.initializePlugins(settings.plugins);
    this.setupCallbacks();
    this.setupTemplates();
    const wrapper = getDom("<div>");
    const control = getDom("<div>");
    const dropdown = this._render("dropdown");
    const dropdown_content = getDom(`<div role="listbox" tabindex="-1">`);
    const classes = this.input.getAttribute("class") || "";
    const inputMode = settings.mode;
    var control_input;
    addClasses(wrapper, settings.wrapperClass, classes, inputMode);
    addClasses(control, settings.controlClass);
    append(wrapper, control);
    addClasses(dropdown, settings.dropdownClass, inputMode);
    if (settings.copyClassesToDropdown) {
      addClasses(dropdown, classes);
    }
    addClasses(dropdown_content, settings.dropdownContentClass);
    append(dropdown, dropdown_content);
    getDom(settings.dropdownParent || wrapper).appendChild(dropdown);
    if (isHtmlString(settings.controlInput)) {
      control_input = getDom(settings.controlInput);
      var attrs = ["autocorrect", "autocapitalize", "autocomplete", "spellcheck"];
      iterate2(attrs, (attr) => {
        if (input.getAttribute(attr)) {
          setAttr(control_input, { [attr]: input.getAttribute(attr) });
        }
      });
      control_input.tabIndex = -1;
      control.appendChild(control_input);
      this.focus_node = control_input;
    } else if (settings.controlInput) {
      control_input = getDom(settings.controlInput);
      this.focus_node = control_input;
    } else {
      control_input = getDom("<input/>");
      this.focus_node = control;
    }
    this.wrapper = wrapper;
    this.dropdown = dropdown;
    this.dropdown_content = dropdown_content;
    this.control = control;
    this.control_input = control_input;
    this.setup();
  }
  /**
   * set up event bindings.
   *
   */
  setup() {
    const self2 = this;
    const settings = self2.settings;
    const control_input = self2.control_input;
    const dropdown = self2.dropdown;
    const dropdown_content = self2.dropdown_content;
    const wrapper = self2.wrapper;
    const control = self2.control;
    const input = self2.input;
    const focus_node = self2.focus_node;
    const passive_event = { passive: true };
    const listboxId = self2.inputId + "-ts-dropdown";
    setAttr(dropdown_content, {
      id: listboxId
    });
    setAttr(focus_node, {
      role: "combobox",
      "aria-haspopup": "listbox",
      "aria-expanded": "false",
      "aria-controls": listboxId
    });
    const control_id = getId(focus_node, self2.inputId + "-ts-control");
    const query = "label[for='" + escapeQuery(self2.inputId) + "']";
    const label = document.querySelector(query);
    const label_click = self2.focus.bind(self2);
    if (label) {
      addEvent(label, "click", label_click);
      setAttr(label, { for: control_id });
      const label_id = getId(label, self2.inputId + "-ts-label");
      setAttr(focus_node, { "aria-labelledby": label_id });
      setAttr(dropdown_content, { "aria-labelledby": label_id });
    }
    wrapper.style.width = input.style.width;
    if (self2.plugins.names.length) {
      const classes_plugins = "plugin-" + self2.plugins.names.join(" plugin-");
      addClasses([wrapper, dropdown], classes_plugins);
    }
    if ((settings.maxItems === null || settings.maxItems > 1) && self2.is_select_tag) {
      setAttr(input, { multiple: "multiple" });
    }
    if (settings.placeholder) {
      setAttr(control_input, { placeholder: settings.placeholder });
    }
    if (!settings.splitOn && settings.delimiter) {
      settings.splitOn = new RegExp("\\s*" + escape_regex(settings.delimiter) + "+\\s*");
    }
    if (settings.load && settings.loadThrottle) {
      settings.load = loadDebounce(settings.load, settings.loadThrottle);
    }
    addEvent(dropdown, "mousemove", () => {
      self2.ignoreHover = false;
    });
    addEvent(dropdown, "mouseenter", (e) => {
      var target_match = parentMatch(e.target, "[data-selectable]", dropdown);
      if (target_match)
        self2.onOptionHover(e, target_match);
    }, { capture: true });
    addEvent(dropdown, "click", (evt) => {
      const option = parentMatch(evt.target, "[data-selectable]");
      if (option) {
        self2.onOptionSelect(evt, option);
        preventDefault(evt, true);
      }
    });
    addEvent(control, "click", (evt) => {
      var target_match = parentMatch(evt.target, "[data-ts-item]", control);
      if (target_match && self2.onItemSelect(evt, target_match)) {
        preventDefault(evt, true);
        return;
      }
      if (control_input.value != "") {
        return;
      }
      self2.onClick();
      preventDefault(evt, true);
    });
    addEvent(focus_node, "keydown", (e) => self2.onKeyDown(e));
    addEvent(control_input, "keypress", (e) => self2.onKeyPress(e));
    addEvent(control_input, "input", (e) => self2.onInput(e));
    addEvent(focus_node, "blur", (e) => self2.onBlur(e));
    addEvent(focus_node, "focus", (e) => self2.onFocus(e));
    addEvent(control_input, "paste", (e) => self2.onPaste(e));
    const doc_mousedown = (evt) => {
      const target = evt.composedPath()[0];
      if (!wrapper.contains(target) && !dropdown.contains(target)) {
        if (self2.isFocused) {
          self2.blur();
        }
        self2.inputState();
        return;
      }
      if (target == control_input && self2.isOpen) {
        evt.stopPropagation();
      } else {
        preventDefault(evt, true);
      }
    };
    const win_scroll = () => {
      if (self2.isOpen) {
        self2.positionDropdown();
      }
    };
    addEvent(document, "mousedown", doc_mousedown);
    addEvent(window, "scroll", win_scroll, passive_event);
    addEvent(window, "resize", win_scroll, passive_event);
    this._destroy = () => {
      document.removeEventListener("mousedown", doc_mousedown);
      window.removeEventListener("scroll", win_scroll);
      window.removeEventListener("resize", win_scroll);
      if (label)
        label.removeEventListener("click", label_click);
    };
    this.revertSettings = {
      innerHTML: input.innerHTML,
      tabIndex: input.tabIndex
    };
    input.tabIndex = -1;
    input.insertAdjacentElement("afterend", self2.wrapper);
    self2.sync(false);
    settings.items = [];
    delete settings.optgroups;
    delete settings.options;
    addEvent(input, "invalid", () => {
      if (self2.isValid) {
        self2.isValid = false;
        self2.isInvalid = true;
        self2.refreshState();
      }
    });
    self2.updateOriginalInput();
    self2.refreshItems();
    self2.close(false);
    self2.inputState();
    self2.isSetup = true;
    if (input.disabled) {
      self2.disable();
    } else if (input.readOnly) {
      self2.setReadOnly(true);
    } else {
      self2.enable();
    }
    self2.on("change", this.onChange);
    addClasses(input, "tomselected", "ts-hidden-accessible");
    self2.trigger("initialize");
    if (settings.preload === true) {
      self2.preload();
    }
  }
  /**
   * Register options and optgroups
   *
   */
  setupOptions(options = [], optgroups = []) {
    this.addOptions(options);
    iterate2(optgroups, (optgroup) => {
      this.registerOptionGroup(optgroup);
    });
  }
  /**
   * Sets up default rendering functions.
   */
  setupTemplates() {
    var self2 = this;
    var field_label = self2.settings.labelField;
    var field_optgroup = self2.settings.optgroupLabelField;
    var templates = {
      "optgroup": (data) => {
        let optgroup = document.createElement("div");
        optgroup.className = "optgroup";
        optgroup.appendChild(data.options);
        return optgroup;
      },
      "optgroup_header": (data, escape) => {
        return '<div class="optgroup-header">' + escape(data[field_optgroup]) + "</div>";
      },
      "option": (data, escape) => {
        return "<div>" + escape(data[field_label]) + "</div>";
      },
      "item": (data, escape) => {
        return "<div>" + escape(data[field_label]) + "</div>";
      },
      "option_create": (data, escape) => {
        return '<div class="create">Add <strong>' + escape(data.input) + "</strong>&hellip;</div>";
      },
      "no_results": () => {
        return '<div class="no-results">No results found</div>';
      },
      "loading": () => {
        return '<div class="spinner"></div>';
      },
      "not_loading": () => {
      },
      "dropdown": () => {
        return "<div></div>";
      }
    };
    self2.settings.render = Object.assign({}, templates, self2.settings.render);
  }
  /**
   * Maps fired events to callbacks provided
   * in the settings used when creating the control.
   */
  setupCallbacks() {
    var key, fn;
    var callbacks = {
      "initialize": "onInitialize",
      "change": "onChange",
      "item_add": "onItemAdd",
      "item_remove": "onItemRemove",
      "item_select": "onItemSelect",
      "clear": "onClear",
      "option_add": "onOptionAdd",
      "option_remove": "onOptionRemove",
      "option_clear": "onOptionClear",
      "optgroup_add": "onOptionGroupAdd",
      "optgroup_remove": "onOptionGroupRemove",
      "optgroup_clear": "onOptionGroupClear",
      "dropdown_open": "onDropdownOpen",
      "dropdown_close": "onDropdownClose",
      "type": "onType",
      "load": "onLoad",
      "focus": "onFocus",
      "blur": "onBlur"
    };
    for (key in callbacks) {
      fn = this.settings[callbacks[key]];
      if (fn)
        this.on(key, fn);
    }
  }
  /**
   * Sync the Tom Select instance with the original input or select
   *
   */
  sync(get_settings = true) {
    const self2 = this;
    const settings = get_settings ? getSettings(self2.input, { delimiter: self2.settings.delimiter }) : self2.settings;
    self2.setupOptions(settings.options, settings.optgroups);
    self2.setValue(settings.items || [], true);
    self2.lastQuery = null;
  }
  /**
   * Triggered when the main control element
   * has a click event.
   *
   */
  onClick() {
    var self2 = this;
    if (self2.activeItems.length > 0) {
      self2.clearActiveItems();
      self2.focus();
      return;
    }
    if (self2.isFocused && self2.isOpen) {
      self2.blur();
    } else {
      self2.focus();
    }
  }
  /**
   * @deprecated v1.7
   *
   */
  onMouseDown() {
  }
  /**
   * Triggered when the value of the control has been changed.
   * This should propagate the event to the original DOM
   * input / select element.
   */
  onChange() {
    triggerEvent(this.input, "input");
    triggerEvent(this.input, "change");
  }
  /**
   * Triggered on <input> paste.
   *
   */
  onPaste(e) {
    var self2 = this;
    if (self2.isInputHidden || self2.isLocked) {
      preventDefault(e);
      return;
    }
    if (!self2.settings.splitOn) {
      return;
    }
    setTimeout(() => {
      var pastedText = self2.inputValue();
      if (!pastedText.match(self2.settings.splitOn)) {
        return;
      }
      var splitInput = pastedText.trim().split(self2.settings.splitOn);
      iterate2(splitInput, (piece) => {
        const hash = hash_key(piece);
        if (hash) {
          if (this.options[piece]) {
            self2.addItem(piece);
          } else {
            self2.createItem(piece);
          }
        }
      });
    }, 0);
  }
  /**
   * Triggered on <input> keypress.
   *
   */
  onKeyPress(e) {
    var self2 = this;
    if (self2.isLocked) {
      preventDefault(e);
      return;
    }
    var character = String.fromCharCode(e.keyCode || e.which);
    if (self2.settings.create && self2.settings.mode === "multi" && character === self2.settings.delimiter) {
      self2.createItem();
      preventDefault(e);
      return;
    }
  }
  /**
   * Triggered on <input> keydown.
   *
   */
  onKeyDown(e) {
    var self2 = this;
    self2.ignoreHover = true;
    if (self2.isLocked) {
      if (e.keyCode !== KEY_TAB) {
        preventDefault(e);
      }
      return;
    }
    switch (e.keyCode) {
      // ctrl+A: select all
      case KEY_A:
        if (isKeyDown(KEY_SHORTCUT, e)) {
          if (self2.control_input.value == "") {
            preventDefault(e);
            self2.selectAll();
            return;
          }
        }
        break;
      // esc: close dropdown
      case KEY_ESC:
        if (self2.isOpen) {
          preventDefault(e, true);
          self2.close();
        }
        self2.clearActiveItems();
        return;
      // down: open dropdown or move selection down
      case KEY_DOWN:
        if (!self2.isOpen && self2.hasOptions) {
          self2.open();
        } else if (self2.activeOption) {
          let next = self2.getAdjacent(self2.activeOption, 1);
          if (next)
            self2.setActiveOption(next);
        }
        preventDefault(e);
        return;
      // up: move selection up
      case KEY_UP:
        if (self2.activeOption) {
          let prev = self2.getAdjacent(self2.activeOption, -1);
          if (prev)
            self2.setActiveOption(prev);
        }
        preventDefault(e);
        return;
      // return: select active option
      case KEY_RETURN:
        if (self2.canSelect(self2.activeOption)) {
          self2.onOptionSelect(e, self2.activeOption);
          preventDefault(e);
        } else if (self2.settings.create && self2.createItem()) {
          preventDefault(e);
        } else if (document.activeElement == self2.control_input && self2.isOpen) {
          preventDefault(e);
        }
        return;
      // left: modifiy item selection to the left
      case KEY_LEFT:
        self2.advanceSelection(-1, e);
        return;
      // right: modifiy item selection to the right
      case KEY_RIGHT:
        self2.advanceSelection(1, e);
        return;
      // tab: select active option and/or create item
      case KEY_TAB:
        if (self2.settings.selectOnTab) {
          if (self2.canSelect(self2.activeOption)) {
            self2.onOptionSelect(e, self2.activeOption);
            preventDefault(e);
          }
          if (self2.settings.create && self2.createItem()) {
            preventDefault(e);
          }
        }
        return;
      // delete|backspace: delete items
      case KEY_BACKSPACE:
      case KEY_DELETE:
        self2.deleteSelection(e);
        return;
    }
    if (self2.isInputHidden && !isKeyDown(KEY_SHORTCUT, e)) {
      preventDefault(e);
    }
  }
  /**
   * Triggered on <input> keyup.
   *
   */
  onInput(e) {
    if (this.isLocked) {
      return;
    }
    const value = this.inputValue();
    if (this.lastValue === value)
      return;
    this.lastValue = value;
    if (value == "") {
      this._onInput();
      return;
    }
    if (this.refreshTimeout) {
      window.clearTimeout(this.refreshTimeout);
    }
    this.refreshTimeout = timeout(() => {
      this.refreshTimeout = null;
      this._onInput();
    }, this.settings.refreshThrottle);
  }
  _onInput() {
    const value = this.lastValue;
    if (this.settings.shouldLoad.call(this, value)) {
      this.load(value);
    }
    this.refreshOptions();
    this.trigger("type", value);
  }
  /**
   * Triggered when the user rolls over
   * an option in the autocomplete dropdown menu.
   *
   */
  onOptionHover(evt, option) {
    if (this.ignoreHover)
      return;
    this.setActiveOption(option, false);
  }
  /**
   * Triggered on <input> focus.
   *
   */
  onFocus(e) {
    var self2 = this;
    var wasFocused = self2.isFocused;
    if (self2.isDisabled || self2.isReadOnly) {
      self2.blur();
      preventDefault(e);
      return;
    }
    if (self2.ignoreFocus)
      return;
    self2.isFocused = true;
    if (self2.settings.preload === "focus")
      self2.preload();
    if (!wasFocused)
      self2.trigger("focus");
    if (!self2.activeItems.length) {
      self2.inputState();
      self2.refreshOptions(!!self2.settings.openOnFocus);
    }
    self2.refreshState();
  }
  /**
   * Triggered on <input> blur.
   *
   */
  onBlur(e) {
    if (document.hasFocus() === false)
      return;
    var self2 = this;
    if (!self2.isFocused)
      return;
    self2.isFocused = false;
    self2.ignoreFocus = false;
    var deactivate = () => {
      self2.close();
      self2.setActiveItem();
      self2.setCaret(self2.items.length);
      self2.trigger("blur");
    };
    if (self2.settings.create && self2.settings.createOnBlur) {
      self2.createItem(null, deactivate);
    } else {
      deactivate();
    }
  }
  /**
   * Triggered when the user clicks on an option
   * in the autocomplete dropdown menu.
   *
   */
  onOptionSelect(evt, option) {
    var value, self2 = this;
    if (option.parentElement && option.parentElement.matches("[data-disabled]")) {
      return;
    }
    if (option.classList.contains("create")) {
      self2.createItem(null, () => {
        if (self2.settings.closeAfterSelect) {
          self2.close();
        }
      });
    } else {
      value = option.dataset.value;
      if (typeof value !== "undefined") {
        self2.lastQuery = null;
        self2.addItem(value);
        if (self2.settings.closeAfterSelect) {
          self2.close();
        }
        if (!self2.settings.hideSelected && evt.type && /click/.test(evt.type)) {
          self2.setActiveOption(option);
        }
      }
    }
  }
  /**
   * Return true if the given option can be selected
   *
   */
  canSelect(option) {
    if (this.isOpen && option && this.dropdown_content.contains(option)) {
      return true;
    }
    return false;
  }
  /**
   * Triggered when the user clicks on an item
   * that has been selected.
   *
   */
  onItemSelect(evt, item) {
    var self2 = this;
    if (!self2.isLocked && self2.settings.mode === "multi") {
      preventDefault(evt);
      self2.setActiveItem(item, evt);
      return true;
    }
    return false;
  }
  /**
   * Determines whether or not to invoke
   * the user-provided option provider / loader
   *
   * Note, there is a subtle difference between
   * this.canLoad() and this.settings.shouldLoad();
   *
   *	- settings.shouldLoad() is a user-input validator.
   *	When false is returned, the not_loading template
   *	will be added to the dropdown
   *
   *	- canLoad() is lower level validator that checks
   * 	the Tom Select instance. There is no inherent user
   *	feedback when canLoad returns false
   *
   */
  canLoad(value) {
    if (!this.settings.load)
      return false;
    if (this.loadedSearches.hasOwnProperty(value))
      return false;
    return true;
  }
  /**
   * Invokes the user-provided option provider / loader.
   *
   */
  load(value) {
    const self2 = this;
    if (!self2.canLoad(value))
      return;
    addClasses(self2.wrapper, self2.settings.loadingClass);
    self2.loading++;
    const callback = self2.loadCallback.bind(self2);
    self2.settings.load.call(self2, value, callback);
  }
  /**
   * Invoked by the user-provided option provider
   *
   */
  loadCallback(options, optgroups) {
    const self2 = this;
    self2.loading = Math.max(self2.loading - 1, 0);
    self2.lastQuery = null;
    self2.clearActiveOption();
    self2.setupOptions(options, optgroups);
    self2.refreshOptions(self2.isFocused && !self2.isInputHidden);
    if (!self2.loading) {
      removeClasses(self2.wrapper, self2.settings.loadingClass);
    }
    self2.trigger("load", options, optgroups);
  }
  preload() {
    var classList = this.wrapper.classList;
    if (classList.contains("preloaded"))
      return;
    classList.add("preloaded");
    this.load("");
  }
  /**
   * Sets the input field of the control to the specified value.
   *
   */
  setTextboxValue(value = "") {
    var input = this.control_input;
    var changed = input.value !== value;
    if (changed) {
      input.value = value;
      triggerEvent(input, "update");
      this.lastValue = value;
    }
  }
  /**
   * Returns the value of the control. If multiple items
   * can be selected (e.g. <select multiple>), this returns
   * an array. If only one item can be selected, this
   * returns a string.
   *
   */
  getValue() {
    if (this.is_select_tag && this.input.hasAttribute("multiple")) {
      return this.items;
    }
    return this.items.join(this.settings.delimiter);
  }
  /**
   * Resets the selected items to the given value.
   *
   */
  setValue(value, silent) {
    var events = silent ? [] : ["change"];
    debounce_events(this, events, () => {
      this.clear(silent);
      this.addItems(value, silent);
    });
  }
  /**
   * Resets the number of max items to the given value
   *
   */
  setMaxItems(value) {
    if (value === 0)
      value = null;
    this.settings.maxItems = value;
    this.refreshState();
  }
  /**
   * Sets the selected item.
   *
   */
  setActiveItem(item, e) {
    var self2 = this;
    var eventName;
    var i, begin, end, swap;
    var last;
    if (self2.settings.mode === "single")
      return;
    if (!item) {
      self2.clearActiveItems();
      if (self2.isFocused) {
        self2.inputState();
      }
      return;
    }
    eventName = e && e.type.toLowerCase();
    if (eventName === "click" && isKeyDown("shiftKey", e) && self2.activeItems.length) {
      last = self2.getLastActive();
      begin = Array.prototype.indexOf.call(self2.control.children, last);
      end = Array.prototype.indexOf.call(self2.control.children, item);
      if (begin > end) {
        swap = begin;
        begin = end;
        end = swap;
      }
      for (i = begin; i <= end; i++) {
        item = self2.control.children[i];
        if (self2.activeItems.indexOf(item) === -1) {
          self2.setActiveItemClass(item);
        }
      }
      preventDefault(e);
    } else if (eventName === "click" && isKeyDown(KEY_SHORTCUT, e) || eventName === "keydown" && isKeyDown("shiftKey", e)) {
      if (item.classList.contains("active")) {
        self2.removeActiveItem(item);
      } else {
        self2.setActiveItemClass(item);
      }
    } else {
      self2.clearActiveItems();
      self2.setActiveItemClass(item);
    }
    self2.inputState();
    if (!self2.isFocused) {
      self2.focus();
    }
  }
  /**
   * Set the active and last-active classes
   *
   */
  setActiveItemClass(item) {
    const self2 = this;
    const last_active = self2.control.querySelector(".last-active");
    if (last_active)
      removeClasses(last_active, "last-active");
    addClasses(item, "active last-active");
    self2.trigger("item_select", item);
    if (self2.activeItems.indexOf(item) == -1) {
      self2.activeItems.push(item);
    }
  }
  /**
   * Remove active item
   *
   */
  removeActiveItem(item) {
    var idx = this.activeItems.indexOf(item);
    this.activeItems.splice(idx, 1);
    removeClasses(item, "active");
  }
  /**
   * Clears all the active items
   *
   */
  clearActiveItems() {
    removeClasses(this.activeItems, "active");
    this.activeItems = [];
  }
  /**
   * Sets the selected item in the dropdown menu
   * of available options.
   *
   */
  setActiveOption(option, scroll = true) {
    if (option === this.activeOption) {
      return;
    }
    this.clearActiveOption();
    if (!option)
      return;
    this.activeOption = option;
    setAttr(this.focus_node, { "aria-activedescendant": option.getAttribute("id") });
    setAttr(option, { "aria-selected": "true" });
    addClasses(option, "active");
    if (scroll)
      this.scrollToOption(option);
  }
  /**
   * Sets the dropdown_content scrollTop to display the option
   *
   */
  scrollToOption(option, behavior) {
    if (!option)
      return;
    const content = this.dropdown_content;
    const height_menu = content.clientHeight;
    const scrollTop = content.scrollTop || 0;
    const height_item = option.offsetHeight;
    const y = option.getBoundingClientRect().top - content.getBoundingClientRect().top + scrollTop;
    if (y + height_item > height_menu + scrollTop) {
      this.scroll(y - height_menu + height_item, behavior);
    } else if (y < scrollTop) {
      this.scroll(y, behavior);
    }
  }
  /**
   * Scroll the dropdown to the given position
   *
   */
  scroll(scrollTop, behavior) {
    const content = this.dropdown_content;
    if (behavior) {
      content.style.scrollBehavior = behavior;
    }
    content.scrollTop = scrollTop;
    content.style.scrollBehavior = "";
  }
  /**
   * Clears the active option
   *
   */
  clearActiveOption() {
    if (this.activeOption) {
      removeClasses(this.activeOption, "active");
      setAttr(this.activeOption, { "aria-selected": null });
    }
    this.activeOption = null;
    setAttr(this.focus_node, { "aria-activedescendant": null });
  }
  /**
   * Selects all items (CTRL + A).
   */
  selectAll() {
    const self2 = this;
    if (self2.settings.mode === "single")
      return;
    const activeItems = self2.controlChildren();
    if (!activeItems.length)
      return;
    self2.inputState();
    self2.close();
    self2.activeItems = activeItems;
    iterate2(activeItems, (item) => {
      self2.setActiveItemClass(item);
    });
  }
  /**
   * Determines if the control_input should be in a hidden or visible state
   *
   */
  inputState() {
    var self2 = this;
    if (!self2.control.contains(self2.control_input))
      return;
    setAttr(self2.control_input, { placeholder: self2.settings.placeholder });
    if (self2.activeItems.length > 0 || !self2.isFocused && self2.settings.hidePlaceholder && self2.items.length > 0) {
      self2.setTextboxValue();
      self2.isInputHidden = true;
    } else {
      if (self2.settings.hidePlaceholder && self2.items.length > 0) {
        setAttr(self2.control_input, { placeholder: "" });
      }
      self2.isInputHidden = false;
    }
    self2.wrapper.classList.toggle("input-hidden", self2.isInputHidden);
  }
  /**
   * Get the input value
   */
  inputValue() {
    return this.control_input.value.trim();
  }
  /**
   * Gives the control focus.
   */
  focus() {
    var self2 = this;
    if (self2.isDisabled || self2.isReadOnly)
      return;
    self2.ignoreFocus = true;
    if (self2.control_input.offsetWidth) {
      self2.control_input.focus();
    } else {
      self2.focus_node.focus();
    }
    setTimeout(() => {
      self2.ignoreFocus = false;
      self2.onFocus();
    }, 0);
  }
  /**
   * Forces the control out of focus.
   *
   */
  blur() {
    this.focus_node.blur();
    this.onBlur();
  }
  /**
   * Returns a function that scores an object
   * to show how good of a match it is to the
   * provided query.
   *
   * @return {function}
   */
  getScoreFunction(query) {
    return this.sifter.getScoreFunction(query, this.getSearchOptions());
  }
  /**
   * Returns search options for sifter (the system
   * for scoring and sorting results).
   *
   * @see https://github.com/orchidjs/sifter.js
   * @return {object}
   */
  getSearchOptions() {
    var settings = this.settings;
    var sort = settings.sortField;
    if (typeof settings.sortField === "string") {
      sort = [{ field: settings.sortField }];
    }
    return {
      fields: settings.searchField,
      conjunction: settings.searchConjunction,
      sort,
      nesting: settings.nesting
    };
  }
  /**
   * Searches through available options and returns
   * a sorted array of matches.
   *
   */
  search(query) {
    var result, calculateScore;
    var self2 = this;
    var options = this.getSearchOptions();
    if (self2.settings.score) {
      calculateScore = self2.settings.score.call(self2, query);
      if (typeof calculateScore !== "function") {
        throw new Error('Tom Select "score" setting must be a function that returns a function');
      }
    }
    if (query !== self2.lastQuery) {
      self2.lastQuery = query;
      result = self2.sifter.search(query, Object.assign(options, { score: calculateScore }));
      self2.currentResults = result;
    } else {
      result = Object.assign({}, self2.currentResults);
    }
    if (self2.settings.hideSelected) {
      result.items = result.items.filter((item) => {
        let hashed = hash_key(item.id);
        return !(hashed && self2.items.indexOf(hashed) !== -1);
      });
    }
    return result;
  }
  /**
   * Refreshes the list of available options shown
   * in the autocomplete dropdown menu.
   *
   */
  refreshOptions(triggerDropdown = true) {
    var i, j, k, n, optgroup, optgroups, html, has_create_option, active_group;
    var create;
    const groups = {};
    const groups_order = [];
    var self2 = this;
    var query = self2.inputValue();
    const same_query = query === self2.lastQuery || query == "" && self2.lastQuery == null;
    var results = self2.search(query);
    var active_option = null;
    var show_dropdown = self2.settings.shouldOpen || false;
    var dropdown_content = self2.dropdown_content;
    if (same_query) {
      active_option = self2.activeOption;
      if (active_option) {
        active_group = active_option.closest("[data-group]");
      }
    }
    n = results.items.length;
    if (typeof self2.settings.maxOptions === "number") {
      n = Math.min(n, self2.settings.maxOptions);
    }
    if (n > 0) {
      show_dropdown = true;
    }
    const getGroupFragment = (optgroup2, order) => {
      let group_order_i = groups[optgroup2];
      if (group_order_i !== void 0) {
        let order_group = groups_order[group_order_i];
        if (order_group !== void 0) {
          return [group_order_i, order_group.fragment];
        }
      }
      let group_fragment = document.createDocumentFragment();
      group_order_i = groups_order.length;
      groups_order.push({ fragment: group_fragment, order, optgroup: optgroup2 });
      return [group_order_i, group_fragment];
    };
    for (i = 0; i < n; i++) {
      let item = results.items[i];
      if (!item)
        continue;
      let opt_value = item.id;
      let option = self2.options[opt_value];
      if (option === void 0)
        continue;
      let opt_hash = get_hash(opt_value);
      let option_el = self2.getOption(opt_hash, true);
      if (!self2.settings.hideSelected) {
        option_el.classList.toggle("selected", self2.items.includes(opt_hash));
      }
      optgroup = option[self2.settings.optgroupField] || "";
      optgroups = Array.isArray(optgroup) ? optgroup : [optgroup];
      for (j = 0, k = optgroups && optgroups.length; j < k; j++) {
        optgroup = optgroups[j];
        let order = option.$order;
        let self_optgroup = self2.optgroups[optgroup];
        if (self_optgroup === void 0) {
          optgroup = "";
        } else {
          order = self_optgroup.$order;
        }
        const [group_order_i, group_fragment] = getGroupFragment(optgroup, order);
        if (j > 0) {
          option_el = option_el.cloneNode(true);
          setAttr(option_el, { id: option.$id + "-clone-" + j, "aria-selected": null });
          option_el.classList.add("ts-cloned");
          removeClasses(option_el, "active");
          if (self2.activeOption && self2.activeOption.dataset.value == opt_value) {
            if (active_group && active_group.dataset.group === optgroup.toString()) {
              active_option = option_el;
            }
          }
        }
        group_fragment.appendChild(option_el);
        if (optgroup != "") {
          groups[optgroup] = group_order_i;
        }
      }
    }
    if (self2.settings.lockOptgroupOrder) {
      groups_order.sort((a, b) => {
        return a.order - b.order;
      });
    }
    html = document.createDocumentFragment();
    iterate2(groups_order, (group_order) => {
      let group_fragment = group_order.fragment;
      let optgroup2 = group_order.optgroup;
      if (!group_fragment || !group_fragment.children.length)
        return;
      let group_heading = self2.optgroups[optgroup2];
      if (group_heading !== void 0) {
        let group_options = document.createDocumentFragment();
        let header = self2.render("optgroup_header", group_heading);
        append(group_options, header);
        append(group_options, group_fragment);
        let group_html = self2.render("optgroup", { group: group_heading, options: group_options });
        append(html, group_html);
      } else {
        append(html, group_fragment);
      }
    });
    dropdown_content.innerHTML = "";
    append(dropdown_content, html);
    if (self2.settings.highlight) {
      removeHighlight(dropdown_content);
      if (results.query.length && results.tokens.length) {
        iterate2(results.tokens, (tok) => {
          highlight(dropdown_content, tok.regex);
        });
      }
    }
    var add_template = (template) => {
      let content = self2.render(template, { input: query });
      if (content) {
        show_dropdown = true;
        dropdown_content.insertBefore(content, dropdown_content.firstChild);
      }
      return content;
    };
    if (self2.loading) {
      add_template("loading");
    } else if (!self2.settings.shouldLoad.call(self2, query)) {
      add_template("not_loading");
    } else if (results.items.length === 0) {
      add_template("no_results");
    }
    has_create_option = self2.canCreate(query);
    if (has_create_option) {
      create = add_template("option_create");
    }
    self2.hasOptions = results.items.length > 0 || has_create_option;
    if (show_dropdown) {
      if (results.items.length > 0) {
        if (!active_option && self2.settings.mode === "single" && self2.items[0] != void 0) {
          active_option = self2.getOption(self2.items[0]);
        }
        if (!dropdown_content.contains(active_option)) {
          let active_index = 0;
          if (create && !self2.settings.addPrecedence) {
            active_index = 1;
          }
          active_option = self2.selectable()[active_index];
        }
      } else if (create) {
        active_option = create;
      }
      if (triggerDropdown && !self2.isOpen) {
        self2.open();
        self2.scrollToOption(active_option, "auto");
      }
      self2.setActiveOption(active_option);
    } else {
      self2.clearActiveOption();
      if (triggerDropdown && self2.isOpen) {
        self2.close(false);
      }
    }
  }
  /**
   * Return list of selectable options
   *
   */
  selectable() {
    return this.dropdown_content.querySelectorAll("[data-selectable]");
  }
  /**
   * Adds an available option. If it already exists,
   * nothing will happen. Note: this does not refresh
   * the options list dropdown (use `refreshOptions`
   * for that).
   *
   * Usage:
   *
   *   this.addOption(data)
   *
   */
  addOption(data, user_created = false) {
    const self2 = this;
    if (Array.isArray(data)) {
      self2.addOptions(data, user_created);
      return false;
    }
    const key = hash_key(data[self2.settings.valueField]);
    if (key === null || self2.options.hasOwnProperty(key)) {
      return false;
    }
    data.$order = data.$order || ++self2.order;
    data.$id = self2.inputId + "-opt-" + data.$order;
    self2.options[key] = data;
    self2.lastQuery = null;
    if (user_created) {
      self2.userOptions[key] = user_created;
      self2.trigger("option_add", key, data);
    }
    return key;
  }
  /**
   * Add multiple options
   *
   */
  addOptions(data, user_created = false) {
    iterate2(data, (dat) => {
      this.addOption(dat, user_created);
    });
  }
  /**
   * @deprecated 1.7.7
   */
  registerOption(data) {
    return this.addOption(data);
  }
  /**
   * Registers an option group to the pool of option groups.
   *
   * @return {boolean|string}
   */
  registerOptionGroup(data) {
    var key = hash_key(data[this.settings.optgroupValueField]);
    if (key === null)
      return false;
    data.$order = data.$order || ++this.order;
    this.optgroups[key] = data;
    return key;
  }
  /**
   * Registers a new optgroup for options
   * to be bucketed into.
   *
   */
  addOptionGroup(id, data) {
    var hashed_id;
    data[this.settings.optgroupValueField] = id;
    if (hashed_id = this.registerOptionGroup(data)) {
      this.trigger("optgroup_add", hashed_id, data);
    }
  }
  /**
   * Removes an existing option group.
   *
   */
  removeOptionGroup(id) {
    if (this.optgroups.hasOwnProperty(id)) {
      delete this.optgroups[id];
      this.clearCache();
      this.trigger("optgroup_remove", id);
    }
  }
  /**
   * Clears all existing option groups.
   */
  clearOptionGroups() {
    this.optgroups = {};
    this.clearCache();
    this.trigger("optgroup_clear");
  }
  /**
   * Updates an option available for selection. If
   * it is visible in the selected items or options
   * dropdown, it will be re-rendered automatically.
   *
   */
  updateOption(value, data) {
    const self2 = this;
    var item_new;
    var index_item;
    const value_old = hash_key(value);
    const value_new = hash_key(data[self2.settings.valueField]);
    if (value_old === null)
      return;
    const data_old = self2.options[value_old];
    if (data_old == void 0)
      return;
    if (typeof value_new !== "string")
      throw new Error("Value must be set in option data");
    const option = self2.getOption(value_old);
    const item = self2.getItem(value_old);
    data.$order = data.$order || data_old.$order;
    delete self2.options[value_old];
    self2.uncacheValue(value_new);
    self2.options[value_new] = data;
    if (option) {
      if (self2.dropdown_content.contains(option)) {
        const option_new = self2._render("option", data);
        replaceNode(option, option_new);
        if (self2.activeOption === option) {
          self2.setActiveOption(option_new);
        }
      }
      option.remove();
    }
    if (item) {
      index_item = self2.items.indexOf(value_old);
      if (index_item !== -1) {
        self2.items.splice(index_item, 1, value_new);
      }
      item_new = self2._render("item", data);
      if (item.classList.contains("active"))
        addClasses(item_new, "active");
      replaceNode(item, item_new);
    }
    self2.lastQuery = null;
  }
  /**
   * Removes a single option.
   *
   */
  removeOption(value, silent) {
    const self2 = this;
    value = get_hash(value);
    self2.uncacheValue(value);
    delete self2.userOptions[value];
    delete self2.options[value];
    self2.lastQuery = null;
    self2.trigger("option_remove", value);
    self2.removeItem(value, silent);
  }
  /**
   * Clears all options.
   */
  clearOptions(filter) {
    const boundFilter = (filter || this.clearFilter).bind(this);
    this.loadedSearches = {};
    this.userOptions = {};
    this.clearCache();
    const selected = {};
    iterate2(this.options, (option, key) => {
      if (boundFilter(option, key)) {
        selected[key] = option;
      }
    });
    this.options = this.sifter.items = selected;
    this.lastQuery = null;
    this.trigger("option_clear");
  }
  /**
   * Used by clearOptions() to decide whether or not an option should be removed
   * Return true to keep an option, false to remove
   *
   */
  clearFilter(option, value) {
    if (this.items.indexOf(value) >= 0) {
      return true;
    }
    return false;
  }
  /**
   * Returns the dom element of the option
   * matching the given value.
   *
   */
  getOption(value, create = false) {
    const hashed = hash_key(value);
    if (hashed === null)
      return null;
    const option = this.options[hashed];
    if (option != void 0) {
      if (option.$div) {
        return option.$div;
      }
      if (create) {
        return this._render("option", option);
      }
    }
    return null;
  }
  /**
   * Returns the dom element of the next or previous dom element of the same type
   * Note: adjacent options may not be adjacent DOM elements (optgroups)
   *
   */
  getAdjacent(option, direction, type = "option") {
    var self2 = this, all;
    if (!option) {
      return null;
    }
    if (type == "item") {
      all = self2.controlChildren();
    } else {
      all = self2.dropdown_content.querySelectorAll("[data-selectable]");
    }
    for (let i = 0; i < all.length; i++) {
      if (all[i] != option) {
        continue;
      }
      if (direction > 0) {
        return all[i + 1];
      }
      return all[i - 1];
    }
    return null;
  }
  /**
   * Returns the dom element of the item
   * matching the given value.
   *
   */
  getItem(item) {
    if (typeof item == "object") {
      return item;
    }
    var value = hash_key(item);
    return value !== null ? this.control.querySelector(`[data-value="${addSlashes(value)}"]`) : null;
  }
  /**
   * "Selects" multiple items at once. Adds them to the list
   * at the current caret position.
   *
   */
  addItems(values, silent) {
    var self2 = this;
    var items = Array.isArray(values) ? values : [values];
    items = items.filter((x) => self2.items.indexOf(x) === -1);
    const last_item = items[items.length - 1];
    items.forEach((item) => {
      self2.isPending = item !== last_item;
      self2.addItem(item, silent);
    });
  }
  /**
   * "Selects" an item. Adds it to the list
   * at the current caret position.
   *
   */
  addItem(value, silent) {
    var events = silent ? [] : ["change", "dropdown_close"];
    debounce_events(this, events, () => {
      var item, wasFull;
      const self2 = this;
      const inputMode = self2.settings.mode;
      const hashed = hash_key(value);
      if (hashed && self2.items.indexOf(hashed) !== -1) {
        if (inputMode === "single") {
          self2.close();
        }
        if (inputMode === "single" || !self2.settings.duplicates) {
          return;
        }
      }
      if (hashed === null || !self2.options.hasOwnProperty(hashed))
        return;
      if (inputMode === "single")
        self2.clear(silent);
      if (inputMode === "multi" && self2.isFull())
        return;
      item = self2._render("item", self2.options[hashed]);
      if (self2.control.contains(item)) {
        item = item.cloneNode(true);
      }
      wasFull = self2.isFull();
      self2.items.splice(self2.caretPos, 0, hashed);
      self2.insertAtCaret(item);
      if (self2.isSetup) {
        if (!self2.isPending && self2.settings.hideSelected) {
          let option = self2.getOption(hashed);
          let next = self2.getAdjacent(option, 1);
          if (next) {
            self2.setActiveOption(next);
          }
        }
        if (!self2.isPending && !self2.settings.closeAfterSelect) {
          self2.refreshOptions(self2.isFocused && inputMode !== "single");
        }
        if (self2.settings.closeAfterSelect != false && self2.isFull()) {
          self2.close();
        } else if (!self2.isPending) {
          self2.positionDropdown();
        }
        self2.trigger("item_add", hashed, item);
        if (!self2.isPending) {
          self2.updateOriginalInput({ silent });
        }
      }
      if (!self2.isPending || !wasFull && self2.isFull()) {
        self2.inputState();
        self2.refreshState();
      }
    });
  }
  /**
   * Removes the selected item matching
   * the provided value.
   *
   */
  removeItem(item = null, silent) {
    const self2 = this;
    item = self2.getItem(item);
    if (!item)
      return;
    var i, idx;
    const value = item.dataset.value;
    i = nodeIndex(item);
    item.remove();
    if (item.classList.contains("active")) {
      idx = self2.activeItems.indexOf(item);
      self2.activeItems.splice(idx, 1);
      removeClasses(item, "active");
    }
    self2.items.splice(i, 1);
    self2.lastQuery = null;
    if (!self2.settings.persist && self2.userOptions.hasOwnProperty(value)) {
      self2.removeOption(value, silent);
    }
    if (i < self2.caretPos) {
      self2.setCaret(self2.caretPos - 1);
    }
    self2.updateOriginalInput({ silent });
    self2.refreshState();
    self2.positionDropdown();
    self2.trigger("item_remove", value, item);
  }
  /**
   * Invokes the `create` method provided in the
   * TomSelect options that should provide the data
   * for the new item, given the user input.
   *
   * Once this completes, it will be added
   * to the item list.
   *
   */
  createItem(input = null, callback = () => {
  }) {
    if (arguments.length === 3) {
      callback = arguments[2];
    }
    if (typeof callback != "function") {
      callback = () => {
      };
    }
    var self2 = this;
    var caret = self2.caretPos;
    var output;
    input = input || self2.inputValue();
    if (!self2.canCreate(input)) {
      callback();
      return false;
    }
    self2.lock();
    var created = false;
    var create = (data) => {
      self2.unlock();
      if (!data || typeof data !== "object")
        return callback();
      var value = hash_key(data[self2.settings.valueField]);
      if (typeof value !== "string") {
        return callback();
      }
      self2.setTextboxValue();
      self2.addOption(data, true);
      self2.setCaret(caret);
      self2.addItem(value);
      callback(data);
      created = true;
    };
    if (typeof self2.settings.create === "function") {
      output = self2.settings.create.call(this, input, create);
    } else {
      output = {
        [self2.settings.labelField]: input,
        [self2.settings.valueField]: input
      };
    }
    if (!created) {
      create(output);
    }
    return true;
  }
  /**
   * Re-renders the selected item lists.
   */
  refreshItems() {
    var self2 = this;
    self2.lastQuery = null;
    if (self2.isSetup) {
      self2.addItems(self2.items);
    }
    self2.updateOriginalInput();
    self2.refreshState();
  }
  /**
   * Updates all state-dependent attributes
   * and CSS classes.
   */
  refreshState() {
    const self2 = this;
    self2.refreshValidityState();
    const isFull = self2.isFull();
    const isLocked = self2.isLocked;
    self2.wrapper.classList.toggle("rtl", self2.rtl);
    const wrap_classList = self2.wrapper.classList;
    wrap_classList.toggle("focus", self2.isFocused);
    wrap_classList.toggle("disabled", self2.isDisabled);
    wrap_classList.toggle("readonly", self2.isReadOnly);
    wrap_classList.toggle("required", self2.isRequired);
    wrap_classList.toggle("invalid", !self2.isValid);
    wrap_classList.toggle("locked", isLocked);
    wrap_classList.toggle("full", isFull);
    wrap_classList.toggle("input-active", self2.isFocused && !self2.isInputHidden);
    wrap_classList.toggle("dropdown-active", self2.isOpen);
    wrap_classList.toggle("has-options", isEmptyObject(self2.options));
    wrap_classList.toggle("has-items", self2.items.length > 0);
  }
  /**
   * Update the `required` attribute of both input and control input.
   *
   * The `required` property needs to be activated on the control input
   * for the error to be displayed at the right place. `required` also
   * needs to be temporarily deactivated on the input since the input is
   * hidden and can't show errors.
   */
  refreshValidityState() {
    var self2 = this;
    if (!self2.input.validity) {
      return;
    }
    self2.isValid = self2.input.validity.valid;
    self2.isInvalid = !self2.isValid;
  }
  /**
   * Determines whether or not more items can be added
   * to the control without exceeding the user-defined maximum.
   *
   * @returns {boolean}
   */
  isFull() {
    return this.settings.maxItems !== null && this.items.length >= this.settings.maxItems;
  }
  /**
   * Refreshes the original <select> or <input>
   * element to reflect the current state.
   *
   */
  updateOriginalInput(opts = {}) {
    const self2 = this;
    var option, label;
    const empty_option = self2.input.querySelector('option[value=""]');
    if (self2.is_select_tag) {
      let AddSelected = function(option_el, value, label2) {
        if (!option_el) {
          option_el = getDom('<option value="' + escape_html(value) + '">' + escape_html(label2) + "</option>");
        }
        if (option_el != empty_option) {
          self2.input.append(option_el);
        }
        selected.push(option_el);
        if (option_el != empty_option || has_selected > 0) {
          option_el.selected = true;
        }
        return option_el;
      };
      const selected = [];
      const has_selected = self2.input.querySelectorAll("option:checked").length;
      self2.input.querySelectorAll("option:checked").forEach((option_el) => {
        option_el.selected = false;
      });
      if (self2.items.length == 0 && self2.settings.mode == "single") {
        AddSelected(empty_option, "", "");
      } else {
        self2.items.forEach((value) => {
          option = self2.options[value];
          label = option[self2.settings.labelField] || "";
          if (selected.includes(option.$option)) {
            const reuse_opt = self2.input.querySelector(`option[value="${addSlashes(value)}"]:not(:checked)`);
            AddSelected(reuse_opt, value, label);
          } else {
            option.$option = AddSelected(option.$option, value, label);
          }
        });
      }
    } else {
      self2.input.value = self2.getValue();
    }
    if (self2.isSetup) {
      if (!opts.silent) {
        self2.trigger("change", self2.getValue());
      }
    }
  }
  /**
   * Shows the autocomplete dropdown containing
   * the available options.
   */
  open() {
    var self2 = this;
    if (self2.isLocked || self2.isOpen || self2.settings.mode === "multi" && self2.isFull())
      return;
    self2.isOpen = true;
    setAttr(self2.focus_node, { "aria-expanded": "true" });
    self2.refreshState();
    applyCSS(self2.dropdown, { visibility: "hidden", display: "block" });
    self2.positionDropdown();
    applyCSS(self2.dropdown, { visibility: "visible", display: "block" });
    self2.focus();
    self2.trigger("dropdown_open", self2.dropdown);
  }
  /**
   * Closes the autocomplete dropdown menu.
   */
  close(setTextboxValue = true) {
    var self2 = this;
    var trigger = self2.isOpen;
    if (setTextboxValue) {
      self2.setTextboxValue();
      if (self2.settings.mode === "single" && self2.items.length) {
        self2.inputState();
      }
    }
    self2.isOpen = false;
    setAttr(self2.focus_node, { "aria-expanded": "false" });
    applyCSS(self2.dropdown, { display: "none" });
    if (self2.settings.hideSelected) {
      self2.clearActiveOption();
    }
    self2.refreshState();
    if (trigger)
      self2.trigger("dropdown_close", self2.dropdown);
  }
  /**
   * Calculates and applies the appropriate
   * position of the dropdown if dropdownParent = 'body'.
   * Otherwise, position is determined by css
   */
  positionDropdown() {
    if (this.settings.dropdownParent !== "body") {
      return;
    }
    var context = this.control;
    var rect = context.getBoundingClientRect();
    var top = context.offsetHeight + rect.top + window.scrollY;
    var left = rect.left + window.scrollX;
    applyCSS(this.dropdown, {
      width: rect.width + "px",
      top: top + "px",
      left: left + "px"
    });
  }
  /**
   * Resets / clears all selected items
   * from the control.
   *
   */
  clear(silent) {
    var self2 = this;
    if (!self2.items.length)
      return;
    var items = self2.controlChildren();
    iterate2(items, (item) => {
      self2.removeItem(item, true);
    });
    self2.inputState();
    if (!silent)
      self2.updateOriginalInput();
    self2.trigger("clear");
  }
  /**
   * A helper method for inserting an element
   * at the current caret position.
   *
   */
  insertAtCaret(el) {
    const self2 = this;
    const caret = self2.caretPos;
    const target = self2.control;
    target.insertBefore(el, target.children[caret] || null);
    self2.setCaret(caret + 1);
  }
  /**
   * Removes the current selected item(s).
   *
   */
  deleteSelection(e) {
    var direction, selection, caret, tail;
    var self2 = this;
    direction = e && e.keyCode === KEY_BACKSPACE ? -1 : 1;
    selection = getSelection(self2.control_input);
    const rm_items = [];
    if (self2.activeItems.length) {
      tail = getTail(self2.activeItems, direction);
      caret = nodeIndex(tail);
      if (direction > 0) {
        caret++;
      }
      iterate2(self2.activeItems, (item) => rm_items.push(item));
    } else if ((self2.isFocused || self2.settings.mode === "single") && self2.items.length) {
      const items = self2.controlChildren();
      let rm_item;
      if (direction < 0 && selection.start === 0 && selection.length === 0) {
        rm_item = items[self2.caretPos - 1];
      } else if (direction > 0 && selection.start === self2.inputValue().length) {
        rm_item = items[self2.caretPos];
      }
      if (rm_item !== void 0) {
        rm_items.push(rm_item);
      }
    }
    if (!self2.shouldDelete(rm_items, e)) {
      return false;
    }
    preventDefault(e, true);
    if (typeof caret !== "undefined") {
      self2.setCaret(caret);
    }
    while (rm_items.length) {
      self2.removeItem(rm_items.pop());
    }
    self2.inputState();
    self2.positionDropdown();
    self2.refreshOptions(false);
    return true;
  }
  /**
   * Return true if the items should be deleted
   */
  shouldDelete(items, evt) {
    const values = items.map((item) => item.dataset.value);
    if (!values.length || typeof this.settings.onDelete === "function" && this.settings.onDelete(values, evt) === false) {
      return false;
    }
    return true;
  }
  /**
   * Selects the previous / next item (depending on the `direction` argument).
   *
   * > 0 - right
   * < 0 - left
   *
   */
  advanceSelection(direction, e) {
    var last_active, adjacent, self2 = this;
    if (self2.rtl)
      direction *= -1;
    if (self2.inputValue().length)
      return;
    if (isKeyDown(KEY_SHORTCUT, e) || isKeyDown("shiftKey", e)) {
      last_active = self2.getLastActive(direction);
      if (last_active) {
        if (!last_active.classList.contains("active")) {
          adjacent = last_active;
        } else {
          adjacent = self2.getAdjacent(last_active, direction, "item");
        }
      } else if (direction > 0) {
        adjacent = self2.control_input.nextElementSibling;
      } else {
        adjacent = self2.control_input.previousElementSibling;
      }
      if (adjacent) {
        if (adjacent.classList.contains("active")) {
          self2.removeActiveItem(last_active);
        }
        self2.setActiveItemClass(adjacent);
      }
    } else {
      self2.moveCaret(direction);
    }
  }
  moveCaret(direction) {
  }
  /**
   * Get the last active item
   *
   */
  getLastActive(direction) {
    let last_active = this.control.querySelector(".last-active");
    if (last_active) {
      return last_active;
    }
    var result = this.control.querySelectorAll(".active");
    if (result) {
      return getTail(result, direction);
    }
  }
  /**
   * Moves the caret to the specified index.
   *
   * The input must be moved by leaving it in place and moving the
   * siblings, due to the fact that focus cannot be restored once lost
   * on mobile webkit devices
   *
   */
  setCaret(new_pos) {
    this.caretPos = this.items.length;
  }
  /**
   * Return list of item dom elements
   *
   */
  controlChildren() {
    return Array.from(this.control.querySelectorAll("[data-ts-item]"));
  }
  /**
   * Disables user input on the control. Used while
   * items are being asynchronously created.
   */
  lock() {
    this.setLocked(true);
  }
  /**
   * Re-enables user input on the control.
   */
  unlock() {
    this.setLocked(false);
  }
  /**
   * Disable or enable user input on the control
   */
  setLocked(lock = this.isReadOnly || this.isDisabled) {
    this.isLocked = lock;
    this.refreshState();
  }
  /**
   * Disables user input on the control completely.
   * While disabled, it cannot receive focus.
   */
  disable() {
    this.setDisabled(true);
    this.close();
  }
  /**
   * Enables the control so that it can respond
   * to focus and user input.
   */
  enable() {
    this.setDisabled(false);
  }
  setDisabled(disabled) {
    this.focus_node.tabIndex = disabled ? -1 : this.tabIndex;
    this.isDisabled = disabled;
    this.input.disabled = disabled;
    this.control_input.disabled = disabled;
    this.setLocked();
  }
  setReadOnly(isReadOnly) {
    this.isReadOnly = isReadOnly;
    this.input.readOnly = isReadOnly;
    this.control_input.readOnly = isReadOnly;
    this.setLocked();
  }
  /**
   * Completely destroys the control and
   * unbinds all event listeners so that it can
   * be garbage collected.
   */
  destroy() {
    var self2 = this;
    var revertSettings = self2.revertSettings;
    self2.trigger("destroy");
    self2.off();
    self2.wrapper.remove();
    self2.dropdown.remove();
    self2.input.innerHTML = revertSettings.innerHTML;
    self2.input.tabIndex = revertSettings.tabIndex;
    removeClasses(self2.input, "tomselected", "ts-hidden-accessible");
    self2._destroy();
    delete self2.input.tomselect;
  }
  /**
   * A helper method for rendering "item" and
   * "option" templates, given the data.
   *
   */
  render(templateName, data) {
    var id, html;
    const self2 = this;
    if (typeof this.settings.render[templateName] !== "function") {
      return null;
    }
    html = self2.settings.render[templateName].call(this, data, escape_html);
    if (!html) {
      return null;
    }
    html = getDom(html);
    if (templateName === "option" || templateName === "option_create") {
      if (data[self2.settings.disabledField]) {
        setAttr(html, { "aria-disabled": "true" });
      } else {
        setAttr(html, { "data-selectable": "" });
      }
    } else if (templateName === "optgroup") {
      id = data.group[self2.settings.optgroupValueField];
      setAttr(html, { "data-group": id });
      if (data.group[self2.settings.disabledField]) {
        setAttr(html, { "data-disabled": "" });
      }
    }
    if (templateName === "option" || templateName === "item") {
      const value = get_hash(data[self2.settings.valueField]);
      setAttr(html, { "data-value": value });
      if (templateName === "item") {
        addClasses(html, self2.settings.itemClass);
        setAttr(html, { "data-ts-item": "" });
      } else {
        addClasses(html, self2.settings.optionClass);
        setAttr(html, {
          role: "option",
          id: data.$id
        });
        data.$div = html;
        self2.options[value] = data;
      }
    }
    return html;
  }
  /**
   * Type guarded rendering
   *
   */
  _render(templateName, data) {
    const html = this.render(templateName, data);
    if (html == null) {
      throw "HTMLElement expected";
    }
    return html;
  }
  /**
   * Clears the render cache for a template. If
   * no template is given, clears all render
   * caches.
   *
   */
  clearCache() {
    iterate2(this.options, (option) => {
      if (option.$div) {
        option.$div.remove();
        delete option.$div;
      }
    });
  }
  /**
   * Removes a value from item and option caches
   *
   */
  uncacheValue(value) {
    const option_el = this.getOption(value);
    if (option_el)
      option_el.remove();
  }
  /**
   * Determines whether or not to display the
   * create item prompt, given a user input.
   *
   */
  canCreate(input) {
    return this.settings.create && input.length > 0 && this.settings.createFilter.call(this, input);
  }
  /**
   * Wraps this.`method` so that `new_fn` can be invoked 'before', 'after', or 'instead' of the original method
   *
   * this.hook('instead','onKeyDown',function( arg1, arg2 ...){
   *
   * });
   */
  hook(when, method, new_fn) {
    var self2 = this;
    var orig_method = self2[method];
    self2[method] = function() {
      var result, result_new;
      if (when === "after") {
        result = orig_method.apply(self2, arguments);
      }
      result_new = new_fn.apply(self2, arguments);
      if (when === "instead") {
        return result_new;
      }
      if (when === "before") {
        result = orig_method.apply(self2, arguments);
      }
      return result;
    };
  }
};

// node_modules/tom-select/dist/esm/plugins/change_listener/plugin.js
var addEvent2 = (target, type, callback, options) => {
  target.addEventListener(type, callback, options);
};
function plugin() {
  addEvent2(this.input, "change", () => {
    this.sync();
  });
}

// node_modules/tom-select/dist/esm/plugins/checkbox_options/plugin.js
var hash_key2 = (value) => {
  if (typeof value === "undefined" || value === null) return null;
  return get_hash2(value);
};
var get_hash2 = (value) => {
  if (typeof value === "boolean") return value ? "1" : "0";
  return value + "";
};
var preventDefault2 = (evt, stop = false) => {
  if (evt) {
    evt.preventDefault();
    if (stop) {
      evt.stopPropagation();
    }
  }
};
var getDom2 = (query) => {
  if (query.jquery) {
    return query[0];
  }
  if (query instanceof HTMLElement) {
    return query;
  }
  if (isHtmlString2(query)) {
    var tpl = document.createElement("template");
    tpl.innerHTML = query.trim();
    return tpl.content.firstChild;
  }
  return document.querySelector(query);
};
var isHtmlString2 = (arg) => {
  if (typeof arg === "string" && arg.indexOf("<") > -1) {
    return true;
  }
  return false;
};
function plugin2(userOptions) {
  var self2 = this;
  var orig_onOptionSelect = self2.onOptionSelect;
  self2.settings.hideSelected = false;
  const cbOptions = Object.assign({
    // so that the user may add different ones as well
    className: "tomselect-checkbox",
    // the following default to the historic plugin's values
    checkedClassNames: void 0,
    uncheckedClassNames: void 0
  }, userOptions);
  var UpdateChecked = function UpdateChecked2(checkbox, toCheck) {
    if (toCheck) {
      checkbox.checked = true;
      if (cbOptions.uncheckedClassNames) {
        checkbox.classList.remove(...cbOptions.uncheckedClassNames);
      }
      if (cbOptions.checkedClassNames) {
        checkbox.classList.add(...cbOptions.checkedClassNames);
      }
    } else {
      checkbox.checked = false;
      if (cbOptions.checkedClassNames) {
        checkbox.classList.remove(...cbOptions.checkedClassNames);
      }
      if (cbOptions.uncheckedClassNames) {
        checkbox.classList.add(...cbOptions.uncheckedClassNames);
      }
    }
  };
  var UpdateCheckbox = function UpdateCheckbox2(option) {
    setTimeout(() => {
      var checkbox = option.querySelector("input." + cbOptions.className);
      if (checkbox instanceof HTMLInputElement) {
        UpdateChecked(checkbox, option.classList.contains("selected"));
      }
    }, 1);
  };
  self2.hook("after", "setupTemplates", () => {
    var orig_render_option = self2.settings.render.option;
    self2.settings.render.option = (data, escape_html3) => {
      var rendered = getDom2(orig_render_option.call(self2, data, escape_html3));
      var checkbox = document.createElement("input");
      if (cbOptions.className) {
        checkbox.classList.add(cbOptions.className);
      }
      checkbox.addEventListener("click", function(evt) {
        preventDefault2(evt);
      });
      checkbox.type = "checkbox";
      const hashed = hash_key2(data[self2.settings.valueField]);
      UpdateChecked(checkbox, !!(hashed && self2.items.indexOf(hashed) > -1));
      rendered.prepend(checkbox);
      return rendered;
    };
  });
  self2.on("item_remove", (value) => {
    var option = self2.getOption(value);
    if (option) {
      option.classList.remove("selected");
      UpdateCheckbox(option);
    }
  });
  self2.on("item_add", (value) => {
    var option = self2.getOption(value);
    if (option) {
      UpdateCheckbox(option);
    }
  });
  self2.hook("instead", "onOptionSelect", (evt, option) => {
    if (option.classList.contains("selected")) {
      option.classList.remove("selected");
      self2.removeItem(option.dataset.value);
      self2.refreshOptions();
      preventDefault2(evt, true);
      return;
    }
    orig_onOptionSelect.call(self2, evt, option);
    UpdateCheckbox(option);
  });
}

// node_modules/tom-select/dist/esm/plugins/clear_button/plugin.js
var getDom3 = (query) => {
  if (query.jquery) {
    return query[0];
  }
  if (query instanceof HTMLElement) {
    return query;
  }
  if (isHtmlString3(query)) {
    var tpl = document.createElement("template");
    tpl.innerHTML = query.trim();
    return tpl.content.firstChild;
  }
  return document.querySelector(query);
};
var isHtmlString3 = (arg) => {
  if (typeof arg === "string" && arg.indexOf("<") > -1) {
    return true;
  }
  return false;
};
function plugin3(userOptions) {
  const self2 = this;
  const options = Object.assign({
    className: "clear-button",
    title: "Clear All",
    html: (data) => {
      return `<div class="${data.className}" title="${data.title}">&#10799;</div>`;
    }
  }, userOptions);
  self2.on("initialize", () => {
    var button = getDom3(options.html(options));
    button.addEventListener("click", (evt) => {
      if (self2.isLocked) return;
      self2.clear();
      if (self2.settings.mode === "single" && self2.settings.allowEmptyOption) {
        self2.addItem("");
      }
      evt.preventDefault();
      evt.stopPropagation();
    });
    self2.control.appendChild(button);
  });
}

// node_modules/tom-select/dist/esm/plugins/drag_drop/plugin.js
var preventDefault3 = (evt, stop = false) => {
  if (evt) {
    evt.preventDefault();
    if (stop) {
      evt.stopPropagation();
    }
  }
};
var addEvent3 = (target, type, callback, options) => {
  target.addEventListener(type, callback, options);
};
var iterate3 = (object, callback) => {
  if (Array.isArray(object)) {
    object.forEach(callback);
  } else {
    for (var key in object) {
      if (object.hasOwnProperty(key)) {
        callback(object[key], key);
      }
    }
  }
};
var getDom4 = (query) => {
  if (query.jquery) {
    return query[0];
  }
  if (query instanceof HTMLElement) {
    return query;
  }
  if (isHtmlString4(query)) {
    var tpl = document.createElement("template");
    tpl.innerHTML = query.trim();
    return tpl.content.firstChild;
  }
  return document.querySelector(query);
};
var isHtmlString4 = (arg) => {
  if (typeof arg === "string" && arg.indexOf("<") > -1) {
    return true;
  }
  return false;
};
var setAttr2 = (el, attrs) => {
  iterate3(attrs, (val, attr) => {
    if (val == null) {
      el.removeAttribute(attr);
    } else {
      el.setAttribute(attr, "" + val);
    }
  });
};
var insertAfter = (referenceNode, newNode) => {
  var _referenceNode$parent;
  (_referenceNode$parent = referenceNode.parentNode) == null || _referenceNode$parent.insertBefore(newNode, referenceNode.nextSibling);
};
var insertBefore = (referenceNode, newNode) => {
  var _referenceNode$parent2;
  (_referenceNode$parent2 = referenceNode.parentNode) == null || _referenceNode$parent2.insertBefore(newNode, referenceNode);
};
var isBefore = (referenceNode, newNode) => {
  do {
    var _newNode;
    newNode = (_newNode = newNode) == null ? void 0 : _newNode.previousElementSibling;
    if (referenceNode == newNode) {
      return true;
    }
  } while (newNode && newNode.previousElementSibling);
  return false;
};
function plugin4() {
  var self2 = this;
  if (self2.settings.mode !== "multi") return;
  var orig_lock = self2.lock;
  var orig_unlock = self2.unlock;
  let sortable = true;
  let drag_item;
  self2.hook("after", "setupTemplates", () => {
    var orig_render_item = self2.settings.render.item;
    self2.settings.render.item = (data, escape) => {
      const item = getDom4(orig_render_item.call(self2, data, escape));
      setAttr2(item, {
        "draggable": "true"
      });
      const mousedown = (evt) => {
        if (!sortable) preventDefault3(evt);
        evt.stopPropagation();
      };
      const dragStart = (evt) => {
        drag_item = item;
        setTimeout(() => {
          item.classList.add("ts-dragging");
        }, 0);
      };
      const dragOver = (evt) => {
        evt.preventDefault();
        item.classList.add("ts-drag-over");
        moveitem(item, drag_item);
      };
      const dragLeave = () => {
        item.classList.remove("ts-drag-over");
      };
      const moveitem = (targetitem, dragitem) => {
        if (dragitem === void 0) return;
        if (isBefore(dragitem, item)) {
          insertAfter(targetitem, dragitem);
        } else {
          insertBefore(targetitem, dragitem);
        }
      };
      const dragend = () => {
        var _drag_item;
        document.querySelectorAll(".ts-drag-over").forEach((el) => el.classList.remove("ts-drag-over"));
        (_drag_item = drag_item) == null || _drag_item.classList.remove("ts-dragging");
        drag_item = void 0;
        var values = [];
        self2.control.querySelectorAll(`[data-value]`).forEach((el) => {
          if (el.dataset.value) {
            let value = el.dataset.value;
            if (value) {
              values.push(value);
            }
          }
        });
        self2.setValue(values);
      };
      addEvent3(item, "mousedown", mousedown);
      addEvent3(item, "dragstart", dragStart);
      addEvent3(item, "dragenter", dragOver);
      addEvent3(item, "dragover", dragOver);
      addEvent3(item, "dragleave", dragLeave);
      addEvent3(item, "dragend", dragend);
      return item;
    };
  });
  self2.hook("instead", "lock", () => {
    sortable = false;
    return orig_lock.call(self2);
  });
  self2.hook("instead", "unlock", () => {
    sortable = true;
    return orig_unlock.call(self2);
  });
}

// node_modules/tom-select/dist/esm/plugins/dropdown_header/plugin.js
var preventDefault4 = (evt, stop = false) => {
  if (evt) {
    evt.preventDefault();
    if (stop) {
      evt.stopPropagation();
    }
  }
};
var getDom5 = (query) => {
  if (query.jquery) {
    return query[0];
  }
  if (query instanceof HTMLElement) {
    return query;
  }
  if (isHtmlString5(query)) {
    var tpl = document.createElement("template");
    tpl.innerHTML = query.trim();
    return tpl.content.firstChild;
  }
  return document.querySelector(query);
};
var isHtmlString5 = (arg) => {
  if (typeof arg === "string" && arg.indexOf("<") > -1) {
    return true;
  }
  return false;
};
function plugin5(userOptions) {
  const self2 = this;
  const options = Object.assign({
    title: "Untitled",
    headerClass: "dropdown-header",
    titleRowClass: "dropdown-header-title",
    labelClass: "dropdown-header-label",
    closeClass: "dropdown-header-close",
    html: (data) => {
      return '<div class="' + data.headerClass + '"><div class="' + data.titleRowClass + '"><span class="' + data.labelClass + '">' + data.title + '</span><a class="' + data.closeClass + '">&times;</a></div></div>';
    }
  }, userOptions);
  self2.on("initialize", () => {
    var header = getDom5(options.html(options));
    var close_link = header.querySelector("." + options.closeClass);
    if (close_link) {
      close_link.addEventListener("click", (evt) => {
        preventDefault4(evt, true);
        self2.close();
      });
    }
    self2.dropdown.insertBefore(header, self2.dropdown.firstChild);
  });
}

// node_modules/tom-select/dist/esm/plugins/caret_position/plugin.js
var iterate4 = (object, callback) => {
  if (Array.isArray(object)) {
    object.forEach(callback);
  } else {
    for (var key in object) {
      if (object.hasOwnProperty(key)) {
        callback(object[key], key);
      }
    }
  }
};
var removeClasses2 = (elmts, ...classes) => {
  var norm_classes = classesArray2(classes);
  elmts = castAsArray2(elmts);
  elmts.map((el) => {
    norm_classes.map((cls) => {
      el.classList.remove(cls);
    });
  });
};
var classesArray2 = (args) => {
  var classes = [];
  iterate4(args, (_classes) => {
    if (typeof _classes === "string") {
      _classes = _classes.trim().split(/[\t\n\f\r\s]/);
    }
    if (Array.isArray(_classes)) {
      classes = classes.concat(_classes);
    }
  });
  return classes.filter(Boolean);
};
var castAsArray2 = (arg) => {
  if (!Array.isArray(arg)) {
    arg = [arg];
  }
  return arg;
};
var nodeIndex2 = (el, amongst) => {
  if (!el) return -1;
  amongst = amongst || el.nodeName;
  var i = 0;
  while (el = el.previousElementSibling) {
    if (el.matches(amongst)) {
      i++;
    }
  }
  return i;
};
function plugin6() {
  var self2 = this;
  self2.hook("instead", "setCaret", (new_pos) => {
    if (self2.settings.mode === "single" || !self2.control.contains(self2.control_input)) {
      new_pos = self2.items.length;
    } else {
      new_pos = Math.max(0, Math.min(self2.items.length, new_pos));
      if (new_pos != self2.caretPos && !self2.isPending) {
        self2.controlChildren().forEach((child, j) => {
          if (j < new_pos) {
            self2.control_input.insertAdjacentElement("beforebegin", child);
          } else {
            self2.control.appendChild(child);
          }
        });
      }
    }
    self2.caretPos = new_pos;
  });
  self2.hook("instead", "moveCaret", (direction) => {
    if (!self2.isFocused) return;
    const last_active = self2.getLastActive(direction);
    if (last_active) {
      const idx = nodeIndex2(last_active);
      self2.setCaret(direction > 0 ? idx + 1 : idx);
      self2.setActiveItem();
      removeClasses2(last_active, "last-active");
    } else {
      self2.setCaret(self2.caretPos + direction);
    }
  });
}

// node_modules/tom-select/dist/esm/plugins/dropdown_input/plugin.js
var KEY_ESC2 = 27;
var KEY_TAB2 = 9;
var preventDefault5 = (evt, stop = false) => {
  if (evt) {
    evt.preventDefault();
    if (stop) {
      evt.stopPropagation();
    }
  }
};
var addEvent4 = (target, type, callback, options) => {
  target.addEventListener(type, callback, options);
};
var iterate5 = (object, callback) => {
  if (Array.isArray(object)) {
    object.forEach(callback);
  } else {
    for (var key in object) {
      if (object.hasOwnProperty(key)) {
        callback(object[key], key);
      }
    }
  }
};
var getDom6 = (query) => {
  if (query.jquery) {
    return query[0];
  }
  if (query instanceof HTMLElement) {
    return query;
  }
  if (isHtmlString6(query)) {
    var tpl = document.createElement("template");
    tpl.innerHTML = query.trim();
    return tpl.content.firstChild;
  }
  return document.querySelector(query);
};
var isHtmlString6 = (arg) => {
  if (typeof arg === "string" && arg.indexOf("<") > -1) {
    return true;
  }
  return false;
};
var addClasses2 = (elmts, ...classes) => {
  var norm_classes = classesArray3(classes);
  elmts = castAsArray3(elmts);
  elmts.map((el) => {
    norm_classes.map((cls) => {
      el.classList.add(cls);
    });
  });
};
var classesArray3 = (args) => {
  var classes = [];
  iterate5(args, (_classes) => {
    if (typeof _classes === "string") {
      _classes = _classes.trim().split(/[\t\n\f\r\s]/);
    }
    if (Array.isArray(_classes)) {
      classes = classes.concat(_classes);
    }
  });
  return classes.filter(Boolean);
};
var castAsArray3 = (arg) => {
  if (!Array.isArray(arg)) {
    arg = [arg];
  }
  return arg;
};
function plugin7() {
  const self2 = this;
  self2.settings.shouldOpen = true;
  self2.hook("before", "setup", () => {
    self2.focus_node = self2.control;
    addClasses2(self2.control_input, "dropdown-input");
    const div = getDom6('<div class="dropdown-input-wrap">');
    div.append(self2.control_input);
    self2.dropdown.insertBefore(div, self2.dropdown.firstChild);
    const placeholder = getDom6('<input class="items-placeholder" tabindex="-1" />');
    placeholder.placeholder = self2.settings.placeholder || "";
    self2.control.append(placeholder);
  });
  self2.on("initialize", () => {
    self2.control_input.addEventListener("keydown", (evt) => {
      switch (evt.keyCode) {
        case KEY_ESC2:
          if (self2.isOpen) {
            preventDefault5(evt, true);
            self2.close();
          }
          self2.clearActiveItems();
          return;
        case KEY_TAB2:
          self2.focus_node.tabIndex = -1;
          break;
      }
      return self2.onKeyDown.call(self2, evt);
    });
    self2.on("blur", () => {
      self2.focus_node.tabIndex = self2.isDisabled ? -1 : self2.tabIndex;
    });
    self2.on("dropdown_open", () => {
      self2.control_input.focus();
    });
    const orig_onBlur = self2.onBlur;
    self2.hook("instead", "onBlur", (evt) => {
      if (evt && evt.relatedTarget == self2.control_input) return;
      return orig_onBlur.call(self2);
    });
    addEvent4(self2.control_input, "blur", () => self2.onBlur());
    self2.hook("before", "close", () => {
      if (!self2.isOpen) return;
      self2.focus_node.focus({
        preventScroll: true
      });
    });
  });
}

// node_modules/tom-select/dist/esm/plugins/input_autogrow/plugin.js
var addEvent5 = (target, type, callback, options) => {
  target.addEventListener(type, callback, options);
};
function plugin8() {
  var self2 = this;
  self2.on("initialize", () => {
    var test_input = document.createElement("span");
    var control = self2.control_input;
    test_input.style.cssText = "position:absolute; top:-99999px; left:-99999px; width:auto; padding:0; white-space:pre; ";
    self2.wrapper.appendChild(test_input);
    var transfer_styles = ["letterSpacing", "fontSize", "fontFamily", "fontWeight", "textTransform"];
    for (const style_name of transfer_styles) {
      test_input.style[style_name] = control.style[style_name];
    }
    var resize = () => {
      test_input.textContent = control.value;
      control.style.width = test_input.clientWidth + "px";
    };
    resize();
    self2.on("update item_add item_remove", resize);
    addEvent5(control, "input", resize);
    addEvent5(control, "keyup", resize);
    addEvent5(control, "blur", resize);
    addEvent5(control, "update", resize);
  });
}

// node_modules/tom-select/dist/esm/plugins/no_backspace_delete/plugin.js
function plugin9() {
  var self2 = this;
  var orig_deleteSelection = self2.deleteSelection;
  this.hook("instead", "deleteSelection", (evt) => {
    if (self2.activeItems.length) {
      return orig_deleteSelection.call(self2, evt);
    }
    return false;
  });
}

// node_modules/tom-select/dist/esm/plugins/no_active_items/plugin.js
function plugin10() {
  this.hook("instead", "setActiveItem", () => {
  });
  this.hook("instead", "selectAll", () => {
  });
}

// node_modules/tom-select/dist/esm/plugins/optgroup_columns/plugin.js
var KEY_LEFT2 = 37;
var KEY_RIGHT2 = 39;
var parentMatch2 = (target, selector, wrapper) => {
  while (target && target.matches) {
    if (target.matches(selector)) {
      return target;
    }
    target = target.parentNode;
  }
};
var nodeIndex3 = (el, amongst) => {
  if (!el) return -1;
  amongst = amongst || el.nodeName;
  var i = 0;
  while (el = el.previousElementSibling) {
    if (el.matches(amongst)) {
      i++;
    }
  }
  return i;
};
function plugin11() {
  var self2 = this;
  var orig_keydown = self2.onKeyDown;
  self2.hook("instead", "onKeyDown", (evt) => {
    var index, option, options, optgroup;
    if (!self2.isOpen || !(evt.keyCode === KEY_LEFT2 || evt.keyCode === KEY_RIGHT2)) {
      return orig_keydown.call(self2, evt);
    }
    self2.ignoreHover = true;
    optgroup = parentMatch2(self2.activeOption, "[data-group]");
    index = nodeIndex3(self2.activeOption, "[data-selectable]");
    if (!optgroup) {
      return;
    }
    if (evt.keyCode === KEY_LEFT2) {
      optgroup = optgroup.previousSibling;
    } else {
      optgroup = optgroup.nextSibling;
    }
    if (!optgroup) {
      return;
    }
    options = optgroup.querySelectorAll("[data-selectable]");
    option = options[Math.min(options.length - 1, index)];
    if (option) {
      self2.setActiveOption(option);
    }
  });
}

// node_modules/tom-select/dist/esm/plugins/remove_button/plugin.js
var escape_html2 = (str) => {
  return (str + "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
};
var preventDefault6 = (evt, stop = false) => {
  if (evt) {
    evt.preventDefault();
    if (stop) {
      evt.stopPropagation();
    }
  }
};
var addEvent6 = (target, type, callback, options) => {
  target.addEventListener(type, callback, options);
};
var getDom7 = (query) => {
  if (query.jquery) {
    return query[0];
  }
  if (query instanceof HTMLElement) {
    return query;
  }
  if (isHtmlString7(query)) {
    var tpl = document.createElement("template");
    tpl.innerHTML = query.trim();
    return tpl.content.firstChild;
  }
  return document.querySelector(query);
};
var isHtmlString7 = (arg) => {
  if (typeof arg === "string" && arg.indexOf("<") > -1) {
    return true;
  }
  return false;
};
function plugin12(userOptions) {
  const options = Object.assign({
    label: "&times;",
    title: "Remove",
    className: "remove",
    append: true
  }, userOptions);
  var self2 = this;
  if (!options.append) {
    return;
  }
  var html = '<a href="javascript:void(0)" class="' + options.className + '" tabindex="-1" title="' + escape_html2(options.title) + '">' + options.label + "</a>";
  self2.hook("after", "setupTemplates", () => {
    var orig_render_item = self2.settings.render.item;
    self2.settings.render.item = (data, escape) => {
      var item = getDom7(orig_render_item.call(self2, data, escape));
      var close_button = getDom7(html);
      item.appendChild(close_button);
      addEvent6(close_button, "mousedown", (evt) => {
        preventDefault6(evt, true);
      });
      addEvent6(close_button, "click", (evt) => {
        if (self2.isLocked) return;
        preventDefault6(evt, true);
        if (self2.isLocked) return;
        if (!self2.shouldDelete([item], evt)) return;
        self2.removeItem(item);
        self2.refreshOptions(false);
        self2.inputState();
      });
      return item;
    };
  });
}

// node_modules/tom-select/dist/esm/plugins/restore_on_backspace/plugin.js
function plugin13(userOptions) {
  const self2 = this;
  const options = Object.assign({
    text: (option) => {
      return option[self2.settings.labelField];
    }
  }, userOptions);
  self2.on("item_remove", function(value) {
    if (!self2.isFocused) {
      return;
    }
    if (self2.control_input.value.trim() === "") {
      var option = self2.options[value];
      if (option) {
        self2.setTextboxValue(options.text.call(self2, option));
      }
    }
  });
}

// node_modules/tom-select/dist/esm/plugins/virtual_scroll/plugin.js
var iterate6 = (object, callback) => {
  if (Array.isArray(object)) {
    object.forEach(callback);
  } else {
    for (var key in object) {
      if (object.hasOwnProperty(key)) {
        callback(object[key], key);
      }
    }
  }
};
var addClasses3 = (elmts, ...classes) => {
  var norm_classes = classesArray4(classes);
  elmts = castAsArray4(elmts);
  elmts.map((el) => {
    norm_classes.map((cls) => {
      el.classList.add(cls);
    });
  });
};
var classesArray4 = (args) => {
  var classes = [];
  iterate6(args, (_classes) => {
    if (typeof _classes === "string") {
      _classes = _classes.trim().split(/[\t\n\f\r\s]/);
    }
    if (Array.isArray(_classes)) {
      classes = classes.concat(_classes);
    }
  });
  return classes.filter(Boolean);
};
var castAsArray4 = (arg) => {
  if (!Array.isArray(arg)) {
    arg = [arg];
  }
  return arg;
};
function plugin14() {
  const self2 = this;
  const orig_canLoad = self2.canLoad;
  const orig_clearActiveOption = self2.clearActiveOption;
  const orig_loadCallback = self2.loadCallback;
  var pagination = {};
  var dropdown_content;
  var loading_more = false;
  var load_more_opt;
  var default_values = [];
  if (!self2.settings.shouldLoadMore) {
    self2.settings.shouldLoadMore = () => {
      const scroll_percent = dropdown_content.clientHeight / (dropdown_content.scrollHeight - dropdown_content.scrollTop);
      if (scroll_percent > 0.9) {
        return true;
      }
      if (self2.activeOption) {
        var selectable = self2.selectable();
        var index = Array.from(selectable).indexOf(self2.activeOption);
        if (index >= selectable.length - 2) {
          return true;
        }
      }
      return false;
    };
  }
  if (!self2.settings.firstUrl) {
    throw "virtual_scroll plugin requires a firstUrl() method";
  }
  self2.settings.sortField = [{
    field: "$order"
  }, {
    field: "$score"
  }];
  const canLoadMore = (query) => {
    if (typeof self2.settings.maxOptions === "number" && dropdown_content.children.length >= self2.settings.maxOptions) {
      return false;
    }
    if (query in pagination && pagination[query]) {
      return true;
    }
    return false;
  };
  const clearFilter = (option, value) => {
    if (self2.items.indexOf(value) >= 0 || default_values.indexOf(value) >= 0) {
      return true;
    }
    return false;
  };
  self2.setNextUrl = (value, next_url) => {
    pagination[value] = next_url;
  };
  self2.getUrl = (query) => {
    if (query in pagination) {
      const next_url = pagination[query];
      pagination[query] = false;
      return next_url;
    }
    self2.clearPagination();
    return self2.settings.firstUrl.call(self2, query);
  };
  self2.clearPagination = () => {
    pagination = {};
  };
  self2.hook("instead", "clearActiveOption", () => {
    if (loading_more) {
      return;
    }
    return orig_clearActiveOption.call(self2);
  });
  self2.hook("instead", "canLoad", (query) => {
    if (!(query in pagination)) {
      return orig_canLoad.call(self2, query);
    }
    return canLoadMore(query);
  });
  self2.hook("instead", "loadCallback", (options, optgroups) => {
    if (!loading_more) {
      self2.clearOptions(clearFilter);
    } else if (load_more_opt) {
      const first_option = options[0];
      if (first_option !== void 0) {
        load_more_opt.dataset.value = first_option[self2.settings.valueField];
      }
    }
    orig_loadCallback.call(self2, options, optgroups);
    loading_more = false;
  });
  self2.hook("after", "refreshOptions", () => {
    const query = self2.lastValue;
    var option;
    if (canLoadMore(query)) {
      option = self2.render("loading_more", {
        query
      });
      if (option) {
        option.setAttribute("data-selectable", "");
        load_more_opt = option;
      }
    } else if (query in pagination && !dropdown_content.querySelector(".no-results")) {
      option = self2.render("no_more_results", {
        query
      });
    }
    if (option) {
      addClasses3(option, self2.settings.optionClass);
      dropdown_content.append(option);
    }
  });
  self2.on("initialize", () => {
    default_values = Object.keys(self2.options);
    dropdown_content = self2.dropdown_content;
    self2.settings.render = Object.assign({}, {
      loading_more: () => {
        return `<div class="loading-more-results">Loading more results ... </div>`;
      },
      no_more_results: () => {
        return `<div class="no-more-results">No more results</div>`;
      }
    }, self2.settings.render);
    dropdown_content.addEventListener("scroll", () => {
      if (!self2.settings.shouldLoadMore.call(self2)) {
        return;
      }
      if (!canLoadMore(self2.lastValue)) {
        return;
      }
      if (loading_more) return;
      loading_more = true;
      self2.load.call(self2, self2.lastValue);
    });
  });
}

// node_modules/tom-select/dist/esm/tom-select.complete.js
TomSelect.define("change_listener", plugin);
TomSelect.define("checkbox_options", plugin2);
TomSelect.define("clear_button", plugin3);
TomSelect.define("drag_drop", plugin4);
TomSelect.define("dropdown_header", plugin5);
TomSelect.define("caret_position", plugin6);
TomSelect.define("dropdown_input", plugin7);
TomSelect.define("input_autogrow", plugin8);
TomSelect.define("no_backspace_delete", plugin9);
TomSelect.define("no_active_items", plugin10);
TomSelect.define("optgroup_columns", plugin11);
TomSelect.define("remove_button", plugin12);
TomSelect.define("restore_on_backspace", plugin13);
TomSelect.define("virtual_scroll", plugin14);
var tom_select_complete_default = TomSelect;

// app/javascript/controllers/select_controller.js
var select_controller_default = class extends Controller2 {
  static targets = ["containerList"];
  connect() {
    this.initializeTomSelect();
    this.initializeSelectedContainers();
  }
  initializeTomSelect() {
    if (!this.element) return;
    this.select = new tom_select_complete_default(this.element, {
      create: (input) => this.addNewWasteCategory(input, this.element),
      onItemAdd: (value, item) => this.addContainerRow(value, item),
      onItemRemove: (value) => this.removeContainerRow(value),
      sortField: {
        field: "text",
        direction: "asc"
      },
      ...this.optionsValue
    });
  }
  initializeSelectedContainers() {
    const existingContainersInput = document.getElementById(
      "existing-containers-data"
    );
    const existingContainers = existingContainersInput ? JSON.parse(existingContainersInput.value) : [];
    console.log("existingContainers", existingContainers);
    existingContainers.forEach((container, index) => {
      this.addContainerRow(
        container.name,
        null,
        container.cost,
        container.charge,
        container.id || index
      );
    });
    const selectElement = document.querySelector("#container-multiselect");
    if (selectElement) {
      Array.from(selectElement.selectedOptions).forEach((option) => {
        const existingContainer = existingContainers.find(
          (c) => c.name === option.value
        );
        console.log("option", option);
        console.log("existingContainer", existingContainer);
        if (existingContainer) {
          this.addExistingContainerRow(existingContainer);
        }
      });
    } else {
      console.error("Multi-select element not found.");
    }
  }
  addExistingContainerRow(existingContainer) {
    console.log("existingContainer...", existingContainer);
    const containerRow = document.createElement("div");
    containerRow.classList.add(
      "flex",
      "justify-between",
      "items-center",
      "bg-gray-100",
      "p-2",
      "mb-2",
      "border",
      "rounded"
    );
    containerRow.setAttribute("data-container-id", existingContainer.name);
    containerRow.innerHTML = `
      <span>Container Name: <span class="text-red-500 font-semibold mx-2">${existingContainer.name}</span></span>
      <div class="flex items-center">
        <label class="mr-2">Disposal Cost: $</label>
        <input type="number" name="disposal_cost[disposal_containers_attributes][${existingContainer.id}][cost]" class="border rounded p-1 w-20 text-center" value="${existingContainer.cost}" />
        <label class="ml-4 mr-2">Disposal Charge: $</label>
        <input type="number" name="disposal_cost[disposal_containers_attributes][${existingContainer.id}][charge]" class="border rounded p-1 w-20 text-center" value="${existingContainer.charge}" />
        <input type="hidden" name="disposal_cost[disposal_containers_attributes][${existingContainer.id}][name]" value="${existingContainer.name}" />
        ${existingContainer.id ? `<input type="hidden" name="disposal_cost[disposal_containers_attributes][${existingContainer.id}][id]" value="${existingContainer.id}" />` : ""}
      </div>
    `;
    const containerList = document.querySelector("#containerList");
    if (containerList) {
      containerList.appendChild(containerRow);
    } else {
      console.error("ContainerList is not available.");
    }
  }
  addContainerRow(value, item) {
    if (!item) {
      return;
    }
    const uniqueIndex = (/* @__PURE__ */ new Date()).getTime();
    const containerRow = document.createElement("div");
    containerRow.classList.add(
      "flex",
      "justify-between",
      "items-center",
      "bg-gray-100",
      "p-2",
      "mb-2",
      "border",
      "rounded"
    );
    containerRow.setAttribute("data-container-id", value);
    console.log("value", value);
    console.log("uniqueIndex", uniqueIndex);
    containerRow.innerHTML = `
      <span class="text-red-500 font-semibold mr-4">${item.textContent}</span>
      <div class="flex items-center">
        <label class="mr-2">Disposal Cost: $</label>
        <input type="number" name="disposal_cost[disposal_containers_attributes][${uniqueIndex}][cost]" class="border rounded p-1 w-20 text-center" />
        <label class="ml-4 mr-2">Disposal Charge: $</label>
        <input type="number" name="disposal_cost[disposal_containers_attributes][${uniqueIndex}][charge]" class="border rounded p-1 w-20 text-center" />
        <input type="hidden" name="disposal_cost[disposal_containers_attributes][${uniqueIndex}][name]" value="${value}" />
      </div>
    `;
    const containerList = document.querySelector("#containerList");
    if (containerList) {
      containerList.appendChild(containerRow);
    } else {
      console.error("ContainerList is not available.");
    }
  }
  removeContainerRow(value) {
    const containerRow = document.querySelector(
      `#containerList [data-container-id="${value}"]`
    );
    if (containerRow) {
      containerRow.remove();
    } else {
      console.error(`No container row found with id ${value}.`);
    }
  }
};

// node_modules/stimulus-use/dist/index.js
var composeEventName = (name, controller, eventPrefix) => {
  let composedName = name;
  if (eventPrefix === true) {
    composedName = `${controller.identifier}:${name}`;
  } else if (typeof eventPrefix === "string") {
    composedName = `${eventPrefix}:${name}`;
  }
  return composedName;
};
var extendedEvent = (type, event, detail) => {
  const { bubbles, cancelable, composed } = event || {
    bubbles: true,
    cancelable: true,
    composed: true
  };
  if (event) {
    Object.assign(detail, {
      originalEvent: event
    });
  }
  const customEvent = new CustomEvent(type, {
    bubbles,
    cancelable,
    composed,
    detail
  });
  return customEvent;
};
function isElementInViewport(el) {
  const rect = el.getBoundingClientRect();
  const windowHeight = window.innerHeight || document.documentElement.clientHeight;
  const windowWidth = window.innerWidth || document.documentElement.clientWidth;
  const vertInView = rect.top <= windowHeight && rect.top + rect.height > 0;
  const horInView = rect.left <= windowWidth && rect.left + rect.width > 0;
  return vertInView && horInView;
}
var defaultOptions$5 = {
  events: ["click", "touchend"],
  onlyVisible: true,
  dispatchEvent: true,
  eventPrefix: true
};
var useClickOutside = (composableController, options = {}) => {
  const controller = composableController;
  const { onlyVisible, dispatchEvent: dispatchEvent2, events, eventPrefix } = Object.assign({}, defaultOptions$5, options);
  const onEvent = (event) => {
    const targetElement = (options === null || options === void 0 ? void 0 : options.element) || controller.element;
    if (targetElement.contains(event.target) || !isElementInViewport(targetElement) && onlyVisible) {
      return;
    }
    if (controller.clickOutside) {
      controller.clickOutside(event);
    }
    if (dispatchEvent2) {
      const eventName = composeEventName("click:outside", controller, eventPrefix);
      const clickOutsideEvent = extendedEvent(eventName, event, {
        controller
      });
      targetElement.dispatchEvent(clickOutsideEvent);
    }
  };
  const observe = () => {
    events === null || events === void 0 ? void 0 : events.forEach((event) => {
      window.addEventListener(event, onEvent, true);
    });
  };
  const unobserve = () => {
    events === null || events === void 0 ? void 0 : events.forEach((event) => {
      window.removeEventListener(event, onEvent, true);
    });
  };
  const controllerDisconnect = controller.disconnect.bind(controller);
  Object.assign(controller, {
    disconnect() {
      unobserve();
      controllerDisconnect();
    }
  });
  observe();
  return [observe, unobserve];
};
var DebounceController = class extends Controller {
};
DebounceController.debounces = [];
var ThrottleController = class extends Controller {
};
ThrottleController.throttles = [];

// app/javascript/controllers/toggle_controller.js
var toggle_controller_default = class extends Controller {
  static targets = ["toggleable"];
  connect() {
    useClickOutside(this);
  }
  toggle(e) {
    e.preventDefault();
    this.toggleableTargets.forEach((target) => {
      target.classList.toggle(target.dataset.cssClass);
    });
  }
  clickOutside(event) {
    if (this.data.get("clickOutside") === "add") {
      this.toggleableTargets.forEach((target) => {
        target.classList.add(target.dataset.cssClass);
      });
    } else if (this.data.get("clickOutside") === "remove") {
      this.toggleableTargets.forEach((target) => {
        target.classList.remove(target.dataset.cssClass);
      });
    }
  }
};

// app/javascript/controllers/tom_select_controller.js
var tom_select_controller_default = class extends Controller2 {
  connect() {
    this.initializeTomSelect();
  }
  disconnect() {
    this.destroyTomSelect();
  }
  initializeTomSelect() {
    if (!this.element) return;
    this.select = new tom_select_complete_default(this.element, {
      sortField: {
        field: "text",
        direction: "asc"
      },
      ...this.optionsValue
      // Spread other potential options passed via data attributes
    });
  }
  destroyTomSelect() {
    if (this.select) {
      this.select.destroy();
    }
  }
};

// app/javascript/controllers/tabs_controller.js
var tabs_controller_default = class extends Controller {
  static targets = ["tabContent"];
  connect() {
    this.checkHash();
    window.addEventListener("hashchange", this.checkHash.bind(this));
  }
  disconnect() {
    window.removeEventListener("hashchange", this.checkHash.bind(this));
  }
  checkHash() {
    const hash = window.location.hash.substring(1);
    console.log("hash", hash);
    if (hash) {
      this.activateTab(hash);
    } else {
      this.activateTab("general");
    }
  }
  switchTab(event) {
    const targetTab = event.currentTarget.dataset.tab;
    this.activateTab(targetTab);
  }
  activateTab(targetTab) {
    this.tabContentTargets.forEach((element) => {
      if (element.dataset.tabsTabContent === targetTab) {
        element.classList.remove("hidden");
      } else {
        element.classList.add("hidden");
      }
    });
    this.element.querySelectorAll("button").forEach((button) => {
      if (button.dataset.tab === targetTab) {
        button.classList.replace("bg-gray-200", "bg-red-700");
        button.classList.replace("text-gray-600", "text-white");
      } else {
        button.classList.replace("bg-red-700", "bg-gray-200");
        button.classList.replace("text-white", "text-gray-600");
      }
    });
    history.pushState(null, null, `#${targetTab}`);
  }
};

// app/javascript/controllers/client_type_controller.js
var client_type_controller_default = class extends Controller {
  static targets = ["newClientForm", "existingClientForm", "btnWrapper", "modalHeader"];
  toggle(event) {
    event.preventDefault();
    const clientType = event.target.dataset.clientType;
    this.newClientFormTarget.classList.add("hidden");
    this.existingClientFormTarget.classList.add("hidden");
    this.btnWrapperTarget.classList.add("hidden");
    this.modalHeaderTarget.classList.add("hidden");
    if (clientType === "new") {
      this.newClientFormTarget.classList.remove("hidden");
    } else if (clientType === "existing") {
      this.existingClientFormTarget.classList.remove("hidden");
    }
  }
};

// app/javascript/controllers/populate_waste_controller.js
var populate_waste_controller_default = class extends Controller2 {
  static targets = [
    "dotShippingDescription",
    "processingCode",
    "wasteType",
    "containerType",
    "vendor",
    "mxiCost",
    "clientCost",
    "wasteCommonName"
  ];
  populate(event) {
    const selectedId = event.target.value;
    fetch(`/disposal_costs/${selectedId}.json`).then((response) => response.json()).then((data) => {
      this.dotShippingDescriptionTarget.value = data.dot_shipping_description;
      this.processingCodeTarget.value = data.processing_code;
      this.wasteTypeTarget.value = data.waste_type;
      this.wasteCommonNameTarget.value = data.waste_common_name;
      this.populateDropdown(
        this.containerTypeTarget,
        data.disposal_containers,
        "Select a container"
      );
      this.populateDropdown(
        this.vendorTarget,
        data.vendors,
        "Select a vendor"
      );
    }).catch(
      (error2) => console.error("Error fetching disposal cost data:", error2)
    );
  }
  populateDropdown(targetElement, items, defaultText = "Select an option") {
    if (!Array.isArray(items)) {
      console.log("Expected array but got:", typeof items);
      return;
    }
    targetElement.innerHTML = "";
    const defaultOption = document.createElement("option");
    defaultOption.text = defaultText;
    defaultOption.value = "";
    targetElement.add(defaultOption);
    items.forEach((item) => {
      const option = document.createElement("option");
      option.text = item.name || item.company_name || "Unnamed";
      option.value = item.name || item.company_name;
      if (item.cost) option.dataset.cost = item.cost;
      if (item.charge) option.dataset.charge = item.charge;
      targetElement.add(option);
    });
  }
  // New method to populate cost and charge
  populateCostAndCharge(event) {
    const selectedOption = event.target.selectedOptions[0];
    const cost = selectedOption.dataset.cost;
    const charge = selectedOption.dataset.charge;
    this.mxiCostTarget.value = cost;
    this.clientCostTarget.value = charge;
  }
};

// app/javascript/controllers/index.js
application.register("alerts", alerts_controller_default);
application.register("dropdown", dropdown_controller_default);
application.register("hello", hello_controller_default);
application.register("modal", modal_controller_default);
application.register("multiselect", multiselect_controller_default);
application.register("nested-form", nested_form_controller_default);
application.register("phone-format", phone_format_controller_default);
application.register("searchable-dropdown", searchable_dropdown_controller_default);
application.register("select", select_controller_default);
application.register("toggle", toggle_controller_default);
application.register("tom-select", tom_select_controller_default);
application.register("tabs", tabs_controller_default);
application.register("client-type", client_type_controller_default);
application.register("populate-waste", populate_waste_controller_default);
/*! Bundled license information:

@hotwired/turbo/dist/turbo.es2017-esm.js:
  (*!
  Turbo 8.0.12
  Copyright © 2024 37signals LLC
   *)
*/
//# sourceMappingURL=/assets/application.js.map
