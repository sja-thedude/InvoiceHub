import { Controller } from "@hotwired/stimulus"

// Manages the invoice line-item rows: add/remove rows and recalculate
// the subtotal, discount, tax and grand total live as the user types.
export default class extends Controller {
  static targets = ["rows", "template", "subtotal", "taxRate", "discount",
                    "taxAmount", "total", "lineTotal"]
  static values = { currency: String }

  connect() {
    this.recalculate()
  }

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
    this.recalculate()
  }

  remove(event) {
    event.preventDefault()
    const row = event.target.closest("[data-line-item]")
    const destroyInput = row.querySelector("input[name*='_destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
      row.style.display = "none"
    } else {
      row.remove()
    }
    this.recalculate()
  }

  recalculate() {
    let subtotal = 0
    this.rowsTarget.querySelectorAll("[data-line-item]").forEach((row) => {
      if (row.style.display === "none") return
      const qty = parseFloat(row.querySelector("[data-field='quantity']")?.value) || 0
      const price = parseFloat(row.querySelector("[data-field='unit_price']")?.value) || 0
      const lineTotal = qty * price
      subtotal += lineTotal
      const out = row.querySelector("[data-field='line_total']")
      if (out) out.textContent = this.format(lineTotal)
    })

    const discount = parseFloat(this.hasDiscountTarget ? this.discountTarget.value : 0) || 0
    const taxRate = parseFloat(this.hasTaxRateTarget ? this.taxRateTarget.value : 0) || 0
    let discounted = subtotal - discount
    if (discounted < 0) discounted = 0
    const taxAmount = (discounted * taxRate) / 100
    const total = discounted + taxAmount

    if (this.hasSubtotalTarget) this.subtotalTarget.textContent = this.format(subtotal)
    if (this.hasTaxAmountTarget) this.taxAmountTarget.textContent = this.format(taxAmount)
    if (this.hasTotalTarget) this.totalTarget.textContent = this.format(total)
  }

  format(value) {
    try {
      return new Intl.NumberFormat(undefined, {
        style: "currency",
        currency: this.currencyValue || "USD"
      }).format(value)
    } catch (e) {
      return value.toFixed(2)
    }
  }
}
