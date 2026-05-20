import { Controller } from "@hotwired/stimulus"

// Auto-dismisses flash messages after a delay, or on click.
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.close(), 5000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  close() {
    this.element.style.transition = "opacity 0.3s, transform 0.3s"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-8px)"
    setTimeout(() => this.element.remove(), 300)
  }
}
