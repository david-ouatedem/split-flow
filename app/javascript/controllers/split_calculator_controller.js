import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["percentage", "total", "submitButton"]

  connect() {
    this.calculate()
  }

  calculate() {
    let total = 0
    this.percentageTargets.forEach(input => {
      const value = parseFloat(input.value) || 0
      total += value
    })

    const rounded = Math.round(total * 100) / 100
    this.totalTarget.textContent = `${rounded}%`

    if (rounded >= 99.99 && rounded <= 100.01) {
      this.totalTarget.classList.remove("text-error")
      this.totalTarget.classList.add("text-success")
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.classList.remove("btn-disabled")
      }
    } else {
      this.totalTarget.classList.remove("text-success")
      this.totalTarget.classList.add("text-error")
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.disabled = true
        this.submitButtonTarget.classList.add("btn-disabled")
      }
    }
  }
}
