class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "invoices@invoicehub.app")
  layout "mailer"
end
