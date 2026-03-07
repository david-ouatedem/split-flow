import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  copy() {
    const text = this.textValue || this.element.closest(".join")?.querySelector("input")?.value

    if (text) {
      navigator.clipboard.writeText(text).then(() => {
        const originalText = this.element.textContent
        this.element.textContent = "Copied!"
        this.element.classList.add("btn-success")

        setTimeout(() => {
          this.element.textContent = originalText
          this.element.classList.remove("btn-success")
        }, 2000)
      })
    }
  }
}
