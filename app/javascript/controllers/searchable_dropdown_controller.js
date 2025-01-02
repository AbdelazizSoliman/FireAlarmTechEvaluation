// app/javascript/controllers/searchable_dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "option"]

  connect() {
    this.inputTarget.addEventListener("input", this.filterOptions.bind(this))
  }

  filterOptions() {
    const query = this.inputTarget.value.toLowerCase()
    if (query === "") {
      this.hideList()
    } else {
      this.showList()
      this.optionTargets.forEach(option => {
        const text = option.textContent.toLowerCase()
        option.style.display = text.includes(query) ? "block" : "none"
      })
    }
  }

  showList() {
    this.listTarget.style.display = "block"
  }

  hideList() {
    this.listTarget.style.display = "none"
  }
}
