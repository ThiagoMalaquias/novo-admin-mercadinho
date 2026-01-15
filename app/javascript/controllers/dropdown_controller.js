import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "icon"]

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    const isHidden = this.menuTarget.classList.contains("hidden")

    // Fechar todos os outros dropdowns
    document.querySelectorAll('[data-controller*="dropdown"]').forEach(dropdown => {
      const menu = dropdown.querySelector('[data-dropdown-target="menu"]')
      const icon = dropdown.querySelector('[data-dropdown-target="icon"]')
      if (menu && menu !== this.menuTarget) {
        menu.classList.add("hidden")
        if (icon) icon.classList.remove("rotate-180")
      }
    })

    // Toggle do menu atual
    this.menuTarget.classList.toggle("hidden")
    if (this.hasIconTarget) {
      this.iconTarget.classList.toggle("rotate-180")
    }
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
      if (this.hasIconTarget) {
        this.iconTarget.classList.remove("rotate-180")
      }
    }
  }

  connect() {
    this.boundHide = this.hide.bind(this)
    document.addEventListener("click", this.boundHide)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHide)
  }
}

