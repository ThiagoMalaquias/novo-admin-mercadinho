import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const url = new URL(window.location.href)
    if (!url.searchParams.has("page")) return

    this.scrollToBottom()
  }

  scrollToBottom() {
    const main = document.querySelector("main")
    if (!main) return

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        main.scrollTo({ top: main.scrollHeight, behavior: "smooth" })
      })
    })
  }
}
