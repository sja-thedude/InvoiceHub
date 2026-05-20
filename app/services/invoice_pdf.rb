require "prawn"
require "prawn/table"

# Renders a professional, branded invoice PDF using Prawn.
class InvoicePdf
  INDIGO = "4F46E5".freeze
  SLATE  = "1E293B".freeze
  MUTED  = "64748B".freeze
  LIGHT  = "F1F5F9".freeze

  def initialize(invoice)
    @invoice = invoice
    @user    = invoice.user
    @client  = invoice.client
    @doc     = Prawn::Document.new(page_size: "A4", margin: [40, 50, 60, 50])
  end

  def render
    header
    parties
    invoice_meta
    line_items
    totals
    payment_details
    footer
    @doc.render
  end

  private

  def header
    @doc.fill_color INDIGO
    @doc.fill_rectangle [-50, @doc.cursor + 40], @doc.bounds.width + 100, 8
    @doc.fill_color SLATE

    logo_drawn = draw_logo
    @doc.bounding_box([logo_drawn ? 120 : 0, @doc.cursor], width: 300) do
      @doc.fill_color SLATE
      @doc.text @user.display_name, size: 20, style: :bold
      @doc.fill_color MUTED
      @doc.text @user.business_address.to_s, size: 9, leading: 2 if @user.business_address.present?
      @doc.text "Tax ID: #{@user.tax_id}", size: 9 if @user.tax_id.present?
      @doc.text @user.email, size: 9 if @user.email.present?
    end

    @doc.bounding_box([@doc.bounds.width - 180, @doc.bounds.top - 5], width: 180) do
      @doc.fill_color INDIGO
      @doc.text "INVOICE", size: 28, style: :bold, align: :right
      @doc.fill_color MUTED
      @doc.text @invoice.invoice_number, size: 11, align: :right
    end

    @doc.move_down 30
  end

  def draw_logo
    return false unless @user.logo.attached?

    @user.logo.blob.open do |file|
      @doc.image file.path, at: [0, @doc.cursor], fit: [100, 60]
    end
    true
  rescue StandardError
    false
  end

  def parties
    top = @doc.cursor
    @doc.bounding_box([0, top], width: 250) do
      label "BILL TO"
      @doc.fill_color SLATE
      @doc.text @client.name, size: 12, style: :bold
      @doc.fill_color MUTED
      @doc.text @client.company, size: 10 if @client.company.present?
      @doc.text @client.address.to_s, size: 9, leading: 2 if @client.address.present?
      @doc.text @client.email, size: 9 if @client.email.present?
    end

    @doc.bounding_box([300, top], width: 195) do
      meta_row "Issue Date", @invoice.issue_date&.strftime("%B %-d, %Y")
      meta_row "Due Date", @invoice.due_date&.strftime("%B %-d, %Y")
      meta_row "Status", @invoice.status.titleize
      meta_row "Amount Due", money(@invoice.balance_due), bold: true
    end

    @doc.move_down 25
  end

  def invoice_meta
    @doc.stroke_color LIGHT
    @doc.stroke_horizontal_rule
    @doc.move_down 15
  end

  def line_items
    rows = [["#", "Description", "Qty", "Unit Price", "Amount"]]
    @invoice.invoice_items.each_with_index do |item, i|
      rows << [
        (i + 1).to_s,
        item.description,
        format_qty(item.quantity),
        money(item.unit_price),
        money(item.total)
      ]
    end

    @doc.table(rows, header: true,
               column_widths: [25, 270, 50, 80, 70]) do |t|
      t.cells.padding = [7, 8, 7, 8]
      t.cells.borders = [:bottom]
      t.cells.border_color = "E2E8F0"
      t.cells.size = 9.5
      t.row(0).background_color = SLATE
      t.row(0).text_color = "FFFFFF"
      t.row(0).font_style = :bold
      t.row(0).size = 8.5
      t.columns(2..4).align = :right
      t.column(0).align = :center
      t.rows(1..-1).each_with_index do |row, i|
        row.background_color = i.even? ? "FFFFFF" : "F8FAFC"
      end
    end
    @doc.move_down 10
  end

  def totals
    box_x = @doc.bounds.width - 230
    @doc.bounding_box([box_x, @doc.cursor], width: 230) do
      total_row "Subtotal", money(@invoice.subtotal)
      total_row "Discount", "- #{money(@invoice.discount)}" if @invoice.discount.to_d.positive?
      total_row "Tax (#{number_with_precision(@invoice.tax_rate, precision: 2, strip_insignificant_zeros: true)}%)", money(@invoice.tax_amount) if @invoice.tax_rate.to_d.positive?
      @doc.move_down 4
      @doc.fill_color INDIGO
      @doc.fill_rectangle [0, @doc.cursor], 230, 26
      @doc.fill_color "FFFFFF"
      @doc.bounding_box([10, @doc.cursor - 7], width: 210) do
        @doc.text_box "TOTAL", size: 11, style: :bold
        @doc.text_box money(@invoice.total), size: 11, style: :bold, align: :right
      end
      @doc.move_down 30
      if @invoice.amount_paid.to_d.positive?
        @doc.fill_color SLATE
        total_row "Paid", money(@invoice.amount_paid)
        total_row "Balance Due", money(@invoice.balance_due), bold: true
      end
    end
    @doc.move_down 20
  end

  def payment_details
    @doc.fill_color SLATE
    if @user.bank_details.present?
      @doc.text "Payment Details", size: 11, style: :bold
      @doc.fill_color MUTED
      @doc.text @user.bank_details, size: 9, leading: 3
      @doc.move_down 12
    end

    if @invoice.notes.present?
      @doc.fill_color SLATE
      @doc.text "Notes", size: 11, style: :bold
      @doc.fill_color MUTED
      @doc.text @invoice.notes, size: 9, leading: 3
      @doc.move_down 12
    end

    terms = @invoice.terms.presence || "Payment due within #{@user.payment_terms_days} days. Thank you for your business!"
    @doc.fill_color SLATE
    @doc.text "Terms", size: 11, style: :bold
    @doc.fill_color MUTED
    @doc.text terms, size: 9, leading: 3
  end

  def footer
    @doc.repeat(:all) do
      @doc.fill_color MUTED
      @doc.text_box "#{@user.display_name} · #{@invoice.invoice_number} · Generated by InvoiceHub",
                    at: [0, 20], size: 7.5, align: :center, width: @doc.bounds.width
    end
  end

  # --- helpers ---

  def label(text)
    @doc.fill_color MUTED
    @doc.text text, size: 8, style: :bold, character_spacing: 1
    @doc.move_down 4
  end

  def meta_row(key, value, bold: false)
    return if value.blank?

    @doc.fill_color MUTED
    @doc.text_box key, size: 9, at: [0, @doc.cursor], width: 90
    @doc.fill_color bold ? INDIGO : SLATE
    @doc.text_box value.to_s, size: 9, style: bold ? :bold : :normal,
                 at: [90, @doc.cursor], width: 105, align: :right
    @doc.move_down 16
  end

  def total_row(key, value, bold: false)
    @doc.fill_color MUTED
    @doc.text_box key, size: 9.5, at: [0, @doc.cursor], width: 120
    @doc.fill_color bold ? SLATE : MUTED
    @doc.text_box value, size: 9.5, style: bold ? :bold : :normal,
                 at: [120, @doc.cursor], width: 110, align: :right
    @doc.move_down 18
  end

  def money(amount)
    Money.from_amount(amount.to_d, @invoice.currency).format
  rescue StandardError
    "#{@invoice.currency} #{'%.2f' % amount.to_d}"
  end

  def format_qty(qty)
    qty.to_d == qty.to_i ? qty.to_i.to_s : qty.to_s
  end

  def number_with_precision(*) = ActionController::Base.helpers.number_with_precision(*)
end
