import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    content: String
  }
  static targets = ["button", "label"]

  async copy() {
    try {
      await navigator.clipboard.writeText(this.contentValue)
      const originalText = this.hasLabelTarget ? this.labelTarget.textContent : (this.buttonTarget ? this.buttonTarget.textContent : "Copy")

      if (this.hasLabelTarget) {
        this.labelTarget.textContent = "Copied!"
      }

      setTimeout(() => {
        if (this.hasLabelTarget) {
          this.labelTarget.textContent = originalText
        }
      }, 1800)
    } catch (err) {
      console.error("Failed to copy text: ", err)
    }
  }
}
