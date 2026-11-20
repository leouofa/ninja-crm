import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    status: String,
    moveUrl: String
  }

  dragStart(event) {
    const card = event.target.closest("[data-lead-id]")
    if (!card) return
    event.dataTransfer.setData("text/plain", card.dataset.leadId)
    event.dataTransfer.effectAllowed = "move"
    card.classList.add("opacity-50", "rotate-1")
  }

  dragEnd(event) {
    const card = event.target.closest("[data-lead-id]")
    if (card) {
      card.classList.remove("opacity-50", "rotate-1")
    }
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    this.element.classList.add("bg-indigo-50/50", "border-indigo-300")
  }

  dragLeave(event) {
    this.element.classList.remove("bg-indigo-50/50", "border-indigo-300")
  }

  async drop(event) {
    event.preventDefault()
    this.element.classList.remove("bg-indigo-50/50", "border-indigo-300")

    const leadId = event.dataTransfer.getData("text/plain")
    if (!leadId) return

    const card = document.querySelector(`[data-lead-id="${leadId}"]`)
    const targetColumn = this.element
    const targetStatus = this.statusValue

    if (card && targetColumn) {
      const cardsContainer = targetColumn.querySelector("[data-kanban-cards]")
      if (cardsContainer) {
        cardsContainer.appendChild(card)
      }
    }

    // Call server endpoint
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      const response = await fetch(`/leads/${leadId}/move`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html, text/html, application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ status: targetStatus })
      })

      if (!response.ok) {
        window.location.reload()
      } else {
        // Turbo will update or we can refresh counts
        window.location.reload()
      }
    } catch (err) {
      console.error("Failed to move lead:", err)
      window.location.reload()
    }
  }
}
