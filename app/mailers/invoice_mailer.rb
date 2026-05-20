class InvoiceMailer < ApplicationMailer
  def invoice_email(invoice)
    @invoice = invoice
    @user    = invoice.user
    @client  = invoice.client
    @pay_url = public_invoice_url(invoice.public_token)

    attachments["#{invoice.invoice_number}.pdf"] = InvoicePdf.new(invoice).render

    mail(
      to: @client.email.presence || @user.email,
      from: %("#{@user.display_name}" <#{ENV.fetch('MAIL_FROM', 'invoices@invoicehub.app')}>),
      reply_to: @user.email,
      subject: "Invoice #{invoice.invoice_number} from #{@user.display_name}"
    )
  end

  def payment_receipt(payment)
    @payment = payment
    @invoice = payment.invoice
    @user    = @invoice.user
    @client  = @invoice.client

    mail(
      to: @client.email.presence || @user.email,
      subject: "Payment received for #{@invoice.invoice_number}"
    )
  end
end
