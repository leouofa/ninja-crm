import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    content: String,
    successDuration: { type: Number, default: 1800 }
  }
  static targets = ["button", "label", "defaultIcon", "successIcon"]

  async copy(event) {
    if (event) {
      event.stopPropagation()
    }

    try {
      await navigator.clipboard.writeText(this.contentValue)
      const originalText = this.hasLabelTarget ? this.labelTarget.textContent : null
      const originalTitle = this.hasButtonTarget ? this.buttonTarget.getAttribute("title") : null

      if (this.hasLabelTarget) {
        this.labelTarget.textContent = "Copied!"
      }

      if (this.hasDefaultIconTarget && this.hasSuccessIconTarget) {
        this.defaultIconTarget.classList.add("hidden")
        this.successIconTarget.classList.remove("hidden")
      }

      if (this.hasButtonTarget) {
        this.buttonTarget.setAttribute("title", "Copied!")
        this.buttonTarget.classList.add("text-emerald-600")
      }

      setTimeout(() => {
        if (this.hasLabelTarget && originalText !== null) {
          this.labelTarget.textContent = originalText
        }
        if (this.hasDefaultIconTarget && this.hasSuccessIconTarget) {
          this.defaultIconTarget.classList.remove("hidden")
          this.successIconTarget.classList.add("hidden")
        }
        if (this.hasButtonTarget) {
          if (originalTitle !== null) {
            this.buttonTarget.setAttribute("title", originalTitle)
          } else {
            this.buttonTarget.removeAttribute("title")
          }
          this.buttonTarget.classList.remove("text-emerald-600")
        }
      }, this.successDurationValue)
    } catch (err) {
      console.error("Failed to copy text: ", err)
    }
  }
}
