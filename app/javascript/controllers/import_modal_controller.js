import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "fileInput", "openButton", "closeButton"]

  connect() {
    // Fechar modal ao clicar fora dele
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  open() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden")
      this.modalTarget.classList.add("flex")
    }
  }

  close() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
      this.modalTarget.classList.remove("flex")
    }
  }

  importFile() {
    if (this.hasFileInputTarget) {
      this.fileInputTarget.click()
    }
  }

  handleFileChange(event) {
    if (event.target.files.length > 0 && this.hasFormTarget) {
      this.formTarget.requestSubmit()
    }
  }

  handleClickOutside(event) {
    if (!this.hasModalTarget) return

    if (this.modalTarget.contains(event.target)) {
      return
    }

    // Se clicou no botão de abrir, não fechar
    if (this.hasOpenButtonTarget && this.openButtonTarget.contains(event.target)) {
      return
    }

    // Se o modal está aberto e clicou fora, fechar
    if (!this.modalTarget.classList.contains("hidden")) {
      this.close()
    }
  }
}