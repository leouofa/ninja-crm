import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["categorySelect", "newCategoryContainer", "newCategoryInput", "textarea"]
  static values = {
    templatesMap: Object
  }

  categoryChanged() {
    const selectedVal = this.categorySelectTarget.value

    if (selectedVal === "new") {
      this.newCategoryContainerTarget.classList.remove("hidden")
      this.newCategoryInputTarget.required = true
      this.newCategoryInputTarget.focus()
    } else {
      this.newCategoryContainerTarget.classList.add("hidden")
      this.newCategoryInputTarget.required = false
      this.newCategoryInputTarget.value = ""

      if (this.hasTemplatesMapValue && this.templatesMapValue[selectedVal] && !this.textareaTarget.value.trim()) {
        this.textareaTarget.value = this.templatesMapValue[selectedVal]
      }
    }
  }

  cancelNewCategory() {
    this.newCategoryContainerTarget.classList.add("hidden")
    this.newCategoryInputTarget.value = ""
    this.newCategoryInputTarget.required = false
    this.categorySelectTarget.value = this.categorySelectTarget.options[0]?.value || ""
  }
}
