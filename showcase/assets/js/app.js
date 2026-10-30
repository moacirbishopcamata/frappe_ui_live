import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
// Hooks colocated da biblioteca (extraídos na compilação pelo compilador do LiveView).
import {hooks as frappeUiHooks} from "phoenix-colocated/frappe_ui_live"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...frappeUiHooks},
})

liveSocket.connect()
window.liveSocket = liveSocket
