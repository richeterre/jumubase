import "phoenix_html"
import "bootstrap-sass"

// Import polyfills needed for IE11 support
// (see https://github.com/phoenixframework/phoenix_live_view#browser-support)
import "mdn-polyfills/Object.assign"
import "mdn-polyfills/CustomEvent"
import "mdn-polyfills/String.prototype.startsWith"
import "mdn-polyfills/Array.from"
import "mdn-polyfills/Array.prototype.find"
import "mdn-polyfills/Array.prototype.some"
import "mdn-polyfills/NodeList.prototype.forEach"
import "mdn-polyfills/Element.prototype.closest"
import "mdn-polyfills/Element.prototype.matches"
import "mdn-polyfills/Node.prototype.remove"
import "child-replace-with-polyfill"
import "url-search-params-polyfill"
import "formdata-polyfill"
import "classlist-polyfill"
import "@webcomponents/template"
import "shim-keyboard-event-key"
import "core-js/features/set"

import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
})

// Connect if there are any LiveViews on the page
liveSocket.connect()
// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
