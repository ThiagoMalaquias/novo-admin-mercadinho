import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["imagemInput", "previewContainer", "previewImg"]

  preventEnterSubmit(event) {
    if (event.key !== "Enter" && event.keyCode !== 13) return

    const tag = event.target.tagName
    const type = event.target.type

    if (tag === "TEXTAREA") return
    if (tag === "BUTTON" || type === "submit") return

    event.preventDefault()
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
