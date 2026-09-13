import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["imagemInput", "previewContainer", "previewImg", "preco"]

  preventEnterSubmit(event) {
    if (event.key !== "Enter" && event.keyCode !== 13) return

    const tag = event.target.tagName
    const type = event.target.type

    if (tag === "TEXTAREA") return
    if (tag === "BUTTON" || type === "submit") return

    event.preventDefault()
  }

  validarPreco(event) {
    if (!this.hasPrecoTarget) return

    const valor = this.precoTarget.value
      .replace(/\./g, "")
      .replace(",", ".")
      .trim()

    if (!valor || Number(valor) <= 0) {
      event.preventDefault()
      this.precoTarget.setCustomValidity("Informe um preço maior que zero")
      this.precoTarget.reportValidity()
      return
    }

    this.precoTarget.setCustomValidity("")
  }

  limparErroPreco() {
    if (!this.hasPrecoTarget) return
    this.precoTarget.setCustomValidity("")
  }

  previewImagem() {
    if (!this.hasImagemInputTarget) return

    const input = this.imagemInputTarget
    if (!input.files || !input.files[0]) return

    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasPreviewImgTarget) {
        this.previewImgTarget.src = e.target.result
        this.previewImgTarget.classList.remove("hidden")
      }
      if (this.hasPreviewContainerTarget) {
        this.previewContainerTarget.classList.remove("hidden")
      }
    }
    reader.readAsDataURL(input.files[0])
  }
}
